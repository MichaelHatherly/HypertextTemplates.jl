module HypertextTemplatesHTTPReviseExt

import HTTP
import HypertextTemplates
import InteractiveUtils
import Random
import Revise

function HypertextTemplates._template_file_lookup(
    ::HypertextTemplates.TemplateFileLookupType,
    handler,
)
    # Generate a random target to avoid potential collisions if a user has a
    # page that uses the same target, as unlikely as that may be.
    target = "/template-file-lookup-$(Random.randstring())"
    function (request::HTTP.Request)
        return _template_file_lookup_impl(handler, request, target)
    end
end

function _template_file_lookup_impl(handler, request::HTTP.Request, target::String)
    if request.method == "POST" && request.target == target
        location = String(request.body)
        file, line = split(location, ':'; limit = 2)

        filekey = Base.parse(Int, file)
        filename = get(HypertextTemplates.DATA_FILENAME_MAPPING_REVERSE, filekey, nothing)
        isnothing(filename) && error("filename not found for key: $filekey")

        linenumber = Base.parse(Int, line)
        if isfile(filename)
            @debug "Opening $filename at line $linenumber for editing."
            InteractiveUtils.edit(filename, linenumber)
            return HTTP.Response(
                200,
                "Opened file '$filename' at line '$linenumber' in default editor.",
            )
        else
            error("filename does not exist: $filename")
        end
    else
        return _insert_template_file_lookup_listener(handler(request), target)
    end
end

# Injects a script into the response that listens for clicks on elements with
# the `data-htloc` attribute and sends a POST request to the given address
# with the filename as the body. This is used to open the template file in the
# default editor when the user clicks on the rendered template.
function _insert_template_file_lookup_listener(
    response::HTTP.Response,
    address::AbstractString,
)
    if !isnothing(findfirst((==)("Content-Type" => "text/html"), response.headers))
        tags = "</head>"
        script = """
        <script>
        // Track the mouse position so that we can lookup the element under the
        // cursor when the user presses Ctrl+Shift.
        window.addEventListener("mousemove", async function (event) {
            window._lastMousePosition = { x: event.clientX, y: event.clientY };
        });
        // Listen for Ctrl+Shift clicks on elements with the `data-htloc`
        // attribute and send a POST request to the given address with the
        // filename as the body.
        window.addEventListener("keydown", async function (event) {
            if (event.ctrlKey && event.shiftKey) {
                const target = document.elementFromPoint(window._lastMousePosition.x, window._lastMousePosition.y);
                // When we can't find the attribute on the clicked element, we
                // look for it on the body element.
                const node = target.closest("[data-htloc]") || target.querySelector("body");
                const filename = node.attributes["data-htloc"].value;
                if (filename) {
                    fetch("$address", { method: "POST", body: filename });
                } else {
                    alert("We could not find template file. Do you have Revise running?");
                }
            }
        })
        </script>
        $tags
        """
        response.body = codeunits(replace(String(response.body), tags => script))
    end
    return response
end

end

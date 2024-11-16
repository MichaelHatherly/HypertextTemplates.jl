module HypertextTemplatesHTTPExt

import HTTP
import HypertextTemplates
import InteractiveUtils

function HypertextTemplates._template_file_lookup(::Nothing, handler)
    # Generate a random target to avoid potential collisions if a user has a
    # page that uses the same target, as unlikely as that may be.
    uuid = string(rand(UInt); base = 62)
    target = "/template-lookup-$uuid"
    function (request::HTTP.Request)
        request.context[:template_lookup] = target
        return _template_file_lookup_impl(handler, request, target)
    end
end

function _template_file_lookup_impl(handler, request::HTTP.Request, target::String)
    if request.method == "POST" && request.target == target
        location = String(request.body)
        file, line = rsplit(location, ':'; limit = 2)
        isfile(file) || error("`$file` is not a valid file.")
        linenumber = Base.tryparse(Int, line)
        isnothing(linenumber) && error("`$line` is not a valid linenumber.")

        @debug "Opening $file at line $linenumber for editing."
        columnnumber = 1
        InteractiveUtils.edit(file, linenumber, columnnumber)
        return HTTP.Response(200, "Opened '$file' at line '$linenumber' in default editor.")
    else
        return append_lookup_script(handler(request), target)
    end
end

# Injects a script into the response that listens for clicks on elements with
# the `data-htloc` attribute and sends a POST request to the given address
# with the filename as the body. This is used to open the template file in the
# default editor when the user clicks on the rendered template.
function append_lookup_script(response::HTTP.Response, address::String)
    if contains_html_content_type(response.headers)
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
            function goto(selector) {
                const target = document.elementFromPoint(window._lastMousePosition.x, window._lastMousePosition.y);
                // When we can't find the attribute on the clicked element, we
                // look for it on the body element.
                const node = target.closest(`[\${selector}]`) || target.querySelector("body");
                const filename = node.attributes[selector].value;
                console.log(selector)
                console.log(filename)
                if (filename) {
                    fetch("$address", { method: "POST", body: filename });
                } else {
                    alert("We could not find template file. Do you have Revise running?");
                }
            }
            if (event.ctrlKey && event.key == '1') {
                goto("data-htroot");
            } else if (event.ctrlKey && event.key == '2') {
                goto("data-htloc");
            }
        })
        </script>
        $tags
        """
        response.body = codeunits(replace(String(response.body), tags => script))
        HTTP.setheader(response, "Content-Length" => string(sizeof(response.body)))
    end
    return response
end
append_lookup_script(response, ::String) = response

function contains_html_content_type(headers)
    for (key, value) in headers
        if key == "Content-Type" && startswith(value, "text/html")
            return true
        end
    end
    return false
end

end

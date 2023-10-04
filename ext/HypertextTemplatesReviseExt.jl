module HypertextTemplatesReviseExt

import HypertextTemplates
import Revise

function HypertextTemplates.is_stale_template(file::AbstractString, previous_mtime::Float64)
    if isfile(file)
        current_mtime = mtime(file)
        if current_mtime > previous_mtime
            # If the file exists and has been modified since the last time we
            # checked, it's stale.
            @debug "Template file has been modified, recompiling." file current_mtime previous_mtime
            return true
        else
            # If the file exists and hasn't been modified since the last time we
            # checked, it's not stale.
            return false
        end
    else
        # If the file doesn't exist, it's not stale.
        return false
    end
end

end

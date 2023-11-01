module HypertextTemplatesReviseExt

import HypertextTemplates
import InteractiveUtils
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

function HypertextTemplates._data_filename_attr(file::String)
    if HypertextTemplates._DATA_FILENAME_ATTR[]
        return [Symbol("data-filename") => file]
    else
        return Pair{Symbol,String}[]
    end
end

end

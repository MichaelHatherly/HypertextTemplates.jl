module HypertextTemplatesReviseExt

import HypertextTemplates as HTT
import Revise

HTT.__is_revise_loaded(::HTT.ReviseIsLoaded) = true

function _has_uuid(vec::Vector{Base.CodeInfo}, uuid::Symbol)
    for each in vec
        if uuid in each.slotnames
            return true
        end
    end
    return false
end

function HTT._method_offset(::HTT.ReviseIsLoaded, f, uuid, __source__)
    if !isdefined(Revise, :CodeTracking)
        @debug "CodeTracking not available via Revise, skipping source tracking."
        return nothing
    end
    method = nothing
    for candidate in methods(f)
        lowered = Base.code_lowered(f, Base.tuple_type_tail(candidate.sig))
        if _has_uuid(lowered, uuid)
            method = candidate
            break
        end
    end
    if isnothing(method)
        @debug "could not detect method, giving up."
        return nothing
    else
        try
            return Revise.CodeTracking.whereis(__source__, method)
        catch err
            @debug "CodeTracking.whereis failed, skipping source tracking." exception = err
            return nothing
        end
    end
end

end

module HypertextTemplatesReviseExt

import HypertextTemplates as HTT
import Revise

HTT.__is_revise_loaded(::HTT.ReviseIsLoaded) = true

function Revise.parse_source!(
    mod_exprs_sigs::Revise.ModuleExprsSigs,
    file::HTT.CMFile,
    mod::Module;
    kwargs...,
)
    ex = HTT.cm_file_expr(mod, file)
    Revise.process_source!(mod_exprs_sigs, ex, file, mod; kwargs...)
end
Revise.is_same_file(a::HTT.CMFile, b::String) = a.file == b

function HTT._includet(mod::Module, cmfile::HTT.CMFile, ::Nothing)
    Base.moduleroot(mod) === Main && return nothing

    mode = :eval
    id = Base.PkgId(mod)
    fm = Revise.parse_source(cmfile, mod; mode)
    Revise.instantiate_sigs!(fm; mode)
    Timer(1) do timer
        pkgdata = Revise.pkgdatas[id]
        rcmfile = HTT.CMFile(
            relpath(cmfile.file, pkgdata),
            cmfile.mod,
            cmfile.name,
            cmfile.parameters,
        )
        push!(pkgdata, rcmfile => Revise.FileInfo(fm))
        Revise.init_watching(pkgdata, (String(rcmfile)::String,))
        Revise.pkgdatas[id] = pkgdata
    end
    return nothing
end

end

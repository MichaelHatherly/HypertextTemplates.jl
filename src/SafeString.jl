"""
    SafeString <: AbstractString

Represents an internal string type that was created directly within a template,
rather than being passed into a template from a potentially untrusted source as
a parameter. Never create these objects from application-level code.
"""
struct SafeString <: AbstractString
    str::String
end

Base.show(io::IO, s::SafeString) = show(io, s.str)
Base.ncodeunits(s::SafeString) = ncodeunits(s.str)
Base.codeunit(s::SafeString) = codeunit(s.str)
Base.codeunit(s::SafeString, i::Integer) = codeunit(s.str, i)
Base.isvalid(s::SafeString, index::Integer) = isvalid(s.str, index)
Base.iterate(s::SafeString) = iterate(s.str)
Base.iterate(s::SafeString, state::Integer) = iterate(s.str, state)
Base.String(s::SafeString) = String(s.str)

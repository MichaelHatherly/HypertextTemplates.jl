"""
    SafeString(str)

A string type that bypasses the default HTML escaping that is applied to all
strings rendered with `@render` and DOM element properties. Only apply this
type to string values that are not user-defined. If applying this to
user-defined values ensure that proper sanitization has been carried out.
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

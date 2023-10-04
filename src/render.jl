"""
    render(template, args...; kws...)

Render a template to a string. `args` and `kws` are passed to the template
function and a `String` is returned.
"""
function render(func, args...; kws...)
    buffer = IOBuffer()
    func(buffer, args...; kws...)
    return String(take!(buffer))
end

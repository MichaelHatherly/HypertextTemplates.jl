struct ReviseIsLoaded end

_is_revise_loaded() = __is_revise_loaded(ReviseIsLoaded())
__is_revise_loaded(::Any) = false

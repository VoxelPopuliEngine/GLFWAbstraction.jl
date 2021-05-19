######################################################################
# GLFWAbstraction central include hub
# -----
# Licensed under MIT License
module GLFWAbstraction

abstract type GLFWWrapper{T} end
wrapped(w::GLFWWrapper) = w.handle
wrapped_type(::Type{GLFWWrapper{T}}) where T = T

"""`lhs×rhs` creates a 2-tuple (lhs, rhs) for a familiar and convenient notation of 2D measures."""
(×)(lhs::Real, rhs::Real) = (lhs, rhs)

include("./monitors.jl")
include("./windows.jl")
include("./input.jl")

end # module GLFWAbstraction

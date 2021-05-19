######################################################################
# Input Abstraction Layer
# -----
# Licensed under MIT License
using GLFW

export InputEvents
struct InputEvents end

export pollevents, post_empty_event
pollevents() = GLFW.PollEvents()
post_empty_event() = GLFW.PostEmptyEvent()

Base.wait(::Type{InputEvents}) = GLFW.WaitEvents()
Base.wait(::Type{InputEvents}, timeout::AbstractFloat) = GLFW.WaitEvents(timeout)

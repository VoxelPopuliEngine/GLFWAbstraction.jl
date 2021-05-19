######################################################################
# Input Abstraction Layer
# -----
# Licensed under MIT License
using GLFW

export InputEvents
struct InputEvents end

export pollevents
pollevents() = GLFW.PollEvents()

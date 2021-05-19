######################################################################
# Abstraction of GLFW.Monitor
# -----
# Licensed under MIT License
using GLFW
using ..GLFWAbstraction

export VideoMode
struct VideoMode
    width::Int
    height::Int
    bits::NamedTuple{(:red, :green, :blue)}
    refresh_rate::Int
end

export Monitor, monitor
struct Monitor <: GLFWWrapper{GLFW.Monitor}
    handle::GLFW.Monitor
end
monitor(idx::Integer = 1) = Monitors[idx]
monitor(::Nothing) = nothing

export Monitors
"""`Monitors` is a meta type designed to query connected physical monitors using `Base.getindex` and `Base.iterate`."""
struct Monitors end

Base.iterate(::Type{Monitors}, idx = 1) = Monitors[idx], idx < length(Monitors) ? idx+1 : nothing
Base.getindex(::Type{Monitors}, idx::Integer) = collect(Monitors)[idx]
Base.length(::Type{Monitors}) = length(GLFW.GetMonitors())

export videomode, videomodes
videomode(monitor::Monitor) = videomode(GLFW.GetVideoMode(monitor.handle))
videomode(vidmode::GLFW.VidMode) = VideoMode(vidmode.width, vidmode.height, (red = vidmode.redbits, green = vidmode.greenbits, blue = vidmode.bluebits), vidmode.refreshrate)
videomodes(monitor::Monitor) = videomode.(GLFW.GetVideoModes(monitor.handle))

Base.convert(::Type{GLFW.Monitor}, monitor::Monitor) = monitor.handle
Base.collect(::Type{Monitors}) = collect(Monitor.(GLFW.GetMonitors()))

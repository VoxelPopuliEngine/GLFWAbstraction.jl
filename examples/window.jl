######################################################################
# General example of how to create & manipulate a window.
# -----
# Licensed under MIT License
using Pkg
Pkg.activate(".")

using ExtraFun
using GLFWAbstraction

GLFWAbstraction.on_window_move(::Window{:mywnd}, posx::Integer, posy::Integer) = println("window moved to $posx, $posy")
GLFWAbstraction.on_window_resize(::Window{:mywnd}, sizex::Integer, sizey::Integer) = println("window resized to $sizex×$sizey")
GLFWAbstraction.on_window_close(::Window{:mywnd}) = println("window closing")

@windowhint TransparentFramebuffer true

let wnd = window(:mywnd, "Hello, world!", 960, 480)
    @assert !wnd.shouldclose
    wnd.aspect_ratio = 16//9
    use(wnd)
    
    while !wnd.shouldclose
        sleep(0.1)
        swapbuffers(wnd)
        pollevents()
    end
end

######################################################################
# Example of how to create a window in borderless fullscreen mode.
# -----
# Licensed under MIT License
using Pkg
Pkg.activate(".")

using KirUtil
using GLFWAbstraction

let vidmode = videomode(monitor(1))
    # Create window in borderless fullscreen mode
    @windowhint RedBits     vidmode.bits.red
    @windowhint GreenBits   vidmode.bits.green
    @windowhint BlueBits    vidmode.bits.blue
    @windowhint RefreshRate vidmode.refresh_rate
    
    let wnd = window(:mywnd, "Hello, world!", vidmode.width, vidmode.height, monitor(1))
        @assert !wnd.shouldclose
        use(wnd)
        
        while !wnd.shouldclose
            sleep(0.1)
            swapbuffers(wnd)
            pollevents()
        end
    end
end

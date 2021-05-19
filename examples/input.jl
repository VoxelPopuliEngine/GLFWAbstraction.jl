######################################################################
# Example for various input methods
# -----
# Licensed under MIT License
using Pkg
Pkg.activate(".")

using GLFWAbstraction
using GLFW

buffer = ""
function GLFWAbstraction.on_receive_char(::Window{:mywnd}, char::Char)
    global buffer
    buffer *= char
end
function GLFWAbstraction.on_key_press(::Window{:mywnd}, key::Key, scancode::Integer, modifiers::ModifierKey)
    global buffer
    if key === Key(:backspace) && !isempty(buffer)
        buffer = buffer[1:length(buffer)-1]
    elseif key === Key(:enter)
        println(buffer)
        buffer = ""
    end
end
function GLFWAbstraction.on_key_repeat(::Window{:mywnd}, key::Key, scancode::Integer, modifiers::ModifierKey)
    global buffer
    if key === Key(:backspace) && !isempty(buffer)
        buffer = buffer[1:length(buffer)-1]
    end
end
function GLFWAbstraction.on_mouse_press(::Window{:mywnd}, button::MouseButton, modifiers::ModifierKey)
    println(button)
end
function GLFWAbstraction.on_mouse_move(::Window{:mywnd}, xpos::AbstractFloat, ypos::AbstractFloat)
    println("mouse moved to $xpos, $ypos")
end
GLFWAbstraction.on_mouse_enter(::Window{:mywnd}) = println("hi mouse :)")
GLFWAbstraction.on_mouse_leave(::Window{:mywnd}) = println("bye mouse :(")

let wnd = window(:mywnd, "Input Example", 960, 480)
    while !wnd.shouldclose
        sleep(0.1)
        swapbuffers(wnd)
        pollevents()
    end
end

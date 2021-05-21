######################################################################
# Mouse-related input abstraction
# TODO: Custom Cursor Image. This is currently not supported by GLFW.jl,
# so may need to interface with GLFW_jll directly.
# -----
# Licensed under MIT License
using GLFW
using ExtraFun

export CursorMode, CursorDisabled, CursorHidden, CursorNormal
@enum CursorMode CursorDisabled = GLFW.CURSOR_DISABLED CursorHidden = GLFW.CURSOR_HIDDEN CursorNormal = GLFW.CURSOR_NORMAL

export MouseButton
struct MouseButton
    idx::Int32
    function MouseButton(idx)
        idx = idx-1
        if idx ∉ 0:7
            throw(ArgumentError("GLFW only supports mouse buttons 0:7; given $idx"))
        end
        new(idx)
    end
end
# Using Ident{name} here because it allows injecting additional custom names.
MouseButton(name::Symbol) = MouseButton(Ident{name}())
MouseButton(::Ident{:left}) = MouseButton(1)
MouseButton(::Ident{:right}) = MouseButton(2)
MouseButton(::Ident{:middle}) = MouseButton(3)

export Mouse
struct Mouse
    wnd::Window
end

@generate_properties Mouse begin
    @get position = (pos = GLFW.GetCursorPos(self.wnd.handle); (pos.x, pos.y))
    @set position = GLFW.SetCursorPos(self.wnd.handle, value[1], value[2])
    
    @get mode = GLFW.GetInputMode(self.wnd.handle, GLFW.CURSOR)
    @set mode = GLFW.SetInputMode(self.wnd.handle, GLFW.CURSOR, Integer(value))
end

isbuttondown(mouse::Mouse, button::MouseButton) = GLFW.GetMouseButton(mouse.wnd.handle, GLFW.MouseButton(button.idx)) == GLFW.PRESS
isbuttonup(  mouse::Mouse, button::MouseButton) = GLFW.GetMouseButton(mouse.wnd.handle, GLFW.MouseButton(button.idx)) == GLFW.RELEASE


function register_cursor_pos_callback(handler, wnd::Window)
    wrapper(::GLFW.Window, xpos::AbstractFloat, ypos::AbstractFloat) = handler(wnd, xpos, ypos)
    GLFW.SetCursorPosCallback(wnd.handle, wrapper)
    wnd
end
function register_cursor_enter_callback(handler, wnd::Window)
    wrapper(::GLFW.Window, entered::Integer) = handler(wnd, entered != 0)
    GLFW.SetCursorEnterCallback(wnd.handle, wrapper)
    wnd
end
function register_mouse_button_callback(handler, wnd::Window)
    wrapper(::GLFW.Window, button::GLFW.MouseButton, action::GLFW.Action, modifiers::Integer) = handler(wnd, MouseButton(Integer(button)), InputAction(action), ModifierKey(modifiers))
    GLFW.SetMouseButtonCallback(wnd.handle, wrapper)
    wnd
end
function register_mouse_scroll_callback(handler, wnd::Window)
    wrapper(::GLFW.Window, scrollx::AbstractFloat, scrolly::AbstractFloat) = handler(wnd, scrollx, scrolly)
    GLFW.SetScrollCallback(wnd.handle, wrapper)
    wnd
end

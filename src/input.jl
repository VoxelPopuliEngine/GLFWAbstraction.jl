######################################################################
# Input Abstraction Layer
# -----
# Licensed under MIT License
using BitFlags
using GLFW

export InputAction, Press, Release, Repeat
@enum InputAction Press = Integer(GLFW.PRESS) Release = Integer(GLFW.RELEASE) Repeat = Integer(GLFW.REPEAT)
InputAction(action::GLFW.Action) = InputAction(Integer(action))

export ModifierKey, NoMod, ShiftMod, ControlMod, AltMod, SuperMod, CapsLockMod, NumLockMod
@bitflag ModifierKey::UInt16 NoMod = 0 ShiftMod ControlMod AltMod SuperMod CapsLockMod NumLockMod

export pollevents, waitevents, post_empty_event
pollevents() = GLFW.PollEvents()
waitevents() = GLFW.WaitEvents()
waitevents(timeout::AbstractFloat) = GLFW.WaitEvents(timeout)
post_empty_event() = GLFW.PostEmptyEvent()

include("./input.keyboard.jl")
include("./input.mouse.jl")
# It appears GLFW.jl does not support the latest version of GLFW? Gamepad support is incomplete.
# include("./input.gamepad.jl")


# ===== Events =====

"""Called when a key is pressed down."""
function on_key_press(wnd::Window, key::Key, scancode::Integer, modifiers::ModifierKey) end
"""Called when a key is released."""
function on_key_release(wnd::Window, key::Key, scancode::Integer, modifiers::ModifierKey) end
"""Called when a key is being held, triggering continuous textual input."""
function on_key_repeat(wnd::Window, key::Key, scancode::Integer, modifiers::ModifierKey) end
"""Called when a key results in a Unicode character input."""
function on_receive_char(wnd::Window, char::Char) end
"""Called when the mouse cursor is moved while within the window's boundaries."""
function on_mouse_move(wnd::Window, xpos::AbstractFloat, ypos::AbstractFloat) end
"""Called when the mouse cursor enters the window's boundaries."""
function on_mouse_enter(wnd::Window) end
"""Called when the mouse cursor leaves the window's boundaries."""
function on_mouse_leave(wnd::Window) end
"""Called when a mouse button is pressed down."""
function on_mouse_press(wnd::Window, button::MouseButton, modifiers::ModifierKey) end
"""Called when a mouse button is released."""
function on_mouse_release(wnd::Window, button::MouseButton, modifiers::ModifierKey) end
"""Called when a new gamepad is connected."""


function register_default_input_callbacks(wnd::Window)
    register_key_callback(wnd) do _::Window, key::Key, scancode::Integer, action::InputAction, modifiers::ModifierKey
        if action === Press
            on_key_press(wnd, key, scancode, modifiers)
        elseif action === Release
            on_key_release(wnd, key, scancode, modifiers)
        elseif action === Repeat
            on_key_repeat(wnd, key, scancode, modifiers)
        else
            error("unknown key action $action")
        end
    end
    register_text_callback(wnd) do _::Window, char::Char; on_receive_char(wnd, char) end
    register_cursor_pos_callback(wnd) do _::Window, xpos::AbstractFloat, ypos::AbstractFloat; on_mouse_move(wnd, xpos, ypos) end
    register_cursor_enter_callback(wnd) do _::Window, entered::Bool
        if entered
            on_mouse_enter(wnd)
        else
            on_mouse_leave(wnd)
        end
    end
    register_mouse_button_callback(wnd) do _::Window, button::MouseButton, action::InputAction, modifiers::ModifierKey
        @assert action !== Repeat
        if action === Press
            on_mouse_press(wnd, button, modifiers)
        else
            on_mouse_release(wnd, button, modifiers)
        end
    end
end

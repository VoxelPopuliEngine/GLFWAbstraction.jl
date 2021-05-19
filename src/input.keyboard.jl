######################################################################
# Keyboard-related input abstraction
# -----
# Licensed under MIT License
using GLFW

export Key
struct Key <: GLFWWrapper{GLFW.Key}
    wrapped::GLFW.Key
end
Key(::Nothing) = Key(GLFW.KEY_UNKNOWN)
Key(special::Symbol) = resolve_key(Ident{special}())
function Key(digit::Integer; keypad::Bool = false)
    if digit ∉ 0:9
        throw(ArgumentError("number key must be single digit integers"))
    end
    I = Base.Enums.basetype(GLFW.Key)
    Key(GLFW.Key(Integer(keypad ? GLFW.KEY_KP_0 : GLFW.KEY_0) + I(digit)))
end
function Key(char::Char)
    if char ∈ 'a':'z' || char ∈ 'A':'Z'
        I = Base.Enums.basetype(GLFW.Key)
        return Key(GLFW.Key(Integer(GLFW.KEY_A) + convert(I, codepoint(lowercase(char)) - codepoint('a'))))
    end
    resolve_key(Ident{char}())
end

resolve_key(::Ident{K}) where K = throw(ArgumentError("unknown key \"$K\""))
resolve_key(::Ident{'\''}) = Key(GLFW.KEY_APOSTROPHE)
resolve_key(::Ident{','})  = Key(GLFW.KEY_COMMA)
resolve_key(::Ident{'-'})  = Key(GLFW.KEY_MINUS)
resolve_key(::Ident{'.'})  = Key(GLFW.KEY_PERIOD)
resolve_key(::Ident{'/'})  = Key(GLFW.KEY_SLASH)
resolve_key(::Ident{';'})  = Key(GLFW.KEY_SEMICOLON)
resolve_key(::Ident{'='})  = Key(GLFW.KEY_EQUAL)
resolve_key(::Ident{'['})  = Key(GLFW.KEY_LEFT_BRACKET)
resolve_key(::Ident{'\\'}) = Key(GLFW.KEY_BACKSLASH)
resolve_key(::Ident{']'})  = Key(GLFW.KEY_RIGHT_BRACKET)
resolve_key(::Ident{'`'})  = Key(GLFW.KEY_GRAVE_ACCENT)

macro addresolvekeys(blk::Expr)
    @assert blk.head === :block "must be a block expression enumerating the various keys/mappings"
    
    result = Expr(:block)
    for expr ∈ blk.args
        if expr isa LineNumberNode continue end
        
        key, mapping = if expr isa Expr
            @assert expr.head === :call && expr.args[1] === :(=>) && expr.args[2] isa Symbol && expr.args[3] isa Symbol "must be an arrow pair (a=>b) assignment"
            QuoteNode(expr.args[2]), Expr(:., :GLFW, QuoteNode(Symbol("KEY_$(uppercase(string(expr.args[3])))")))
        elseif expr isa Symbol
            QuoteNode(expr), Expr(:., :GLFW, QuoteNode(Symbol("KEY_$(uppercase(string(expr)))")))
        else
            throw(ArgumentError("invalid key mapping $expr"))
        end
        
        push!(result.args, :($(esc(:resolve_key))(::Ident{$key}) = Key($mapping)))
    end
    
    result
end

# This one needs to be added manually because 'end' is a keyword which breaks the macro
resolve_key(::Ident{:end}) = Key(GLFW.KEY_END)
@addresolvekeys begin
    space
    world1 => WORLD_1
    world2 => WORLD_2
    escape; esc => ESCAPE
    enter; tab; backspace; insert; delete
    right; left; down; up
    pageup => PAGE_UP
    pagedown => PAGE_DOWN
    home
    capslock   => CAPS_LOCK
    scrolllock => SCROLL_LOCK
    numlock    => NUM_LOCK
    print       => PRINT_SCREEN
    printscreen => PRINT_SCREEN
    pause
    f1; f2; f3; f4; f5; f6; f7; f8; f9; f10; f11; f12; f13; f14; f15; f16; f17; f18; f19; f20; f21; f22; f23; f24; f25
    decimal  => KP_DECIMAL
    divide   => KP_DIVIDE
    multiply => KP_MULTIPLY
    subtract => KP_SUBTRACT
    add      => KP_ADD
    keypad_enter => KP_ENTER
    keypad_equal => KP_EQUAL
    
    left_shift    => LEFT_SHIFT
    lshift        => LEFT_SHIFT
    left_control  => LEFT_CONTROL
    lcontrol      => LEFT_CONTROL
    lctrl         => LEFT_CONTROL
    left_alt      => LEFT_ALT
    lalt          => LEFT_ALT
    left_super    => LEFT_SUPER
    lsuper        => LEFT_SUPER
    right_shift   => RIGHT_SHIFT
    rshift        => RIGHT_SHIFT
    right_control => RIGHT_CONTROL
    rcontrol      => RIGHT_CONTROL
    rctrl         => RIGHT_CONTROL
    right_alt     => RIGHT_ALT
    ralt          => RIGHT_ALT
    right_super   => RIGHT_SUPER
    rsuper        => RIGHT_SUPER
    menu          => MENU
end


function register_key_callback(handler, wnd::Window)
    wrapper(::GLFW.Window, key::GLFW.Key, scancode::Integer, action::GLFW.Action, modifiers::Integer) = handler(wnd, Key(key), scancode, InputAction(action), ModifierKey(modifiers))
    GLFW.SetKeyCallback(wnd.handle, wrapper)
    wnd
end
function register_text_callback(handler, wnd::Window)
    wrapper(::GLFW.Window, char::Char) = handler(wnd, char)
    GLFW.SetCharCallback(wnd.handle, wrapper)
    wnd
end

export getkeyname
"""`getkeyname(named::Key, scancode::Integer)` attempts to retrieve a key's human readable name. If `named` is not `Key(nothing)`,
the name will be reminiscent of the named key. Otherwise, attempts to retrieve the key identified by `scancode`."""
getkeyname(named::Key, scancode::Integer) = GLFW.GetKeyName(named.wrapped, scancode)

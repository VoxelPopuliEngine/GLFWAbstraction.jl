######################################################################
# Window built on GLFW library
# -----
# Licensed under MIT License
using ExtraFun
using GenerateProperties
using GLFW

export WindowEvent, FramebufferSizeEvent, WindowCloseEvent, WindowContentScaleEvent, WindowFocusEvent, WindowIconifyEvent, WindowMaximizeEvent, WindowPosEvent, WindowRefreshEvent, WindowSizeEvent
"""Enum of various window-related events. These are a relatively low-level abstraction used with the
`register_window_callback` method. However, a more Julian solution exists. Refer to the documentation's *Event System*
section for more details."""
@enum WindowEvent FramebufferSizeEvent WindowCloseEvent WindowContentScaleEvent WindowFocusEvent WindowIconifyEvent WindowMaximizeEvent WindowPosEvent WindowRefreshEvent WindowSizeEvent

export ClientAPI, OpenGLAPI, OpenGLESAPI, NoAPI
"""Enum of the various possible client APIs which GLFW can use to create an OpenGL (ES) context."""
@enum ClientAPI OpenGLAPI = GLFW.OPENGL_API OpenGLESAPI = GLFW.OPENGL_ES_API NoAPI = GLFW.NO_API

export ContextCreationAPI, NativeContextAPI, EGLContextAPI
"""Enum of the various OpenGL (ES) context creation APIs which GLFW may use."""
@enum ContextCreationAPI NativeContextAPI = GLFW.NATIVE_CONTEXT_API EGLContextAPI = GLFW.EGL_CONTEXT_API

export OpenGLProfile, CoreProfile, CompatProfile, AnyProfile
"""Enum of possible OpenGL profiles."""
@enum OpenGLProfile CoreProfile = GLFW.OPENGL_CORE_PROFILE CompatProfile = GLFW.OPENGL_COMPAT_PROFILE AnyProfile = GLFW.OPENGL_ANY_PROFILE

export ContextReleaseBehavior, AnyReleaseBehavior, FlushReleaseBehavior, NoReleaseBehavior
"""Enum of context release behaviors GLFW may employ upon destroying an OpenGL (ES) context."""
@enum ContextReleaseBehavior AnyReleaseBehavior = GLFW.ANY_RELEASE_BEHAVIOR FlushReleaseBehavior = GLFW.RELEASE_BEHAVIOR_FLUSH NoReleaseBehavior = GLFW.RELEASE_BEHAVIOR_NONE

export ContextRobustness, LoseContextOnReset, NoResetNotification, NoRobustness
"""Context robustness solutions GLFW may employ when an OpenGL (ES) context fails."""
@enum ContextRobustness LoseContextOnReset = GLFW.LOSE_CONTEXT_ON_RESET NoResetNotification = GLFW.NO_RESET_NOTIFICATION NoRobustness = GLFW.NO_ROBUSTNESS


export Window, window
mutable struct Window{L} <: GLFWWrapper{GLFW.Window}
    handle::GLFW.Window
    function Window{L}(handle) where L
        inst = new(handle)
        register_default_window_callbacks(inst)
        register_default_input_callbacks(inst)
        inst
    end
end
window(label::Symbol, title::AbstractString, width::Integer, height::Integer) = Window{label}(GLFW.CreateWindow(width, height, title))
window(label::Symbol, title::AbstractString, width::Integer, height::Integer, monitor::Monitor) = Window{label}(GLFW.CreateWindow(width, height, title, monitor.handle))
window(label::Symbol, title::AbstractString, width::Integer, height::Integer, monitor::Monitor, share::Window) = Window{label}(GLFW.CreateWindow(width, height, title, monitor.handle, share.handle))

# Use virtual properties to reduce namespace clutter
@generate_properties Window begin
    # Getters & Setters
    @get auto_iconify = GLFW.GetWindowAttrib(self.handle, GLFW.AUTO_ICONIFY)
    @set auto_iconify = GLFW.SetWindowAttrib(self.handle, GLFW.AUTO_ICONIFY, value)
    
    @get decorated = GLFW.GetWindowAttrib(self.handle, GLFW.DECORATED)
    @set decorated = GLFW.SetWindowAttrib(self.handle, GLFW.DECORATED, value)
    
    @get floating = GLFW.GetWindowAttrib(self.handle, GLFW.FLOATING)
    @set floating = GLFW.SetWindowAttrib(self.handle, GLFW.FLOATING, value)
    
    @get focus_on_show = GLFW.GetWindowAttrib(self.handle, GLFW.FOCUS_ON_SHOW)
    @set focus_on_show = GLFW.SetWindowAttrib(self.handle, GLFW.FOCUS_ON_SHOW, value)
    
    @get opacity = GLFW.GetWindowOpacity(self.handle)
    @set opacity = GLFW.SetWindowOpacity(self.handle, value)
    
    @get position = (pos = GLFW.GetWindowPos(self.handle); pos.x × pos.y)
    @set position = GLFW.SetWindowPos(self.handle, value[1], value[2])
    
    @get resizable = GLFW.GetWindowAttrib(self.handle, GLFW.RESIZABLE)
    @set resizable = GLFW.SetWindowAttrib(self.handle, GLFW.RESIZABLE, value)
    
    @get shouldclose = GLFW.WindowShouldClose(self.handle)
    @set shouldclose = GLFW.SetWindowShouldClose(self.handle, value)
    
    @get visible = GLFW.GetWindowAttrib(self.handle, GLFW.VISIBLE)
    @set visible = if visible; GLFW.ShowWindow(self.handle) else; GLFW.HideWindow(self.handle) end
    
    # Setters Only
    @set aspect_ratio = set_aspect_ratio(self, value)
    @set icon = GLFW.SetWindowIcon(self.handle, value) # can be a single 2D matrix of pixels or an array of matrices of pixels.
    @set title = GLFW.SetWindowTitle(self.handle, value)
    
    # Getters Only
    @get content_scale    = (scales = GLFW.GetWindowContentScale(self.handle); scales.xscale × scales.yscale)
    @get focused          = GLFW.GetWindowAttrib(self.handle, GLFW.FOCUSED)
    @get framebuffer_size = (size = GLFW.GetFramebufferSize(self.handle); size.width × size.height)
    @get hovered          = GLFW.GetWindowAttrib(self.handle, GLFW.HOVERED)
    @get iconified        = GLFW.GetWindowAttrib(self.handle, GLFW.ICONIFIED)
    @get maximized        = GLFW.GetWindowAttrib(self.handle, GLFW.MAXIMIZED)
    @get transparent      = GLFW.GetWindowAttrib(self.handle, GLFW.TRANSPARENT_FRAMEBUFFER)
    
    # Context-related Properties
    @get client_api                 = ClientAPI(GLFW.GetWindowAttrib(self.handle, GLFW.CLIENT_API))
    @get context_creation_api       = ContextCreationAPI(GLFW.GetWindowAttrib(self.handle, GLFW.CONTEXT_CREATION_API))
    @get context_version            = VersionNumber(GLFW.GetWindowAttrib(self.handle, GLFW.CONTEXT_VERSION_MAJOR), GLFW.GetWindowAttrib(self.handle, GLFW.CONTEXT_VERSION_MINOR), GLFW.GetWindowAttrib(self.handle, GLFW.CONTEXT_REVISION))
    @get context_forward_compatible = GLFW.GetWindowAttrib(self.handle, GLFW.OPENGL_FORWARD_COMPAT) != 0
    @get context_debug              = GLFW.GetWindowAttrib(self.handle, GLFW.OPENGL_DEBUG_CONTEXT) != 0
    @get context_profile            = OpenGLProfile(GLFW.GetWindowAttrib(self.handle, GLFW.OPENGL_PROFILE))
    @get context_release_behavior   = ContextReleaseBehavior(GLFW.GetWindowAttrib(self.handle, GLFW.CONTEXT_RELEASE_BEHAVIOR))
    @get context_generates_errors   = GLFW.GetWindowAttrib(self.handle, GLFW.CONTEXT_NO_ERROR) == 0
    @get context_robustness         = ContextRobustness(GLFW.GetWindowAttrib(self.handle, GLFW.CONTEXT_ROBUSTNESS))
end

function Base.close(wnd::Window)
    GLFW.DestroyWindow(wnd.handle)
    wnd.handle = nothing
end

ExtraFun.use(wnd::Window) = (GLFW.MakeContextCurrent(wnd.handle); nothing)

monitor(wnd::Window) = monitor(GLFW.GetWindowMonitor(wnd.handle))
monitor(wnd::Window, monitor::Monitor, refresh_rate::Integer) = GLFW.SetWindowMonitor(wnd.handle, monitor.handle, 0, 0, size(wnd)..., refresh_rate)
monitor(wnd::Window, ::Nothing; xpos::Integer = 0, ypos::Integer = 0) = GLFW.SetWindowMonitor(wnd.handle, nothing, xpos, ypos, size(wnd)..., GLFW.DONT_CARE)

set_aspect_ratio(wnd::Window, ::Nothing) = GLFW.SetWindowAspectRatio(wnd.handle, GLFW.DONT_CARE, GLFW.DONT_CARE)
set_aspect_ratio(wnd::Window, aspect_ratio::Rational) = GLFW.SetWindowAspectRatio(wnd.handle, numerator(aspect_ratio), denominator(aspect_ratio))
set_aspect_ratio(wnd::Window, values) = GLFW.SetWindowAspectRatio(wnd.handle, values[1], values[2])

export limitsize
function limitsize(wnd::Window; min_width::Integer = -1, min_height::Integer = -1, max_width::Integer = -1, max_height::Integer = -1)
    real_limits(lim) = if lim < 1; GLFW.DONT_CARE else; lim end
    real_min_width, real_min_height, real_max_width, real_max_height = real_limits.((min_width, min_height, max_width, max_height))
    GLFW.SetWindowSizeLimits(wnd.handle, real_min_width, real_min_height, real_max_width, real_max_height)
    wnd
end

export maximize, restore
maximize(wnd::Window) = GLFW.MaximizeWindow(wnd.handle)
restore(wnd::Window)  = GLFW.RestoreWindow(wnd.handle)

export swapbuffers
swapbuffers(wnd::Window) = GLFW.SwapBuffers(wnd.handle)

export request_attention
request_attention(wnd::Window) = GLFW.RequestWindowAttention(wnd.handle)


macro make_register_window_callback(event, registrar)
    esc(:(register_window_callback(handler, wnd::Window, ::Ident{$event}) = GLFW.$registrar(wnd.handle, handler)))
end

"""Registers the default callbacks for the window. These callbacks forward events to concrete, semantic signatures in a more Julian approach."""
function register_default_window_callbacks(wnd::Window)
    register_window_callback(wnd, FramebufferSizeEvent)    do _::GLFW.Window, width::Integer, height::Integer; on_framebuffer_resize(wnd, width, height) end
    register_window_callback(wnd, WindowCloseEvent)        do _::GLFW.Window; on_window_close(wnd) end
    register_window_callback(wnd, WindowContentScaleEvent) do _::GLFW.Window, scalex::AbstractFloat, scaley::AbstractFloat; on_window_content_scale(wnd, scalex, scaley) end
    register_window_callback(wnd, WindowFocusEvent)        do _::GLFW.Window, focused::Integer; if focused != 0; on_window_focus(wnd) else; on_window_defocus(wnd) end; end
    register_window_callback(wnd, WindowIconifyEvent)      do _::GLFW.Window, iconified::Integer; if iconified != 0; on_window_iconify(wnd) else; on_window_restore(wnd) end; end
    register_window_callback(wnd, WindowMaximizeEvent)     do _::GLFW.Window, maximized::Integer; if maximized != 0; on_window_maximize(wnd) else; on_window_restore(wnd) end; end
    register_window_callback(wnd, WindowPosEvent)          do _::GLFW.Window, posx::Integer, posy::Integer; on_window_move(wnd, posx, posy) end
    register_window_callback(wnd, WindowRefreshEvent)      do _::GLFW.Window; on_window_refresh(wnd) end
    register_window_callback(wnd, WindowSizeEvent)         do _::GLFW.Window, sizex::Integer, sizey::Integer; on_window_resize(wnd, sizex, sizey) end
end
register_window_callback(handler, wnd::Window, event::WindowEvent) = register_window_callback(handler, wnd, Ident{event}())
@make_register_window_callback FramebufferSizeEvent    SetFramebufferSizeCallback
@make_register_window_callback WindowCloseEvent        SetWindowCloseCallback
@make_register_window_callback WindowContentScaleEvent SetWindowContentScaleCallback
@make_register_window_callback WindowFocusEvent        SetWindowFocusCallback
@make_register_window_callback WindowIconifyEvent      SetWindowIconifyCallback
@make_register_window_callback WindowMaximizeEvent     SetWindowMaximizeCallback
@make_register_window_callback WindowPosEvent          SetWindowPosCallback
@make_register_window_callback WindowRefreshEvent      SetWindowRefreshCallback
@make_register_window_callback WindowSizeEvent         SetWindowSizeCallback

# Window Events
"""Called when the window's framebuffer has been resized."""
function on_framebuffer_resize(::Window, width::Integer, height::Integer) end
"""Called when the window is *requested* to close."""
function on_window_close(::Window) end
"""Called when the window's content scale is adjusted."""
function on_window_content_scale(::Window, scalex::AbstractFloat, scaley::AbstractFloat) end
"""Called when the window loses focus."""
function on_window_defocus(::Window) end
"""Called when the window gains focus."""
function on_window_focus(::Window) end
"""Called when the window is iconified (minimized to taskbar)."""
function on_window_iconify(::Window) end
"""Called when the window is maximized."""
function on_window_maximize(::Window) end
"""Called when the window is moved."""
function on_window_move(::Window, posx::Integer, posy::Integer) end
"""Called when the window should refresh."""
function on_window_refresh(::Window) end
"""Called when the window is resized."""
function on_window_resize(::Window, sizex::Integer, sizey::Integer) end
"""Called when the window is restored, either from being iconified or maximized."""
function on_window_restore(::Window) end

export @windowhint
"""`@windowhint hint value` is a more semantic & Julian, albeit comparatively low-level interface which sets the window
creation hint. It is equivalent to `GLFW.WindowHint(...)`. However, most hints are can be adjusted post creation through
`Window`'s virtual properties. Some, especially framebuffer context hints, can only be configured prior to creation
through this macro.

`hint` may be either the desired GLFW hint constant (e.g. `RED_BITS`) or a camel-cased version (e.g. `RedBits` or `redBits`).

`value` may be the appropriate value (Integer/Bool) which is passed to the hint directly.

If `value` is `nothing`, `GLFW.DONT_CARE` is passed instead.

If `value` is an `Enum`, it's `Integer(value)` is passed in. This allows setting the hint to a value such as `OpenGLAPI`
(a `ClientAPI` enum value) which is assigned the appropriate GLFW constant.

Example
-------
```julia
@windowhint TransparentFramebuffer true
@windowhint ClientAPI OpenGLAPI"""
macro windowhint(hint::Symbol, value)
    glfw_hint = Expr(:., :GLFW, QuoteNode(Symbol(decamelcase(string(hint)))))
    Expr(:call, :windowhint, glfw_hint, esc(value))
end
windowhint(hint::UInt32, ::Union{Nothing, Missing}) = windowhint(hint, GLFW.DONT_CARE)
windowhint(hint::UInt32, value::Enum) = windowhint(hint, Integer(value))
windowhint(hint::UInt32, value) = GLFW.WindowHint(hint, value)

decamelcase(sym::AbstractString) = Symbol(uppercase(replace(sym, r"([a-z])([A-Z])" => s"\1_\2")))

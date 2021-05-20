# GLFWAbstraction.jl
Abstraction layer for [GLFW.jl](https://github.com/JuliaGL/GLFW.jl).

# Mission
*GLFWAbstraction* is designed to provide a more Julia-native and partly functional experience to working with the [GLFW](https://www.glfw.org/) library.

# Abstractions
Not every component of the GLFW library is abstracted here. Two reasons for this exist: A) GLFW.jl does not expose the feature itself; B) time pressure.

Following are the GLFW components which have received abstractions:

* Windows
* Monitors
* Input
  * Keyboard Input
  * Mouse Input

These abstractions are not implemented for given reasons:

* Joystick/Gamepad abstraction - GLFW.jl is not up-to-date.
* Input:
  * Custom Cursor Images - GLFW.jl is not up-to-date.
  * Time & clipboard input - GLFW.jl intentionally does not expose these as there is standard Julia functionality.
  * Path dropping - lack of time.
* Vulkan - lack of time.

# Table of Contents
- [GLFWAbstraction.jl](#glfwabstractionjl)
- [Mission](#mission)
- [Abstractions](#abstractions)
- [Table of Contents](#table-of-contents)
- [Documentation](#documentation)
  - [Monitors](#monitors)
    - [Video Modes](#video-modes)
  - [Windows](#windows)
    - [Window Creation](#window-creation)
    - [Entering & Leaving Fullscreen Mode](#entering--leaving-fullscreen-mode)
    - [Borderless Fullscreen Mode](#borderless-fullscreen-mode)
    - [Window Attributes](#window-attributes)
    - [Aspect Ratio](#aspect-ratio)
    - [Window Icon](#window-icon)
    - [Window Creation Hints](#window-creation-hints)
    - [Window Manipulation Functions](#window-manipulation-functions)
    - [Events](#events)
  - [Input](#input)
    - [Modifier Keys](#modifier-keys)
  - [Keyboard Input](#keyboard-input)
  - [Mouse Input](#mouse-input)

# Documentation
This preliminary documentation shall provide every information necessary to work with GLFWAbstraction.jl.

## Monitors
Monitors revolve around the `Monitor` struct retrieved from the `monitor` function.

Use `monitor(window::Window)` to retrieve the monitor associated with a fullscreen window. If none (i.e. the window is not in fullscreen mode), returns `nothing`. Use `monitor(n::Integer)` to retrieve the `n`-th connected monitor. Usually, you will simply call `monitor(1)` to assign a window to the primary monitor. A convenient `monitor(::Nothing) = nothing` exists if needed.

Another abstraction exists through the `Monitors` meta type. Note the plural *s*. This meta type allows querying information on the collective of connected monitors.

Use `length(Monitors)` to retrieve the total number of connected monitors. You may also use `Monitors[index]` in place of `monitor(index)`. You may also `collect(Monitors)` to retrieve a vector of all currently connected monitors, or `iterate(Monitors)` which allows usage with a regular `for` loop:

```julia
for monitor in Monitors
    # do something
end
```

### Video Modes
Monitors are associated with one or more `VideoMode`s. The current video mode of the monitor - either the default desktop video mode or the video mode of its current fullscreen application - can be retrieved through `videomode(monitor)`. All of its supported video modes can be queried through `videomodes(monitor)`, respectively.

While the `VideoMode` contains the same information as `GLFW.VidMode`, it arranges it slightly differently:

```julia
struct VideoMode
    width::Int
    height::Int
    bits::NamedTuple{(:red, :green, :blue), Tuple{UInt8, UInt8, UInt8}}
    refresh_rate::Int
end
```

See section [Borderless Fullscreen Mode](#Borderless-Fullscreen-Mode) below to learn how to use this struct.

## Windows
The centerpiece of GLFW is arguably the windowing system. *GLFWAbstraction* tries to simplify it as much as possible. Various GLFW constants were wrapped in their own enums. Updating & retrieving window attributes is accomplished through virtual properties. Events are delegated through Julia's native multiple dispatch.

### Window Creation
`Window{ID}`s are created through the `window` factory. Every `Window` is decorated with an arbitrary `ID`entifier. These are used to hook into the multiple dispatch based event system. A window can be created as such:

```julia
window(id::Symbol, title::AbstractString, width::Integer, height::Integer, [monitor::Monitor], [share::Window])
```

If `monitor === nothing`, the window will be created in windowed mode. Otherwise, it will be created in fullscreen on the specified window. `share` may be provided if multiple windows need to share the same OpenGL context. One such use case is spanning multiple monitors in fullscreen with two distinct windows.

The `title` will be displayed in the window's title bar - given it uses border decorations. `width` and `height` describe the desired window's drawing size - although the size of the window need not necessarily match the framebuffer's size.

`id` is passed to the `Window{id}` such that it may be used to uniquely identify your window in the event system described below.

### Entering & Leaving Fullscreen Mode
Entering and leaving fullscreen mode is as easy as setting the window's monitor to either a concrete instance or `nothing` respectively:

```julia
monitor(window, monitor::Monitor, refresh_rate::Integer = 0)
monitor(window, ::Nothing)
```

When `refresh_rate` is set to non-positive, it is synonymous for `GLFW.DONT_CARE`.

### Borderless Fullscreen Mode
*Borderless Fullscreen Mode* is a special variant of fullscreen mode where the video mode of the window in fullscreen mode matches that of the monitor's video mode in desktop mode. Note that, if another application is already in fullscreen on the queried monitor, its video mode will be retrieved. Currently, there is no way to retrieve the desktop video mode directly from the OS through GLFW.

```julia
let monitor = Monitor(1), vidmode = videomode(monitor)
    @windowhint redBits     vidmode.bits.red
    @windowhint greenBits   vidmode.bits.green
    @windowhint blueBits    vidmode.bits.blue
    @windowhint refreshRate vidmode.refresh_rate
    wnd = window(:id, "Borderless Fullscreen Window", vidmode.width, vidmode.height, Monitor(1))
end
```

Unfortunately, window hints are still relatively low-level, lending the syntax almost directly from GLFW.

### Window Attributes
GLFW exposes countless window attributes - some related to the window itself, others to its underlying OpenGL context. To the best of my knowledge, all window attributes have received virtual getters and setters for convenient use. Example:

```julia
let wnd = window(...)
  wnd.decorated = false
  wnd.opacity = 0.5
  
  if wnd.hovered
    println("mouse cursor is currently above window")
  end
end
```

**Attributes with both getters & setters include:**

| Virtual Property | Get                                        | Set                                         |
| ---------------: | :----------------------------------------- | :------------------------------------------ |
|   `auto_iconify` | window attribute                           | window attribute                            |
|      `decorated` | window attribute                           | window attribute                            |
|       `floating` | window attribute                           | window attribute                            |
|  `focus_on_show` | window attribute                           | window attribute                            |
|        `opacity` | window attribute                           | window attribute                            |
|       `position` | (unnamed) 2-tuple of `GLFW.GetWindowPos()` | (unnamed) 2-tuple to `GLFW.SetWindowPos()`  |
|      `resizable` | window attribute                           | window attribute                            |
|    `shouldclose` | `GLFW.WindowShouldClose()`                 | `GLFW.SetWindowShouldClose()`               |
|        `visible` | window attribute                           | `GLFW.ShowWindow()` and `GLFW.HideWindow()` |

**Attributes with only setters include:**

| Virtual Property | Set                                               |
| ---------------: | :------------------------------------------------ |
|   `aspect_ratio` | `GLFW.SetWindowAspectRatio()` - see details below |
|           `icon` | `GLFW.SetWindowIcon()` - see details below        |
|          `title` | `GLFW.SetWindowTitle()`                           |

**Attributes with only getters include:**

|   Virtual Property | Get                                                 |
| -----------------: | :-------------------------------------------------- |
|    `content_scale` | (unnamed) 2-tuple of `GLFW.GetWindowContentScale()` |
|          `focused` | window attribute                                    |
| `framebuffer_size` | (unnamed) 2-tuple of `GLFW.GetFramebufferSize()`    |
|          `hovered` | window attribute                                    |
|        `iconified` | window attribute                                    |
|        `maximized` | window attribute                                    |
|      `transparent` | window attribute `GLFW.TRANSPARENT_FRAMEBUFFER`     |

**Context Attributes with only getters include:**

|             Virtual Property | Get                                                                                                                        |
| ---------------------------: | :------------------------------------------------------------------------------------------------------------------------- |
|                 `client_api` | `ClientAPI` (enum) from window attribute                                                                                   |
|       `context_creation_api` | `ContextCreationAPI` (enum) from window attribute                                                                          |
|            `context_version` | `VersionNumber` from window attributes `GLFW.CONTEXT_VERSION_MAJOR`, `GLFW.CONTEXT_VERSION_MINOR`, `GLFW.CONTEXT_REVISION` |
| `context_forward_compatible` | `Bool` from window attribute                                                                                               |
|              `context_debug` | `Bool` from window attribute                                                                                               |
|            `context_profile` | `OpenGLProfile` (enum) from window attribute                                                                               |
|   `context_release_behavior` | `ContextReleaseBehavior` (enum) from window attribute                                                                      |
|   `context_generates_errors` | `Bool` from window attribute `GLFW.CONTEXT_NO_ERROR`                                                                       |
|         `context_robustness` | `ContextRobustness` (enum) from window attribute                                                                           |

### Aspect Ratio
The `wnd.aspect_ratio` attribute has received special treatment. For convenient and semantic use, it can be written as such:

```julia
let wnd = window(...)
  wnd.aspect_ratio = 16//9   # |-These are equivalent
  wnd.aspect_ratio = (16, 9) # |
  wnd.aspect_ratio = nothing # Clear aspect ratio
end
```

When set, the windowing system will enforce the given aspect ratio upon attempting to resize it. The exact behavior is a platform-dependent implementation detail.

### Window Icon
GLFW.jl already simplifies setting the application's icon. All that is needed is to pass in either a single 2-by-2 `Matrix` of pixels resembling the icon data, or a `Vector` of such images for animated icons.

*TODO*

### Window Creation Hints
Unfortunately, window creation hints are intertwined with the above [Window Attributes](#window-attributes) and difficult to simplify. As of the time of writing, the best solution I've come up with is the `@windowhint` macro, which is comparatively low-level and follows this syntax:

```julia
@windowhint <attribute> <value>
```

Where `attribute` directly corresponds to the GLFW constants in camel-case, e.g. `TransparentFramebuffer` - although one may also choose to simply use `TRANSPARENT_FRAMEBUFFER`. `value` may then be any valid value - usually an integer. `Enum`s are converted to their integer values and `nothing` is synonymous for `GLFW.DONT_CARE`.

### Window Manipulation Functions
Few manipulation functions for windows are exposed:

|                                                       Function | Purpose                                                                                                                                                         |
| -------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|                                                `maximize(wnd)` | Maximize the window.                                                                                                                                            |
|                                                 `restore(wnd)` | Restore a window from either maximized or iconified/minimized state.                                                                                            |
| `limitsize(wnd; min_width, min_height, max_width, max_height)` | Adjust window's minimum and maximum dimensions. All components are optional. When non-positive, the respective limit is removed.                                |
|                                             `swapbuffers(wnd)` | Swap front & back buffers.                                                                                                                                      |
|                                       `request_attention(wnd)` | Request the users attention. The exact behavior is dependent on the underlying platform. On windows, this will cause the window's icon in the taskbar to blink. |

### Events
Events have shifted from callbacks to a Julia-native multiple dispatch based solution. This is where the `ID` in `Window{ID}` comes into play. Following are the signatures for all currently available event handlers:

* `on_framebuffer_resize(::Window{ID}, width::Integer, height::Integer)`
* `on_window_close(::Window{ID})`
* `on_window_content_scale(::Window{ID}, scalex::AbstractFloat, scaley::AbstractFloat)`
* `on_window_defocus(::Window{ID})`
* `on_window_focus(::Window{ID})`
* `on_window_iconify(::Window{ID})`
* `on_window_maximize(::Window{ID})`
* `on_window_move(::Window{ID}, posx::Integer, posy::Integer)`
* `on_window_refresh(::Window{ID})`
* `on_window_resize(::Window{ID}, sizex::Integer, sizey::Integer)`
* `on_window_restore(::Window{ID})`

## Input
Few global input functions exist:

|                Function | Purpose                                                                                                            |
| ----------------------: | :----------------------------------------------------------------------------------------------------------------- |
|          `pollevents()` | Poll events & trigger corresponding handlers.                                                                      |
| `waitevents([timeout])` | Wait for any event & trigger corresponding handlers. If `timeout` is supplied, wait at most for `timeout` seconds. |
|    `post_empty_event()` | Post an empty event to the event queue, waking up any `Task` or `Thread` waiting on events.                        |

### Modifier Keys
Both keyboard & mouse events can come with `ModifierKey`s that were active at the moment the key or mouse button was pressed or released. The pseudo-enum is built using [BitFlags.jl](https://github.com/jmert/BitFlags.jl) which has various benefits over regular enums. The following modifier keys exist:

* `NoMod` - no modifier key was held.
* `ShiftMod`
* `ControlMod`
* `AltMod`
* `SuperMod`
* `CapsLockMod`
* `NumLockMod`

Note that caps lock and num lock may not be usable yet as *GLFW.jl* is not up-to-date.

Test for specific modifier keys like such:

```julia
function foo(modifiers::ModifierKey)
  if (modifier & ShiftMod) != NoMod
    # do something
  end
end
```

## Keyboard Input
*TODO*

## Mouse Input
*TODO*

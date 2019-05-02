# [docs](index.md) » SplitView
---

*Open two windows side by side in Full Screen SplitView.*  Select by name and/or using a searchable popup display.  Also provides focus toggling between splitview "halves" and ability to close a fullscreen or split desktop by keyboard.
Important points:
* `SplitView` relies on the undocumented `spaces` API, and the separate accessibility ui `axuielement`; which _must_ both be installed for it to work; see https://github.com/asmagill/hs._asm.undocumented.spaces and https://github.com/asmagill/hs._asm.axuielement/, 
* This tool works by _simulating_ the split-view user interface: a long green-button click followed by a 2nd window click.  This requires some time delays to work reliably.  If it is unreliable for you, trying increasing these (see `delay*` variables in the reference below).
* `SplitView` uses `hw.window.filter` to try to ignore atypical windows (menu panes, etc.), which see.  Unrecognized non-standard windows may interfere with `SplitView`'s operation.

*Download*: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SplitView.spoon.zip]
Example config in your `~/.hammerspoon/init.lua`:
```
mash =      {"ctrl", "cmd"}
mashshift = {"ctrl", "cmd","shift"}
hs.loadSpoon("SplitView",true) -- add to global, so we can access from command line
spoon.SplitView:bindHotkeys({choose={mash,"e"},
			     chooseAppEmacs={mashshift,"e","Emacs"},
			     chooseAppWin130={mashshift,"o","Terminal","130"},
			     switchFocus={mash,"x"},
			     removeDesktop={mashshift,"x"}})
```

## API Overview
* Variables - Configurable values
 * [checkInterval](#checkInterval)
 * [debug](#debug)
 * [delayOtherClick](#delayOtherClick)
 * [delayZoomHold](#delayZoomHold)
 * [showImage](#showImage)
* Methods - API calls which can only be made on an object returned by a constructor
 * [bindHotkeys](#bindHotkeys)
 * [byName](#byName)
 * [choose](#choose)
 * [removeCurrentFullScreenDesktop](#removeCurrentFullScreenDesktop)
 * [switchFocus](#switchFocus)

## API Documentation

### Variables

| [checkInterval](#checkInterval)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:checkInterval`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (Float) Time interval in seconds to check for MC/SplitView animations to complete                                                                     |

| [debug](#debug)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:debug`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (Boolean) Whether to print debug information to the console.  Can                                                                     |

| [delayOtherClick](#delayOtherClick)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:delayOtherClick`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (Float) How long in seconds to delay finding and clicking the other window                                                                     |

| [delayZoomHold](#delayZoomHold)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:delayZoomHold`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (Float) How long in seconds to "hold" the zoom button down.                                                                     |

| [showImage](#showImage)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:showImage`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (Boolean) Whether to show a thumbnail image of the window in the choice selection list.  On by default (which slightly slows the interface).                                                                     |

### Methods

| [bindHotkeys](#bindHotkeys)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:bindHotkeys(mapping)`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Binds hotkeys for SplitView                                                                     |
| **Parameters**                              | <ul><li>mapping - A table containing hotkey details for the following items:</li><li> choose - Interactively choose another window to enter split-view with</li><li> switchFocus - Switch the split view window focus</li><li> removeDesktop - Remove the current fullscreen desktop</li><li> chooseApp* - Create one or more special `choose` bindings to choose among only those windows matching a given application string.  In this case, give the app string to match as the last table entry.  E.g. `chooseAppEmacs={{"cmd","ctrl"},"e","Emacs"}`</li><li> chooseWin* - Create one or more special `choose` bindings to choose among only those windows matching a given title string.  Give the title string as the last table entry.  E.g. `{chooseWinProj={{"cmd","ctrl"},"p","MyProject"}}`</li><li> chooseAppWin* - Create one or more special `choose` bindings to choose among only those applications matching a given string, and windows of that applicaiton matching a given title string.  Give the application string, then title string as the last two table entries. E.g. `{chooseAppWinEmacsProj={{"cmd","ctrl"},"1","Emacs","MyProject"}}</li></ul> |

| [byName](#byName)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:byName([otherapp,othrewin,noChoose])`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Select an application and window _by name_ to enter split-view along side the currently focused window                                                                     |
| **Parameters**                              | <ul><li>`otherapp`: (Optional, String) The (partial) name of the other window's application, or omitted/`nil` for no application filtering</li><li>`otherwin`: (Optional, String) The (partial) title of the other window, or omitted/`nil` for no window name filtering</li><li>`noChoose`: (Optional, Boolean) By default a chooser window is invoked if more than one window matches. To disable this behavior and always take the first match (if any), pass `true` for this parameter.</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |

| [choose](#choose)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:choose()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Choose another window to enter split-view with current window                                                                     |
| **Parameters**                              | <ul><li>`winChoices`: (Optional) A table of windows to choose from (as, e.g., provided by `SplitView:byName`).  Defaults to choosing among all other windows on the same screen.  Only standard, non-fullscreen windows are offered.</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |

| [removeCurrentFullScreenDesktop](#removeCurrentFullScreenDesktop)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:removeCurrentFullScreenDesktop`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Use Mission Control to remove the current full-screen or split-view desktop (aka space) and switch back to the first user space.                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |

| [switchFocus](#switchFocus)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:switchFocus()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Switch focus from one side of a Split View to another, with an animated arrow showing the switch.                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |


# [docs](index.md) » SplitView
---

*Open two windows side by side in SplitView.*  Select by name and/or using a popup.  Also provides focus toggling between splitview "halves".
Important points:
* `SplitView` Relies on the undocumented `spaces` API, which _must_ be installed separately for it to work; see https://github.com/asmagill/hs._asm.undocumented.spaces
* This tool works by _simulating_ the split-view user interface: a long green-button click followed by a 2nd window click.  This requires hand tuned time delays to work reliably.  If it is unreliable for you, trying increasing these (see `delay*` variables, below).
* `SplitView` uses `hw.window.filter` to try to ignore atypical windows (menu panes, etc.), which see.  Unrecognized non-standard windows may interfere with `SplitView`'s operation.
* If there is only a single space, `SplitView` creates _and does not remove_ a new, empty space for temporarily holding unwanted windows from the same application(s).  This space can safely be deleted, but will recur on future invocations.

*Download*: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SplitView.spoon.zip]
Example config in your `~/.hammerspoon/init.lua`:
```
mash =      {"ctrl", "cmd"}
spoon.splitView=hs.loadSpoon("SplitView")
spoon.splitView:bindHotkeys({choose={mash,"s"},switchFocus={mash,"x"},chooseAppEmacs={mash,"e","Emacs"})
```

## API Overview
* Variables - Configurable values
 * [debug](#debug)
 * [delay*](#delay*)
 * [showImage](#showImage)
* Methods - API calls which can only be made on an object returned by a constructor
 * [bindHotkeys](#bindHotkeys)
 * [byName](#byName)
 * [choose](#choose)
 * [switchFocus](#switchFocus)

## API Documentation

### Variables

| [debug](#debug)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:debug`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (Boolean) Whether to print debug information to the console                                                                     |

| [delay*](#delay*)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:delay*`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (Boolean) Time in seconds to delay between actions:                                                                     |

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
| **Parameters**                              | <ul><li>mapping - A table containing hotkey details for the following items:</li><li> choose - Interactively choose another window to enter split-view with</li><li> switchFocus - Switch the split view window focus</li><li> chooseApp* - Create one or more special `choose` bindings to choose among only those windows matching a given application string.  In this case, give the app string to match as the last table entry.  E.g. `chooseAppEmacs={{"cmd","ctrl"},"e","Emacs"}`</li><li> chooseWin* - Create one or more special `choose` bindings to choose among only those windows matching a given title string.  Give the title string as the last table entry.  E.g. `{chooseWinProj={{"cmd","ctrl"},"p","MyProject"}}`</li><li> chooseAppWin* - Create one or more special `choose` bindings to choose among only those applications matching a given string, and windows of that applicaiton matching a given title string.  Give the application string, then title string as the last two table entries. E.g. `{chooseAppWinEmacsProj={{"cmd","ctrl"},"1","Emacs","MyProject"}}</li></ul> |

| [byName](#byName)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:byName([otherapp,othrewin,noChoose])`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Select an application and window _by name_ to enter split-view along side the currently focused window                                                                     |
| **Parameters**                              | <ul><li>`otherapp`: (Optional) The (partial) name of the other window's application, or omitted/`nil` for no application filtering</li><li>`otherwin`: (Optional) The (partial) title of the other window, or omitted/`nil` for no window name filtering</li><li>`noChoose`: (Optional, Boolean) By default a chooser window is invoked if more than one window matches. To disable this behavior and always take the first match (if any), pass `false` for this parameter.</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |

| [choose](#choose)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:choose()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Choose another window to enter split-view with current window                                                                     |
| **Parameters**                              | <ul><li>`winChoices`: (Optional) A table of windows to choose from (as, e.g., provided by `SplitView:byName`).  Defaults to choosing among all other windows on the same screen.  Only standard, non-fullscreen windows are considered.</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |

| [switchFocus](#switchFocus)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:switchFocus()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Switch focus from one side of a Split View to another, with an animated arrow showing the switch.                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |


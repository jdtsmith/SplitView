# [docs](index.md) » SplitView
---

*Open two windows side by side in Full Screen SplitView.*  Select by name and/or using a searchable popup display.  Also provides focus toggling between splitview "halves" and ability to close a fullscreen or split desktop by keyboard. Requires MacOS>=10.15
Important points:
* `SplitView` relies on the undocumented `spaces` API, and the separate accessibility ui `axuielement`; which _must_ both be installed for it to work; see https://github.com/asmagill/hs._asm.undocumented.spaces and https://github.com/asmagill/hs._asm.axuielement/, 
* This tool works by _simulating_ the split-view user interface: a long green-button click followed by a 2nd window click.  This requires some time delays to work reliably.  If it is unreliable for you, trying increasing these (see `delay*` variables in the reference below).
* `SplitView` uses `hw.window.filter` to try to ignore atypical windows (menu panes, etc.), which see.  Unrecognized non-standard windows may interfere with `SplitView`'s operation.

*Download*: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SplitView.spoon.zip]
Example config in your `~/.hammerspoon/init.lua`:
```
mash =      {"ctrl", "cmd"}
mashshift = {"ctrl", "cmd","shift"}
-- SplitView for Split Screen 
hs.spoons.use("SplitView",
	      {config = {tileSide="right"},
	       hotkeys={choose={mash,"e"},
	       			chooseAppEmacs={mashshift,"e","Emacs"},
	       			chooseAppWin130={mashshift,"o","Terminal","130"},
	       			removeDesktop={mashshift,"k"},
	       			swapWindows={mashshift,"x"},
	       			switchFocus={mash,"x"}}})
```
Version 1.8.0

## API Overview
* Variables - Configurable values
 * [checkInterval](#checkInterval)
 * [debug](#debug)
 * [delayOtherClick](#delayOtherClick)
 * [maxRefineIter](#maxRefineIter)
 * [showImage](#showImage)
 * [tileSide](#tileSide)
* Methods - API calls which can only be made on an object returned by a constructor
 * [bindHotkeys](#bindHotkeys)
 * [byName](#byName)
 * [choose](#choose)
 * [removeCurrentFullScreenDesktop](#removeCurrentFullScreenDesktop)
 * [swapWindows](#swapWindows)
 * [switchFocus](#switchFocus)

## API Documentation

### Variables

| [checkInterval](#checkInterval)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:checkInterval`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (Float) Time interval in seconds to check for various MC/SplitView actions to complete                                                                     |

| [debug](#debug)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:debug`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (Boolean) Whether to print debug information to the console.  Can                                                                     |

| [delayOtherClick](#delayOtherClick)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:delayOtherClick`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (Float) How long in seconds to delay finding and clicking the other window.                                                                     |

| [maxRefineIter](#maxRefineIter)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:maxRefineIter`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (String) Maximum number of mini-screen probe point "jiggle" refinement iterations                                                                     |

| [showImage](#showImage)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:showImage`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (Boolean) Whether to show a thumbnail image of the window in the choice selection list.  On by default (which slightly slows the interface).                                                                     |

| [tileSide](#tileSide)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:tileSide`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | (String) Which side to tile the window on ("left" or "right").                                                                      |

### Methods

| [bindHotkeys](#bindHotkeys)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:bindHotkeys(mapping)`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Binds hotkeys for SplitView                                                                     |
| **Parameters**                              | <ul><li>mapping - A table containing hotkey details for the following items:
  choose - Interactively choose another window to enter split-view with
  switchFocus - Switch the split view window focus
  removeDesktop - Remove the current fullscreen desktop
  chooseApp* - Create one or more special `choose` bindings to choose among only those windows matching a given application string.  In this case, give the app string to match as the last table entry.  E.g. `chooseAppEmacs={{"cmd","ctrl"},"e","Emacs"}`
  chooseWin* - Create one or more special `choose` bindings to choose among only those windows matching a given title string.  Give the title string as the last table entry.  E.g. `{chooseWinProj={{"cmd","ctrl"},"p","MyProject"}}`
  chooseAppWin* - Create one or more special `choose` bindings to choose among only those applications matching a given string, and windows of that applicaiton matching a given title string.  Give the application string, then title string as the last two table entries. E.g. `{chooseAppWinEmacsProj={{"cmd","ctrl"},"1","Emacs","MyProject"}}</li></ul> |
| **Returns**                                 | <ul></ul>          |
| **Notes**                                   | <ul></ul>                |

| [byName](#byName)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:byName([otherapp,otherwin,noChoose])`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Select an application and window _by name_ to enter split-view                                                                     |
| **Parameters**                              | <ul><li>`otherapp`: (Optional, String) The (partial) name of the other window's application, or omitted/`nil` for no application filtering</li><li>`otherwin`: (Optional, String) The (partial) title of the other window, or omitted/`nil` for no window name filtering</li><li>`noChoose`: (Optional, Boolean) By default a chooser window is invoked if more than one window matches. To disable this behavior and always take the first match (if any), pass `true` for this parameter.</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |
| **Notes**                                   | <ul></ul>                |

| [choose](#choose)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:choose()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Choose another window to enter split-view with together with the current window                                                                     |
| **Parameters**                              | <ul><li>`winChoices`: (Optional) A table of hs.windows to choose from (as, e.g., provided by `SplitView:byName`).  Defaults to choosing among all other windows on the same screen.  Only standard, non-fullscreen windows from the list are included.</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |
| **Notes**                                   | <ul></ul>                |

| [removeCurrentFullScreenDesktop](#removeCurrentFullScreenDesktop)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:removeCurrentFullScreenDesktop`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Use Mission Control to remove the current full-screen or split-view desktop (aka space) and switch back to the first user space.                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |
| **Notes**                                   | <ul></ul>                |

| [swapWindows](#swapWindows)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:swapWindows`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Swap the two spaces in a full screen split view                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |
| **Notes**                                   | <ul></ul>                |

| [switchFocus](#switchFocus)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SplitView:switchFocus()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Switch focus from one side of a Split View to another, with an animated arrow showing the switch.                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |
| **Notes**                                   | <ul></ul>                |


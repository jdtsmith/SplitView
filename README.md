# SplitView
`SplitView` is a [Hammerspoon](https://www.hammerspoon.org) Spoon which can automate the painful chore of putting two windows side by side in MacOS's fullscreen split-view mode.  Using it is simple: just navigate to the first window you'd like in the split view, invoke the assigned key shortcut, choose another window from the popup, and watch the magic happen. You can also create special bindings to search by application and/or window name, or even invoke `SplitView` from the command line.  And as a bonus you can bind a shortcut key to toggle focus while in split view from one side to the other, and another to remove a full screen desktop (single or split-view) with another shortcut.

Important points:
* `SplitView` relies on the undocumented `spaces` API, and the separate accessibility `axuielement` extension; which _must_ both be installed for it to work; see https://github.com/asmagill/hs._asm.undocumented.spaces and https://github.com/asmagill/hs._asm.axuielement/.  These extensions rely on undocumented behavior so caveat splitviewor.
* This tool works by _simulating_ the split-view user interface: a long green-button click followed by a 2nd window click on the chosen miniature window.  This requires time delays to work reliably (once for holding the green button, and again to wait for mini-windows to move into position).  If it is unreliable for you, trying increasing these (see `delay` variables in the reference below).
* `SplitView` uses `hw.window.filter` to try to ignore atypical windows (menu panes, etc.), which see.  Unrecognized non-standard windows may interfere with `SplitView`'s operation.

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

To install, just [download](https://github.com/jdtsmith/SplitView/releases/latest) `SplitView.spoon.zip` and double-click it!
See [the docs](http://htmlpreview.github.io/?https://github.com/jdtsmith/SplitView/blob/master/html/SplitView.html) for complete information on configuring `SplitView`.

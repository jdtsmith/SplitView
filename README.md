# SplitView
`SplitView` is a [Hammerspoon](https://www.hammerspoon.org) Spoon which can automate the painful chore of putting two windows side by side in MacOS's fullscreen split-view mode.  Using it is simple: just navigate to the window you'd like on the left side of the split view, invoke the assigned key shortcut, choose another window from the popup, and watch the magic happen. You can also create special bindings to search by application and/or window name, or even invoke `SplitView` from the command line.  And as a bonus you can bind a shortcut key to toggle focus while in split view from one side to the other, and remove a full screen desktop (single or split-view) with another shortcut.

Important points:
* `SplitView` relies on the undocumented `spaces` and `axuielement` APIs, which _must_ both be installed separately for it to work; see https://github.com/asmagill/hs._asm.undocumented.spaces, https://github.com/asmagill/hs._asm.axuielement/
* This tool works by _simulating_ the split-view user interface: a long green-button click followed by a 2nd window click.  This requires hand tuned time delays to work reliably.  If it is unreliable for you, trying increasing these (see `delay*` variables, below).
* `SplitView` uses `hw.window.filter` to try to ignore atypical windows (menu panes, etc.), which see.  Unrecognized non-standard windows may interfere with `SplitView`'s operation.
* If there is only a single space, `SplitView` creates _and does not remove_ a new, empty space for temporarily holding unwanted windows from the same application(s).  This space can safely be deleted, but will recur on future invocations.

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

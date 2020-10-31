--- === SplitView ===
---
--- *Open two windows side by side in Full Screen SplitView.*  Select by name and/or using a searchable popup display.  Also provides focus toggling between splitview "halves" and ability to close a fullscreen or split desktop by keyboard.
--- Important points:
--- * `SplitView` relies on the undocumented `spaces` API, and the separate accessibility ui `axuielement`; which _must_ both be installed for it to work; see https://github.com/asmagill/hs._asm.undocumented.spaces and https://github.com/asmagill/hs._asm.axuielement/, 
--- * This tool works by _simulating_ the split-view user interface: a long green-button click followed by a 2nd window click.  This requires some time delays to work reliably.  If it is unreliable for you, trying increasing these (see `delay*` variables in the reference below).
--- * `SplitView` uses `hw.window.filter` to try to ignore atypical windows (menu panes, etc.), which see.  Unrecognized non-standard windows may interfere with `SplitView`'s operation.
---
--- *Download*: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SplitView.spoon.zip]
--- Example config in your `~/.hammerspoon/init.lua`:
--- ```
--- mash =      {"ctrl", "cmd"}
--- mashshift = {"ctrl", "cmd","shift"}
--- -- SplitView for Split Screen 
--- hs.spoons.use("SplitView",
--- 	      {config = {tileSide="right"},
--- 	       hotkeys={choose={mash,"e"},
--- 	       			chooseAppEmacs={mashshift,"e","Emacs"},
--- 	       			chooseAppWin130={mashshift,"o","Terminal","130"},
--- 	       			removeDesktop={mashshift,"k"},
--- 	       			swapWindows={mashshift,"x"},
--- 	       			switchFocus={mash,"x"}}})
--- ```
local obj = {}
obj.__index = obj

--::: Modules
local hasAX, ax
ax = hs.axuielement

local hasSpaces, spaces = pcall(require, "hs._asm.undocumented.spaces")

if not hasSpaces then
   print("hs._asm.undocumented.spaces + hs.axuielement (HS>=0.9.79) are required for SplitView; please install")
   return nil
end
obj.dockAX = ax.applicationElement(hs.application("Dock"))
--   :searchPath({role="AXApplication"})
local hse,hsee,hst=hs.eventtap,hs.eventtap.event,hs.timer

--::: Metadata
obj.name = "SplitView"
obj.version = "1.6.0"
obj.author = "JD Smith"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local ret, ver = hs.applescript("system version of (system info)")
obj.osversion = ver

--::: Default keys
local mash =      {"ctrl", "cmd"}
local mashshift = {"ctrl", "cmd","shift"}
obj.defaultHotkeys={choose={mash,"e"},
		    removeDesktop={mashshift,"x"},
		    switchFocus={mash,"x"}}

--::: Methods and Local Functions

--- SplitView:showImage
--- Variable
--- (Boolean) Whether to show a thumbnail image of the window in the choice selection list.  On by default (which slightly slows the interface).
obj.showImage = true

--- SplitView:debug
--- Variable
--- (Boolean) Whether to print debug information to the console.  Can
--- set to the special value "draw" to draw grid search positions (can
--- be slow for large grids)
obj.debug = false

--- SplitView:delayZoomHold
--- Variable
--- (Float) How long in seconds to "hold" the zoom button down.
---  Defaults to 0.75s.
obj.delayZoomHold = 0.75

--- SplitView:delayOtherClick
--- Variable
--- (Float) How long in seconds to delay finding and clicking the other window
---  Defaults to 0.2s.
obj.delayOtherClick = 0.2

--- SplitView:checkInterval
--- Variable
--- (Float) Time interval in seconds to check for MC/SplitView animations to complete
obj.checkInterval = 0.1

--- SplitView:tileSide
--- Variable
--- (String) Which side to tile the window on ("left" or "right"). For Catalina only
obj.tileSide = "left"

--- SplitView:maxRefineIter
--- Variable
--- (String) Maximum number of mini-screen probe point "jiggle" refinement iterations
obj.maxRefineIter = 4


-- Internal Function
local function getGoodFocusedWindow(nofull)
   local win = hs.window.focusedWindow()
   if not win or not win:isStandard() then return end
   if nofull and win:isFullScreen() then return end
   return win
end 

--- SplitView:choose()
--- Method
--- Choose another window to enter split-view with current window
---
--- Parameters:
---  * `winChoices`: (Optional) A table of windows to choose from (as, e.g., provided by `SplitView:byName`).  Defaults to choosing among all other windows on the same screen.  Only standard, non-fullscreen windows are offered.
---
--- Returns:
---  * None
function obj:choose(winChoices)
   local win = getGoodFocusedWindow()
   if not win then return end
   local choices={}

   if winChoices then		-- Make sure not to include focused win
      winChoices=hs.fnutils.filter(winChoices,
				   function(w)
				      return w:isStandard() and w~=win and not w:isFullScreen()
      end)
   else
      winChoices=hs.fnutils.filter(win:otherWindowsSameScreen(),
				   function(w) return w:isStandard() and not w:isFullScreen()
      end)
   end
   if not winChoices or #winChoices==0 then
      if self.debug then
	 print("No other window to utilize for Split")
      end
      return
   end 
   if #winChoices==1 then
      if self.debug then
	 print("Obvious split: ",win,winChoices[1])
      end 
      self:performSplit(win,winChoices[1])
      return self
   end
   for _,w in pairs(winChoices) do
      local choice={text=w:title(),
		    subText=w:application():title(),
		    wid=w:id()}
      if self.showImage then choice.image=hs.window.snapshotForID(w:id()) end
      table.insert(choices,choice)
   end

   if not choices then return self end
      
   local chooser=hs.chooser.new(function(choice)
	 if choice then
	    local otherwin=hs.window.find(choice.wid)
	    if otherwin then
	       self:performSplit(win,otherwin)
	    end
	 end 
   end)

   if chooser.placeholderText then
      chooser:placeholderText("SplitView with " .. win:application():title() .. ":" .. win:title())
   end
   chooser:choices(choices)
   chooser:searchSubText(true)
   chooser:subTextColor({hex="#424"})
   chooser:show()
   return self
end 
   
--- SplitView:byName([otherapp,othrewin,noChoose])
--- Method
--- Select an application and window _by name_ to enter split-view along side the currently focused window
--- Useful for creating custom key bindings for specific applications and/or matching window title strings (see `SplitView:bindHotkeys`).  Also useful for calling from the command line (c.f. `hs.ipc.cliInstall`).  E.g., assuming `spoon.splitView` was assigned in your top level as in the example config above:
---   `hs -c "spoon.splitView.byName("Terminal","server1")`
--- would enter split view with the current window and a Terminal window with "server1" in the title.
---
--- Parameters:
---  * `otherapp`: (Optional, String) The (partial) name of the other window's application, or omitted/`nil` for no application filtering
---  * `otherwin`: (Optional, String) The (partial) title of the other window, or omitted/`nil` for no window name filtering
---  * `noChoose`: (Optional, Boolean) By default a chooser window is invoked if more than one window matches. To disable this behavior and always take the first match (if any), pass `true` for this parameter.
---
--- Returns:
---  * None
function obj:byName(otherapp,otherwin,noChoose)
   local win = getGoodFocusedWindow()
   if not win then return end
   local selectWins={}

   if(win:isFullScreen()) then
      win:setFullScreen(false)
      return
   end

   if otherapp then otherapp=hs.application.find(otherapp) end 
   if otherapp then    -- select window from given application
      if otherwin then
	 selectWins={otherapp:findWindow(otherwin)}
      else
	 selectWins=otherapp:allWindows()
      end 
   elseif otherwin then
      selectWins={hs.window.find(otherwin)}
   else
      selectWins=win:otherWindowsSameScreen()
   end

   if self.debug then
      print("byName: ",otherapp,otherwin," found: ",#selectWins," wins")
      for i,v in ipairs(selectWins) do print(i,v) end
   end 
   
   if not selectWins or #selectWins==0 then return end
   if #selectWins==1 or noChoose then 
      self:performSplit(win,selectWins[1])
      return 
   end
   self:choose(selectWins)
end

-- windowAtPosition
-- Internal function: use accessibility tree to find window at the given position
local function windowAtPosition(...)
   local b=ax.systemElementAtPosition(...)
   if not b then return end
   if b.AXRole~="AXWindow" then b=b.AXWindow end
   return b and b:asHSWindow()
end

--  Internal function to perform the simulated split view
--  for two input windows
function obj:performSplit(thiswin,otherwin)
   if not thiswin or not otherwin or thiswin==otherwin then return end
   local clickPoint=thiswin:zoomButtonRect()

   zoom=ax.applicationElement(thiswin:application()):elementAtPosition(clickPoint)

   hsee.newMouseEvent(hsee.types.leftMouseDown, clickPoint):post()
   hst.doAfter(self.delayZoomHold, -- hold green button to activate SV!
	       function()
		  if self.osversion >= "10.15" then -- deal with new popup pane
		     local side=self.tileSide:lower():find('left') and "tileLeft" or "tileRight";
		     for _,child in ipairs(zoom[1]) do
			if child.AXRole == "AXMenuItem" and child.AXIdentifier:find(side) then
			   child:doAXPress()
			   break
			end 
		     end
		  end
		  hsee.newMouseEvent(hsee.types.leftMouseUp, clickPoint):post() 
		  hst.waitUntil(
		     function () return thiswin:isFullscreen() end,
		     function ()
			hst.doAfter(self.delayOtherClick,
				    function()
				       local pos=self:findMiniSplitViewWindow(thiswin,otherwin)
				       if pos then hse.leftClick(pos) end
			end)
		  end, self.checkInterval)
   end)
end


-- SplitView:findSafeDither:
-- Internal Method: Find a safe position near a position to click
-- SplitView mini windows have a several pixel buffer around them,
-- where systemElementAtPosition() sees the window, but the window is not
-- highlighted or clickable.  So use this to probe a 3x3 grid around
-- the found location to look for edges or corners, and select a "safe" point
-- interior to the edge or corner.  The spacing between grid positions
-- must be larger than the width of this "spurious boundary" (so you
-- can't have two hits within it along any direction ).  For very
-- small windows this dither refinement can fail; in that case just
-- return the original coordinates and hope for the best.
function obj:findSafeDither(x,y,targ,targwin)
   local hits={ [-1]={}, [0]={}, [1]={} } -- 3x3 array indexed by -1,0,1
   local hitCnt=0
   local dither=7
   for offy=-1,1,1 do
      local yd=y + dither*offy
      for offx=-1,1,1 do
	 if offx~=0 or offy~=0 then -- skip the middle, it's good
	    local xd=x + dither*offx
	    if not hs.geometry(xd,yd):inside(targ) then
	       hits[offx][offy]=false -- fell off
	    else
	       local dwin=windowAtPosition(xd,yd) -- still on?
	       hits[offx][offy]=(dwin and dwin==targwin)
	    end
	    hitCnt=hitCnt + (hits[offx][offy] and 1 or 0)
	 end
      end
   end
   if     hitCnt==8 then return x,y -- full coverage, take original
   elseif hitCnt==5 then -- edge, take center of the good side
      for _,p in pairs({{0,-1},{1,0},{0,1},{-1,0}}) do
	 if not hits[-p[1]][-p[2]] then -- opposite side out
	    return x + p[1]*dither,y + p[2]*dither
	 end 
      end
   elseif hitCnt==3 then -- corner: take good interior corner
      for offx=-1,1,2 do for offy=-1,1,2 do -- take the good corner
	    if hits[offx][offy] then
	       return x + offx*dither,y + offy*dither
	    end
      end end
   else -- Window too small, just hope for the best
      if self.debug then 
	 print("No refinement found.  Canceling Dither.  Hit Count: ",hitCnt)
      end 
      return x,y
   end 
end

-- SplitView:findMiniSplitViewWindow
-- Internal Method: Find the position of a mini-representation of
-- given target window by tiling the screen and querying for
-- accessibility entities there.
-- Must be called after split view mini-window animation completes.
-- Keeps refining the tiling onto smaller grids until a window is
-- found (up to self.maxRefineIter)
function obj:findMiniSplitViewWindow(thiswin,targwin)   
   local t=hs.timer.absoluteTime()
   local frame=thiswin:screen():fullFrame()
   local targ=hs.geometry(frame.x,frame.y,frame.w/2,frame.h) -- LHS by default
   if thiswin:frame().x==frame.x then targ.x=targ.x + frame.w/2 end -- search RHS
   
   local wcnt=#thiswin:otherWindowsSameScreen() -- total windows to tile
   local n=5 -- starting nxm grid of points
   local m=math.ceil(targ.h/targ.w * n)

   if self.debug then
      print(string.format("SplitView: Tiling %d windows with initial %d x %d grid",
			  wcnt,n,m))
   end 

   local cnt=0
   local jigStep,jiggleSet=0.5, {{0.5,0.5}}

   local iter=0
   while iter<self.maxRefineIter do
      for _,jiggle in pairs(jiggleSet) do 
	 for i=1,n do
	    for j=1,m do
	       local circ
	       local x=targ.x+(i-jiggle[1])*targ.w/n 
	       local y=targ.y+(j-jiggle[2])*targ.h/m
	       cnt=cnt+1
	       
	       if self.debug=="draw" then
		  circ = hs.drawing.circle(hs.geometry.rect(x-6, y-6, 12, 12))
		  circ:setFillColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=0.5})
		  circ:show()
		  hst.doAfter(5,function() circ:delete() end)
	       end 
	       
	       local win=windowAtPosition(x,y)
	       if win and win==targwin then
		  if self.debug then
		     print(string.format("Searched %d locations, matched at x=%0.1f, y=%0.1f"..
					    " (jiggle %0.3f,%0.3f)",
					 cnt,x,y,jiggle[1],jiggle[2]))
		     if self.debug=="draw" then 
			circ:setFillColor({["red"]=0,["blue"]=0,["green"]=1,["alpha"]=0.5})
			circ:show()
		     end 
		  end
		  newx,newy=self:findSafeDither(x,y,targ,targwin) -- take care of edge cases
		  if self.debug and (x~=newx or y~=newy) then
		     print(string.format("Dither-Refined to x=%0.1f, y=%0.1f",newx,newy))
		     if self.debug=="draw" then 
			circ:setTopLeft(x-6,y-6)
			circ:setFillColor({["red"]=0,["blue"]=1,["green"]=1,["alpha"]=0.5})
			circ:show()
		     end 
		  end
		  if self.debug then
		     print(string.format("Completed in %0.3fs",(hs.timer.absoluteTime()-t)/1e9))
		  end
		  if newx and newy then return {x=newx,y=newy} end 
	       end
	    end
	 end
      end
      if self.debug then
	 print(string.format("Failed to match at jiggle %0f, increasing resolution by a factor of 2.",
			     jigStep))
      end
      jigStep=jigStep/2
      jiggleSet=hs.fnutils.mapCat(jiggleSet,-- offset and refine jiggle grid
				  function(p)
				     local t={}
				     for x=-1,1,2 do for y=-1,1,2 do
					   table.insert(t,{p[1]+x*jigStep,p[2]+y*jigStep})
				     end end
				     return t
      end)
      iter=iter+1
   end
   if iter==self.maxRefineIter then
      if self.debug then
	 print("Maximum Iterations Exceeded...")
      end
      hse.keyStroke({},"ESCAPE")	 
   elseif self.degub then
      print("No match found for ",targwin) 
   end
end

obj.arrow=nil
obj.timer=nil
--- SplitView:switchFocus()
--- Method
--- Switch focus from one side of a Split View to another, with an animated arrow showing the switch.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:switchFocus()
   local win = getGoodFocusedWindow()
   if not win or not win:isFullScreen() then return end
   local others=win:otherWindowsSameScreen()
   for _, wto in ipairs(others) do
      if wto:isFullScreen() then
	 wto:focus()

	 local thisWinTopLeft=win:topLeft()
	 local rect=wto:screen():fullFrame()
	 local left=wto:topLeft().x<thisWinTopLeft.x
	 local str= left and "⬅️" or "➡️"
	 local style={size=rect.h/5}
	 local txtSize=hs.drawing.getTextDrawingSize(str,style)

	 -- position it
	 rect.y=rect.y+rect.h/2-txtSize.h/2
	 rect.h=txtSize.h
	 rect.w=txtSize.w
	 if left then
	    rect.x= thisWinTopLeft.x
	 else 
	    rect.x=thisWinTopLeft.x+win:size().w - txtSize.w
	 end 

	 -- Animate a directional arrow
	 if self.arrow then 		-- already animating, stop
	    if self.timer then self.timer:stop() end
	    self.arrow:delete()
	 end
	 self.arrow=hs.drawing.text(rect,str)
	 self.arrow:setTextStyle(style):setAlpha(0.5)
	 local animSteps=1
	 local deltaX=(left and -1 or 1) * txtSize.w/12
	 self.arrow:show()
	 self.timer=hst.doUntil(function() return animSteps>=15 end,
	    function()
	       animSteps=animSteps+1
	       rect.x=rect.x+deltaX
	       self.arrow:setFrame(rect)
	       if animSteps>=15 then
		  self.arrow:delete()
		  self.arrow=nil
	       end 
	    end, 1/40)
	 break
      end
   end
end


-- SplitView:spaceButtons
-- Find the space button list element and return via callback which takes two args:
-- element (the AXList element) and error (non-nil if an error occurred searching)
-- Pass the full frame of the screen of interest and a callback.
function obj:spaceButtonsList(frame,callback)
   self.dockAX:elementSearch(
      function (msg,result,cnt)
	 --print("GOT ",cnt," results"," time: ",result:runTime())
	 local args={}
	 for _,e in ipairs(result) do
	    if hs.geometry(e.AXFrame):inside(frame) then
	       callback(e)
	       return
	    end
	 end
	 callback(nil,'error')
      end,
      ax.searchCriteriaFunction({attribute="AXIdentifier",
				 value="mc.spaces.list"}))
end


-- SplitView:spaceButtons
-- Internal method to find the spaces Buttons at the top of Mission
-- Control using accessibility.  Invoke with MC active, passing the
-- full frame of the screen of interest.  Provide a callback that
-- takes three arguments: newSpaceButton (a single entity), 
-- spaceButtons (a table of buttons, one for each space), and error
-- (non-nil if an error occurred during search)
function obj:spaceButtons(frame,callback)
   self:spaceButtonsList(frame,
			 function(sbl,err)
			    if err then callback(nil,nil,err) end
			    local addSpace
			    for _,sib in ipairs(sbl.AXParent) do 
			       if sib~=e and sib.AXIdentifier=='mc.spaces.add' then
				  addSpace=sib
				  break
			       end
			    end
			    callback(sbl.AXChildren,addSpace)
   end)
end 

--- SplitView:swapWindows
--- Method
--- Swap the two spaces in a full screen split view
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:swapWindows()
   local mousePos=hs.mouse.getAbsolutePosition()
   local win = getGoodFocusedWindow()
   local screen=win:screen()
   local frame=screen:frame()
   local ff=screen:fullFrame()
   if self.debug then
      print("Swapping Windows...")
   end 
   if win:topLeft().x~=frame.x or not win:isFullScreen() then 
      win=hs.fnutils.find(win:otherWindowsSameScreen(),
			  function(w)
			     return w:isFullScreen() and w:topLeft().x==frame.x
      end)
   end
   if not (win and win:isFullScreen()) then return end

   local wframe=win:frame()
   local x,y=wframe.x + wframe.w/2 , frame.y + 2

   clickPoint = win:zoomButtonRect()

   local alreadyDown=clickPoint.y >= frame.y
   local mm=hsee.newEvent():setType(hsee.types.mouseMoved)
   -- Move along top to make the menubar visible
   if not already_down then mm:location({x=x,y=ff.y}):post() end

   local oldy
   hst.waitUntil(
      function() -- wait until the clickPoint settles
	 if alreadyDown then return true end
	 local cp = win:zoomButtonRect()
	 local good=cp.y >= frame.y and cp.y ~= clickPoint.y and oldy and cp.y==oldy
	 oldy=cp.y
	 return good
      end,
      function()
	 hsee.newMouseEvent(hsee.types.leftMouseDown,{x=x,y=y}):post()
	 hst.doAfter(self.checkInterval,
		     function()
			local dragEV=hsee.newEvent():setType(hsee.types.leftMouseDragged)
			for i=0,4,1 do
			   dragEV:location({x=x+i*frame.w/8,y=y}):post()
			end
			hsee.newMouseEvent(hsee.types.leftMouseUp,{x=x+frame.w/2,y=y}):post()
			hst.doAfter(.4,function()
				       mm:location(mousePos):post()
			end)
	 end)
      end, self.checkInterval)
end

--- SplitView:removeCurrentFullScreenDesktop
--- Method
--- Use Mission Control to remove the current full-screen or split-view desktop (aka space) and switch back to the first user space.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:removeCurrentFullScreenDesktop()
   -- screen with cursor in it
   local frame, screen
   local cursor=hs.mouse.getAbsolutePosition()
   for _,s in pairs(hs.screen.allScreens()) do
      frame=s:fullFrame()
      if cursor.x >= frame.x and cursor.x<frame.x + frame.w and
      cursor.y >= frame.y and cursor.y<frame.y + frame.h then
	 screen=s  		-- screen holding our cursor
	 break
      end
   end

   -- current space for this screen, only fullscreen allowed
   local scrID=screen:spacesUUID()
   local space=spaces.spacesByScreenUUID(spaces.masks.currentSpaces)[scrID][1]
   local type=spaces.spaceType(space)
   if not (type==spaces.types.fullscreen or type==spaces.types.tiled) then return end

   -- Open Mission control and determine layout
   hs.application.open("Mission Control")
   local layout=spaces.layout()[scrID]
   local spaceOrder={} 
   for k,v in ipairs(layout) do spaceOrder[v]=k end

   -- Start searching for space buttons
   local closeSpace=nil
   self:spaceButtonsList(frame, function(sbl,error)
			    if error then return end
			    closeSpace=sbl[spaceOrder[space]]
   end)
   

   -- toSpace=spaceButtons[spaceOrder[toSpace]]
   local timeout, timer
   timer=hst.waitUntil( -- wait for MC to finish loading and set AX properties
      function()
	 return closeSpace and closeSpace.doAXRemoveDesktop
      end,
      function ()
	 if self.debug then
	    print("Closing: ",closeSpace.AXDescription)
	 end
	 timeout:stop()
	 closeSpace:doAXRemoveDesktop()
	 hse.keyStroke({},"ESCAPE")	 
      end,self.checkInterval)
   timeout=hst.doAfter(5,function()
			  print("Timed out waiting for Space Close")
			  timer:stop()
   end)
end

--- SplitView:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for SplitView
---
--- Parameters:
---  * mapping - A table containing hotkey details for the following items:
---   * choose - Interactively choose another window to enter split-view with
---   * switchFocus - Switch the split view window focus
---   * removeDesktop - Remove the current fullscreen desktop
---   * chooseApp* - Create one or more special `choose` bindings to choose among only those windows matching a given application string.  In this case, give the app string to match as the last table entry.  E.g. `chooseAppEmacs={{"cmd","ctrl"},"e","Emacs"}`
---   * chooseWin* - Create one or more special `choose` bindings to choose among only those windows matching a given title string.  Give the title string as the last table entry.  E.g. `{chooseWinProj={{"cmd","ctrl"},"p","MyProject"}}`
---   * chooseAppWin* - Create one or more special `choose` bindings to choose among only those applications matching a given string, and windows of that applicaiton matching a given title string.  Give the application string, then title string as the last two table entries. E.g. `{chooseAppWinEmacsProj={{"cmd","ctrl"},"1","Emacs","MyProject"}}
function obj:bindHotkeys(mapping)
   local def = {
      choose = hs.fnutils.partial(self.choose, self),
      switchFocus = hs.fnutils.partial(self.switchFocus, self),
      removeDesktop = hs.fnutils.partial(self.removeCurrentFullScreenDesktop, self),
      swapWindows = hs.fnutils.partial(self.swapWindows, self)
   }
   for k,v in pairs(mapping) do
      if k:sub(1,6)=="choose" and #k>6 then
	 local sub=k:sub(7,9)
	 if sub=="App" then
	    if k:sub(10,12)=="Win" then -- AppWin flavor
	       def[k]=hs.fnutils.partial(self.byName,self,v[3],v[4])
	       table.remove(v)
	       table.remove(v)
	    else --- AppFlavor
	       def[k]=hs.fnutils.partial(self.byName,self,v[3])
	       table.remove(v)
	    end
	 elseif sub=="Win" then
	    def[k]=hs.fnutils.partial(self.byName,self,nil,v[3])
	    table.remove(v)
	 else
	    error("Unrecognized choose* binding: ",k)
	 end 
      end
   end

   hs.spoons.bindHotkeysToSpec(def, mapping)
end

return obj

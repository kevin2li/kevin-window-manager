--- === KevinWindowManager ===
---
--- With this script you will be able to move the window in halves and in corners using your keyboard and mainly using arrows. 
--- 
--- Official homepage for more info and documentation: [https://github.com/kevin2li/kevin-window-manager](https://github.com/kevin2li/kevin-window-manager)
---

local obj={}
local frameCache = {}
obj.__index = obj

-- Metadata
obj.name = "Kevin Window Manager"
obj.version = "0.1"
obj.author = "Kevin <kevin2li@qq.com>"
obj.homepage = "https://github.com/kevin2li/kevin-window-manager"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- current state of the window for 1/2 and 1/4 split mode
-- {
--   -1: "random",
--   0: "maxmized",
--   1: "left",
--   2: "right",
--   3: "top",
--   4: "bottom",
--   5: "top-left",
--   6: "top-right",
--   7: "bottom-left",
--   8: "bottom-right",
-- }
obj._state = -1

-- current state of the window for 1/3 split mode
-- {
--   -1: "random",
--   0: "maxmized",
--   1: "left_1/3",
--   2: "middle_1/3",
--   3: "right_1/3",
--   4: "left_2/3",
--   5: "right_2/3",
-- }
obj._third_state = -1

obj.GRID = {w = 24, h = 24}

obj._pressed = {
  up = false,
  down = false,
  left = false,
  right = false,
  third_left = false,
  third_right = false,
}

function obj:_moveWindowHalfnTo(x, y, w, h)
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    local screen = win:screen()
    cell = hs.grid.get(win, screen)
    print(cell)
    cell.x = self.GRID.w * x
    cell.y = self.GRID.h * y
    cell.w = self.GRID.w * w
    cell.h = self.GRID.h * h
    hs.grid.set(win, cell, screen)
  end
end

function obj:_setMaxmized()
  -- self:_moveWindowHalfnTo(0, 0, 1, 1)
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    win:maximize()
  end
end

function obj:_setMinimized()
  -- self:_moveWindowHalfnTo(0, 0, 1, 1)
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    win:minimize()
  end
end

function obj:_setCentered()
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    win:centerOnScreen()
    frameCache[win:id()] = win:frame()
   end
end

function obj:_setNormalCentered()
  self:_moveWindowHalfnTo(0.1, 0.1, 0.8, 0.8)
end

function obj:_setLastPos()
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    if frameCache[win:id()] then
      local cur_frame = win:frame()
      win:setFrame(frameCache[win:id()])
      frameCache[win:id()] = cur_frame
   else
      frameCache[win:id()] = win:frame()
      self:_moveWindowHalfnTo(0.1, 0.1, 0.8, 0.8)
   end
  end
end

function obj:_setLeftHalf()
  self:_moveWindowHalfnTo(0, 0, 0.5, 1)
end

function obj:_setRightHalf()
  self:_moveWindowHalfnTo(0.5, 0, 0.5, 1)
end

function obj:_setTopHalf()
  self:_moveWindowHalfnTo(0, 0, 1, 0.5)
end

function obj:_setBottomHalf()
  self:_moveWindowHalfnTo(0, 0.5, 1, 0.5)
end

function obj:_setTopLeftQuarter()
  self:_moveWindowHalfnTo(0, 0, 0.5, 0.5)
end

function obj:_setTopRightQuarter()
  self:_moveWindowHalfnTo(0.5, 0, 0.5, 0.5)
end


function obj:_setBottomLeftQuarter()
  self:_moveWindowHalfnTo(0, 0.5, 0.5, 0.5)
end

function obj:_setBottomRightQuarter()
  self:_moveWindowHalfnTo(0.5, 0.5, 0.5, 0.5)
end

function obj:_setLeftThird()
  self:_moveWindowHalfnTo(0, 0, 1/3, 1)
end

function obj:_setMiddleThird()
  self:_moveWindowHalfnTo(1/3, 0, 1/3, 1)
end

function obj:_setRightThird()
  self:_moveWindowHalfnTo(2/3, 0, 1/3, 1)
end

function obj:_setLeftTwoThirds()
  self:_moveWindowHalfnTo(0, 0, 2/3, 1)
end

function obj:_setRightTwoThirds()
  self:_moveWindowHalfnTo(1/3, 0, 2/3, 1)
end


function obj:_moveWindowHalf()
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    cell = hs.grid.get(win)
    if not (cell.x == 0. or cell.x == self.GRID.w / 2) then
      self._state = -1
    end
    if self._pressed.left then 
      if self._pressed.up then
        self:_setTopLeftQuarter()
      elseif self._pressed.down then
          self:_setBottomLeftQuarter()
      else
        -- move window to left side if it's in [random, maxmized, right-half] state
        if self._state == -1 or self._state == 0  or self._state == 2 then
          self:_setLeftHalf()
          self._state = 1
        -- move window to right side if it's in [left-half] state
        elseif self._state == 1 then
          self:_setRightHalf()
          self._state = 2
        -- move window to top-left quarter if it's in [top-half] state
        elseif self._state == 3 then
          self:_setTopLeftQuarter()
          self._state = 5
        elseif self._state == 4 then
          self:_setBottomLeftQuarter()
          self._state = 7
        elseif self._state == 5 then
          self:_setTopRightQuarter()
          self._state = 6
        elseif self._state == 6 then
          self:_setTopHalf()
          self._state = 3
        elseif self._state == 7 then
          self:_setBottomRightQuarter()
          self._state = 8
        elseif self._state == 8 then
          self:_setBottomHalf()
          self._state = 4
        end
      end
    elseif self._pressed.right then
      if self._pressed.up then
        self:_setTopRightQuarter()
      elseif self._pressed.down then
          self:_setBottomRightQuarter()
      else
        -- move window to right side if it's in [random, maxmized, left-half] state
        if self._state == -1 or self._state == 0  or self._state == 1 then
          self:_setRightHalf()
          self._state = 2
        elseif self._state == 2 then
          self:_setLeftHalf()
          self._state = 1
        elseif self._state == 3 then
          self:_setTopRightQuarter()
          self._state = 6
        elseif self._state == 4 then
          self:_setBottomRightQuarter()
          self._state = 8
        elseif self._state == 5 then
          self:_setTopHalf()
          self._state = 3
        elseif self._state == 6 then
          self:_setTopLeftQuarter()
          self._state = 5
        elseif self._state == 7 then
          self:_setBottomHalf()
          self._state = 4
        elseif self._state == 8 then
          self:_setBottomLeftQuarter()
          self._state = 7
        end
      end
    elseif self._pressed.up then
      if self._pressed.left then
        self:_setTopLeftQuarter()
      elseif self._pressed.right then
          self:_setTopRightQuarter()
      else
        -- move window to top-half side if it's in [random, maxmized, bottom-half] state
        if self._state == -1 then
          self:_setMaxmized()
          self._state = 0
        elseif self._state == 0 then
          self:_setTopHalf()
          self._state = 3
        elseif self._state == 1 then
          self:_setTopLeftQuarter()
          self._state = 5
        elseif self._state == 2 then
          self:_setTopRightQuarter()
          self._state = 6
        elseif self._state == 3 then
          self:_setMaxmized()
          self._state = 0
        elseif self._state == 4 then
          self:_setMaxmized()
          self._state = 0
        elseif self._state == 5 then
          self:_setMaxmized()
          self._state = 0
        elseif self._state == 6 then
          self:_setMaxmized()
          self._state = 0
        elseif self._state == 7 then
          self:_setLeftHalf()
          self._state = 1
        elseif self._state == 8 then
          self:_setRightHalf()
          self._state = 2
        end
      end
    elseif self._pressed.down then
      if self._pressed.left then
        self:_setBottomLeftQuarter()
      elseif self._pressed.right then
          self:_setBottomRightQuarter()
      else
        -- move window to bottom-half side if it's in [random, maxmized, top-half] state
        if self._state == -1 then
          self:_setMinimized()
          self._state = -1
        elseif self._state == 0 then
          self:_setNormalCentered()
          self._state = -1
        elseif self._state == 1 then
          self:_setBottomLeftQuarter()
          self._state = 7
        elseif self._state == 2 then
          self:_setBottomRightQuarter()
          self._state = 8
        elseif self._state == 3 then
          self:_setBottomHalf()
          self._state = 4
        elseif self._state == 4 then
          self:_setTopHalf()
          self._state = 3
        elseif self._state == 5 then
          self:_setLeftHalf()
          self._state = 1
        elseif self._state == 6 then
          self:_setRightHalf()
          self._state = 2
        elseif self._state == 7 then
          self:_setTopLeftQuarter()
          self._state = 5
        elseif self._state == 8 then
          self:_setTopRightQuarter()
          self._state = 6
        end
      end
    end
    frameCache[win:id()] = win:frame()
  end
end

function obj:_moveWindowThird()
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    cell = hs.grid.get(win)
    print("cell:", cell.x, cell.y, cell.w, cell.h)
    if self._pressed.third_left then 
      if self._third_state == -1 or self._third_state == 0 then
        self:_setLeftThird()
        self._third_state = 1
      elseif self._third_state == 1 then
        self:_setRightThird()
        self._third_state = 3
      elseif self._third_state == 2 then
        self:_setLeftTwoThirds()
        self._third_state = 4
      elseif self._third_state == 3 then
        self:_setRightTwoThirds()
        self._third_state = 5
      elseif self._third_state == 4 then
        self:_setLeftThird()
        self._third_state = 1
      elseif self._third_state == 5 then
        self:_setMiddleThird()
        self._third_state = 2
      end
    elseif self._pressed.third_right then 
      if self._third_state == -1 or self._third_state == 0 then
        self:_setRightThird()
        self._third_state = 1
      elseif self._third_state == 1 then
        self:_setLeftTwoThirds()
        self._third_state = 4
      elseif self._third_state == 2 then
        self:_setRightTwoThirds()
        self._third_state = 5
      elseif self._third_state == 3 then
        self:_setLeftThird()
        self._third_state = 1
      elseif self._third_state == 4 then
        self:_setMiddleThird()
        self._third_state = 2
      elseif self._third_state == 5 then
        self:_setRightThird()
        self._third_state = 3
      end
    end
    frameCache[win:id()] = win:frame()
  end
end

function obj:bindHotkeys(mapping)
  hs.inspect(mapping)
  print("Bind Hotkeys for Kevin Window Manager")

  hs.hotkey.bind(mapping.left[1], mapping.left[2], function ()
    self._pressed.left = true
    self:_moveWindowHalf()
  end, function () 
    self._pressed.left = false
  end)

  hs.hotkey.bind(mapping.right[1], mapping.right[2], function ()
    self._pressed.right = true
    self:_moveWindowHalf()
  end, function () 
    self._pressed.right = false
  end)

  hs.hotkey.bind(mapping.up[1], mapping.up[2], function ()
    self._pressed.up = true
    self:_moveWindowHalf()
  end, function () 
    self._pressed.up = false
  end)

  hs.hotkey.bind(mapping.down[1], mapping.down[2], function ()
    self._pressed.down = true
    self:_moveWindowHalf()
  end, function () 
    self._pressed.down = false
  end)

  hs.hotkey.bind(mapping.fullscreen[1], mapping.fullscreen[2], function ()
    self:_setMaxmized()
  end, function () 
  end)
  
  hs.hotkey.bind(mapping.fullscreen[1], mapping.fullscreen[2], function ()
    self:_setMaxmized()
  end, function () 
  end)
  
  hs.hotkey.bind(mapping.center[1], mapping.center[2], function ()
    self:_setCentered()
  end, function () 
  end)
  
  hs.hotkey.bind(mapping.recover[1], mapping.recover[2], function ()
    self:_setLastPos()
  end, function () 
  end)

  hs.hotkey.bind(mapping.third_left[1], mapping.third_left[2], function ()
    self._pressed.third_left = true
    self:_moveWindowThird()
  end, function () 
    self._pressed.third_left = false
  end)

  hs.hotkey.bind(mapping.third_right[1], mapping.third_right[2], function ()
    self._pressed.third_right = true
    self:_moveWindowThird()
  end, function () 
    self._pressed.third_right = false
  end)
end

function obj:init()
  print("Initializing Kevin Window Manager")
  hs.grid.setGrid(obj.GRID.w .. 'x' .. obj.GRID.h)
  hs.grid.MARGINX = 0
  hs.grid.MARGINY = 0
end

return obj

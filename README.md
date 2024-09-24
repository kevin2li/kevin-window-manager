# Kevin Window Manager

## Description

Kevin Window Manager is a window manager based on [Hammerspoon](https://www.hammerspoon.org/) that implements window management operations similar to those on Windows. It allows for quick use of shortcuts to achieve split-screen in half, 1/4 split-screen, full-screen, and window centering.

## Installation

```lua
hs.loadSpoon("KevinWindowsManager")

local hyper = {"ctrl", "alt"}
spoon.KevinWindowsManager:bindHotkeys({
  up = {hyper, "up"},
  right = {hyper, "right"},
  down = {hyper, "down"},
  left = {hyper, "left"},
  fullscreen = {hyper, "f"},
  center = {hyper, "c"},
  recover = {hyper, "r"},
  third_left = {hyper, "["},
  third_right = {hyper, "]"},
})
```
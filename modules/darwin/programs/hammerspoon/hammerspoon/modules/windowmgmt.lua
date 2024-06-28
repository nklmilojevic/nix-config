hs.loadSpoon('MiroWindowsManager')

local hyper = { 'ctrl', 'alt', 'cmd', 'shift' }

hs.window.animationDuration = 0
spoon.MiroWindowsManager:bindHotkeys({
  up = { hyper, 'up' },
  right = { hyper, 'right' },
  down = { hyper, 'down' },
  left = { hyper, 'left' },
  fullscreen = { hyper, 'return' },
  nextscreen = { hyper, 'n' },
})

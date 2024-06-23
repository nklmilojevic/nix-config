local SkyRocket = hs.loadSpoon('SkyRocket')

sky = SkyRocket:new({
  -- Opacity of resize canvas
  opacity = 0.3,
  -- Which modifiers to hold to move a window?
  moveModifiers = { 'cmd', 'shift' },
  -- Which mouse button to hold to move a window?
  moveMouseButton = 'left',
  -- Which modifiers to hold to resize a window?
  resizeModifiers = { 'ctrl', 'shift' },
  -- Which mouse button to hold to resize a window?
  resizeMouseButton = 'left',
})

-- Cmd+Shift+Y: Focus Ghostty, open a bottom split, and run yazi
hs.hotkey.bind({"cmd", "shift"}, "y", function()
  local ghostty = hs.application.find("Ghostty")
  if not ghostty then
    return
  end

  ghostty:activate()

  hs.timer.doAfter(0.1, function()
    -- Cmd+Shift+D creates a bottom split in Ghostty (inherits current directory)
    hs.eventtap.keyStroke({"cmd", "shift"}, "d")

    hs.timer.doAfter(0.3, function()
      hs.eventtap.keyStrokes("yazi")
      hs.eventtap.keyStroke({}, "return")
    end)
  end)
end)

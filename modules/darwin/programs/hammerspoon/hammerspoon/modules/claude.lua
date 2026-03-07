-- Cmd+Shift+C: Focus Ghostty, open a right split, and run claude code
hs.hotkey.bind({"cmd", "shift"}, "c", function()
  local ghostty = hs.application.find("Ghostty")
  if not ghostty then
    return
  end

  ghostty:activate()

  hs.timer.doAfter(0.1, function()
    -- Cmd+D creates a right split in Ghostty (inherits current directory)
    hs.eventtap.keyStroke({"cmd"}, "d")

    hs.timer.doAfter(0.3, function()
      hs.eventtap.keyStrokes("ccc")
      hs.eventtap.keyStroke({}, "return")
    end)
  end)
end)

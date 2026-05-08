local M = {}

local primaryIface = nil
local lastIn, lastOut, lastT = 0, 0, 0
local rateIn, rateOut = 0, 0
local procCache = {}
local procTask = nil

local function detectPrimaryIface()
  local out = hs.execute("/sbin/route -n get default 2>/dev/null | /usr/bin/awk '/interface:/ {print $2}'")
  if out then primaryIface = out:match("(%w+)") end
end

local function readBytes()
  if not primaryIface then return nil, nil end
  local cmd = string.format(
    "/usr/sbin/netstat -ibn | /usr/bin/awk '$1==\"%s\" {print $7, $10; exit}'",
    primaryIface
  )
  local out = hs.execute(cmd)
  if not out then return nil, nil end
  local i, o = out:match("(%d+)%s+(%d+)")
  if not i then return nil, nil end
  return tonumber(i), tonumber(o)
end

local function fmt(bps)
  if bps < 1024 then return "0 KB/s" end
  if bps < 1024 * 1024 then return string.format("%.0f KB/s", bps / 1024) end
  return string.format("%.1f MB/s", bps / 1024 / 1024)
end

local menubar = hs.menubar.new(true, "netstats")
menubar:setTitle("")

local titleW, titleH = 64, 22
local titleCanvas = hs.canvas.new({ x = 0, y = 0, w = titleW, h = titleH })
local DOWNCOL_T = { red = 0.40, green = 0.70, blue = 1.00, alpha = 1 }
local UPCOL_T = { red = 0.95, green = 0.45, blue = 0.45, alpha = 1 }
local TXT_T = { white = 0.95 }

local function renderTitle()
  titleCanvas:replaceElements(
    {
      type = "oval", action = "fill", fillColor = DOWNCOL_T,
      frame = { x = 2, y = 5, w = 4, h = 4 },
    },
    {
      type = "oval", action = "fill", fillColor = UPCOL_T,
      frame = { x = 2, y = 14, w = 4, h = 4 },
    },
    {
      type = "text", text = fmt(rateIn),
      textFont = ".AppleSystemUIFontMonospaced", textSize = 10, textColor = TXT_T,
      frame = { x = 8, y = 1, w = titleW - 10, h = 11 }, textAlignment = "right",
    },
    {
      type = "text", text = fmt(rateOut),
      textFont = ".AppleSystemUIFontMonospaced", textSize = 10, textColor = TXT_T,
      frame = { x = 8, y = 11, w = titleW - 10, h = 11 }, textAlignment = "right",
    }
  )
  menubar:setIcon(titleCanvas:imageFromCanvas(), false)
end

local function tick()
  if not primaryIface then detectPrimaryIface() end
  local now = hs.timer.secondsSinceEpoch()
  local i, o = readBytes()
  if i and lastIn > 0 and now > lastT then
    local dt = now - lastT
    rateIn = math.max(0, (i - lastIn) / dt)
    rateOut = math.max(0, (o - lastOut) / dt)
  end
  if i then lastIn, lastOut, lastT = i, o, now end
  renderTitle()
end

M.titleTimer = hs.timer.new(1, tick)
M.titleTimer:start()
tick()

local function parseNettop(stdout)
  local samples = { {} }
  for line in stdout:gmatch("[^\n]+") do
    if line:match("^time,") then
      if next(samples[#samples]) then samples[#samples + 1] = {} end
    else
      local _, key, bin, bout = line:match("^([^,]+),([^,]+),(%d+),(%d+)")
      if key then
        samples[#samples][key] = { bin = tonumber(bin), bout = tonumber(bout) }
      end
    end
  end
  if #samples < 2 then return {} end
  local first, last = samples[1], samples[#samples]
  local procs = {}
  for key, v2 in pairs(last) do
    local v1 = first[key] or { bin = v2.bin, bout = v2.bout }
    local din = math.max(0, v2.bin - v1.bin)
    local dout = math.max(0, v2.bout - v1.bout)
    if din > 0 or dout > 0 then
      local name = key:gsub("%.%d+$", "")
      table.insert(procs, { name = name, bin = din, bout = dout })
    end
  end
  table.sort(procs, function(a, b) return (a.bin + a.bout) > (b.bin + b.bout) end)
  return procs
end

local function refreshProcs()
  if procTask and procTask:isRunning() then return end
  procTask = hs.task.new("/usr/bin/nettop", function(_, stdout)
    if stdout then procCache = parseNettop(stdout) end
  end, { "-P", "-x", "-J", "bytes_in,bytes_out", "-L", "2", "-s", "1", "-n" })
  procTask:start()
end

M.procTimer = hs.timer.new(3, refreshProcs)
M.procTimer:start()
refreshProcs()

-- Live panel
local panelW = 320
local rowCount = 8
local rowH = 22
local headerH = 30
local subH = 18
local padX = 16
local padY = 14
local panelH = padY + headerH + 12 + subH + rowCount * rowH + padY + 18

local panel = nil
local panelTimer = nil
local panelTap = nil
local idx = { rateDown = nil, rateUp = nil, footer = nil, rows = {} }

local function buildPanel()
  local p = hs.canvas.new({ x = 0, y = 0, w = panelW, h = panelH })
  p:behavior({ "canJoinAllSpaces", "stationary" })
  p:level(hs.canvas.windowLevels.popUpMenu)
  p:clickActivating(false)

  local TEXT = { white = 0.92 }
  local DIM = { white = 0.55 }
  local UPCOL = { red = 0.95, green = 0.45, blue = 0.45, alpha = 1 }
  local DOWNCOL = { red = 0.40, green = 0.70, blue = 1.00, alpha = 1 }
  local FONT = ".AppleSystemUIFont"
  local MONO = ".AppleSystemUIFontMonospaced"

  -- background
  p[1] = {
    type = "rectangle",
    action = "fill",
    fillColor = { red = 0.10, green = 0.10, blue = 0.12, alpha = 0.96 },
    roundedRectRadii = { xRadius = 22, yRadius = 22 },
  }
  -- header download
  p[2] = {
    type = "text",
    text = "↓ 0 KB/s",
    textFont = FONT,
    textSize = 18,
    textColor = DOWNCOL,
    frame = { x = padX, y = padY, w = (panelW - 2 * padX) / 2, h = headerH },
  }
  idx.rateDown = 2
  -- header upload
  p[3] = {
    type = "text",
    text = "↑ 0 KB/s",
    textFont = FONT,
    textSize = 18,
    textColor = UPCOL,
    textAlignment = "right",
    frame = { x = padX + (panelW - 2 * padX) / 2, y = padY, w = (panelW - 2 * padX) / 2, h = headerH },
  }
  idx.rateUp = 3
  -- divider
  p[4] = {
    type = "segments",
    coordinates = { { x = padX, y = padY + headerH + 4 }, { x = panelW - padX, y = padY + headerH + 4 } },
    strokeColor = { white = 0.18 },
    strokeWidth = 1,
    action = "stroke",
  }
  -- subheader
  p[5] = {
    type = "text",
    text = "TOP PROCESSES",
    textFont = FONT,
    textSize = 10,
    textColor = DIM,
    frame = { x = padX, y = padY + headerH + 12, w = panelW - 2 * padX, h = subH },
  }

  local rowsTop = padY + headerH + 12 + subH + 4
  for i = 1, rowCount do
    local y = rowsTop + (i - 1) * rowH
    local nameIdx = #p + 1
    p[nameIdx] = {
      type = "text",
      text = "",
      textFont = FONT,
      textSize = 12,
      textColor = TEXT,
      frame = { x = padX, y = y, w = 140, h = rowH },
    }
    local dinIdx = #p + 1
    p[dinIdx] = {
      type = "text",
      text = "",
      textFont = MONO,
      textSize = 11,
      textColor = DOWNCOL,
      textAlignment = "right",
      frame = { x = padX + 140, y = y + 2, w = 70, h = rowH },
    }
    local doutIdx = #p + 1
    p[doutIdx] = {
      type = "text",
      text = "",
      textFont = MONO,
      textSize = 11,
      textColor = UPCOL,
      textAlignment = "right",
      frame = { x = panelW - padX - 70, y = y + 2, w = 70, h = rowH },
    }
    table.insert(idx.rows, { name = nameIdx, din = dinIdx, dout = doutIdx })
  end

  -- footer
  local footerIdx = #p + 1
  p[footerIdx] = {
    type = "text",
    text = "",
    textFont = FONT,
    textSize = 10,
    textColor = DIM,
    frame = { x = padX, y = panelH - padY - 12, w = panelW - 2 * padX, h = 14 },
  }
  idx.footer = footerIdx

  return p
end

local function refreshPanel()
  if not panel then return end
  panel[idx.rateDown].text = "↓ " .. fmt(rateIn)
  panel[idx.rateUp].text = "↑ " .. fmt(rateOut)
  for i, row in ipairs(idx.rows) do
    local p = procCache[i]
    if p then
      panel[row.name].text = p.name
      panel[row.din].text = fmt(p.bin)
      panel[row.dout].text = fmt(p.bout)
    else
      panel[row.name].text = ""
      panel[row.din].text = ""
      panel[row.dout].text = ""
    end
  end
  panel[idx.footer].text = "Interface: " .. (primaryIface or "?")
end

local function hidePanel()
  if panel then panel:hide() end
  if panelTimer then panelTimer:stop() end
  if panelTap then panelTap:stop(); panelTap = nil end
end

local function showPanel()
  if not panel then panel = buildPanel() end
  local f = menubar:frame()
  local x = f.x + f.w / 2 - panelW / 2
  local y = f.y + f.h + 4
  panel:topLeft({ x = x, y = y })
  refreshProcs()
  refreshPanel()
  panel:show()
  if not panelTimer then
    panelTimer = hs.timer.new(1, function()
      tick()
      refreshProcs()
      refreshPanel()
    end)
  end
  panelTimer:start()
  panelTap = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function()
    local pt = hs.mouse.absolutePosition()
    local pf = panel:frame()
    local mf = menubar:frame()
    local insidePanel = pt.x >= pf.x and pt.x <= pf.x + pf.w and pt.y >= pf.y and pt.y <= pf.y + pf.h
    local onIcon = pt.x >= mf.x and pt.x <= mf.x + mf.w and pt.y >= mf.y and pt.y <= mf.y + mf.h
    if not insidePanel and not onIcon then hidePanel() end
    return false
  end)
  panelTap:start()
end

menubar:setClickCallback(function()
  if panel and panel:isShowing() then
    hidePanel()
  else
    showPanel()
  end
end)

M.menubar = menubar
M.showPanel = showPanel
M.hidePanel = hidePanel
M.getProcs = function() return procCache end

return M

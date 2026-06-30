-- SF Symbol loader for Hammerspoon menubar icons.
--
-- hs.image.imageFromName doesn't reliably resolve SF Symbol names on this
-- HS/macOS combo, so we shell out to a tiny Swift renderer that writes the
-- symbol to a PNG, cache it on disk, and load with hs.image.imageFromPath.
--
-- First call per (name,size,weight,color) costs ~1s (swift startup). After
-- that the cache hit is instant.
--
-- Usage:
--   local sf = require("modules/sf-symbols")
--
--   -- "active" style: render in default color, use template = true so macOS
--   -- repaints to current menubar foreground (white in dark, black in light).
--   local active = sf.symbol("bell.fill", { size = 18 })
--   menubar:setIcon(active, true)
--
--   -- "idle" style: render in fixed gray, use template = false so the gray
--   -- pixels are preserved.
--   local idle = sf.symbol("bell.fill", { size = 18, color = "gray" })
--   menubar:setIcon(idle, false)

local M = {}

local CACHE_DIR = os.getenv("HOME") .. "/.cache/hammerspoon/sf-symbols"
local RENDERER = CACHE_DIR .. "/render.swift"

local SWIFT_RENDERER = [==[
import AppKit

let args = CommandLine.arguments
guard args.count >= 6 else {
    FileHandle.standardError.write("usage: render.swift NAME SIZE WEIGHT COLOR OUT\n".data(using: .utf8)!)
    exit(1)
}

let name = args[1]
let pointSize = Double(args[2]) ?? 16.0
let weightName = args[3]
let colorName = args[4]
let outPath = args[5]

guard let img = NSImage(systemSymbolName: name, accessibilityDescription: nil) else {
    FileHandle.standardError.write("symbol not found: \(name)\n".data(using: .utf8)!)
    exit(2)
}

let weights: [String: NSFont.Weight] = [
    "thin": .thin, "light": .light, "regular": .regular,
    "medium": .medium, "semibold": .semibold, "bold": .bold,
    "heavy": .heavy, "black": .black,
]
let weight = weights[weightName] ?? .regular

var config = NSImage.SymbolConfiguration(pointSize: CGFloat(pointSize), weight: weight)

let colors: [String: NSColor] = [
    "gray": .gray,
    "secondaryLabel": .secondaryLabelColor,
    "white": .white,
    "black": .black,
    "red": .systemRed,
    "orange": .systemOrange,
    "green": .systemGreen,
    "blue": .systemBlue,
]

if !colorName.isEmpty, let color = colors[colorName] {
    if #available(macOS 12.0, *) {
        config = config.applying(NSImage.SymbolConfiguration(paletteColors: [color]))
    }
}

let configured = img.withSymbolConfiguration(config) ?? img

// Render into an explicit bitmap context so we control the pixel dimensions.
// We render at 2x the logical size for retina sharpness, then label the
// bitmap's logical size at 1x (so consumers display it at the requested
// point size while keeping high-DPI pixel density).
let logicalSize = configured.size
let scale: CGFloat = 2.0
let pixelW = Int(logicalSize.width * scale)
let pixelH = Int(logicalSize.height * scale)

guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: pixelW,
    pixelsHigh: pixelH,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 32
) else {
    FileHandle.standardError.write("failed to create bitmap\n".data(using: .utf8)!)
    exit(3)
}
bitmap.size = logicalSize  // logical points (consumers see this as the size)

guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
    FileHandle.standardError.write("failed to create graphics context\n".data(using: .utf8)!)
    exit(4)
}
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context
configured.draw(in: NSRect(origin: .zero, size: logicalSize),
                from: .zero,
                operation: .sourceOver,
                fraction: 1.0)
NSGraphicsContext.restoreGraphicsState()

guard let png = bitmap.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write("failed to render PNG\n".data(using: .utf8)!)
    exit(5)
}
try? png.write(to: URL(fileURLWithPath: outPath))
]==]

local function shellEscape(s)
	return "'" .. (s or ""):gsub("'", "'\\''") .. "'"
end

local function safeName(name)
	return (name:gsub("[^%w%.]", "_"))
end

local function cachePath(name, size, weight, color)
	local colorPart = (color and color ~= "") and color or "default"
	return string.format("%s/%s-%s-%s-%s.png", CACHE_DIR, safeName(name), size, weight, colorPart)
end

-- Always (re)write the renderer at module load so updates take effect on
-- Hammerspoon reload without manual cache busting.
local function writeRenderer()
	hs.execute("mkdir -p " .. shellEscape(CACHE_DIR))
	local out = io.open(RENDERER, "w")
	if not out then
		return false
	end
	out:write(SWIFT_RENDERER)
	out:close()
	return true
end
writeRenderer()

-- Returns hs.image at the requested SF Symbol point size, or nil if the
-- symbol can't be rendered. The renderer writes a bitmap at 2× density so
-- retina screens stay sharp, with the bitmap's logical size labelled at 1×.
--
-- opts.size: SF Symbol point size (default 14, which is what SwiftBar uses
--            and what looks right in the macOS menubar)
function M.symbol(name, opts)
	opts = opts or {}
	local pointSize = opts.size or 14
	local weight = opts.weight or "regular"
	local color = opts.color or ""
	local path = cachePath(name, pointSize, weight, color)

	if not hs.fs.attributes(path) then
		local cmd = string.format(
			"/usr/bin/swift %s %s %d %s %s %s 2>/dev/null",
			shellEscape(RENDERER),
			shellEscape(name),
			pointSize,
			shellEscape(weight),
			shellEscape(color),
			shellEscape(path)
		)
		hs.execute(cmd)
	end

	if not hs.fs.attributes(path) then
		return nil
	end
	return hs.image.imageFromPath(path)
end

return M

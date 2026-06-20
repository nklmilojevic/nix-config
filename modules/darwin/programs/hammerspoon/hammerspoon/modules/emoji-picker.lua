-- Fast emoji grid picker. Custom hs.webview UI (Tahoe-style rounded panel,
-- blurred background, 9-col emoji grid) with all scoring done in-page so
-- per-keystroke ranking stays inside WebKit.

local hyper = { "ctrl", "alt", "cmd", "shift" }
local RECENTS_KEY = "emojiPickerRecents"
local RECENTS_MAX = 40
local WIDTH = 560
local HEIGHT = 460

local function loadEmojiJson()
	local path = hs.configdir .. "/data/emojis.json"
	local f = assert(io.open(path, "r"), "emoji-picker: cannot open " .. path)
	local data = f:read("*a")
	f:close()
	return data
end
local EMOJI_JSON = loadEmojiJson()

local function getRecents()
	return hs.settings.get(RECENTS_KEY) or {}
end

local function bumpRecent(alias)
	local r = getRecents()
	for i, a in ipairs(r) do
		if a == alias then
			table.remove(r, i)
			break
		end
	end
	table.insert(r, 1, alias)
	while #r > RECENTS_MAX do
		r[#r] = nil
	end
	hs.settings.set(RECENTS_KEY, r)
end

local CSS = [[
:root {
  color-scheme: dark;
  font-family: -apple-system, "SF Pro Text", system-ui, sans-serif;
  -webkit-user-select: none; user-select: none;
}
* { margin: 0; padding: 0; box-sizing: border-box; }
html { overflow: hidden; height: 100%; }
body {
  height: 100%;
  background: transparent;
  padding: 14px;
  overflow: visible;
}
.frame {
  width: 100%; height: 100%;
  background: rgba(38, 38, 40, 0.78);
  -webkit-backdrop-filter: blur(48px) saturate(180%);
  backdrop-filter: blur(48px) saturate(180%);
  border-radius: 22px;
  border: 0.5px solid rgba(255,255,255,0.10);
  box-shadow: 0 6px 18px rgba(0,0,0,0.30);
  display: flex; flex-direction: column;
  overflow: hidden;
}
input.search {
  background: transparent; border: none; outline: none;
  color: white;
  font-size: 17px; font-weight: 400;
  padding: 16px 20px 12px;
  caret-color: rgba(255,255,255,0.85);
}
input.search::placeholder { color: rgba(255,255,255,0.30); }
.grid {
  flex: 1;
  display: grid;
  grid-template-columns: repeat(9, 1fr);
  gap: 4px;
  padding: 4px 12px 12px;
  overflow-y: auto;
  align-content: start;
  scrollbar-gutter: stable;
}
.cell {
  display: flex; align-items: center; justify-content: center;
  height: 48px;
  font-size: 30px;
  line-height: 1;
  border-radius: 10px;
  cursor: default;
}
.cell.selected { background: rgba(0, 122, 255, 0.85); }
.empty {
  grid-column: 1 / -1;
  color: rgba(255,255,255,0.32);
  text-align: center;
  padding: 32px 0;
  font-size: 13px;
}
.grid::-webkit-scrollbar { width: 6px; }
.grid::-webkit-scrollbar-thumb {
  background: rgba(255,255,255,0.12);
  border-radius: 3px;
}
.grid::-webkit-scrollbar-track { background: transparent; }
]]

local JS = [[
const EMOJIS = __EMOJI_JSON__;
let RECENTS = __RECENTS_JSON__;
const aliasIdx = new Map();
EMOJIS.forEach(e => { e.nameWords = e.n.split(/\s+/); aliasIdx.set(e.a, e); });

function sharedPrefixLen(a,b){const n=Math.min(a.length,b.length);for(let i=0;i<n;i++)if(a[i]!==b[i])return i;return n;}
function stemMatch(t,k){if(t.length<4||k.length<4)return false;const s=sharedPrefixLen(t,k);return s>=4&&s*10>=Math.min(t.length,k.length)*8;}
function pfx(t){return t.length>=4;}
function tokenScore(e,t){
  let b=0;
  if(e.n===t)b=100;
  for(const w of e.nameWords){
    if(w===t){if(b<80)b=80;}
    else if(pfx(t)&&w.startsWith(t)){if(b<50)b=50;}
    else if(stemMatch(t,w)){if(b<40)b=40;}
    else if(pfx(t)&&w.includes(t)){if(b<25)b=25;}
  }
  if(e.a===t){if(b<70)b=70;}
  else if(pfx(t)&&e.a.startsWith(t)){if(b<40)b=40;}
  else if(stemMatch(t,e.a)){if(b<30)b=30;}
  else if(pfx(t)&&e.a.includes(t)){if(b<18)b=18;}
  if(e.k)for(const k of e.k){
    if(k===t){if(b<70)b=70;}
    else if(pfx(t)&&k.startsWith(t)){if(b<45)b=45;}
    else if(stemMatch(t,k)){if(b<35)b=35;}
    else if(pfx(t)&&k.includes(t)){if(b<15)b=15;}
  }
  return b;
}
function search(q){
  q=q.toLowerCase().trim();
  if(!q)return [];
  const toks=q.split(/\s+/);
  const N=EMOJIS.length;
  const freq=toks.map(()=>0);
  const rs=new Array(N);
  for(let i=0;i<N;i++){
    const s=new Array(toks.length);
    for(let t=0;t<toks.length;t++){
      const v=tokenScore(EMOJIS[i],toks[t]);
      s[t]=v;
      if(v>0)freq[t]++;
    }
    rs[i]=s;
  }
  const idf=freq.map(f=>f>0?Math.log(N/f)+1:0);
  const out=[];
  for(let i=0;i<N;i++){
    let raw=0,m=0;
    for(let t=0;t<toks.length;t++){
      if(rs[i][t]>0){raw+=rs[i][t]*idf[t];m++;}
    }
    if(raw>0){const c=m/toks.length;out.push({e:EMOJIS[i],score:raw*c*c});}
  }
  out.sort((a,b)=>b.score-a.score);
  return out.slice(0,80).map(x=>x.e);
}

const COLS = 9;
const $input = document.querySelector('input.search');
const $grid = document.querySelector('.grid');
let current = [];
let selected = 0;

function defaultList(){
  const out = RECENTS.map(a => aliasIdx.get(a)).filter(Boolean);
  const seen = new Set(out.map(e => e.a));
  for(const e of EMOJIS){
    if(seen.has(e.a)) continue;
    out.push(e);
    if(out.length >= 200) break;
  }
  return out;
}

function render(keepSelectedVisible){
  if(current.length === 0){
    $grid.innerHTML = '<div class="empty">no matches</div>';
    return;
  }
  const html = current.map((e,i) =>
    `<div class="cell${i===selected?' selected':''}" data-i="${i}" title="${e.n}">${e.c}</div>`
  ).join('');
  $grid.innerHTML = html;
  if(keepSelectedVisible){
    const sel = $grid.querySelector('.cell.selected');
    if(sel) sel.scrollIntoView({block:'nearest'});
  }
}

function update(){
  const q = $input.value;
  current = q.trim() ? search(q) : defaultList();
  if(selected >= current.length) selected = Math.max(0, current.length-1);
  if(selected < 0) selected = 0;
  render(false);
  $grid.scrollTop = 0;
}

function move(dx, dy){
  if(current.length === 0) return;
  let row = Math.floor(selected/COLS);
  let col = selected % COLS;
  col += dx; row += dy;
  if(col < 0){ col = COLS-1; row -= 1; }
  if(col >= COLS){ col = 0; row += 1; }
  let next = row*COLS + col;
  if(next < 0) next = 0;
  if(next >= current.length) next = current.length - 1;
  selected = next;
  render(true);
}

function pick(){
  const e = current[selected];
  if(!e) return;
  window.webkit.messageHandlers.emojiPicker.postMessage({action:'pick', char:e.c, alias:e.a});
}
function cancel(){
  window.webkit.messageHandlers.emojiPicker.postMessage({action:'cancel'});
}

document.addEventListener('keydown', (e) => {
  if(e.key === 'Escape'){ e.preventDefault(); cancel(); return; }
  if(e.key === 'Enter'){ e.preventDefault(); pick(); return; }
  if(e.key === 'ArrowLeft'){ e.preventDefault(); move(-1,0); return; }
  if(e.key === 'ArrowRight'){ e.preventDefault(); move(1,0); return; }
  if(e.key === 'ArrowUp'){ e.preventDefault(); move(0,-1); return; }
  if(e.key === 'ArrowDown'){ e.preventDefault(); move(0,1); return; }
  if(document.activeElement !== $input && e.key.length === 1 && !e.metaKey && !e.ctrlKey && !e.altKey){
    $input.focus();
  }
});
$input.addEventListener('input', () => { selected = 0; update(); });
$grid.addEventListener('click', (e) => {
  const cell = e.target.closest('.cell');
  if(!cell) return;
  selected = parseInt(cell.dataset.i, 10);
  pick();
});

window.setRecents = (recentsList) => { RECENTS = recentsList || RECENTS; };
window.resetUI = () => {
  $input.value = '';
  selected = 0;
  update();
  $input.focus();
  $input.select();
};

update();
requestAnimationFrame(() => requestAnimationFrame(() => {
  window.webkit.messageHandlers.emojiPicker.postMessage({action:'ready'});
  $input.focus();
}));
]]

local function buildHtml()
	local recentsJson = hs.json.encode(getRecents())
	local js = JS:gsub("__EMOJI_JSON__", function()
		return EMOJI_JSON
	end):gsub("__RECENTS_JSON__", function()
		return recentsJson
	end)
	return [[<!DOCTYPE html><html><head><meta charset="utf-8"><style>]]
		.. CSS
		.. [[</style></head><body><div class="frame"><input class="search" type="text" placeholder="search emoji" autofocus><div class="grid"></div></div><script>]]
		.. js
		.. [[</script></body></html>]]
end

local prevApp
local userContent = hs.webview.usercontent.new("emojiPicker")
local webview
local cachedHsWindow
local isShown = false
local isReady = false
local warming = false
local mapped = false
-- hs.timer objects are garbage-collected (and never fire) unless referenced;
-- a collected park timer leaves the invisible webview mapped at screen
-- center, silently swallowing clicks.
local primeTimer, parkTimer, wakeWarmupTimer, typeTimer

local OFFSCREEN = { x = -20000, y = -20000, w = WIDTH, h = HEIGHT }

local function rectForFocusedScreen()
	local screen = hs.screen.mainScreen():frame()
	return {
		x = screen.x + (screen.w - WIDTH) / 2,
		y = screen.y + (screen.h - HEIGHT) / 3,
		w = WIDTH,
		h = HEIGHT,
	}
end

local function parkWebview()
	if not webview then
		return
	end
	webview:alpha(0)
	webview:frame(OFFSCREEN)
end

local function createWebview()
	isReady = false
	mapped = false
	cachedHsWindow = nil
	webview = hs.webview
		.new(rectForFocusedScreen(), { developerExtrasEnabled = false }, userContent)
		:windowStyle({ "borderless" })
		:allowTextEntry(true)
		:transparent(true)
		:allowGestures(false)
		:allowMagnificationGestures(false)
		:allowNewWindows(false)
		:shadow(false)
		:alpha(0)
		:html(buildHtml())

	webview:windowCallback(function(action, _, focused)
		if action == "focusChange" and focused == false and isShown then
			isShown = false
			parkWebview()
		end
	end)
end

local function ensureWebview()
	if not webview then
		createWebview()
	end
	return webview
end

local function rebuildWebview()
	if webview then
		webview:delete()
		webview = nil
	end
	mapped = false
	cachedHsWindow = nil
	createWebview()
end

local function getHsWindow()
	if not webview then
		return nil
	end
	if cachedHsWindow then
		return cachedHsWindow
	end
	cachedHsWindow = webview:hswindow()
	return cachedHsWindow
end

local function activateHammerspoon()
	local apps = hs.application.applicationsForBundleID("org.hammerspoon.Hammerspoon")
	if apps and apps[1] then
		apps[1]:activate(true)
	end
end

local function hideOnly()
	if not webview or not isShown then
		return
	end
	isShown = false
	parkWebview()
end

local function dismiss()
	hideOnly()
	if prevApp and prevApp:isRunning() then
		prevApp:activate()
	end
end

local function commit(char, alias)
	if alias then
		bumpRecent(alias)
		ensureWebview():evaluateJavaScript(
			"if(window.setRecents)setRecents(" .. hs.json.encode(getRecents()) .. ");"
		)
	end
	hideOnly()
	if prevApp and prevApp:isRunning() then
		prevApp:activate()
	end
	typeTimer = hs.timer.doAfter(0.06, function()
		hs.eventtap.keyStrokes(char)
	end)
end

local function lap(t0, label)
	local ms = (hs.timer.secondsSinceEpoch() - t0) * 1000
	print(string.format("[emoji-picker] %-22s %6.1f ms", label, ms))
	return hs.timer.secondsSinceEpoch()
end

local function focusShownWebview()
	if not webview then
		return
	end
	local t = hs.timer.secondsSinceEpoch()
	webview:bringToFront(true)
	t = lap(t, "bringToFront")
	local hsw = getHsWindow()
	t = lap(t, "getHsWindow")
	if hsw then
		hsw:raise()
		t = lap(t, "hsw:raise")
		hsw:focus()
		t = lap(t, "hsw:focus")
	end
	webview:evaluateJavaScript("if(window.resetUI)resetUI();")
	lap(t, "evalJS resetUI")
end

local function showNow()
	local t = hs.timer.secondsSinceEpoch()
	local view = ensureWebview()
	t = lap(t, "ensureWebview")
	view:frame(rectForFocusedScreen())
	t = lap(t, "frame")
	view:alpha(1)
	t = lap(t, "alpha(1)")
	if not mapped then
		view:show()
		mapped = true
		t = lap(t, "view:show()")
	end
	activateHammerspoon()
	t = lap(t, "activateHammerspoon")
	isShown = true
	warming = false
	focusShownWebview()
end

local function show()
	print("[emoji-picker] ── show begin ──")
	local t = hs.timer.secondsSinceEpoch()
	prevApp = hs.application.frontmostApplication()
	lap(t, "frontmostApplication")
	ensureWebview()
	showNow()
end

userContent:setCallback(function(msg)
	local body = msg and msg.body
	if type(body) ~= "table" then
		dismiss()
		return
	end
	if body.action == "ready" then
		isReady = true
		if warming and webview and not isShown then
			parkWebview()
			warming = false
		end
	elseif body.action == "cancel" then
		dismiss()
	elseif body.action == "pick" and body.char then
		commit(body.char, body.alias)
	end
end)

local function toggle()
	if isShown then
		dismiss()
	else
		show()
	end
end

hs.hotkey.bind(hyper, "space", toggle)

createWebview()

local function warmup()
	if isShown then
		return
	end
	warming = true
	local view = ensureWebview()
	view:frame(rectForFocusedScreen())
	view:alpha(0)
	if not mapped then
		view:show()
		mapped = true
	end
	-- Prime hswindow cache off the hot path. hs.webview:hswindow() walks the
	-- AX window list, which takes ~1.5s. Run after one runloop tick so the
	-- NSWindow is registered with the AX system.
	primeTimer = hs.timer.doAfter(0.05, function()
		if view == webview then
			getHsWindow()
		end
	end)
	parkTimer = hs.timer.doAfter(1.0, function()
		if warming and view == webview and not isShown then
			warming = false
			view:frame(OFFSCREEN)
		end
	end)
end

-- Paint once at the real on-screen position with alpha 0 so WebKit composites
-- against a live display, then park offscreen. The window stays mapped — every
-- subsequent show is just alpha + frame, no NSWindow unmap/remap round-trip.
warmup()

-- Backstop: if any parking step is ever lost, the invisible mapped webview
-- sits at screen center and swallows clicks until reload. Re-park it.
parkWatchdog = hs.timer.doEvery(5, function()
	if webview and mapped and not isShown and not warming then
		local f = webview:frame()
		if f and f.x ~= OFFSCREEN.x then
			print("[emoji-picker] watchdog: re-parking stray webview")
			parkWebview()
		end
	end
end)

local caffeinateWatcher = hs.caffeinate.watcher.new(function(event)
	if event == hs.caffeinate.watcher.systemDidWake then
		if not isShown then
			rebuildWebview()
			wakeWarmupTimer = hs.timer.doAfter(1.0, warmup)
		end
	end
end)
caffeinateWatcher:start()

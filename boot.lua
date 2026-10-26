--[[
    tea.cc boot - one paste, straight to the bar

        loadstring(game:HttpGet("https://raw.githubusercontent.com/Teachairloader/tea-cc/main/boot.lua"))()

    Flow:
        1. gate.lua puts the loading screen up on the first frame. No key screen,
           no key list fetch: the gate opens on the bar.
        2. The bar runs loader.lua, which pulls drift.lua, which patches tea.cc
           and builds the menu. The bar is paced against that work, so it covers
           the whole load instead of blinking.
        3. Nothing loads after the menu opens. World, weather, skin changer and
           legit macro are sections of the misc tab, anti lock, cframe speed,
           fake macro, orbit, super jump and fly are the rage tab, all inside
           drift, so there is no addon pass and no ordering race.

    loader.lua -> drift.lua -> tea.cc is a straight line with no path back here.
]]

local GATE_SOURCES = {
    "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/gate.lua",
    "https://raw.githubusercontent.com/Teachairloader/tea-cc/49f1c61853ae265fd77445099fff9b3f323247ba/gate.lua",
}

-- gate.lua is the loading screen only now that the key list is gone, so the
-- floor dropped from 20kb to 4kb. Anything under this is a truncated body or an
-- error page, not the file.
local MIN_SIZE = 4000

-- bar pacing, patched into the gate: SHOW_RATE is how many seconds of work map
-- to 94% of the bar, MIN_SHOW is the floor so a warm start still shows a load
-- instead of a single frame.
local SHOW_RATE = "3.2"
local MIN_SHOW = "2.2"

local function fetch(url)
    local ok, body = pcall(function()
        return game:HttpGet(url .. "?t=" .. tostring(os.time()))
    end)
    if ok and type(body) == "string" and #body >= MIN_SIZE then
        return body
    end
    return nil, ok and ("short body (" .. tostring(body and #body or 0) .. "b)") or body
end

-- literal replace, returns text and the number of hits
local function lit(text, find, with)
    if type(text) ~= "string" or type(find) ~= "string" or find == "" then
        return text, 0
    end
    local parts, index, hits = {}, 1, 0
    while true do
        local s, e = text:find(find, index, true)
        if not s then
            break
        end
        parts[#parts + 1] = text:sub(index, s - 1)
        parts[#parts + 1] = with
        index = e + 1
        hits = hits + 1
    end
    parts[#parts + 1] = text:sub(index)
    return table.concat(parts), hits
end

local source, lastError = nil, "no source tried"
for _, url in ipairs(GATE_SOURCES) do
    source, lastError = fetch(url)
    if source then
        break
    end
end

if not source then
    return warn("[tea.boot] gate fetch failed: " .. tostring(lastError))
end

source = source:gsub("\r\n", "\n")

-- The gate ships RUN_LOADER = true, which is what this file wants: the gate owns
-- the chain, loader.lua pulls drift.lua, drift builds the menu. The patch is
-- here only so an upstream flip to false cannot leave the bar spinning on
-- nothing while no chain runs.
local armed, armedHits = lit(source, "local RUN_LOADER = false", "local RUN_LOADER = true")
if armedHits > 0 then
    source = armed
end

local paced, pacingHits = lit(source, "local SHOW_RATE = 2.2", "local SHOW_RATE = " .. SHOW_RATE)
if pacingHits > 0 then
    source = paced
end

local floored, floorHits = lit(source, "local MIN_SHOW = 1.2", "local MIN_SHOW = " .. MIN_SHOW)
if floorHits > 0 then
    source = floored
end

local chunk, compileError = loadstring(source)
if not chunk then
    return warn("[tea.boot] gate compile failed: " .. tostring(compileError))
end

local okRun, runError = pcall(chunk)
if not okRun then
    return warn("[tea.boot] gate run failed: " .. tostring(runError))
end

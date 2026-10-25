--[[
    drift - white shell over tea.cc

    Loads the tea.cc loader, then rewrites it before it compiles:

      - window 575x450 -> 690x552 (content area 430 -> 532), left column
        overflow threshold 405 -> 507 so the frame still grows correctly
      - accent, logo, cursor, crosshair, theme json: pink -> #FFFFFF
      - hover / value / error / alert tints: pink family -> neutral greys
      - header mark "Tea.cc" + "live" -> "Drift"
      - loader folder tea.cc -> drift

    The window size and the header image live inside the juju source that
    tea.cc fetches, so they are patched at the one point where that source is
    in hand: right after its HttpGet, before its own recolour pass runs.

    Logo: LOGO_URL if set (re-pulled every load), else drift/assets/logo.png,
    else the embedded fallback mark. Drop your own PNG at that path and it
    wins permanently.
]]

local BASE_URL =
    "https://raw.githubusercontent.com/Teachairloader/tea-cc/631cce01e830568560198a1c48eb406889de3bd5/tea_cc.lua"
local FOLDER = "drift"
local LOGO_PATH = FOLDER .. "/assets/logo.png"

-- 256x256 RGBA PNG, white mark on transparent
local LOGO_B64 = [==[
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
]==]

-- literal find/replace; Lua patterns would eat the brackets and periods
local function lit(text, find, with)
    if type(text) ~= "string" or type(find) ~= "string" or find == "" then
        return text
    end
    local parts, i = {}, 1
    while true do
        local s, e = text:find(find, i, true)
        if not s then
            break
        end
        parts[#parts + 1] = text:sub(i, s - 1)
        parts[#parts + 1] = with
        i = e + 1
    end
    parts[#parts + 1] = text:sub(i)
    return table.concat(parts)
end

local function decode_b64(data)
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local map = {}
    for i = 1, 64 do
        map[alphabet:sub(i, i)] = i - 1
    end

    data = data:gsub("%s+", "")
    local out = {}
    for i = 1, #data, 4 do
        local c1 = data:sub(i, i)
        local c2 = data:sub(i + 1, i + 1)
        local c3 = data:sub(i + 2, i + 2)
        local c4 = data:sub(i + 3, i + 3)
        local triple = (map[c1] or 0) * 262144
            + (map[c2] or 0) * 4096
            + (map[c3] or 0) * 64
            + (map[c4] or 0)

        out[#out + 1] = string.char(math.floor(triple / 65536) % 256)
        if c3 ~= "=" and c3 ~= "" then
            out[#out + 1] = string.char(math.floor(triple / 256) % 256)
        end
        if c4 ~= "=" and c4 ~= "" then
            out[#out + 1] = string.char(triple % 256)
        end
    end
    return table.concat(out)
end

-- ------------------------------------------------------------------- files --
pcall(function()
    if not isfolder(FOLDER) then
        makefolder(FOLDER)
    end
    if not isfolder(FOLDER .. "/assets") then
        makefolder(FOLDER .. "/assets")
    end
end)

-- Direct image URL wins over both the cache and the embedded fallback: set it
-- once and every load re-pulls the exact file. Empty string = use the cache,
-- then the embedded mark.
local LOGO_URL = ""

local logo_ready = false

if LOGO_URL ~= "" then
    pcall(function()
        local bytes = game:HttpGet(LOGO_URL)
        if type(bytes) == "string" and #bytes > 512 then
            writefile(LOGO_PATH, bytes)
        end
    end)
end

pcall(function()
    if not isfile(LOGO_PATH) then
        writefile(LOGO_PATH, decode_b64(LOGO_B64))
    end
    logo_ready = isfile(LOGO_PATH)
end)

-- ------------------------------------------------------------------- fetch --
local okFetch, source = pcall(function()
    return game:HttpGet(BASE_URL)
end)
if not okFetch or type(source) ~= "string" or #source < 1000 then
    return warn("[drift] could not fetch tea.cc: " .. tostring(source))
end

-- ------------------------------------------------------------ tea.cc edits --
local EDITS = {
    { 'local FOLDER = "tea.cc"', 'local FOLDER = "drift"' },
    {
        'getgenv().script_name = "Tea.cc"',
        'getgenv().script_name = "Drift"\ngetgenv().script_version = ""',
    },
    { "local TAB_HEIGHT = 430", "local TAB_HEIGHT = 532" },

    -- accent family and theme json (spaced + unspaced forms both appear)
    { "255, 121, 198", "255, 255, 255" },
    { "255,121,198", "255,255,255" },

    -- pink-tinted hover fill, value text, error, alert -> neutral
    { "72, 36, 60", "30, 30, 30" },
    { "72,36,60", "30,30,30" },
    { "92, 62, 82", "140, 140, 140" },
    { "92,62,82", "140,140,140" },
    { "96, 39, 60", "58, 58, 58" },
    { "96,39,60", "58,58,58" },
    { "61, 30, 51", "38, 38, 38" },
    { "61,30,51", "38,38,38" },
}

for _, edit in ipairs(EDITS) do
    source = lit(source, edit[1], edit[2])
end

-- --------------------------------------------------------- juju ui edits ---
-- Runs inside the tea.cc chunk, where `source` already holds the juju ui.
-- 575/450/405 each appear only as the window width, height and left column
-- overflow threshold in that file, so a plain swap is exact.
local UI_PATCH = [==[
if type(source) == "string" then
    local function lit_(text, from, to)
        if type(text) ~= "string" or from == "" then
            return text
        end
        local out, i = {}, 1
        while true do
            local s, e = text:find(from, i, true)
            if not s then
                break
            end
            out[#out + 1] = text:sub(i, s - 1)
            out[#out + 1] = to
            i = e + 1
        end
        out[#out + 1] = text:sub(i)
        return table.concat(out)
    end

    source = lit_(source, "575", "690")
    source = lit_(source, "450", "552")
    source = lit_(source, "405", "507")
    source = lit_(source, "udim2_new(0, 35, 0, 35)", "udim2_new(0, 40, 0, 40)")

    pcall(function()
        if isfile(getgenv().custom_folder .. "/assets/logo.png") then
            source = lit_(
                source,
                'safeHttp("https://raw.githubusercontent.com/panduh16/juju/main/assets/logo.png")',
                'readfile(getgenv().custom_folder .. "/assets/logo.png")'
            )
        end
    end)
end
]==]

source = lit(
    source,
    'if not okFetch or type(source) ~= "string" or #source < 1000 then',
    UI_PATCH .. '\nif not okFetch or type(source) ~= "string" or #source < 1000 then'
)

-- ----------------------------------------------------------------- compile --
local chunk, compileError = loadstring(source)
if not chunk then
    return warn("[drift] patched loader failed to compile: " .. tostring(compileError))
end

local okRun, result = pcall(chunk)
if not okRun then
    return warn("[drift] tea.cc failed to run: " .. tostring(result))
end

print("[drift] loaded - 690x552, white, mark Drift, logo " .. (logo_ready and "local" or "upstream"))

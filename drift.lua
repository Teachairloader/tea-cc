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

    Logo: drift/assets/logo.png. Written once from the embedded PNG if the
    path is empty, then never touched again - drop your own file there and it
    wins on every future load.
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

local logo_ready = false
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

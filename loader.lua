-- ================================================================ drift load ===
-- Single entry point. Drops the logo asset the menu reads at boot, then pulls
-- the menu build and runs it. Nothing else to paste.
--
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/Teachairloader/tea-cc/main/loader.lua"))()

local FOLDER = "drift"
local ASSET_DIR = FOLDER .. "/assets"
local LOGO_PATH = ASSET_DIR .. "/logo.png"
local LOGO_URL = "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/assets/logo.png"
local LOGO_MIN = 1024

-- The obfuscated build wins; the plain build is the same source and stays as a
-- fallback for the day the obfuscated file is missing or truncated.
local SOURCES = {
    "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/menu.lua",
    "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/menu.plain.lua",
}

local MIN_SIZE = 40000

local function http(url)
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(body) == "string" then
        return body
    end
    return nil, tostring(body)
end

local function ensure_dir(path)
    if type(makefolder) ~= "function" or type(isfolder) ~= "function" then
        return false
    end
    if isfolder(path) then
        return true
    end
    return (pcall(makefolder, path))
end

local function file_size(path)
    if type(isfile) ~= "function" or type(readfile) ~= "function" then
        return 0
    end
    if not isfile(path) then
        return 0
    end
    local ok, size = pcall(function()
        return #readfile(path)
    end)
    if ok and type(size) == "number" then
        return size
    end
    return 0
end

-- juju reads getgenv().custom_folder .. "/assets/logo.png" and falls back to the
-- upstream panda when the file is missing, so the asset has to be on disk before
-- the menu compiles.
local function drop_logo()
    if type(writefile) ~= "function" then
        return false
    end

    if file_size(LOGO_PATH) > LOGO_MIN then
        return true
    end

    if not ensure_dir(FOLDER) then
        return false
    end
    ensure_dir(ASSET_DIR)

    local bytes = http(LOGO_URL .. "?t=" .. tostring(os.time()))
    if not bytes or #bytes <= LOGO_MIN then
        warn("[drift] logo fetch failed, menu falls back to the stock mark")
        return false
    end

    if not pcall(writefile, LOGO_PATH, bytes) then
        return false
    end
    return file_size(LOGO_PATH) > LOGO_MIN
end

pcall(drop_logo)

local source, lastError = nil, "no source tried"
for _, url in ipairs(SOURCES) do
    local body, err = http(url .. "?t=" .. tostring(os.time()))
    if body and #body >= MIN_SIZE then
        source = body
        break
    end
    lastError = body and ("short body (" .. tostring(#body) .. "b)") or err
end

if not source then
    return warn("[drift] menu fetch failed: " .. tostring(lastError))
end

local chunk, compileError = loadstring(source)
if not chunk then
    return warn("[drift] menu compile failed: " .. tostring(compileError))
end

local okRun, runError = pcall(chunk)
if not okRun then
    return warn("[drift] menu run failed: " .. tostring(runError))
end

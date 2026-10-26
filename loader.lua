-- ================================================================ drift load ===
-- Single entry point. Pulls the current drift loader, which in turn fetches
-- tea.cc and patches it before compiling. Nothing else to paste.
--
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/Teachairloader/tea-cc/main/loader.lua"))()

local SOURCES = {
    "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/drift.lua",
    "https://raw.githubusercontent.com/Teachairloader/tea-cc/49f1c61853ae265fd77445099fff9b3f323247ba/drift.lua",
}

local MIN_SIZE = 20000

local function fetch(url)
    local ok, body = pcall(function()
        return game:HttpGet(url .. "?t=" .. tostring(os.time()))
    end)
    if ok and type(body) == "string" and #body >= MIN_SIZE then
        return body
    end
    return nil, ok and ("short body (" .. tostring(body and #body or 0) .. "b)") or body
end

local source, lastError = nil, "no source tried"
for _, url in ipairs(SOURCES) do
    source, lastError = fetch(url)
    if source then
        break
    end
end

if not source then
    return warn("[drift] loader fetch failed: " .. tostring(lastError))
end

local chunk, compileError = loadstring(source)
if not chunk then
    return warn("[drift] loader compile failed: " .. tostring(compileError))
end

local okRun, runError = pcall(chunk)
if not okRun then
    return warn("[drift] loader run failed: " .. tostring(runError))
end

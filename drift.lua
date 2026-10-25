--[[
    drift - white shell over tea.cc

    Loads the tea.cc loader, then rewrites it before it compiles:

      - window 575x450 -> 690x552 (content area 430 -> 532), left column
        overflow threshold 405 -> 507 so the frame still grows correctly
      - accent, logo, cursor, crosshair, theme json: pink -> #FFFFFF
      - hover / value / error / alert tints: pink family -> neutral greys
      - header mark "Tea.cc" + "live" -> "Drift"
      - loader folder tea.cc -> drift
      - adds a silent aim section under aimbot: __namecall hook rewrites the
        direction / aim-point argument of FireServer calls toward the picked
        target, so shots curve while the camera stays put; tracer + target dot
        overlay draws from the same target pick
      - adds an "overlay esp" section on visuals column 2, body fetched from
        esp.lua (fonts included) and folded into the same chunk

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
local LOGO_URL = "https://media.discordapp.net/attachments/1537736136141701151/1563713376952262778/Logo.png.png?ex=6adea111&is=6add4f91&hm=3590194de36fd4f8fd295ad537f7e939192c2902e9ef44b73e60295ba2d3cd89&=&format=png"

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

-- upstream ships CRLF; every anchor below is written with plain newlines
source = source:gsub("\r\n", "\n")

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

-- ------------------------------------------------------- silent aim (menu) ---
-- Slotted into combat column 1 directly under aimbot, reusing the cursor that
-- block call left behind. The anchor is the reset to 0 that starts column 2.
local SILENT_MENU = [==[
y = block(main, "combat", 1, y, "silent aim", {
    { k = "toggle", n = "enabled", f = "silent_enabled", d = false },
    { k = "dropdown", n = "activation", f = "silent_activation", o = { "Toggle", "Hold" }, d = { "Toggle" }, req = true },
    { k = "keybind", n = "aim key", f = "silent_key", d = Enum.KeyCode.E },
    { k = "dropdown", n = "hit part", f = "silent_part", o = { "Head", "Torso", "HumanoidRootPart", "Closest Part" }, d = { "Head" }, req = true },
    { k = "slider", n = "fov size", f = "silent_fov", min = 0, max = 1000, d = 250 },
    { k = "toggle", n = "wall check", f = "silent_wall_check", d = false },
    { k = "toggle", n = "team check", f = "silent_team_check", d = true },
    { k = "toggle", n = "tracer", f = "silent_tracer", d = true },
    { k = "dropdown", n = "tracer from", f = "silent_tracer_from", o = { "Mouse", "Bottom", "Character" }, d = { "Mouse" } },
    { k = "toggle", n = "target dot", f = "silent_dot", d = true },
    { k = "slider", n = "dot size", f = "silent_dot_size", min = 1, max = 20, d = 6 },
})

]==]

-- ----------------------------------------------------------------- esp (menu) ---
-- Lives on visuals column 2, stacked under "world". Combat column 1 already
-- carries aimbot + silent aim; a third section there overruns the content area.
-- Flags are esp_ov_* so tea.cc's own "player esp" block keeps its names.
local ESP_MENU = [==[y = block(main, "visuals", 2, y, "overlay esp", {
    { k = "toggle", n = "enabled", f = "esp_ov_enabled", d = false },
    { k = "toggle", n = "box", f = "esp_ov_box", d = true },
    { k = "toggle", n = "filled box", f = "esp_ov_filled", d = false },
    { k = "toggle", n = "gradient", f = "esp_ov_gradient", d = true },
    { k = "toggle", n = "name", f = "esp_ov_name", d = true },
    { k = "toggle", n = "distance", f = "esp_ov_distance", d = true },
    { k = "toggle", n = "tool", f = "esp_ov_tool", d = false },
    { k = "toggle", n = "health bar", f = "esp_ov_health", d = true },
    { k = "toggle", n = "armor bar", f = "esp_ov_armor", d = false },
    { k = "dropdown", n = "font", f = "esp_ov_font", o = { "SmallestPixel", "ProggyClean", "ProggyTiny", "Visitor", "Tahoma", "TahomaBold", "Verdana", "Stratum2", "WindowsXP" }, d = { "SmallestPixel" } },
    { k = "slider", n = "max distance", f = "esp_ov_max_distance", min = 50, max = 2000, d = 500 },
    { k = "toggle", n = "team check", f = "esp_ov_team", d = true },
})

]==]

source = lit(
    source,
    'y = 0\ny = block(main, "combat", 2, y, "rapid fire", {',
    SILENT_MENU .. 'y = 0\ny = block(main, "combat", 2, y, "rapid fire", {'
)

source = lit(
    source,
    '-- misc -----------------------------------------------------------------',
    ESP_MENU .. '-- misc -----------------------------------------------------------------'
)

-- ---------------------------------------------------------------- esp (body) ---
-- The overlay esp carries its own fonts (base64 TTFs), which is most of a
-- megabyte, so it lives as a second file and gets folded into the same chunk.
-- An empty string here leaves the menu inert instead of failing the load.
local ESP_URL =
    "https://raw.githubusercontent.com/Teachairloader/tea-cc/89464276aa2792d3ccce9ab819c9614b35805965/esp.lua"
local espChunk = ""

pcall(function()
    local body = game:HttpGet(ESP_URL)
    if type(body) == "string" and #body > 1000 then
        espChunk = body
    end
end)

if espChunk == "" then
    warn("[drift] could not fetch esp.lua - esp options stay inert")
end

-- --------------------------------------------------- silent aim (runtime) ---
-- Appended before the finish marker, not after `return menu`, so it stays live.
-- Uses the loader's own locals: fget, first, key_of, key_down, flags, Client,
-- Players, Workspace, UserInputService.
local SILENT_RUNTIME = [==[
-- ================================================================ silent aim ===
-- Two halves, independent:
--   1. namecall hook - rewrites direction-like FireServer/InvokeServer args so
--      the shot curves to the target while the camera never moves.
--   2. overlay - dot + tracer from the same target pick.
-- The old GunHandler.getAim probe is gone: that module does not exist in this
-- game, so the whole block used to sit inert behind a failed require.
do
    local RenderStepped = game:GetService("RunService").RenderStepped

    -- drawings outlive a reload; tear the previous pass down before re-creating
    local DRAW_KEY = "__drift_silent_draw"
    local stale = getgenv()[DRAW_KEY]
    if type(stale) == "table" then
        for _, object in ipairs(stale) do
            pcall(function()
                object:Remove()
            end)
        end
    end

    local drawings = {}
    getgenv()[DRAW_KEY] = drawings

    local hasDrawing = pcall(function()
        local probe = Drawing.new("Circle")
        probe:Remove()
    end)

    local mouse = Client:GetMouse()
    local toggled = false
    local PART_ORDER = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" }

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or not fget("silent_enabled", false) then
            return
        end
        if first(fget("silent_activation", { "Toggle" }), "Toggle") ~= "Toggle" then
            return
        end
        if input.KeyCode == key_of(fget("silent_key", Enum.KeyCode.E)) then
            toggled = not toggled
        end
    end)

    local function active()
        if not fget("silent_enabled", false) then
            return false
        end
        if first(fget("silent_activation", { "Toggle" }), "Toggle") == "Toggle" then
            return toggled
        end
        return key_down(fget("silent_key", Enum.KeyCode.E))
    end

    local function pick_part(character)
        local mode = first(fget("silent_part", { "Head" }), "Head")

        if mode == "Closest Part" then
            local origin = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position
            local best, bestDistance = nil, math.huge
            for _, name in ipairs(PART_ORDER) do
                local part = character:FindFirstChild(name)
                if part and part:IsA("BasePart") and origin then
                    local distance = (part.Position - origin).Magnitude
                    if distance < bestDistance then
                        best, bestDistance = part, distance
                    end
                end
            end
            if best then
                return best
            end
        else
            local part = character:FindFirstChild(mode)
            if part and part:IsA("BasePart") then
                return part
            end
        end

        local head = character:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            return head
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            return root
        end
        return nil
    end

    local function blocked(origin, part)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { Client.Character, part.Parent }
        params.IgnoreWater = true
        return Workspace:Raycast(origin, part.Position - origin, params) ~= nil
    end

    local function closest()
        local camera = Workspace.CurrentCamera
        if not camera then
            return nil
        end

        local cursor = Vector2.new(mouse.X, mouse.Y)
        local radius = fget("silent_fov", 250)
        local wall = fget("silent_wall_check", false)
        local team = fget("silent_team_check", true)
        local origin = camera.CFrame.Position
        local best, bestDistance = nil, math.huge

        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if player ~= Client and humanoid and humanoid.Health > 0 then
                local sameTeam = team and Client.Team ~= nil and player.Team == Client.Team
                if not sameTeam then
                    local part = pick_part(character)
                    if part then
                        local screen, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local distance = (Vector2.new(screen.X, screen.Y) - cursor).Magnitude
                            if distance <= radius
                                and distance < bestDistance
                                and not (wall and blocked(origin, part))
                            then
                                best, bestDistance = part, distance
                            end
                        end
                    end
                end
            end
        end

        return best
    end

    -- ------------------------------------------------------------- redirection ---
    -- Guns call FireServer(direction) with the camera's unit ray. A Vector3 of
    -- length ~1 that points within ~25 degrees of the look vector is that
    -- direction argument; positions are studs long, so the magnitude gate keeps
    -- them out. Everything else is forwarded untouched.
    local wrap = newcclosure or function(fn)
        return fn
    end

    local redirected = false

    if hookmetamethod then
        pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", wrap(function(self, ...)
                local method = getnamecallmethod()

                if method ~= "FireServer" and method ~= "InvokeServer" then
                    return oldNamecall(self, ...)
                end

                if not active() then
                    return oldNamecall(self, ...)
                end

                local camera = Workspace.CurrentCamera
                local target = camera and closest()
                if not target then
                    return oldNamecall(self, ...)
                end

                local delta = target.Position - camera.CFrame.Position
                if delta.Magnitude < 0.01 then
                    return oldNamecall(self, ...)
                end

                local direction = delta.Unit
                local look = camera.CFrame.LookVector
                local arguments = table.pack(...)
                local changed = false

                for index = 1, arguments.n do
                    local value = arguments[index]
                    if typeof(value) == "Vector3" then
                        local magnitude = value.Magnitude
                        if magnitude > 0.9
                            and magnitude < 1.1
                            and value.Unit:Dot(look) > 0.9
                        then
                            arguments[index] = direction
                            changed = true
                        end
                    end
                end

                if not changed then
                    -- position-style aim args: the world point under the cursor.
                    -- Only rewritten when it sits almost exactly on the look ray,
                    -- so movement / physics remotes keep their own vectors.
                    for index = 1, arguments.n do
                        local value = arguments[index]
                        if typeof(value) == "Vector3" and value.Magnitude > 2 then
                            local toPoint = value - camera.CFrame.Position
                            if toPoint.Magnitude > 0.5 then
                                local along = toPoint.Unit:Dot(look)
                                local miss = (toPoint - look * toPoint:Dot(look)).Magnitude
                                if along > 0.98 and miss < 4 then
                                    arguments[index] = target.Position
                                    changed = true
                                end
                            end
                        end
                    end
                end

                if not changed then
                    return oldNamecall(self, ...)
                end

                redirected = true
                return oldNamecall(self, table.unpack(arguments, 1, arguments.n))
            end))
        end)
    else
        warn("[drift] no hookmetamethod - silent aim cannot redirect shots")
    end

    -- ------------------------------------------------------------------ overlay ---
    if not hasDrawing then
        warn("[drift] executor has no Drawing API - tracer and dot stay off")
    else
        local tracer = Drawing.new("Line")
        tracer.Thickness = 1.5
        tracer.Color = Color3.fromRGB(255, 255, 255)
        tracer.Transparency = 0.75
        tracer.Visible = false
        tracer.ZIndex = 1

        local dot = Drawing.new("Circle")
        dot.Thickness = 1
        dot.Color = Color3.fromRGB(255, 255, 255)
        dot.Transparency = 1
        dot.Filled = true
        dot.NumSides = 24
        dot.Visible = false
        dot.ZIndex = 2

        drawings[#drawings + 1] = tracer
        drawings[#drawings + 1] = dot

        local function hide_overlay()
            tracer.Visible = false
            dot.Visible = false
        end

        local function tracer_origin(camera, viewport)
            local mode = first(fget("silent_tracer_from", { "Mouse" }), "Mouse")

            if mode == "Bottom" then
                return Vector2.new(viewport.X / 2, viewport.Y)
            end

            if mode == "Character" then
                local character = Client.Character
                local anchor = character
                    and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
                if anchor and anchor:IsA("BasePart") then
                    local point, onScreen = camera:WorldToViewportPoint(anchor.Position)
                    if onScreen then
                        return Vector2.new(point.X, point.Y)
                    end
                end
                return Vector2.new(viewport.X / 2, viewport.Y)
            end

            return Vector2.new(mouse.X, mouse.Y)
        end

        RenderStepped:Connect(function()
            if not active() then
                hide_overlay()
                return
            end

            local target = closest()
            local camera = Workspace.CurrentCamera
            if not target or not target.Parent or not camera then
                hide_overlay()
                return
            end

            local point, onScreen = camera:WorldToViewportPoint(target.Position)
            if not onScreen then
                hide_overlay()
                return
            end

            local screen = Vector2.new(point.X, point.Y)

            if fget("silent_tracer", true) then
                tracer.From = tracer_origin(camera, camera.ViewportSize)
                tracer.To = screen
                tracer.Visible = true
            else
                tracer.Visible = false
            end

            if fget("silent_dot", true) then
                dot.Position = screen
                dot.Radius = fget("silent_dot_size", 6)
                dot.Visible = true
            else
                dot.Visible = false
            end
        end)
    end
end

]==]

source = lit(
    source,
    "-- ----------------------------------------------------------------- finish ---",
    SILENT_RUNTIME .. espChunk .. "-- ----------------------------------------------------------------- finish ---"
)

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
    source = lit_(source, "\r\n", "\n")

    -- header text: the stock offsets (x +5, y +3 / +19) sit on the top edge of
    -- a 35px mark; the 40px mark needs the label optically centred instead.
    source = lit_(
        source,
        '["Position"] = udim2_new(1, 5, 0, 3)',
        '["Position"] = udim2_new(1, 8, 0, 12)'
    )
    source = lit_(
        source,
        '["Position"] = udim2_new(1, 5, 0, 19)',
        '["Position"] = udim2_new(1, 8, 0, 27)'
    )

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

--[[
    tea.cc - juju shell (panduh16/juju), blossom pink

    Interface only. No feature source, no RunService, no game reads. Every
    widget writes into juju's own flag table and nothing subscribes to it.

    Recolour is done on the source text before it is compiled, not after the
    window is drawn: juju bakes every colour into the Drawing objects as they
    are created, so a table override after load only reaches widgets built
    later. The accent triple 154, 213, 222 is the blue, and it appears in
    accent, shadow, logo, juju, build, cursor and success.

    Title comes from getgenv().script_name, read at line ~769 during load, so
    it has to be set before the chunk runs.

    This revision adds a runtime layer below the layout: camlock aimbot with the
    menu's own pink FOV ring (replaces silent aim), rapid fire (driven by the
    user's own utility source, now flag-driven), hitbox expander (reasserted
    every frame so the game's own replication cannot shrink it back). Weapon
    and triggerbot sections removed.
]]

local UI_URL = "https://raw.githubusercontent.com/panduh16/juju/main/ui.lua"
local FOLDER = "tea.cc"

-- --------------------------------------------------------------- identity ---
getgenv().script_name = "Tea.cc"
getgenv().custom_folder = FOLDER

-- ------------------------------------------------------------------ fetch ---
local okFetch, source = pcall(function()
    return game:HttpGet(UI_URL)
end)
if not okFetch or type(source) ~= "string" or #source < 1000 then
    return warn("[tea.cc] could not fetch juju: " .. tostring(source))
end

-- ---------------------------------------------------------------- recolour ---
-- plain text replacement; the patterns contain regex metacharacters, so they
-- are escaped for Lua's pattern engine rather than used raw.
local function swap(text, find, replace)
    local escaped = find:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")
    return (text:gsub(escaped, replace))
end

local BLUE = "154, 213, 222"
if not source:find(BLUE, 1, true) then
    warn("[tea.cc] accent triple not found in juju source - upstream changed, colours left stock")
end

-- accent family: accent, shadow, logo, juju, build, cursor, success
source = swap(source, "color3_fromrgb(" .. BLUE .. ")", "color3_fromrgb(255, 121, 198)")
-- hover fill on toggles, sliders, buttons
source = swap(source, "color3_fromrgb(51, 65, 70)", "color3_fromrgb(72, 36, 60)")
-- dropdown and textbox value text
source = swap(source, "color3_fromrgb(70, 85, 87)", "color3_fromrgb(92, 62, 82)")
-- error and alert were blue-tinted too
source = swap(source, "color3_fromrgb(39, 60, 96)", "color3_fromrgb(96, 39, 60)")
source = swap(source, "color3_fromrgb(30, 51, 61)", "color3_fromrgb(61, 30, 51)")

-- ---------------------------------------------------------------- compile ---
local chunk, compileError = loadstring(source)
if not chunk then
    return warn("[tea.cc] juju failed to compile: " .. tostring(compileError))
end

local okRun, juju = pcall(chunk)
if not okRun or type(juju) ~= "table" or type(juju.menu) ~= "table" then
    return warn("[tea.cc] juju failed to load: " .. tostring(juju))
end

local menu = juju.menu
local flags = juju.flags

-- belt and braces: anything built after this point reads the live table
menu["colors"]["accent"] = Color3.fromRGB(255, 121, 198)
menu["colors"]["shadow"] = Color3.fromRGB(255, 121, 198)
menu["colors"]["success"] = Color3.fromRGB(255, 121, 198)
menu["colors"]["logo"] = Color3.fromRGB(255, 121, 198)
menu["colors"]["juju"] = Color3.fromRGB(255, 121, 198)
menu["colors"]["build"] = Color3.fromRGB(255, 121, 198)
menu["colors"]["cursor"] = Color3.fromRGB(255, 121, 198)

-- the settings panel can reload themes/default.th from disk; keep that one
-- pink as well so a theme switch does not put the blue back
pcall(function()
    writefile(
        FOLDER .. "/themes/default.th",
        '{"!image_color":[89,89,89],"!error_color":[96,39,60],"!accent_color":[255,121,198],'
            .. '"!build_color":[255,121,198],"!success_color":[255,121,198],"!active_border_color":[72,36,60],'
            .. '"!dark_text_color":[92,62,82],"!juju_color":[255,121,198],"!background_color":[0,0,0],'
            .. '"!border_color":[24,25,24],"!keybind_text_color":[197,197,197],"!inactive_text_color":[75,72,72],'
            .. '"!shadow_color":[255,121,198],"!active_text_color":[197,197,197],"!alert_color":[61,30,51],'
            .. '"!logo_color":[255,121,198],"!section_color":[6,6,6]}'
    )
end)

-- ----------------------------------------------------------------- layout ---
local TAB_HEIGHT = 430 -- right-side content area, window is 575x450

local ROW_HEIGHT = {
    toggle = 17,
    keybind = 17,
    slider = 31,
    dropdown = 35,
    textbox = 35,
    button = 21,
    colorpicker = 17,
    info = 17,
}

local PINK = Color3.fromRGB(255, 121, 198)

local function fill(section, row)
    local properties = {}

    if row.k == "toggle" then
        properties.toggle = { flag = row.f, default = row.d }
    elseif row.k == "keybind" then
        properties.keybind = { flag = row.f, default = row.d }
    elseif row.k == "slider" then
        properties.slider = {
            flag = row.f,
            min = row.min,
            max = row.max,
            default = row.d,
            decimals = row.dec or 0,
            suffix = row.suffix,
            prefix = row.prefix,
            min_text = row.min_text,
            max_text = row.max_text,
        }
    elseif row.k == "dropdown" then
        properties.dropdown = {
            flag = row.f,
            options = row.o,
            default = row.d,
            multi = row.multi,
            requires_one = row.req,
        }
    elseif row.k == "textbox" then
        properties.textbox = { flag = row.f, default = row.d }
    elseif row.k == "button" then
        properties.button = { confirmation = row.conf }
    elseif row.k == "colorpicker" then
        properties.colorpicker = {
            color_flag = row.f,
            transparency_flag = row.f .. "_transparency",
            default_color = row.d or PINK,
            default_transparency = row.t or 0,
        }
    elseif row.k == "info" then
        properties.info = {}
    end

    local element = section:create_element({ name = row.n }, properties, true)

    -- juju draws the keybind chip from its own element state, not from the flag
    -- table, so a fresh keybind renders "none" until something calls set_key.
    -- Seeding the flag alone was not enough; the element has to be told.
    if row.k == "keybind" and element and element["set_key"] and not flags[row.f] then
        element:set_key(row.d)
    end

    return element
end

-- builds one section and returns the cursor for the next one in that column
local function block(group, tab, side, cursor, title, rows)
    local height = 20
    for _, row in ipairs(rows) do
        height = height + (ROW_HEIGHT[row.k] or 17)
    end

    local size = math.min(height / TAB_HEIGHT, 1)
    local section = group:create_section(tab, title, side, size, cursor)
    if not section then
        warn("[tea.cc] section failed: " .. tostring(title))
        return cursor
    end

    for _, row in ipairs(rows) do
        fill(section, row)
    end

    return cursor + size
end

-- ------------------------------------------------------------------ build ---
local VERSION = "2026-10-24k"

local main = menu.create_group("main")
main:create_tab("combat")
main:create_tab("visuals")
main:create_tab("misc")

-- combat ---------------------------------------------------------------
local y = 0
y = block(main, "combat", 1, y, "aimbot", {
    { k = "toggle", n = "enabled", f = "aim_enabled", d = true },
    { k = "dropdown", n = "activation", f = "aim_activation", o = { "Toggle", "Hold" }, d = { "Toggle" }, req = true },
    { k = "keybind", n = "aim key", f = "aim_key", d = Enum.KeyCode.Q },
    { k = "dropdown", n = "hit part", f = "aim_hit_part", o = { "Head", "Torso", "Closest Part", "Nearest Bone" }, d = { "Head" }, req = true },
    { k = "slider", n = "y offset", f = "aim_y_offset", min = -3, max = 3, d = -0.6, dec = 2 },
    { k = "slider", n = "fov size", f = "aim_fov", min = 0, max = 1000, d = 120 },
    { k = "toggle", n = "visualise fov", f = "aim_fov_visualise", d = false },
    { k = "slider", n = "smoothing", f = "aim_smooth", min = 0, max = 100, d = 0 },
    { k = "slider", n = "prediction", f = "aim_prediction", min = 0, max = 0.3, d = 0, dec = 3 },
    { k = "toggle", n = "wall check", f = "aim_wall_check", d = false },
    { k = "toggle", n = "team check", f = "aim_team_check", d = false },
})

y = 0
y = block(main, "combat", 2, y, "rapid fire", {
    { k = "toggle", n = "enabled", f = "rapid_enabled", d = false },
    { k = "slider", n = "shots per second", f = "rapid_rate", min = 1, max = 120, d = 20 },
    { k = "toggle", n = "require ammo", f = "rapid_require_ammo", d = true },
})
y = block(main, "combat", 2, y, "hitbox expander", {
    { k = "toggle", n = "enabled", f = "hitbox_enabled", d = false },
    { k = "dropdown", n = "target", f = "hitbox_target", o = { "All Players", "Aim Target" }, d = { "All Players" }, req = true },
    { k = "slider", n = "size", f = "hitbox_size", min = 1, max = 60, d = 12, dec = 1 },
    { k = "slider", n = "transparency", f = "hitbox_transparency", min = 0, max = 1, d = 0.6, dec = 2 },
    { k = "dropdown", n = "part", f = "hitbox_part", o = { "HumanoidRootPart", "Head", "Torso", "UpperTorso", "LowerTorso", "All Body" }, d = { "HumanoidRootPart" }, req = true },
})
y = block(main, "combat", 2, y, "targets", {
    { k = "toggle", n = "prefer closest", f = "target_closest", d = true },
    { k = "toggle", n = "prefer lowest health", f = "target_lowest", d = false },
    { k = "toggle", n = "ignore friends", f = "target_friends", d = false },
    { k = "slider", n = "max distance", f = "target_distance", min = 0, max = 1000, d = 500 },
})

-- visuals --------------------------------------------------------------
y = 0
y = block(main, "visuals", 1, y, "player esp", {
    { k = "toggle", n = "enabled", f = "esp_enabled", d = false },
    { k = "toggle", n = "box", f = "esp_box", d = true },
    { k = "toggle", n = "name", f = "esp_name", d = true },
    { k = "toggle", n = "distance", f = "esp_distance", d = true },
    { k = "toggle", n = "health bar", f = "esp_health", d = true },
    { k = "toggle", n = "held tool", f = "esp_tool", d = false },
    { k = "slider", n = "max distance", f = "esp_max_distance", min = 0, max = 2000, d = 500 },
})

y = 0
y = block(main, "visuals", 2, y, "world", {
    { k = "toggle", n = "fullbright", f = "world_fullbright", d = false },
    { k = "toggle", n = "remove fog", f = "world_no_fog", d = false },
    { k = "slider", n = "time of day", f = "world_time", min = 0, max = 24, d = 14, dec = 1 },
})

-- misc -----------------------------------------------------------------
y = 0
y = block(main, "misc", 1, y, "skin changer", {
    { k = "toggle", n = "enabled", f = "skin_enabled", d = false },
    { k = "dropdown", n = "material", f = "skin_material", o = { "ForceField", "Keep", "Neon", "Glass", "Plastic", "SmoothPlastic", "Metal", "Ice" }, d = { "ForceField" }, req = true },
    { k = "colorpicker", n = "skin colour", f = "skin_color" },
    { k = "slider", n = "transparency", f = "skin_transparency", min = 0, max = 1, d = 0.45, dec = 2 },
})
y = block(main, "misc", 1, y, "avatar", {
    { k = "toggle", n = "aura", f = "avatar_aura", d = false },
    { k = "toggle", n = "china hat", f = "avatar_china_hat", d = false },
})
y = block(main, "misc", 1, y, "fake macro", {
    { k = "toggle", n = "enabled", f = "macro_enabled", d = false },
    { k = "slider", n = "walkspeed", f = "macro_walkspeed", min = 16, max = 500, d = 100 },
})
y = block(main, "misc", 1, y, "legit macro", {
    { k = "toggle", n = "enabled", f = "legit_enabled", d = false },
    { k = "keybind", n = "bind", f = "legit_key", d = Enum.KeyCode.X },
    { k = "slider", n = "delay", f = "legit_delay", min = 0, max = 200, d = 0, suffix = "ms" },
})

y = 0
y = block(main, "misc", 2, y, "interface", {
    { k = "toggle", n = "watermark", f = "ui_watermark", d = false },
    { k = "toggle", n = "keybind list", f = "ui_keybind_list", d = false },
    { k = "slider", n = "menu scale", f = "ui_scale", min = 80, max = 120, d = 100, suffix = "%" },
})
y = block(main, "misc", 2, y, "crosshair", {
    { k = "toggle", n = "enabled", f = "crosshair_enabled", d = false },
    { k = "colorpicker", n = "colour", f = "crosshair_color", d = Color3.fromRGB(255, 121, 198) },
    { k = "toggle", n = "spin", f = "crosshair_spin", d = true },
    { k = "toggle", n = "resize", f = "crosshair_resize", d = true },
})

-- configs (juju's own config list, info and editor) ---------------------
pcall(function()
    menu:setup_configs("settings")
end)

print("[tea.cc] build " .. VERSION .. " loaded - aim key " .. tostring(flags["aim_key"]))

-- ================================================================== runtime ===
-- Every feature below reads juju's flags live. Nothing here hard-codes a value
-- that the menu owns.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = workspace
local Client = Players.LocalPlayer

local function fget(name, default)
    local value = flags[name]
    if value == nil then
        return default
    end
    return value
end

local function first(value, default)
    if type(value) == "table" then
        return value[1] or default
    end
    if type(value) == "string" then
        return value
    end
    if value == nil then
        return default
    end
    return value
end

local function velocity_of(part)
    local velocity = part.AssemblyLinearVelocity
    if velocity.Magnitude == 0 then
        velocity = part.Velocity
    end
    return velocity
end

-- juju writes keybinds as whatever the widget stored: an EnumItem, a table
-- wrapping one, or the name. IsKeyDown explodes on anything but an EnumItem,
-- so the shape is resolved here instead of at the call site.
local function key_of(binding)
    if typeof(binding) == "EnumItem" then
        return binding
    end

    if type(binding) == "table" then
        local inner = binding.key or binding[1] or binding.value
        if typeof(inner) == "EnumItem" then
            return inner
        end
        if type(inner) == "string" then
            local ok, item = pcall(function()
                return Enum.KeyCode[inner]
            end)
            if ok then
                return item
            end
        end
        return nil
    end

    if type(binding) == "string" then
        local ok, item = pcall(function()
            return Enum.KeyCode[binding]
        end)
        if ok then
            return item
        end
    end

    return nil
end

local function key_down(binding)
    local key = key_of(binding)
    if not key then
        return false
    end
    return UserInputService:IsKeyDown(key)
end

-- juju reloads the last saved config on boot, so a binding saved by an older
-- build outlives a default change. Only a missing or unusable binding is
-- rewritten here - a deliberate rebind is left alone.
if not key_of(flags["aim_key"]) then
    flags["aim_key"] = Enum.KeyCode.Q
end

-- ------------------------------------------------------------------ aimbot ---
local Aim = { player = nil, part = nil, locked = nil }

do
    local BONE_ORDER = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" }

    local circle = nil
    if typeof(Drawing) == "table" and type(Drawing.new) == "function" then
        local ok, created = pcall(Drawing.new, "Circle")
        if ok and created then
            circle = created
            circle.Thickness = 1
            circle.Filled = false
            circle.Color = Color3.fromRGB(255, 121, 198)
            circle.Visible = false
        end
    end

    local function part_for(character, mode)
        if mode == "Torso" then
            local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
            if torso and torso:IsA("BasePart") then
                return torso
            end
        elseif mode == "Closest Part" then
            local my_root = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
            local best, best_distance = nil, math.huge
            for _, name in BONE_ORDER do
                local part = character:FindFirstChild(name)
                if part and part:IsA("BasePart") and my_root then
                    local distance = (part.Position - my_root.Position).Magnitude
                    if distance < best_distance then
                        best, best_distance = part, distance
                    end
                end
            end
            if best then
                return best
            end
        elseif mode == "Nearest Bone" then
            for _, name in BONE_ORDER do
                local part = character:FindFirstChild(name)
                if part and part:IsA("BasePart") then
                    return part
                end
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

    local function blocked(origin, position, character)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { Client.Character, character }
        params.IgnoreWater = true
        return Workspace:Raycast(origin, position - origin, params) ~= nil
    end

    local function usable(player)
        if not player or player == Client then
            return false
        end

        local character = player.Character
        if not character then
            return false
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            return false
        end

        if fget("aim_team_check", false) and Client.Team and player.Team == Client.Team then
            return false
        end

        local effects = character:FindFirstChild("BodyEffects")
        local ko = effects and effects:FindFirstChild("K.O")
        if ko and ko.Value then
            return false
        end

        if character:FindFirstChild("GRABBING_CONSTRAINT") then
            return false
        end

        if character:FindFirstChildOfClass("ForceField") then
            return false
        end

        return true
    end

    -- Same metric as the working camlock: viewport centre, not cursor, and
    -- WorldToViewportPoint rather than WorldToScreenPoint so the gui inset
    -- does not shift the ring off the crosshair.
    local function nearest()
        local camera = Workspace.CurrentCamera
        if not camera then
            return nil, nil
        end

        local radius = fget("aim_fov", 120)
        local centre = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local my_root = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
        local max_distance = fget("target_distance", 500)
        local mode = first(fget("aim_hit_part", { "Head" }), "Head")
        local prediction = fget("aim_prediction", 0)
        local wall = fget("aim_wall_check", false)
        local origin = camera.CFrame.Position

        local best, best_part, best_distance = nil, nil, math.huge

        for _, player in Players:GetPlayers() do
            if usable(player) then
                local character = player.Character
                local part = part_for(character, mode)

                if part then
                    local in_range = not my_root
                        or (my_root.Position - part.Position).Magnitude <= max_distance
                    local goal = part.Position + velocity_of(part) * prediction
                    local clear = not wall or not blocked(origin, goal, character)

                    if in_range and clear then
                        local point, visible = camera:WorldToViewportPoint(goal)
                        if visible then
                            local distance = (Vector2.new(point.X, point.Y) - centre).Magnitude
                            if distance <= radius and distance < best_distance then
                                best, best_part, best_distance = player, part, distance
                            end
                        end
                    end
                end
            end
        end

        return best, best_part
    end

    -- Toggle mode reads the key as an edge, hold mode reads it as a level.
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        if not fget("aim_enabled", true) then
            return
        end
        if first(fget("aim_activation", { "Toggle" }), "Toggle") ~= "Toggle" then
            return
        end
        if input.KeyCode ~= key_of(fget("aim_key", Enum.KeyCode.Q)) then
            return
        end

        if Aim.locked then
            Aim.locked = nil
            return
        end

        local player = nearest()
        if player then
            Aim.locked = player
        end
    end)

    function Aim.step(dt)
        local camera = Workspace.CurrentCamera
        if not camera then
            return
        end

        if circle then
            circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            circle.Radius = fget("aim_fov", 120)
            circle.Visible = fget("aim_enabled", true) and fget("aim_fov_visualise", false)
        end

        if not fget("aim_enabled", true) then
            Aim.player, Aim.part, Aim.locked = nil, nil, nil
            return
        end

        local activation = first(fget("aim_activation", { "Toggle" }), "Toggle")
        local target_player = nil

        if activation == "Hold" then
            if key_down(fget("aim_key", Enum.KeyCode.Q)) then
                target_player = nearest()
            end
        elseif Aim.locked then
            local character = Aim.locked.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if character and humanoid and humanoid.Health > 0 then
                target_player = Aim.locked
            else
                Aim.locked = nil
            end
        end

        local part = nil
        if target_player and target_player.Character then
            part = part_for(target_player.Character, first(fget("aim_hit_part", { "Head" }), "Head"))
        end

        Aim.player, Aim.part = target_player, part

        if not part then
            return
        end

        local lock_position = part.Position
            + velocity_of(part) * fget("aim_prediction", 0)
            + Vector3.new(0, fget("aim_y_offset", -0.6), 0)

        local smooth = math.clamp(fget("aim_smooth", 0) / 100, 0, 1)
        local goal = CFrame.new(camera.CFrame.Position, lock_position)

        -- 0 is the raw snap, identical to CFrame.new(pos, lock_pos). Anything
        -- above it damps the angular step: the exponent keeps the low end
        -- responsive so 10 still tracks a strafing target, while 100 crawls
        -- in over roughly half a second, which is where it reads as legit.
        if smooth <= 0 then
            camera.CFrame = goal
        else
            local base = 1 - (smooth ^ 0.6) * 0.97
            local alpha = 1 - (1 - base) ^ (dt * 60)
            camera.CFrame = camera.CFrame:Lerp(goal, alpha)
        end
    end

    getgenv().TeaAim = Aim
end

-- -------------------------------------------------------------- rapid fire ---
-- User's utility source, kept structurally intact and wired to the flags.
-- get_gun is re-evaluated every tick so a reload or a tool swap cannot leave
-- the loop driving a dead handle.
do
    local utility = {}
    local config = getgenv().config or {}
    getgenv().config = config

    utility.get_gun = function()
        local character = Client.Character
        if not character then
            return nil
        end
        for _, tool in next, character:GetChildren() do
            if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
                return tool
            end
        end
        return nil
    end

    utility.rapid = function(tool)
        tool:Activate()
    end

    getgenv().is_firing = false

    local function loop()
        while getgenv().is_firing do
            config.enable = fget("rapid_enabled", false)
            config.delay = 1 / math.max(fget("rapid_rate", 20), 1)

            if not config.enable then
                getgenv().is_firing = false
                break
            end

            local gun = utility.get_gun()
            if gun then
                utility.rapid(gun)
            elseif fget("rapid_require_ammo", true) then
                getgenv().is_firing = false
                break
            end

            task.wait(config.delay)
        end
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        if not fget("rapid_enabled", false) then
            return
        end
        if utility.get_gun() == nil then
            return
        end
        if getgenv().is_firing then
            return
        end
        getgenv().is_firing = true
        task.spawn(loop)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            getgenv().is_firing = false
        end
    end)
end

-- ---------------------------------------------------------- hitbox expander ---
-- Size is reasserted every frame instead of once. Da Hood's own replication
-- writes the root's size back whenever the character moves, which is what made
-- the old build look like it was flickering off. Restore happens only when a
-- character leaves the wanted set, so there is no restore/re-apply strobe.
do
    local Expanded = {}

    local function parts_for(character)
        local mode = first(fget("hitbox_part", { "HumanoidRootPart" }), "HumanoidRootPart")
        local out = {}

        local function add(name)
            local part = character:FindFirstChild(name)
            if part and part:IsA("BasePart") then
                table.insert(out, part)
            end
        end

        if mode == "Head" then
            add("Head")
        elseif mode == "Torso" then
            add("Torso")
            add("UpperTorso")
        elseif mode == "UpperTorso" then
            add("UpperTorso")
        elseif mode == "LowerTorso" then
            add("LowerTorso")
        elseif mode == "All Body" then
            add("HumanoidRootPart")
            add("Head")
            add("Torso")
            add("UpperTorso")
            add("LowerTorso")
        else
            add("HumanoidRootPart")
        end

        return out
    end

    local function restore(character)
        local record = Expanded[character]
        if not record then
            return
        end
        Expanded[character] = nil

        for part, original in record do
            if part and part.Parent then
                pcall(function()
                    part.Size = original.Size
                    part.Transparency = original.Transparency
                    part.CanCollide = original.CanCollide
                end)
            end
        end
    end

    local function expand(character)
        local record = Expanded[character]
        if not record then
            record = {}
            Expanded[character] = record
        end

        local size = fget("hitbox_size", 12)
        local transparency = fget("hitbox_transparency", 0.6)
        local vector = Vector3.new(size, size, size)

        for _, part in parts_for(character) do
            if not record[part] then
                record[part] = {
                    Size = part.Size,
                    Transparency = part.Transparency,
                    CanCollide = part.CanCollide,
                }
            end

            pcall(function()
                part.Size = vector
                part.Transparency = transparency
                part.CanCollide = false
            end)
        end
    end

    function Aim.sweep_hitboxes()
        if not fget("hitbox_enabled", false) then
            for character in Expanded do
                restore(character)
            end
            return
        end

        local wanted = {}
        local mode = first(fget("hitbox_target", { "All Players" }), "All Players")

        if mode == "Aim Target" then
            local character = Aim.player and Aim.player.Character
            if character then
                wanted[character] = true
            end
        else
            for _, player in Players:GetPlayers() do
                if player ~= Client and player.Character then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        wanted[player.Character] = true
                    end
                end
            end
        end

        for character in Expanded do
            if not wanted[character] then
                restore(character)
            end
        end

        for character in wanted do
            expand(character)
        end
    end

    getgenv().TeaHitboxRestore = function()
        for character in Expanded do
            restore(character)
        end
    end
end

-- ------------------------------------------------------------------ avatar ---
-- Aura and china hat, both rebuilt against the live character so a respawn
-- cannot leave a stale instance welded to a dead head. Flag off destroys.
local Avatar = {}

do
    local Aura = { instance = nil }
    local Hat = { instance = nil }

    local function aura_anchor(character)
        return character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
    end

    local function build_aura(character)
        local anchor = aura_anchor(character)
        if not anchor then
            return nil
        end

        local attachment = Instance.new("Attachment")
        attachment.Name = "TeaAura"

        local healing_one = Instance.new("ParticleEmitter")
        healing_one.Name = "Healing Wave 1"
        healing_one.Lifetime = NumberRange.new(1.5, 1.5)
        healing_one.SpreadAngle = Vector2.new(10, -10)
        healing_one.LockedToPart = true
        healing_one.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.1702454, 0.7, 0.014881),
            NumberSequenceKeypoint.new(0.2254601, 0.03125, 0.03125),
            NumberSequenceKeypoint.new(0.2852761, 0),
            NumberSequenceKeypoint.new(0.702454, 0),
            NumberSequenceKeypoint.new(0.8374233, 0.9125, 0.0601461),
            NumberSequenceKeypoint.new(1, 1),
        })
        healing_one.LightEmission = 0.4
        healing_one.Color = ColorSequence.new(Color3.fromRGB(234, 8, 255))
        healing_one.VelocitySpread = 10
        healing_one.Speed = NumberRange.new(3, 6)
        healing_one.Brightness = 10
        healing_one.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 3.0624998, 1.8805969),
            NumberSequenceKeypoint.new(0.6420546, 1.9999999, 1.7619393),
            NumberSequenceKeypoint.new(1, 0.7499999, 0.7499999),
        })
        healing_one.Rate = 20
        healing_one.Texture = "rbxassetid://8047533775"
        healing_one.RotSpeed = NumberRange.new(200, 400)
        healing_one.Rotation = NumberRange.new(-180, 180)
        healing_one.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
        healing_one.Parent = attachment

        local healing_two = Instance.new("ParticleEmitter")
        healing_two.Name = "Healing Wave 2"
        healing_two.Lifetime = NumberRange.new(1.5, 1.5)
        healing_two.SpreadAngle = Vector2.new(10, -10)
        healing_two.LockedToPart = true
        healing_two.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.2254601, 0.03125, 0.03125),
            NumberSequenceKeypoint.new(0.6288344, 0.25625, 0.0593491),
            NumberSequenceKeypoint.new(0.8374233, 0.9125, 0.0601461),
            NumberSequenceKeypoint.new(1, 1),
        })
        healing_two.LightEmission = 1
        healing_two.Color = ColorSequence.new(Color3.fromRGB(238, 3, 255))
        healing_two.VelocitySpread = 10
        healing_two.Speed = NumberRange.new(3, 5)
        healing_two.Brightness = 10
        healing_two.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 3.125),
            NumberSequenceKeypoint.new(0.4165329, 1.3749999, 1.3749999),
            NumberSequenceKeypoint.new(1, 0.9375, 0.9375),
        })
        healing_two.Rate = 20
        healing_two.Texture = "rbxassetid://8047796070"
        healing_two.RotSpeed = NumberRange.new(100, 300)
        healing_two.Rotation = NumberRange.new(-180, 180)
        healing_two.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
        healing_two.Parent = attachment

        local sparks = Instance.new("ParticleEmitter")
        sparks.Name = "Sparks"
        sparks.Lifetime = NumberRange.new(0.5, 2)
        sparks.SpreadAngle = Vector2.new(180, -180)
        sparks.LightEmission = 1
        sparks.Color = ColorSequence.new(Color3.fromRGB(255, 21, 255))
        sparks.Drag = 3
        sparks.VelocitySpread = 180
        sparks.Speed = NumberRange.new(5, 15)
        sparks.Brightness = 10
        sparks.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.14687, 0.4374999, 0.1875001),
            NumberSequenceKeypoint.new(1, 0),
        })
        sparks.Acceleration = Vector3.new(0, 3, 0)
        sparks.ZOffset = -1
        sparks.Rate = 40
        sparks.Texture = "rbxassetid://8611887361"
        sparks.RotSpeed = NumberRange.new(-30, 30)
        sparks.Orientation = Enum.ParticleOrientation.VelocityParallel
        sparks.Parent = attachment

        local star_sparks = Instance.new("ParticleEmitter")
        star_sparks.Name = "Star Sparks"
        star_sparks.Lifetime = NumberRange.new(1.5, 1.5)
        star_sparks.SpreadAngle = Vector2.new(180, -180)
        star_sparks.LightEmission = 1
        star_sparks.Color = ColorSequence.new(Color3.fromRGB(226, 60, 255))
        star_sparks.Drag = 3
        star_sparks.VelocitySpread = 180
        star_sparks.Speed = NumberRange.new(5, 10)
        star_sparks.Brightness = 10
        star_sparks.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.1492777, 0.6874996, 0.6874996),
            NumberSequenceKeypoint.new(1, 0),
        })
        star_sparks.Acceleration = Vector3.new(0, 3, 0)
        star_sparks.ZOffset = 2
        star_sparks.Texture = "rbxassetid://8611887703"
        star_sparks.RotSpeed = NumberRange.new(-30, 30)
        star_sparks.Rotation = NumberRange.new(-30, 30)
        star_sparks.Parent = attachment

        attachment.Parent = anchor
        return attachment
    end

    local function build_hat(character)
        local head = character:FindFirstChild("Head")
        if not head then
            return nil
        end

        local cone = Instance.new("Part")
        cone.Name = "TeaChinaHat"
        cone.Size = Vector3.new(1, 1, 1)
        cone.BrickColor = BrickColor.new("Hot pink")
        cone.Material = Enum.Material.Neon
        cone.Transparency = 0.2
        cone.Anchored = false
        cone.CanCollide = false
        cone.Massless = true
        cone.CastShadow = false
        cone.Color = Color3.fromRGB(255, 105, 180)

        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://1033714"
        mesh.Scale = Vector3.new(1.7, 1.1, 1.7)
        mesh.Parent = cone

        local weld = Instance.new("Weld")
        weld.Part0 = head
        weld.Part1 = cone
        weld.C0 = CFrame.new(0, 0.9, 0)
        weld.Parent = cone

        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 105, 180)
        light.Brightness = 0
        light.Range = 12
        light.Shadows = true
        light.Parent = cone

        cone.Parent = character
        return cone
    end

    function Avatar.step()
        local character = Client.Character

        local aura_wanted = fget("avatar_aura", false) and character
        local aura_alive = Aura.instance
            and Aura.instance.Parent
            and Aura.instance.Parent == (character and aura_anchor(character))

        if aura_wanted and not aura_alive then
            if Aura.instance then
                Aura.instance:Destroy()
            end
            Aura.instance = build_aura(character)
        elseif not aura_wanted and Aura.instance then
            Aura.instance:Destroy()
            Aura.instance = nil
        end

        local hat_wanted = fget("avatar_china_hat", false) and character
        local hat_alive = Hat.instance
            and Hat.instance.Parent
            and Hat.instance.Parent == character

        if hat_wanted and not hat_alive then
            if Hat.instance then
                Hat.instance:Destroy()
            end
            Hat.instance = build_hat(character)
        elseif not hat_wanted and Hat.instance then
            Hat.instance:Destroy()
            Hat.instance = nil
        end
    end
end

-- --------------------------------------------------------------- walkspeed ---
-- Lives in the fake macro slot. Reasserted every frame: the game rewrites
-- WalkSpeed on respawn, on ragdoll and on any server-side speed correction.
-- The captured value is restored the moment the toggle drops.
local Walkspeed = { humanoid = nil, original = nil }

function Walkspeed.step()
    local character = Client.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local wanted = fget("macro_enabled", false) and humanoid

    if wanted then
        if Walkspeed.humanoid ~= humanoid then
            Walkspeed.humanoid = humanoid
            Walkspeed.original = humanoid.WalkSpeed
        end

        local speed = fget("macro_walkspeed", 100)
        if humanoid.WalkSpeed ~= speed then
            humanoid.WalkSpeed = speed
        end
    elseif Walkspeed.humanoid then
        if Walkspeed.humanoid.Parent and Walkspeed.original then
            Walkspeed.humanoid.WalkSpeed = Walkspeed.original
        end
        Walkspeed.humanoid = nil
        Walkspeed.original = nil
    end
end


-- ------------------------------------------------------------- legit macro ---
-- Mouse wheel down/up on a Heartbeat cadence, toggled from the bound key. The
-- wheel is the input the game reads for the emote/weapon flip this imitates.
-- delay stretches the gap between the down and the up; 0 keeps the source's
-- one-heartbeat spacing.
local Legit = { active = false }

do
    local vim = game:GetService("VirtualInputManager")

    local function wheel(down)
        vim:SendMouseWheelEvent(0.1, 0.1, down, game)
    end

    local function loop()
        while Legit.active do
            if not fget("legit_enabled", false) then
                Legit.active = false
                break
            end

            RunService.Heartbeat:Wait()
            wheel(true)

            local delay = fget("legit_delay", 0) / 1000
            if delay > 0 then
                task.wait(delay)
            end

            RunService.Heartbeat:Wait()
            wheel(false)
            RunService.Heartbeat:Wait()
        end
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        if not fget("legit_enabled", false) then
            return
        end
        if input.KeyCode ~= key_of(fget("legit_key", Enum.KeyCode.X)) then
            return
        end

        if Legit.active then
            Legit.active = false
        else
            Legit.active = true
            task.spawn(loop)
        end
    end)

    getgenv().TeaLegit = Legit
end

-- ---------------------------------------------------------------- crosshair ---
-- Spinning, breathing four-line crosshair. Mouse-anchored, pink by default,
-- no label text under it. Everything the source had as a constant is a flag.
local Crosshair = {}

do
    local ready = typeof(Drawing) == "table" and type(Drawing.new) == "function"
    local lines = {}

    if ready then
        for index = 1, 8 do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = 1.5
            lines[index] = line
        end
    end

    local function solve(angle, radius)
        return Vector2.new(
            math.sin(math.rad(angle)) * radius,
            math.cos(math.rad(angle)) * radius
        )
    end

    function Crosshair.step()
        if not ready then
            return
        end

        local enabled = fget("crosshair_enabled", false)

        for index = 1, 8 do
            lines[index].Visible = enabled
        end

        if not enabled or not Workspace.CurrentCamera then
            return
        end

        local colour = flags["crosshair_color"] or Color3.fromRGB(255, 121, 198)
        local position = UserInputService:GetMouseLocation()
        local now = tick()

        local radius = 11
        local width = 1.5
        local length = 10

        for index = 1, 4 do
            local outline = lines[index]
            local inline = lines[index + 4]
            local angle = (index - 1) * 90

            if fget("crosshair_spin", true) then
                local spin = -now * 150 % 340
                angle = angle
                    + TweenService:GetValue(
                        spin / 360,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ) * 360
            end

            if fget("crosshair_resize", true) then
                local stretch = now * 150 % 180
                length = 5 + math.sin(math.rad(stretch)) * 22
            end

            inline.Color = colour
            inline.From = position + solve(angle, radius)
            inline.To = position + solve(angle, radius + length)
            inline.Thickness = width

            outline.Color = colour
            outline.From = position + solve(angle, radius - 1)
            outline.To = position + solve(angle, radius + length + 1)
            outline.Thickness = width + 1.5
        end
    end
end

-- --------------------------------------------------------------------- loop ---
-- RenderStepped, not BindToRenderStep: the default camera module runs inside
-- the camera-priority step, so a CFrame written there is overwritten before
-- the frame draws. RenderStepped fires after every render step, so the write
-- survives to the render - which is why the plain camlock loop works.
getgenv().TeaRuntimeConnection = RunService.RenderStepped:Connect(function(dt)
    Aim.step(dt)
    Aim.sweep_hitboxes()
    Avatar.step()
    Walkspeed.step()
    Crosshair.step()
end)

-- ------------------------------------------------------------------ unload ---
getgenv().TeaUnload = function()
    pcall(function()
        if getgenv().TeaRuntimeConnection then
            getgenv().TeaRuntimeConnection:Disconnect()
            getgenv().TeaRuntimeConnection = nil
        end
    end)
    pcall(getgenv().TeaHitboxRestore)
    getgenv().is_firing = false

    if Walkspeed.humanoid and Walkspeed.humanoid.Parent and Walkspeed.original then
        Walkspeed.humanoid.WalkSpeed = Walkspeed.original
    end
    Walkspeed.humanoid = nil
    Walkspeed.original = nil
end

-- ----------------------------------------------------------------- finish ---
getgenv().TeaJujuMenu = menu
getgenv().TeaJujuFlags = flags

return menu

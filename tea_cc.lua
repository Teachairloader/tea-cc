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

    This revision adds a runtime layer below the layout: aimbot (replaces
    silent aim), triggerbot, rapid fire (driven by the user's own utility
    source, now flag-driven), hitbox expander (reasserted every frame so the
    game's own replication cannot shrink it back). Weapon section removed.
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

    section:create_element({ name = row.n }, properties, true)
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
local main = menu.create_group("main")
main:create_tab("combat")
main:create_tab("visuals")
main:create_tab("players")
main:create_tab("misc")

-- combat ---------------------------------------------------------------
local y = 0
y = block(main, "combat", 1, y, "aimbot", {
    { k = "toggle", n = "enabled", f = "aim_enabled", d = false },
    { k = "keybind", n = "aim key", f = "aim_key", d = Enum.KeyCode.F },
    { k = "dropdown", n = "mode", f = "aim_mode", o = { "Mouse", "Camera" }, d = { "Mouse" }, req = true },
    { k = "slider", n = "smoothing", f = "aim_smooth", min = 0, max = 100, d = 25 },
    { k = "slider", n = "fov size", f = "aim_fov", min = 0, max = 1000, d = 300 },
    { k = "toggle", n = "visualise fov", f = "aim_fov_visualise", d = false },
    { k = "dropdown", n = "hit part", f = "aim_hit_part", o = { "Head", "Torso", "Closest Part", "Nearest Bone" }, d = { "Head" }, req = true },
    { k = "slider", n = "prediction", f = "aim_prediction", min = 0, max = 0.3, d = 0.15, dec = 3 },
    { k = "toggle", n = "wall check", f = "aim_wall_check", d = true },
    { k = "toggle", n = "team check", f = "aim_team_check", d = false },
    { k = "slider", n = "hit chance", f = "aim_hit_chance", min = 0, max = 100, d = 100, suffix = "%" },
})
y = block(main, "combat", 1, y, "triggerbot", {
    { k = "toggle", n = "enabled", f = "trigger_enabled", d = false },
    { k = "keybind", n = "trigger key", f = "trigger_key", d = Enum.KeyCode.F },
    { k = "slider", n = "fire rate", f = "trigger_rate", min = 1, max = 60, d = 20 },
    { k = "slider", n = "crosshair range", f = "trigger_range", min = 5, max = 120, d = 35 },
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
y = block(main, "visuals", 1, y, "item esp", {
    { k = "toggle", n = "knives", f = "items_knives", d = false },
    { k = "toggle", n = "armor", f = "items_armor", d = false },
    { k = "toggle", n = "ammo", f = "items_ammo", d = false },
    { k = "slider", n = "range", f = "items_range", min = 0, max = 2000, d = 500 },
})

y = 0
y = block(main, "visuals", 2, y, "world", {
    { k = "toggle", n = "fullbright", f = "world_fullbright", d = false },
    { k = "toggle", n = "remove fog", f = "world_no_fog", d = false },
    { k = "slider", n = "time of day", f = "world_time", min = 0, max = 24, d = 14, dec = 1 },
})
y = block(main, "visuals", 2, y, "fov changer", {
    { k = "toggle", n = "enabled", f = "cam_enabled", d = false },
    { k = "slider", n = "field of view", f = "cam_fov", min = 40, max = 180, d = 120, dec = 1 },
})

-- players --------------------------------------------------------------
y = 0
y = block(main, "players", 2, y, "esp preview", {
    { k = "toggle", n = "show preview", f = "esp_preview", d = true },
    { k = "toggle", n = "show health bar", f = "esp_preview_health", d = true },
    { k = "toggle", n = "show distance", f = "esp_preview_distance", d = true },
    { k = "toggle", n = "show held tool", f = "esp_preview_tool", d = false },
})

-- misc -----------------------------------------------------------------
y = 0
y = block(main, "misc", 1, y, "skin changer", {
    { k = "toggle", n = "enabled", f = "skin_enabled", d = false },
    { k = "dropdown", n = "material", f = "skin_material", o = { "ForceField", "Keep", "Neon", "Glass", "Plastic", "SmoothPlastic", "Metal", "Ice" }, d = { "ForceField" }, req = true },
    { k = "colorpicker", n = "skin colour", f = "skin_color" },
    { k = "slider", n = "transparency", f = "skin_transparency", min = 0, max = 1, d = 0.45, dec = 2 },
})
y = block(main, "misc", 1, y, "teleports", {
    { k = "dropdown", n = "destination", f = "tp_destination", o = { "Bank", "Jewelry Store", "Sewer", "Gas Station", "Spawn" }, d = { "Bank" }, req = true },
    { k = "toggle", n = "use hotkey", f = "tp_key_enabled", d = false },
    { k = "keybind", n = "teleport key", f = "tp_key", d = Enum.KeyCode.T },
})

y = 0
y = block(main, "misc", 2, y, "interface", {
    { k = "toggle", n = "watermark", f = "ui_watermark", d = false },
    { k = "toggle", n = "keybind list", f = "ui_keybind_list", d = false },
    { k = "slider", n = "menu scale", f = "ui_scale", min = 80, max = 120, d = 100, suffix = "%" },
})

-- configs (juju's own config list, info and editor) ---------------------
pcall(function()
    menu:setup_configs("settings")
end)

-- ================================================================== runtime ===
-- Every feature below reads juju's flags live. Nothing here hard-codes a value
-- that the menu owns.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
local function key_down(binding)
    if typeof(binding) == "EnumItem" then
        return UserInputService:IsKeyDown(binding)
    end

    if type(binding) == "table" then
        local inner = binding.key or binding[1] or binding.value
        if typeof(inner) == "EnumItem" then
            return UserInputService:IsKeyDown(inner)
        end
        if type(inner) == "string" then
            local ok, item = pcall(function()
                return Enum.KeyCode[inner]
            end)
            if ok and item then
                return UserInputService:IsKeyDown(item)
            end
        end
        return false
    end

    if type(binding) == "string" then
        local ok, item = pcall(function()
            return Enum.KeyCode[binding]
        end)
        if ok and item then
            return UserInputService:IsKeyDown(item)
        end
    end

    return false
end

-- ------------------------------------------------------------------ aimbot ---
local Aim = { player = nil, part = nil }

do
    local Camera = Workspace.CurrentCamera
    local Mouse = Client:GetMouse()
    local BONE_ORDER = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" }
    local saved_camera_type = nil

    -- A camera CFrame write is discarded by the default camera script unless
    -- the type is Scriptable, which is why a plain lerp looks like no aim at
    -- all. The original type is remembered and put back on release.
    local function restore_camera()
        if saved_camera_type and Camera then
            pcall(function()
                Camera.CameraType = saved_camera_type
            end)
        end
        saved_camera_type = nil
    end

    getgenv().TeaRestoreCamera = restore_camera

    local circle = nil
    if typeof(Drawing) == "table" and type(Drawing.new) == "function" then
        local ok, created = pcall(Drawing.new, "Circle")
        if ok and created then
            circle = created
            circle.Thickness = 1.6
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

    local function select_target()
        -- the camera instance is replaced on respawn and on spectate, so a
        -- reference captured at load goes stale and every projection fails
        Camera = Workspace.CurrentCamera
        if not Camera then
            return nil, nil
        end

        local radius = fget("aim_fov", 300)
        local centre = Vector2.new(Mouse.X, Mouse.Y)
        local my_root = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
        local max_distance = fget("target_distance", 500)
        local mode = first(fget("aim_hit_part", { "Head" }), "Head")
        local prediction = fget("aim_prediction", 0.15)
        local wall = fget("aim_wall_check", true)
        local origin = Camera.CFrame.Position

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
                        local point, on_screen = Camera:WorldToScreenPoint(goal)
                        if on_screen then
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

    function Aim.step(dt)
        Camera = Workspace.CurrentCamera
        if not Camera then
            return
        end

        if circle then
            circle.Position = Vector2.new(Mouse.X, Mouse.Y)
            circle.Radius = fget("aim_fov", 300)
            circle.Visible = fget("aim_enabled", false) and fget("aim_fov_visualise", false)
        end

        local aiming = fget("aim_enabled", false)
        if (not aiming and not fget("trigger_enabled", false)) or not Camera then
            restore_camera()
            Aim.player, Aim.part = nil, nil
            return
        end

        local player, part = select_target()
        Aim.player, Aim.part = player, part

        if not aiming or not part then
            restore_camera()
            return
        end

        if not key_down(fget("aim_key", Enum.KeyCode.F)) then
            restore_camera()
            return
        end

        if math.random() * 100 > fget("aim_hit_chance", 100) then
            return
        end

        local goal = part.Position + velocity_of(part) * fget("aim_prediction", 0.15)
        local smooth = math.clamp(fget("aim_smooth", 25) / 100, 0.02, 1)
        local mode = first(fget("aim_mode", { "Mouse" }), "Mouse")
        local can_move_mouse = type(mousemoverel) == "function"

        if mode == "Mouse" and can_move_mouse then
            restore_camera()
            local point, on_screen = Camera:WorldToScreenPoint(goal)
            if not on_screen then
                return
            end
            mousemoverel((point.X - Mouse.X) * smooth, (point.Y - Mouse.Y) * smooth)
        else
            if Camera.CameraType ~= Enum.CameraType.Scriptable then
                saved_camera_type = Camera.CameraType
                Camera.CameraType = Enum.CameraType.Scriptable
            end
            local alpha = 1 - (1 - smooth) ^ (dt * 60)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, goal), alpha)
        end
    end

    getgenv().TeaAim = Aim
end

-- -------------------------------------------------------------- triggerbot ---
local Trigger = { next_fire = 0 }

function Trigger.step()
    if not fget("trigger_enabled", false) then
        return
    end

    if not key_down(fget("trigger_key", Enum.KeyCode.F)) then
        return
    end

    if not Aim.part then
        return
    end

    local point, on_screen = Workspace.CurrentCamera:WorldToScreenPoint(Aim.part.Position)
    if not on_screen then
        return
    end

    local Mouse = Client:GetMouse()
    local offset = (Vector2.new(point.X, point.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
    if offset > fget("trigger_range", 35) then
        return
    end

    local now = os.clock()
    if now < Trigger.next_fire then
        return
    end
    Trigger.next_fire = now + 1 / math.max(fget("trigger_rate", 20), 1)

    if type(mouse1click) == "function" then
        mouse1click()
    end
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

-- --------------------------------------------------------------------- loop ---
RunService:BindToRenderStep("tea_runtime", Enum.RenderPriority.Camera.Value + 1, function(dt)
    Aim.step(dt)
    Aim.sweep_hitboxes()
end)

RunService.Heartbeat:Connect(function()
    Trigger.step()
end)

-- ------------------------------------------------------------------ unload ---
getgenv().TeaUnload = function()
    pcall(function()
        RunService:UnbindFromRenderStep("tea_runtime")
    end)
    pcall(function()
        if getgenv().TeaRestoreCamera then
            getgenv().TeaRestoreCamera()
        end
    end)
    pcall(getgenv().TeaHitboxRestore)
    getgenv().is_firing = false
end

-- ----------------------------------------------------------------- finish ---
getgenv().TeaJujuMenu = menu
getgenv().TeaJujuFlags = flags

return menu

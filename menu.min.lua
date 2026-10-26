local UI_URL = "https://raw.githubusercontent.com/panduh16/juju/main/ui.lua"
local FOLDER = "drift"
local UI_CACHE = FOLDER .. "/ui.lua"
local UI_TTL = 6 * 60 * 60
local UI_TAG = "--[[tea.cc cache:"
getgenv().script_name = "Drift"
getgenv().script_version = ""
getgenv().custom_folder = FOLDER
local function read_cached_ui()
if type(isfile) ~= "function" or type(readfile) ~= "function" then
return nil
end
if not isfile(UI_CACHE) then
return nil
end
local ok, body = pcall(readfile, UI_CACHE)
if not ok or type(body) ~= "string" or #body < 1000 then
return nil
end
if body:sub(1, #UI_TAG) ~= UI_TAG then
return nil
end
local close = body:find("]]", #UI_TAG + 1, true)
if not close then
return nil
end
local stamp = tonumber(body:sub(#UI_TAG + 1, close - 1))
if not stamp or os.time() - stamp > UI_TTL then
return nil
end
local cached = body:sub(close + 2)
if #cached < 1000 then
return nil
end
return cached
end
local function write_cached_ui(body)
if type(writefile) ~= "function" then
return
end
pcall(function()
if type(isfolder) == "function" and type(makefolder) == "function"
and not isfolder(FOLDER) then
makefolder(FOLDER)
end
writefile(UI_CACHE, UI_TAG .. tostring(os.time()) .. "]]\n" .. body)
end)
end
local function drop_cached_ui()
if type(delfile) ~= "function" or type(isfile) ~= "function" then
return
end
if isfile(UI_CACHE) then
pcall(delfile, UI_CACHE)
end
end
local function fetch_remote_ui()
local ok, body = pcall(function()
return game:HttpGet(UI_URL .. "?t=" .. tostring(os.time()))
end)
if not ok or type(body) ~= "string" or #body < 1000 then
return nil, tostring(body)
end
write_cached_ui(body)
return body
end
local source = read_cached_ui()
if source and not loadstring(source) then
drop_cached_ui()
source = nil
end
local fetch_error
if not source then
source, fetch_error = fetch_remote_ui()
end
if not source then
return warn("[tea.cc] could not fetch juju: " .. tostring(fetch_error))
end
local function swap(text, find, replace)
local escaped = find:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")
return (text:gsub(escaped, replace))
end
local BLUE = "154, 213, 222"
if not source:find(BLUE, 1, true) then
warn("[tea.cc] accent triple not found in juju source - upstream changed, colours left stock")
end
source = swap(source, "color3_fromrgb(" .. BLUE .. ")", "color3_fromrgb(255, 255, 255)")
source = swap(source, "color3_fromrgb(51, 65, 70)", "color3_fromrgb(30, 30, 30)")
source = swap(source, "color3_fromrgb(70, 85, 87)", "color3_fromrgb(140, 140, 140)")
source = swap(source, "color3_fromrgb(39, 60, 96)", "color3_fromrgb(58, 58, 58)")
source = swap(source, "color3_fromrgb(30, 51, 61)", "color3_fromrgb(38, 38, 38)")
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
source = lit_(source, "450", "710")
source = lit_(source, "405", "665")
source = lit_(source, "udim2_new(0, 35, 0, 35)", "udim2_new(0, 40, 0, 40)")
source = lit_(source, "\r\n", "\n")
if not source:find("udim2_new(0, 690, 0, 710)", 1, true) then
warn("[drift] juju window anchors moved - frame left at stock 575x450")
end
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
local chunk, compileError = loadstring(source)
if not chunk then
drop_cached_ui()
return warn("[tea.cc] juju failed to compile (cache cleared): " .. tostring(compileError))
end
local okRun, juju = pcall(chunk)
if not okRun or type(juju) ~= "table" or type(juju.menu) ~= "table" then
return warn("[tea.cc] juju failed to load: " .. tostring(juju))
end
local menu = juju.menu
local flags = juju.flags
menu["colors"]["accent"] = Color3.fromRGB(255, 255, 255)
menu["colors"]["shadow"] = Color3.fromRGB(255, 255, 255)
menu["colors"]["success"] = Color3.fromRGB(255, 255, 255)
menu["colors"]["logo"] = Color3.fromRGB(255, 255, 255)
menu["colors"]["juju"] = Color3.fromRGB(255, 255, 255)
menu["colors"]["build"] = Color3.fromRGB(255, 255, 255)
menu["colors"]["cursor"] = Color3.fromRGB(255, 255, 255)
pcall(function()
writefile(
FOLDER .. "/themes/default.th",
'{"!image_color":[89,89,89],"!error_color":[58,58,58],"!accent_color":[255,255,255],'
.. '"!build_color":[255,255,255],"!success_color":[255,255,255],"!active_border_color":[30,30,30],'
.. '"!dark_text_color":[140,140,140],"!juju_color":[255,255,255],"!background_color":[0,0,0],'
.. '"!border_color":[24,25,24],"!keybind_text_color":[197,197,197],"!inactive_text_color":[75,72,72],'
.. '"!shadow_color":[255,255,255],"!active_text_color":[197,197,197],"!alert_color":[38,38,38],'
.. '"!logo_color":[255,255,255],"!section_color":[6,6,6]}'
)
end)
local TAB_HEIGHT = 690 
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
local PINK = Color3.fromRGB(255, 255, 255)
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
if row.k == "keybind" and element and element["set_key"] and not flags[row.f] then
element:set_key(row.d)
end
return element
end
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
local VERSION = "2026-10-25g"
local main = menu.create_group("main")
main:create_tab("combat")
main:create_tab("visuals")
main:create_tab("rage")
main:create_tab("misc")
local y = 0
y = block(main, "combat", 1, y, "camlock", {
{ k = "toggle", n = "enabled", f = "aim_enabled", d = false },
{ k = "dropdown", n = "activation", f = "aim_activation", o = { "Toggle", "Hold" }, d = { "Toggle" }, req = true },
{ k = "keybind", n = "aim key", f = "aim_key", d = Enum.UserInputType.MouseButton2 },
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
{ k = "slider", n = "shots per second", f = "rapid_rate", min = 60, max = 1000, d = 300 },
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
y = 0
y = block(main, "visuals", 1, y, "esp", {
{ k = "toggle", n = "enabled", f = "esp_enabled", d = false },
{ k = "toggle", n = "box", f = "esp_box", d = true },
{ k = "slider", n = "box width", f = "esp_width", min = 0.1, max = 1, d = 0.28, dec = 2 },
{ k = "toggle", n = "name", f = "esp_name", d = true },
{ k = "toggle", n = "distance", f = "esp_distance", d = true },
{ k = "toggle", n = "skeleton", f = "esp_skeleton", d = false },
{ k = "toggle", n = "health bar", f = "esp_health", d = true },
{ k = "toggle", n = "armor bar", f = "esp_armor", d = false },
{ k = "toggle", n = "held tool", f = "esp_tool", d = false },
{ k = "toggle", n = "highlight", f = "esp_highlight", d = false },
{ k = "toggle", n = "team check", f = "esp_team", d = true },
{ k = "slider", n = "text size", f = "esp_text_size", min = 10, max = 24, d = 14 },
{ k = "slider", n = "max distance", f = "esp_max_distance", min = 50, max = 2000, d = 2000 },
})
y = 0
y = block(main, "visuals", 2, y, "interface", {
{ k = "toggle", n = "watermark", f = "ui_watermark", d = false },
{ k = "toggle", n = "keybind list", f = "ui_keybind_list", d = false },
{ k = "slider", n = "menu scale", f = "ui_scale", min = 80, max = 120, d = 100, suffix = "%" },
})
y = block(main, "visuals", 2, y, "crosshair", {
{ k = "toggle", n = "enabled", f = "crosshair_enabled", d = false },
{ k = "colorpicker", n = "colour", f = "crosshair_color", d = Color3.fromRGB(255, 255, 255) },
{ k = "toggle", n = "spin", f = "crosshair_spin", d = true },
{ k = "toggle", n = "resize", f = "crosshair_resize", d = true },
})
y = block(main, "visuals", 2, y, "avatar", {
{ k = "toggle", n = "aura", f = "avatar_aura", d = false },
{ k = "toggle", n = "china hat", f = "avatar_china_hat", d = false },
})
y = 0
y = block(main, "misc", 1, y, "world", {
{ k = "dropdown", n = "lighting", f = "world_preset", o = { "Off", "Red", "Night", "Overcast", "Storm", "Dusk", "Void", "Custom" }, d = { "Off" }, req = true },
{ k = "colorpicker", n = "sky tint", f = "world_sky_top", d = Color3.fromRGB(255, 255, 255) },
{ k = "colorpicker", n = "ground tint", f = "world_sky_bottom", d = Color3.fromRGB(255, 255, 255) },
{ k = "colorpicker", n = "ambient", f = "world_ambient", d = Color3.fromRGB(255, 255, 255) },
{ k = "colorpicker", n = "fog", f = "world_fog", d = Color3.fromRGB(255, 255, 255) },
{ k = "slider", n = "brightness", f = "world_brightness", min = 0, max = 4, d = 2, dec = 2 },
{ k = "slider", n = "time of day", f = "world_clock", min = 0, max = 24, d = 14, dec = 1 },
{ k = "slider", n = "fog distance", f = "world_fog_end", min = 0, max = 5000, d = 800 },
{ k = "slider", n = "exposure", f = "world_exposure", min = -3, max = 3, d = 0, dec = 2 },
{ k = "toggle", n = "fullbright", f = "world_fullbright", d = false },
{ k = "toggle", n = "remove fog", f = "world_no_fog", d = false },
})
y = block(main, "misc", 1, y, "weather", {
{ k = "dropdown", n = "type", f = "world_weather", o = { "None", "Snow", "Rain", "Storm" }, d = { "None" }, req = true },
{ k = "slider", n = "density", f = "world_weather_rate", min = 0, max = 100, d = 55 },
{ k = "slider", n = "size", f = "world_weather_size", min = 0.2, max = 4, d = 1, dec = 1 },
{ k = "slider", n = "fall speed", f = "world_weather_speed", min = 20, max = 200, d = 100 },
{ k = "slider", n = "wind", f = "world_weather_wind", min = -80, max = 80, d = 14 },
{ k = "colorpicker", n = "colour", f = "world_weather_color", d = Color3.fromRGB(235, 244, 255) },
{ k = "toggle", n = "lightning", f = "world_lightning", d = false },
})
y = 0
y = block(main, "misc", 2, y, "skin changer", {
{ k = "toggle", n = "enabled", f = "skin_enabled", d = false },
{ k = "dropdown", n = "skin", f = "skin_choice", o = { "Inferno", "Galaxy", "Matrix", "RedDeath", "GoldGlory" }, d = { "Inferno" }, req = true },
})
y = block(main, "misc", 2, y, "legit macro", {
{ k = "toggle", n = "enabled", f = "legit_enabled", d = false },
{ k = "keybind", n = "bind", f = "legit_key", d = Enum.KeyCode.X },
{ k = "slider", n = "delay", f = "legit_delay", min = 0, max = 200, d = 0, suffix = "ms" },
})
y = 0
y = block(main, "rage", 1, y, "anti lock", {
{ k = "toggle", n = "enabled", f = "misc_antilock", d = false },
{ k = "toggle", n = "resolver", f = "misc_resolver", d = false },
})
y = block(main, "rage", 1, y, "cframe speed", {
{ k = "toggle", n = "enabled", f = "cspeed_enabled", d = false },
{ k = "keybind", n = "bind", f = "cspeed_key", d = Enum.KeyCode.LeftAlt },
{ k = "slider", n = "speed", f = "cspeed_value", min = 10, max = 400, d = 60, suffix = " s/s" },
{ k = "toggle", n = "hold", f = "cspeed_hold", d = false },
})
y = block(main, "rage", 1, y, "fake macro", {
{ k = "toggle", n = "enabled", f = "macro_enabled", d = false },
{ k = "slider", n = "walkspeed", f = "macro_walkspeed", min = 16, max = 500, d = 100 },
})
y = 0
y = block(main, "rage", 2, y, "orbit", {
{ k = "toggle", n = "enabled", f = "orbit_enabled", d = false },
{ k = "keybind", n = "bind", f = "orbit_key", d = Enum.KeyCode.Q },
{ k = "slider", n = "height", f = "orbit_height", min = 0, max = 16, d = 5.4, dec = 1 },
{ k = "slider", n = "radius", f = "orbit_radius", min = 0.5, max = 8, d = 8, dec = 1 },
{ k = "slider", n = "speed", f = "orbit_speed", min = 5, max = 80, d = 12 },
})
do
local elements = getgenv().DriftMoveElements or {}
local function keyed_block(group, tab, side, cursor, title, rows)
local height = 20
for _, row in ipairs(rows) do
height = height + (ROW_HEIGHT[row.k] or 17)
end
local size = math.min(height / TAB_HEIGHT, 1)
local section = group:create_section(tab, title, side, size, cursor)
if not section then
warn("[drift] section failed: " .. tostring(title))
return cursor
end
for _, row in ipairs(rows) do
elements[row.f] = fill(section, row)
end
return cursor + size
end
y = keyed_block(main, "rage", 2, y, "super jump", {
{ k = "toggle", n = "enabled", f = "sjump_enabled", d = false },
{ k = "keybind", n = "bind", f = "sjump_key", d = Enum.KeyCode.J },
{ k = "slider", n = "jump power", f = "sjump_power", min = 50, max = 500, d = 180 },
})
y = keyed_block(main, "rage", 2, y, "fly", {
{ k = "toggle", n = "enabled", f = "fly_enabled", d = false },
{ k = "keybind", n = "bind", f = "fly_key", d = Enum.KeyCode.F },
{ k = "slider", n = "speed", f = "fly_speed", min = 10, max = 300, d = 80 },
})
getgenv().DriftMoveElements = elements
end
pcall(function()
menu:setup_configs("settings")
end)
print("[tea.cc] build " .. VERSION .. " loaded - aim key " .. tostring(flags["aim_key"]))
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
if not key_of(flags["aim_key"]) then
flags["aim_key"] = Enum.UserInputType.MouseButton2
elseif flags["aim_key"] == Enum.KeyCode.Q then
flags["aim_key"] = Enum.UserInputType.MouseButton2
end
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
circle.Color = Color3.fromRGB(255, 255, 255)
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
local MOUSE_BUTTONS = {
Right = Enum.UserInputType.MouseButton2,
Left = Enum.UserInputType.MouseButton1,
}
local function aim_button()
return MOUSE_BUTTONS[first(fget("aim_mouse", { "None" }), "None")]
end
local function aim_input(input)
local button = aim_button()
if button then
return input.UserInputType == button
end
return input.KeyCode == key_of(fget("aim_key", Enum.KeyCode.Q))
end
local function aim_held()
local button = aim_button()
if button then
return UserInputService:IsMouseButtonPressed(button)
end
return key_down(fget("aim_key", Enum.KeyCode.Q))
end
local function is_aim_input(input)
local bound = key_of(fget("aim_key", Enum.UserInputType.MouseButton2))
if typeof(bound) ~= "EnumItem" then
return false
end
if bound.EnumType == Enum.UserInputType then
return input.UserInputType == bound
end
return input.KeyCode == bound
end
UserInputService.InputBegan:Connect(function(input, processed)
local is_mouse = input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.MouseButton2
if processed and not is_mouse then
return
end
if not fget("aim_enabled", true) then
return
end
if first(fget("aim_activation", { "Toggle" }), "Toggle") ~= "Toggle" then
return
end
if not is_aim_input(input) then
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
local held = false
local bound = key_of(fget("aim_key", Enum.UserInputType.MouseButton2))
if typeof(bound) == "EnumItem" then
if bound.EnumType == Enum.UserInputType then
held = UserInputService:IsMouseButtonPressed(bound)
else
held = key_down(bound)
end
end
if held then
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
config.rate = math.max(fget("rapid_rate", 300), 1)
config.delay = 1 / config.rate
if not config.enable then
getgenv().is_firing = false
break
end
local gun = utility.get_gun()
if gun then
local per_frame = 1
if config.rate >= 60 then
per_frame = math.max(1, math.floor(config.rate / 60 + 0.5))
end
for _ = 1, per_frame do
if not getgenv().is_firing then
break
end
utility.rapid(gun)
end
elseif fget("rapid_require_ammo", true) then
getgenv().is_firing = false
break
end
if config.rate >= 60 then
RunService.Heartbeat:Wait()
else
task.wait(config.delay)
end
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
local colour = flags["crosshair_color"] or Color3.fromRGB(255, 255, 255)
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
local Orbit = {
active = false,
target = nil,
angle = 0,
auto_rotate = true,
auto_state = nil,
last_position = nil,
}
do
local vector_zero = Vector3.zero
local function root_of(player)
local character = player and player.Character
return character and character:FindFirstChild("HumanoidRootPart")
end
local function hum_of(player)
local character = player and player.Character
return character and character:FindFirstChildOfClass("Humanoid")
end
local function alive(player)
local humanoid = hum_of(player)
return humanoid ~= nil and humanoid.Health > 0 and root_of(player) ~= nil
end
local function nearest()
local my_root = root_of(Players.LocalPlayer)
local camera = Workspace.CurrentCamera
if not my_root or not camera then
return nil
end
local centre = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
local max_distance = fget("target_distance", 500)
local best, best_screen = nil, math.huge
for _, player in Players:GetPlayers() do
if player ~= Players.LocalPlayer and alive(player) then
local root = root_of(player)
if (root.Position - my_root.Position).Magnitude <= max_distance then
local point, visible = camera:WorldToViewportPoint(root.Position)
if visible then
local screen = (Vector2.new(point.X, point.Y) - centre).Magnitude
if screen < best_screen then
best, best_screen = player, screen
end
end
end
end
end
return best
end
local function release()
local my_root = root_of(Players.LocalPlayer)
local humanoid = hum_of(Players.LocalPlayer)
if my_root then
my_root.Anchored = false
my_root.AssemblyLinearVelocity = vector_zero
my_root.AssemblyAngularVelocity = vector_zero
end
if humanoid then
humanoid.AutoRotate = Orbit.auto_rotate
if Orbit.auto_state then
pcall(function()
humanoid:ChangeState(Orbit.auto_state)
end)
end
end
Orbit.active = false
Orbit.target = nil
Orbit.auto_state = nil
Orbit.last_position = nil
end
local function engage()
local my_root = root_of(Players.LocalPlayer)
local humanoid = hum_of(Players.LocalPlayer)
if not my_root or not humanoid or humanoid.Health <= 0 then
return
end
local target = (Aim.locked and alive(Aim.locked)) and Aim.locked or nearest()
if not target then
return
end
my_root.Anchored = false
Orbit.auto_rotate = humanoid.AutoRotate
Orbit.auto_state = humanoid:GetState()
humanoid.AutoRotate = false
pcall(function()
humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end)
Orbit.target = target
Orbit.angle = 0
Orbit.last_position = my_root.Position
Orbit.active = true
end
function Orbit.release()
release()
end
function Orbit.toggle()
if Orbit.active then
release()
else
engage()
end
end
UserInputService.InputBegan:Connect(function(input, processed)
if processed then
return
end
if not fget("orbit_enabled", false) then
return
end
if input.KeyCode ~= key_of(fget("orbit_key", Enum.KeyCode.Q)) then
return
end
Orbit.toggle()
end)
function Orbit.step(dt)
if not fget("orbit_enabled", false) then
if Orbit.active then
release()
end
return
end
if not Orbit.active then
return
end
local my_root = root_of(Players.LocalPlayer)
local humanoid = hum_of(Players.LocalPlayer)
if not my_root or not humanoid or humanoid.Health <= 0 then
release()
return
end
if not alive(Orbit.target) then
local replacement = (Aim.locked and alive(Aim.locked)) and Aim.locked or nearest()
if not replacement then
release()
return
end
Orbit.target = replacement
end
local height = fget("orbit_height", 5.4)
local head = Orbit.target.Character:FindFirstChild("Head")
local anchor = head
and (head.Position + Vector3.new(0, height, 0))
or (root_of(Orbit.target).Position + Vector3.new(0, height + 1.5, 0))
Orbit.angle = (Orbit.angle + fget("orbit_speed", 12) * dt) % (math.pi * 2)
local radius = fget("orbit_radius", 8)
local position = anchor + Vector3.new(
math.cos(Orbit.angle) * radius,
0,
math.sin(Orbit.angle) * radius
)
my_root.CFrame = CFrame.lookAt(position, anchor)
local previous = Orbit.last_position or position
Orbit.last_position = position
local safe_dt = math.max(dt, 1 / 240)
local echo = (position - previous) / safe_dt
if echo.Magnitude > 200 then
echo = echo.Unit * 200
end
my_root.AssemblyLinearVelocity = echo
my_root.AssemblyAngularVelocity = vector_zero
end
getgenv().TeaOrbit = Orbit
end
local Speed = { active = false, held = {} }
do
local function root()
local character = Players.LocalPlayer and Players.LocalPlayer.Character
return character and character:FindFirstChild("HumanoidRootPart")
end
local function matches(input, binding)
local bound = key_of(binding)
if typeof(bound) ~= "EnumItem" then
return false
end
if bound.EnumType == Enum.UserInputType then
return input.UserInputType == bound
end
return input.KeyCode == bound
end
local function axes()
local forward = (Speed.held[Enum.KeyCode.W] and 1 or 0)
- (Speed.held[Enum.KeyCode.S] and 1 or 0)
local side = (Speed.held[Enum.KeyCode.D] and 1 or 0)
- (Speed.held[Enum.KeyCode.A] and 1 or 0)
if forward == 0 and side == 0 then
return nil
end
return forward, side
end
UserInputService.InputBegan:Connect(function(input, processed)
Speed.held[input.KeyCode] = true
if processed then
return
end
if not fget("cspeed_enabled", false) then
return
end
if not matches(input, fget("cspeed_key", Enum.KeyCode.LeftAlt)) then
return
end
if fget("cspeed_hold", false) then
Speed.active = true
else
Speed.active = not Speed.active
end
end)
UserInputService.InputEnded:Connect(function(input)
Speed.held[input.KeyCode] = nil
if fget("cspeed_hold", false) then
if matches(input, fget("cspeed_key", Enum.KeyCode.LeftAlt)) then
Speed.active = false
end
end
end)
function Speed.step(dt)
if not fget("cspeed_enabled", false) then
Speed.active = false
return
end
if not Speed.active then
return
end
local my_root = root()
if not my_root then
return
end
local forward, side = axes()
if not forward then
return
end
local look = my_root.CFrame.LookVector
local flat = Vector3.new(look.X, 0, look.Z)
if flat.Magnitude < 1e-3 then
return
end
flat = flat.Unit
local right = Vector3.new(-flat.Z, 0, flat.X)
local move = flat * forward + right * side
if move.Magnitude < 1e-3 then
return
end
local step = math.min(dt, 1 / 20)
my_root.CFrame = my_root.CFrame + move.Unit * (fget("cspeed_value", 60) * step)
end
function Speed.release()
Speed.active = false
Speed.held = {}
end
getgenv().TeaSpeed = Speed
end
local World = { kind = "None", last = 0, rigs = {}, flash_at = 0, atmo_owned = false, restored = false }
do
local Lighting = game:GetService("Lighting")
local WHITE = Color3.fromRGB(255, 255, 255)
local TEXTURE = "rbxassetid://1316045217"
local LIGHT_KEYS = {
"Ambient", "OutdoorAmbient", "Brightness", "ClockTime",
"ColorShift_Top", "ColorShift_Bottom", "FogColor", "FogEnd",
"FogStart", "ExposureCompensation",
}
local snap = {}
for _, key in ipairs(LIGHT_KEYS) do
local ok, value = pcall(function()
return Lighting[key]
end)
if ok then
snap[key] = value
end
end
local game_atmo = Lighting:FindFirstChildOfClass("Atmosphere")
local atmo_snap = nil
if game_atmo then
atmo_snap = {
Density = game_atmo.Density, Offset = game_atmo.Offset,
Color = game_atmo.Color, Decay = game_atmo.Decay,
Glare = game_atmo.Glare, Haze = game_atmo.Haze,
}
end
local function write(object, property, value)
pcall(function()
object[property] = value
end)
end
local function tint(colour, picker)
return Color3.new(colour.R * picker.R, colour.G * picker.G, colour.B * picker.B)
end
local PALETTES = {
["Off"] = { keep = true },
["Custom"] = {
custom = true,
ambient = Color3.fromRGB(255, 255, 255),
outdoor = Color3.fromRGB(255, 255, 255),
top = Color3.fromRGB(255, 255, 255),
bottom = Color3.fromRGB(255, 255, 255),
fog = Color3.fromRGB(255, 255, 255),
atmo = { Density = 0.34, Offset = 0, Glare = 1, Haze = 2.5 },
},
["Red"] = {
ambient = Color3.fromRGB(120, 26, 26),
outdoor = Color3.fromRGB(190, 60, 50),
top = Color3.fromRGB(255, 96, 84),
bottom = Color3.fromRGB(120, 22, 22),
fog = Color3.fromRGB(160, 40, 36),
atmo = { Density = 0.34, Offset = 0, Decay = Color3.fromRGB(80, 14, 14), Glare = 2, Haze = 3 },
},
["Night"] = {
ambient = Color3.fromRGB(18, 22, 44),
outdoor = Color3.fromRGB(26, 32, 60),
top = Color3.fromRGB(20, 28, 70),
bottom = Color3.fromRGB(6, 6, 14),
fog = Color3.fromRGB(10, 14, 30),
atmo = { Density = 0.42, Offset = -0.2, Decay = Color3.fromRGB(8, 10, 26), Glare = 0, Haze = 1.4 },
},
["Overcast"] = {
ambient = Color3.fromRGB(96, 102, 112),
outdoor = Color3.fromRGB(128, 134, 144),
top = Color3.fromRGB(170, 178, 190),
bottom = Color3.fromRGB(120, 126, 136),
fog = Color3.fromRGB(150, 158, 170),
atmo = { Density = 0.46, Offset = 0, Decay = Color3.fromRGB(120, 126, 136), Glare = 0, Haze = 5.5 },
},
["Storm"] = {
ambient = Color3.fromRGB(46, 52, 64),
outdoor = Color3.fromRGB(60, 66, 78),
top = Color3.fromRGB(78, 88, 104),
bottom = Color3.fromRGB(38, 42, 52),
fog = Color3.fromRGB(64, 70, 82),
atmo = { Density = 0.52, Offset = 0, Decay = Color3.fromRGB(40, 44, 54), Glare = 0, Haze = 7 },
},
["Dusk"] = {
ambient = Color3.fromRGB(62, 40, 46),
outdoor = Color3.fromRGB(120, 78, 70),
top = Color3.fromRGB(255, 138, 92),
bottom = Color3.fromRGB(96, 44, 62),
fog = Color3.fromRGB(180, 108, 92),
atmo = { Density = 0.30, Offset = 0.1, Decay = Color3.fromRGB(90, 40, 60), Glare = 1.5, Haze = 2.2 },
},
["Void"] = {
ambient = Color3.fromRGB(0, 0, 0),
outdoor = Color3.fromRGB(0, 0, 0),
top = Color3.fromRGB(0, 0, 0),
bottom = Color3.fromRGB(0, 0, 0),
fog = Color3.fromRGB(0, 0, 0),
atmo = { Density = 0.6, Offset = 0, Decay = Color3.fromRGB(0, 0, 0), Glare = 0, Haze = 0 },
},
}
local WEATHER = {
Snow = {
gravity = -3,
layers = {
{ rate = 220, size = 0.20, speed = NumberRange.new(4, 8), transparency = 0.62,
lifetime = NumberRange.new(18, 26), height = 36, spread = Vector2.new(70, 70), rot = NumberRange.new(-30, 30) },
{ rate = 340, size = 0.34, speed = NumberRange.new(7, 12), transparency = 0.34,
lifetime = NumberRange.new(12, 18), height = 27, spread = Vector2.new(50, 50), rot = NumberRange.new(-60, 60) },
{ rate = 150, size = 0.58, speed = NumberRange.new(11, 17), transparency = 0.12,
lifetime = NumberRange.new(8, 13), height = 18, spread = Vector2.new(38, 38), rot = NumberRange.new(-90, 90) },
},
},
Rain = {
gravity = -95,
layers = {
{ rate = 820, size = 0.55, speed = NumberRange.new(120, 165), transparency = 0.32,
lifetime = NumberRange.new(1.1, 1.7), height = 28, spread = Vector2.new(7, 7), squash = 0.05 },
{ rate = 460, size = 0.34, speed = NumberRange.new(155, 205), transparency = 0.55,
lifetime = NumberRange.new(0.8, 1.2), height = 32, spread = Vector2.new(5, 5), squash = 0.04 },
{ rate = 130, size = 1.10, speed = NumberRange.new(26, 44), transparency = 0.90,
lifetime = NumberRange.new(1.4, 2.2), height = 14, spread = Vector2.new(45, 45), squash = 1 },
},
},
}
WEATHER.Storm = WEATHER.Rain
local follow = nil
local function clear_rigs()
for _, part in ipairs(World.rigs) do
pcall(function()
part:Destroy()
end)
end
World.rigs = {}
end
local function start_follow()
if follow then
return
end
follow = RunService.RenderStepped:Connect(function()
local camera = Workspace.CurrentCamera
if not camera then
return
end
for _, part in ipairs(World.rigs) do
if part.Parent then
part.CFrame = camera.CFrame * CFrame.new(0, part:GetAttribute("Height") or 24, 0)
end
end
end)
end
local function build(kind)
clear_rigs()
local definition = WEATHER[kind]
World.kind = kind
if not definition then
return
end
for index, layer in ipairs(definition.layers) do
local part = Instance.new("Part")
part.Name = "TeaWorldRig" .. index
part.Anchored = true
part.CanCollide = false
part.CanQuery = false
part.CanTouch = false
part.CastShadow = false
part.Transparency = 1
part.Size = Vector3.new(190, 4, 190)
part.Parent = Workspace
part:SetAttribute("Height", layer.height)
local emitter = Instance.new("ParticleEmitter")
emitter.Name = "TeaWorldEmitter" .. index
emitter.Texture = TEXTURE
emitter.Color = ColorSequence.new(WHITE)
emitter.Lifetime = layer.lifetime
emitter.SpreadAngle = layer.spread
emitter.Rotation = layer.rot or NumberRange.new(0, 0)
emitter.RotSpeed = NumberRange.new(-35, 35)
emitter.Squash = NumberSequence.new(layer.squash or 1)
emitter.EmissionDirection = Enum.NormalId.Bottom
emitter.LightEmission = 0
emitter.LightInfluence = 0
emitter.ZOffset = 1
emitter.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, layer.transparency),
NumberSequenceKeypoint.new(1, 1),
})
pcall(function()
emitter.Shape = Enum.ParticleEmitterShape.Box
emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
emitter.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
end)
emitter.Parent = part
table.insert(World.rigs, part)
end
start_follow()
end
local function tune_weather()
local kind = first(fget("world_weather", { "None" }), "None")
if kind ~= World.kind then
build(WEATHER[kind] and kind or "None")
end
local definition = WEATHER[World.kind]
if not definition then
return
end
local size = fget("world_weather_size", 1)
local speed = fget("world_weather_speed", 100) / 100
local density = fget("world_weather_rate", 55) / 55
local wind = fget("world_weather_wind", 14)
local colour = flags["world_weather_color"] or Color3.fromRGB(235, 244, 255)
for index, part in ipairs(World.rigs) do
local emitter = part:FindFirstChildOfClass("ParticleEmitter")
local layer = definition.layers[index]
if emitter and layer then
write(emitter, "Rate", math.max(layer.rate * density, 0))
write(emitter, "Color", ColorSequence.new(colour))
write(emitter, "Size", NumberSequence.new(layer.size * size))
write(emitter, "Speed", NumberRange.new(layer.speed.Min * speed, layer.speed.Max * speed))
write(emitter, "Acceleration", Vector3.new(wind, definition.gravity * speed, wind * 0.35))
end
end
end
local function restore_lighting()
for key, value in pairs(snap) do
write(Lighting, key, value)
end
if atmo_snap and game_atmo then
for key, value in pairs(atmo_snap) do
write(game_atmo, key, value)
end
elseif World.atmo_owned then
local atmo = Lighting:FindFirstChild("TeaWorldAtmosphere")
if atmo then
atmo:Destroy()
end
World.atmo_owned = false
end
end
local function apply_lighting()
local name = first(fget("world_preset", { "Off" }), "Off")
local palette = PALETTES[name] or PALETTES["Off"]
if palette.keep then
if not World.restored then
restore_lighting()
World.restored = true
end
return
end
World.restored = false
local pick = {
top = flags["world_sky_top"] or WHITE,
bottom = flags["world_sky_bottom"] or WHITE,
ambient = flags["world_ambient"] or WHITE,
fog = flags["world_fog"] or WHITE,
}
write(Lighting, "Brightness", fget("world_brightness", 2))
write(Lighting, "ClockTime", fget("world_clock", 14))
write(Lighting, "ExposureCompensation", fget("world_exposure", 0))
if fget("world_fullbright", false) then
write(Lighting, "Ambient", WHITE)
write(Lighting, "OutdoorAmbient", WHITE)
elseif not palette.keep then
write(Lighting, "Ambient", tint(palette.ambient, pick.ambient))
write(Lighting, "OutdoorAmbient", tint(palette.outdoor, pick.ambient))
end
if fget("world_no_fog", false) then
write(Lighting, "FogStart", 100000)
write(Lighting, "FogEnd", 100000)
else
if not palette.keep then
write(Lighting, "FogColor", tint(palette.fog, pick.fog))
write(Lighting, "FogStart", 0)
end
write(Lighting, "FogEnd", fget("world_fog_end", 800))
end
if palette.keep then
return
end
write(Lighting, "ColorShift_Top", tint(palette.top, pick.top))
write(Lighting, "ColorShift_Bottom", tint(palette.bottom, pick.bottom))
local atmo = game_atmo
if not atmo then
atmo = Lighting:FindFirstChild("TeaWorldAtmosphere")
if not atmo then
atmo = Instance.new("Atmosphere")
atmo.Name = "TeaWorldAtmosphere"
atmo.Parent = Lighting
World.atmo_owned = true
end
end
write(atmo, "Density", palette.atmo.Density)
write(atmo, "Offset", palette.atmo.Offset)
write(atmo, "Decay", palette.atmo.Decay)
write(atmo, "Glare", palette.atmo.Glare)
write(atmo, "Haze", palette.atmo.Haze)
write(atmo, "Color", tint(palette.top, pick.top))
if palette.custom then
write(atmo, "Color", pick.top)
write(atmo, "Decay", Color3.new(
pick.bottom.R * 0.55,
pick.bottom.G * 0.55,
pick.bottom.B * 0.55
))
end
end
local function flash_tick()
local kind = World.kind
if kind ~= "Rain" and kind ~= "Storm" then
return
end
if not fget("world_lightning", false) and first(fget("world_weather", { "None" }), "None") ~= "Storm" then
return
end
local now = os.clock()
if now < World.flash_at then
return
end
World.flash_at = now + math.random(4, 10)
local base = fget("world_brightness", 2)
task.spawn(function()
write(Lighting, "Brightness", base + 3.5)
task.wait(0.05)
write(Lighting, "Brightness", base + 1.2)
task.wait(0.05)
write(Lighting, "Brightness", base)
end)
end
function World.step()
local now = os.clock()
if now - World.last < 0.12 then
return
end
World.last = now
apply_lighting()
tune_weather()
flash_tick()
end
function World.release()
for key, value in pairs(snap) do
write(Lighting, key, value)
end
if atmo_snap and game_atmo then
for key, value in pairs(atmo_snap) do
write(game_atmo, key, value)
end
elseif World.atmo_owned then
local atmo = Lighting:FindFirstChild("TeaWorldAtmosphere")
if atmo then
atmo:Destroy()
end
World.atmo_owned = false
end
clear_rigs()
World.kind = "None"
end
getgenv().TeaWorld = World
end
getgenv().TeaRuntimeConnection = RunService.RenderStepped:Connect(function(dt)
Aim.step(dt)
Aim.sweep_hitboxes()
Orbit.step(dt)
Speed.step(dt)
World.step()
Avatar.step()
Walkspeed.step()
Crosshair.step()
end)
getgenv().TeaUnload = function()
pcall(function()
if getgenv().TeaRuntimeConnection then
getgenv().TeaRuntimeConnection:Disconnect()
getgenv().TeaRuntimeConnection = nil
end
end)
pcall(getgenv().TeaHitboxRestore)
if getgenv().TeaOrbit then
pcall(getgenv().TeaOrbit.release)
end
if getgenv().TeaWorld then
pcall(getgenv().TeaWorld.release)
end
if getgenv().TeaSpeed then
pcall(getgenv().TeaSpeed.release)
end
getgenv().is_firing = false
if Walkspeed.humanoid and Walkspeed.humanoid.Parent and Walkspeed.original then
Walkspeed.humanoid.WalkSpeed = Walkspeed.original
end
Walkspeed.humanoid = nil
Walkspeed.original = nil
end
do
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local VEL_MAX = 128 ^ 2
local TIME_RELEASE = 0.015
local CHOKE_MAX = 0.5
local IDLE_POLL = 0.25
local rad = math.rad
local rnd = math.random
local clamp = math.clamp
local angles = CFrame.Angles
local vector = Vector3.new
local setHidden = sethiddenproperty
local haveHidden = type(setHidden) == "function"
local pingStat = game:GetService("Stats"):FindFirstChild("PerformanceStats")
pingStat = pingStat and pingStat:FindFirstChild("Ping")
local function get(name, fallback)
local ok, value = pcall(fget, name, fallback)
if ok and value ~= nil then
return value
end
return fallback
end
local function pingMs()
if not pingStat then
return 100
end
local ok, value = pcall(function()
return pingStat:GetValue()
end)
if ok and type(value) == "number" then
return value
end
return 100
end
task.spawn(function()
while true do
local enabled = get("misc_antilock", false)
local character = localPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if enabled and haveHidden and root and humanoid and humanoid.Health > 0 then
local heldVelocity = root.Velocity
local yaw = rnd(-180, 180)
local offset = vector(
rnd(-VEL_MAX, VEL_MAX),
-rnd(0, VEL_MAX),
rnd(-VEL_MAX, VEL_MAX)
)
local ok = pcall(function()
root.CFrame = root.CFrame * angles(0, rad(yaw), 0)
root.Velocity = offset
end)
if ok then
RunService.RenderStepped:Wait()
pcall(function()
root.CFrame = root.CFrame * angles(0, rad(-yaw), 0)
root.Velocity = heldVelocity
end)
local chokeBeat = RunService.Heartbeat:Connect(function()
pcall(setHidden, root, "NetworkIsSleeping", true)
end)
local chokeRender = RunService.RenderStepped:Connect(function()
pcall(setHidden, root, "NetworkIsSleeping", true)
end)
task.wait(clamp(pingMs(), 0, CHOKE_MAX * 1000) / 1000)
pcall(function()
chokeBeat:Disconnect()
end)
pcall(function()
chokeRender:Disconnect()
end)
pcall(setHidden, root, "NetworkIsSleeping", false)
end
task.wait(TIME_RELEASE)
else
task.wait(IDLE_POLL)
end
end
end)
RunService.Heartbeat:Connect(function()
if not get("misc_resolver", false) then
return
end
for _, player in ipairs(Players:GetPlayers()) do
if player ~= localPlayer then
local character = player.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if root and humanoid and humanoid.Health > 0 then
pcall(function()
local velocity = root.Velocity
root.Velocity = vector(velocity.X, 0, velocity.Z)
end)
end
end
end
end)
end
do
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local SKINS = {
Inferno = {
["[SilencerAR]"] = 9401972413,
["[SMG]"] = 9387593777,
["[TacticalShotgun]"] = 9402244359,
["[AK47]"] = 9402094255,
["[AUG]"] = 9401802930,
["[AR]"] = 9401972413,
["[Glock]"] = 9401670081,
["[Shotgun]"] = 9387831940,
["[Silencer]"] = 9401670081,
["[P90]"] = 9399878713,
["[Revolver]"] = 9370404463,
["[RPG]"] = 9399831924,
["[LMG]"] = 9400160302,
["[Flamethrower]"] = 9400503673,
["[DrumGun]"] = 9381496666,
["[Double-Barrel SG]"] = 9401416743,
},
Galaxy = {
["[SilencerAR]"] = 9402007158,
["[SMG]"] = 9387614760,
["[TacticalShotgun]"] = 9402279010,
["[AK47]"] = 9402132929,
["[AUG]"] = 9401832956,
["[AR]"] = 9402007158,
["[Glock]"] = 9401709916,
["[Shotgun]"] = 9387933478,
["[Silencer]"] = 9401709916,
["[P90]"] = 9399887933,
["[Revolver]"] = 9370936730,
["[RPG]"] = 9399842353,
["[LMG]"] = 9400170566,
["[Flamethrower]"] = 9400558000,
["[DrumGun]"] = 9381577172,
["[Double-Barrel SG]"] = 9401441647,
},
Matrix = {
["[SilencerAR]"] = 9402023983,
["[SMG]"] = 9387681455,
["[TacticalShotgun]"] = 9402295362,
["[AK47]"] = 9402147406,
["[AUG]"] = 9401855319,
["[AR]"] = 9402023983,
["[Glock]"] = 9401727978,
["[Shotgun]"] = 9387945198,
["[Silencer]"] = 9401727978,
["[P90]"] = 9399894480,
["[Revolver]"] = 9380928144,
["[RPG]"] = 9399850204,
["[LMG]"] = 9400178599,
["[Flamethrower]"] = 9400582867,
["[DrumGun]"] = 9381601709,
["[Double-Barrel SG]"] = 9401457713,
},
RedDeath = {
["[SilencerAR]"] = 8213168054,
["[SMG]"] = 8199875638,
["[TacticalShotgun]"] = 9203641766,
["[AK47]"] = 8213572965,
["[AUG]"] = 8212802637,
["[AR]"] = 8213168054,
["[Glock]"] = 8212637463,
["[Shotgun]"] = 8200647420,
["[Silencer]"] = 8212637463,
["[P90]"] = 8205381104,
["[Revolver]"] = 8173928665,
["[RPG]"] = 8201055935,
["[LMG]"] = 8205713344,
["[Flamethrower]"] = 8206707126,
["[DrumGun]"] = 8186385983,
["[Double-Barrel SG]"] = 8212384179,
},
GoldGlory = {
["[SilencerAR]"] = 8213175568,
["[SMG]"] = 8199883519,
["[TacticalShotgun]"] = 9203647967,
["[AK47]"] = 8213606202,
["[AUG]"] = 8212809463,
["[AR]"] = 8213175568,
["[Glock]"] = 8212667115,
["[Shotgun]"] = 8200657428,
["[Silencer]"] = 8212667115,
["[P90]"] = 8205397990,
["[Revolver]"] = 8173955378,
["[RPG]"] = 8201059812,
["[LMG]"] = 8205719479,
["[Flamethrower]"] = 8208010648,
["[DrumGun]"] = 8186168230,
["[Double-Barrel SG]"] = 8212394280,
},
}
local function get(name, fallback)
local ok, value = pcall(fget, name, fallback)
if ok and value ~= nil then
return value
end
return fallback
end
local original = {}
local active = false
local function restore()
for decal, texture in pairs(original) do
if decal and decal.Parent then
pcall(function()
decal.TextureID = texture
end)
end
end
original = {}
active = false
end
local function apply(character, skin)
local set = SKINS[skin]
if not set then
return
end
for weapon, assetId in pairs(set) do
local tool = character:FindFirstChild(weapon)
local decal = tool and tool:FindFirstChild("Default")
if decal then
if original[decal] == nil then
local ok, texture = pcall(function()
return decal.TextureID
end)
original[decal] = ok and texture or ""
end
local wanted = "rbxassetid://" .. tostring(assetId)
local ok, current = pcall(function()
return decal.TextureID
end)
if ok and current ~= wanted then
pcall(function()
decal.TextureID = wanted
end)
end
end
end
end
RunService.RenderStepped:Connect(function()
local character = localPlayer.Character
if not get("skin_enabled", false) or not character then
if active then
restore()
end
return
end
active = true
apply(character, first(get("skin_choice", { "Inferno" }), "Inferno"))
end)
end
do
local elements = getgenv().DriftMoveElements or {}
local function get(name, fallback)
local ok, value = pcall(fget, name, fallback)
if ok and value ~= nil then
return value
end
return fallback
end
local function set_toggle(flag, value)
local element = elements[flag]
if element and type(element.set_toggle) == "function" then
local ok = pcall(function()
element:set_toggle(value)
end)
if ok then
return
end
end
flags[flag] = value
end
local function flip(flag)
set_toggle(flag, not get(flag, false))
end
local Jump = { humanoid = nil, power = nil, use_power = nil }
local function jump_release()
local humanoid = Jump.humanoid
local power = Jump.power
local use_power = Jump.use_power
Jump.humanoid, Jump.power, Jump.use_power = nil, nil, nil
if humanoid and humanoid.Parent then
pcall(function()
humanoid.JumpPower = power or 50
humanoid.UseJumpPower = use_power ~= false
end)
end
end
local function jump_step()
local character = Client.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local wanted = humanoid and get("sjump_enabled", false)
if not wanted then
if Jump.humanoid then
jump_release()
end
return
end
if Jump.humanoid ~= humanoid then
jump_release()
Jump.humanoid = humanoid
Jump.power = humanoid.JumpPower
Jump.use_power = humanoid.UseJumpPower
end
local power = get("sjump_power", 180)
pcall(function()
humanoid.UseJumpPower = true
humanoid.JumpPower = power
end)
end
local Fly = { body = nil, gyro = nil, root = nil, humanoid = nil }
local UP = Vector3.new(0, 1, 0)
local function fly_release()
local body, gyro, humanoid = Fly.body, Fly.gyro, Fly.humanoid
Fly.body, Fly.gyro, Fly.root, Fly.humanoid = nil, nil, nil, nil
if body then
pcall(function()
body:Destroy()
end)
end
if gyro then
pcall(function()
gyro:Destroy()
end)
end
if humanoid and humanoid.Parent then
pcall(function()
humanoid.PlatformStand = false
end)
end
end
local function fly_attach(root, humanoid)
local body = Instance.new("BodyVelocity")
body.Name = "DriftFlyBody"
body.MaxForce = Vector3.new(1e6, 1e6, 1e6)
body.P = 1250
body.Velocity = Vector3.new(0, 0, 0)
body.Parent = root
local gyro = Instance.new("BodyGyro")
gyro.Name = "DriftFlyGyro"
gyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
gyro.P = 3000
gyro.D = 100
gyro.CFrame = root.CFrame
gyro.Parent = root
Fly.body, Fly.gyro, Fly.root, Fly.humanoid = body, gyro, root, humanoid
pcall(function()
humanoid.PlatformStand = true
end)
end
local function fly_step()
local character = Client.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local alive = humanoid and humanoid.Health > 0
local wanted = alive and root and get("fly_enabled", false)
if not wanted then
if Fly.body or Fly.gyro or Fly.humanoid then
fly_release()
end
return
end
if Fly.root ~= root
or Fly.humanoid ~= humanoid
or not Fly.body
or not Fly.body.Parent
or not Fly.gyro
or not Fly.gyro.Parent
then
fly_release()
fly_attach(root, humanoid)
end
local camera = Workspace.CurrentCamera
local direction = Vector3.new(0, 0, 0)
if camera then
local look = camera.CFrame.LookVector
local right = camera.CFrame.RightVector
local flat = Vector3.new(look.X, 0, look.Z)
if flat.Magnitude > 1e-3 then
flat = flat.Unit
end
local flat_right = Vector3.new(right.X, 0, right.Z)
if flat_right.Magnitude > 1e-3 then
flat_right = flat_right.Unit
end
if UserInputService:IsKeyDown(Enum.KeyCode.W) then
direction = direction + flat
end
if UserInputService:IsKeyDown(Enum.KeyCode.S) then
direction = direction - flat
end
if UserInputService:IsKeyDown(Enum.KeyCode.D) then
direction = direction + flat_right
end
if UserInputService:IsKeyDown(Enum.KeyCode.A) then
direction = direction - flat_right
end
end
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
direction = direction + UP
end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
direction = direction - UP
end
if direction.Magnitude > 1 then
direction = direction.Unit
end
local speed = get("fly_speed", 80)
pcall(function()
Fly.body.Velocity = direction * speed
if camera then
Fly.gyro.CFrame = CFrame.new(root.Position) * (camera.CFrame - camera.CFrame.Position)
else
Fly.gyro.CFrame = CFrame.new(root.Position)
end
end)
end
UserInputService.InputBegan:Connect(function(input, processed)
if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
return
end
if input.KeyCode == key_of(get("sjump_key", Enum.KeyCode.J)) then
flip("sjump_enabled")
elseif input.KeyCode == key_of(get("fly_key", Enum.KeyCode.F)) then
flip("fly_enabled")
end
end)
local connection = RunService.RenderStepped:Connect(function()
pcall(jump_step)
pcall(fly_step)
end)
local function stop()
if connection then
pcall(function()
connection:Disconnect()
end)
connection = nil
end
if Fly.body or Fly.gyro or Fly.humanoid then
fly_release()
end
if Jump.humanoid then
jump_release()
end
end
getgenv().DriftMove = {
toggle = flip,
set = set_toggle,
stop = stop,
}
task.defer(function()
local previous = getgenv().TeaUnload
getgenv().TeaUnload = function()
if previous then
pcall(previous)
end
pcall(stop)
end
end)
end
do
local folder = "drift/configs"
local function api()
return getgenv().TeaJujuMenu
end
local function ensure()
pcall(function()
if not isfolder("drift") then
makefolder("drift")
end
if not isfolder(folder) then
makefolder(folder)
end
end)
end
local function clean(name)
if type(name) ~= "string" or name == "" then
return nil
end
if name:find("/", 1, true) or name:find(".", 1, true) then
return nil
end
return name
end
local function path_of(name)
local safe = clean(name)
if not safe then
return nil
end
return folder .. "/" .. safe .. ".cfg"
end
local DriftConfig = {}
function DriftConfig.list()
ensure()
local out = {}
local ok, files = pcall(listfiles, folder)
if not ok or type(files) ~= "table" then
return out
end
local prefix = #folder + 2
for _, file in ipairs(files) do
local extension = file:match("%.([^%.]+)$")
if extension and extension:lower() == "cfg" then
local name = file:sub(prefix, -5)
if name ~= "" then
out[#out + 1] = name
end
end
end
table.sort(out)
return out
end
function DriftConfig.export(name)
local path = path_of(name)
if not path or type(isfile) ~= "function" or not isfile(path) then
return nil
end
local ok, blob = pcall(readfile, path)
if not ok or type(blob) ~= "string" then
return nil
end
if type(setclipboard) == "function" then
pcall(setclipboard, blob)
end
return blob
end
function DriftConfig.readable(name)
local blob = DriftConfig.export(name)
local menu = api()
if not blob or not menu or type(menu.get_config_data) ~= "function" then
return nil
end
local ok, data = pcall(menu.get_config_data, blob)
if not ok or type(data) ~= "table" then
return nil
end
local encoded, json = pcall(function()
return game:GetService("HttpService"):JSONEncode(data)
end)
if encoded and type(json) == "string" then
return json
end
return nil
end
function DriftConfig.save(name)
local menu = api()
if not menu or type(menu.save_config) ~= "function" or not clean(name) then
return false
end
ensure()
local ok = pcall(menu.save_config, name)
return ok
end
function DriftConfig.load(name)
local menu = api()
if not menu or type(menu.load_config) ~= "function" or not clean(name) then
return false
end
local ok = pcall(menu.load_config, name)
return ok
end
function DriftConfig.import(name, blob)
local path = path_of(name)
if not path or type(blob) ~= "string" or #blob < 16 then
return false
end
if type(writefile) ~= "function" then
return false
end
ensure()
local ok = pcall(writefile, path, blob)
if not ok then
return false
end
DriftConfig.load(name)
return true
end
getgenv().DriftConfig = DriftConfig
end
local function build_esp()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = workspace
local localPlayer = Players.LocalPlayer
if not Drawing then
warn("[drift esp] no Drawing API - overlay esp stays off")
return
end
local standalone = type(fget) ~= "function"
local manual = true
local function get(name, default)
if not standalone then
local ok, value = pcall(fget, name, default)
if ok and value ~= nil then
return value
end
local live = getgenv().TeaJujuFlags
if type(live) == "table" and live[name] ~= nil then
return live[name]
end
return default
end
local config = getgenv().drift_esp
if type(config) == "table" and config[name] ~= nil then
return config[name]
end
return default
end
local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(0, 0, 0)
local guiParent = nil
do
local ok, core = pcall(function()
return game:GetService("CoreGui")
end)
if ok and core then
guiParent = core
end
if not guiParent then
local ok2, playerGui = pcall(function()
return localPlayer:FindFirstChildOfClass("PlayerGui")
end)
if ok2 then
guiParent = playerGui
end
end
end
if not guiParent then
warn("[drift esp] no gui parent available - overlay esp stays off")
return
end
local R15_BONES = {
{ "Head", "UpperTorso" },
{ "UpperTorso", "LowerTorso" },
{ "UpperTorso", "LeftUpperArm" },
{ "LeftUpperArm", "LeftLowerArm" },
{ "LeftLowerArm", "LeftHand" },
{ "UpperTorso", "RightUpperArm" },
{ "RightUpperArm", "RightLowerArm" },
{ "RightLowerArm", "RightHand" },
{ "LowerTorso", "LeftUpperLeg" },
{ "LeftUpperLeg", "LeftLowerLeg" },
{ "LeftLowerLeg", "LeftFoot" },
{ "LowerTorso", "RightUpperLeg" },
{ "RightUpperLeg", "RightLowerLeg" },
{ "RightLowerLeg", "RightFoot" },
}
local R6_BONES = {
{ "Head", "Torso" },
{ "Torso", "Left Arm" },
{ "Torso", "Right Arm" },
{ "Torso", "Left Leg" },
{ "Torso", "Right Leg" },
}
local DRAW_KEY = "__drift_esp_draw"
local GUI_KEY = "__drift_esp_gui"
local stale = getgenv()[DRAW_KEY]
if type(stale) == "table" then
for _, object in ipairs(stale) do
pcall(function()
object:Remove()
end)
end
end
local staleGui = getgenv()[GUI_KEY]
if type(staleGui) == "table" then
for _, object in ipairs(staleGui) do
pcall(function()
object:Destroy()
end)
end
end
local LOOP_KEY = "__drift_esp_loop"
local staleLoop = getgenv()[LOOP_KEY]
if type(staleLoop) == "function" then
pcall(staleLoop)
getgenv()[LOOP_KEY] = nil
end
local okScan, guiChildren = pcall(function()
return guiParent:GetChildren()
end)
if okScan and type(guiChildren) == "table" then
for _, object in ipairs(guiChildren) do
local name = object.Name
if typeof(object) == "Instance"
and object:IsA("ScreenGui")
and string.sub(name, 1, 10) == "drift_esp_" then
pcall(function()
object:Destroy()
end)
end
end
end
local pool = {}
local guiPool = {}
getgenv()[DRAW_KEY] = pool
getgenv()[GUI_KEY] = guiPool
local drawFailureWarned = false
local function new(kind)
local ok, object = pcall(function()
return Drawing.new(kind)
end)
if not ok or object == nil then
if not drawFailureWarned then
drawFailureWarned = true
warn("[drift esp] Drawing.new(" .. tostring(kind) .. ") unavailable - esp cannot draw")
end
return nil
end
object.Visible = false
pool[#pool + 1] = object
return object
end
local function label(size)
local ok, object = pcall(function()
local textLabel = Instance.new("TextLabel")
textLabel.BackgroundTransparency = 1
textLabel.BorderSizePixel = 0
textLabel.TextColor3 = WHITE
textLabel.TextStrokeColor3 = BLACK
textLabel.TextStrokeTransparency = 0
textLabel.TextScaled = false
textLabel.RichText = false
textLabel.TextSize = size
textLabel.Font = Enum.Font.Code
textLabel.TextXAlignment = Enum.TextXAlignment.Center
textLabel.Size = UDim2.new(0, 220, 0, size + 4)
textLabel.Visible = false
return textLabel
end)
if not ok or object == nil then
return nil
end
return object
end
local cache = {}
local function ensure(player)
local entry = cache[player]
if entry then
return entry
end
entry = {
box = new("Square"),
outline = new("Square"),
bones = {},
highlight = nil,
lastHealth = nil,
lastArmor = nil,
drawn = false,
}
if entry.box then
pcall(function()
entry.box.Filled = false
entry.box.Thickness = 2
entry.box.Color = WHITE
end)
end
if entry.outline then
pcall(function()
entry.outline.Filled = false
entry.outline.Thickness = 1
entry.outline.Color = BLACK
end)
end
entry.healthOutline = new("Square")
entry.healthFill = new("Square")
entry.armorOutline = new("Square")
entry.armorFill = new("Square")
for _, key in ipairs({ "healthOutline", "armorOutline" }) do
local object = entry[key]
if object then
pcall(function()
object.Filled = true
object.Thickness = 1
object.Color = BLACK
object.Transparency = 0.45
end)
end
end
if entry.healthFill then
pcall(function()
entry.healthFill.Filled = true
entry.healthFill.Color = Color3.fromRGB(0, 255, 0)
entry.healthFill.Transparency = 0
end)
end
if entry.armorFill then
pcall(function()
entry.armorFill.Filled = true
entry.armorFill.Color = Color3.fromRGB(120, 180, 255)
entry.armorFill.Transparency = 0
end)
end
local okGui, gui = pcall(function()
local screen = Instance.new("ScreenGui")
screen.Name = "drift_esp_" .. player.Name
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.DisplayOrder = 9999
screen.Parent = guiParent
return screen
end)
if okGui and gui then
guiPool[#guiPool + 1] = gui
entry.gui = gui
entry.name = label(14)
entry.studs = label(14)
entry.tool = label(14)
for _, key in ipairs({ "name", "studs", "tool" }) do
local object = entry[key]
if object then
object.Parent = gui
end
end
end
cache[player] = entry
return entry
end
local function hide(entry)
if not entry.drawn then
return
end
entry.drawn = false
if entry.box then
entry.box.Visible = false
end
if entry.outline then
entry.outline.Visible = false
end
for _, key in ipairs({ "name", "studs", "tool", "healthOutline", "healthFill",
"armorOutline", "armorFill" }) do
local object = entry[key]
if object then
object.Visible = false
end
end
for _, line in ipairs(entry.bones) do
if line then
line.Visible = false
end
end
end
local function destroy(entry)
hide(entry)
if entry.box then
pcall(function()
entry.box:Remove()
end)
end
if entry.outline then
pcall(function()
entry.outline:Remove()
end)
end
for _, key in ipairs({ "healthOutline", "healthFill", "armorOutline", "armorFill" }) do
local object = entry[key]
if object then
pcall(function()
object:Remove()
end)
entry[key] = nil
end
end
for _, line in ipairs(entry.bones) do
if line then
pcall(function()
line:Remove()
end)
end
end
if entry.highlight then
pcall(function()
entry.highlight:Destroy()
end)
entry.highlight = nil
end
if entry.gui then
pcall(function()
entry.gui:Destroy()
end)
entry.gui = nil
end
end
local function bone_line(entry, index)
local line = entry.bones[index]
if line then
return line
end
line = new("Line")
if line then
pcall(function()
line.Thickness = 1
line.Color = WHITE
line.Transparency = 0.85
end)
entry.bones[index] = line
end
return line
end
local function health_color(ratio)
local red, green
if ratio > 0.5 then
green = 1
red = (1 - ratio) * 2
else
red = 1
green = ratio * 2
end
return Color3.new(red, green, 0)
end
local BAR_WIDTH = 3
local BAR_GAP = 3
local function draw_bar(slot, background, fill, boxX, boxY, boxHeight, ratio, color)
if not background or not fill then
return
end
local bgX = boxX - BAR_GAP - BAR_WIDTH - 1 - slot * (BAR_WIDTH + BAR_GAP)
local bgY = boxY - 1
local bgHeight = boxHeight + 2
local inner = boxHeight
local fillHeight = math.floor(ratio * inner + 0.5)
if fillHeight > inner then
fillHeight = inner
elseif fillHeight < 0 then
fillHeight = 0
end
background.Position = Vector2.new(bgX, bgY)
background.Size = Vector2.new(BAR_WIDTH + 2, bgHeight)
background.Visible = true
if fillHeight < 1 then
fill.Visible = false
return
end
fill.Position = Vector2.new(bgX + 1, bgY + 1 + (inner - fillHeight))
fill.Size = Vector2.new(BAR_WIDTH, fillHeight)
if color then
fill.Color = color
end
fill.Visible = true
end
local function set_highlight(entry, character, enabled)
if not enabled then
if entry.highlight then
pcall(function()
entry.highlight:Destroy()
end)
entry.highlight = nil
end
return
end
if entry.highlight and entry.highlight.Parent ~= character then
pcall(function()
entry.highlight.Parent = character
end)
end
if not entry.highlight then
local ok, highlight = pcall(function()
local object = Instance.new("Highlight")
object.Name = "drift_esp"
object.FillColor = WHITE
object.FillTransparency = 0.72
object.OutlineColor = WHITE
object.OutlineTransparency = 0
object.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
object.Parent = character
return object
end)
if ok then
entry.highlight = highlight
end
end
end
local function read_armor(character, humanoid)
local bodyEffects = character:FindFirstChild("BodyEffects")
local armorValue = bodyEffects and bodyEffects:FindFirstChild("Armor")
if armorValue and typeof(armorValue) == "Instance" and armorValue:IsA("ValueBase") then
local maximum = bodyEffects:FindFirstChild("MaxArmor")
local maxValue = 130
if maximum and typeof(maximum) == "Instance" and maximum:IsA("ValueBase") then
maxValue = tonumber(maximum.Value) or maxValue
end
local current = tonumber(armorValue.Value)
if current then
return math.max(0, math.min(1, current / math.max(maxValue, 1)))
end
end
local attribute = character:GetAttribute("Armor") or humanoid:GetAttribute("Armor")
if type(attribute) == "number" then
local maxAttribute = character:GetAttribute("MaxArmor")
or humanoid:GetAttribute("MaxArmor")
or 100
return math.max(0, math.min(1, attribute / math.max(maxAttribute, 1)))
end
return 0
end
Players.PlayerRemoving:Connect(function(player)
local entry = cache[player]
if entry then
destroy(entry)
cache[player] = nil
end
end)
if standalone then
UserInputService.InputBegan:Connect(function(input, processed)
if processed then
return
end
if input.KeyCode == Enum.KeyCode.RightShift then
manual = not manual
end
end)
print("[drift esp] standalone - right shift toggles, overrides in getgenv().drift_esp")
end
local shown = false
local function render()
local camera = Workspace.CurrentCamera
local enabled = manual and get("esp_enabled", standalone) and camera ~= nil
if not enabled then
if shown then
for _, entry in pairs(cache) do
hide(entry)
end
shown = false
end
return
end
shown = true
local maxDistance = get("esp_max_distance", 2000)
local teamCheck = get("esp_team", true)
local textSize = get("esp_text_size", 14)
local widthScale = get("esp_width", 0.28)
local drawBox = get("esp_box", true)
local drawName = get("esp_name", true)
local drawDistance = get("esp_distance", true)
local drawTool = get("esp_tool", false)
local drawHealth = get("esp_health", true)
local drawArmor = get("esp_armor", false)
local drawSkeleton = get("esp_skeleton", false)
local drawHighlight = get("esp_highlight", false)
local cameraPosition = camera.CFrame.Position
local viewport = camera.ViewportSize
for _, player in ipairs(Players:GetPlayers()) do
local character = player.Character
local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
local root = character and character:FindFirstChild("HumanoidRootPart")
local sameTeam = teamCheck
and localPlayer.Team ~= nil
and player.Team == localPlayer.Team
local alive = player ~= localPlayer
and character ~= nil
and humanoid ~= nil
and humanoid.Health > 0
and root ~= nil
and not sameTeam
local distance = 0
if alive then
distance = (root.Position - cameraPosition).Magnitude
if distance > maxDistance then
alive = false
end
end
local entry = cache[player]
if not alive then
if entry then
hide(entry)
set_highlight(entry, character, false)
end
else
local screenPoint, onScreen = camera:WorldToViewportPoint(root.Position)
local lowerY = camera:WorldToViewportPoint(
root.Position - Vector3.new(0, 1, 0)
).Y
local upperY = camera:WorldToViewportPoint(
root.Position + Vector3.new(0, 3, 0)
).Y
local charSize = (lowerY - upperY) / 2
local visible = onScreen
and charSize > 1
and screenPoint.X > -64
and screenPoint.Y > -64
and screenPoint.X < viewport.X + 64
and screenPoint.Y < viewport.Y + 64
if not visible then
if entry then
hide(entry)
set_highlight(entry, character, false)
end
else
entry = ensure(player)
entry.drawn = true
local boxHeight = math.floor(charSize * 3.2)
local boxWidth = math.floor(charSize * 1.5)
if boxWidth > boxHeight * widthScale then
boxWidth = math.floor(boxHeight * widthScale)
end
if boxWidth < 2 then
boxWidth = 2
end
if boxHeight < 4 then
boxHeight = 4
end
local boxX = math.floor(screenPoint.X - boxWidth * 0.5)
local boxY = math.floor(screenPoint.Y - boxHeight * 0.47)
if drawBox and entry.box then
entry.box.Position = Vector2.new(boxX, boxY)
entry.box.Size = Vector2.new(boxWidth, boxHeight)
entry.box.Visible = true
elseif entry.box then
entry.box.Visible = false
end
if drawBox and entry.outline then
entry.outline.Position = Vector2.new(boxX - 1, boxY - 1)
entry.outline.Size = Vector2.new(boxWidth + 2, boxHeight + 2)
entry.outline.Visible = true
elseif entry.outline then
entry.outline.Visible = false
end
local centerX = boxX + boxWidth * 0.5
local guiY = boxY
if drawName and entry.name then
entry.name.TextSize = textSize
entry.name.Size = UDim2.new(0, 220, 0, textSize + 4)
entry.name.Text = player.Name
entry.name.Position = UDim2.new(0, centerX - 110, 0, guiY - textSize - 6)
entry.name.Visible = true
elseif entry.name then
entry.name.Visible = false
end
if drawDistance and entry.studs then
entry.studs.TextSize = textSize
entry.studs.Size = UDim2.new(0, 220, 0, textSize + 4)
entry.studs.Text = string.format("[%.0fm]", distance * 0.28)
entry.studs.Position = UDim2.new(0, centerX - 110, 0, guiY + boxHeight + 3)
entry.studs.Visible = true
elseif entry.studs then
entry.studs.Visible = false
end
if drawTool and entry.tool then
local held = character:FindFirstChildOfClass("Tool")
entry.tool.TextSize = textSize
entry.tool.Size = UDim2.new(0, 220, 0, textSize + 4)
entry.tool.Text = held and held.Name or "none"
entry.tool.Position = UDim2.new(0, centerX - 110, 0, guiY + boxHeight + textSize + 5)
entry.tool.Visible = true
elseif entry.tool then
entry.tool.Visible = false
end
if drawHealth and entry.healthOutline and entry.healthFill then
local target = humanoid.Health / math.max(humanoid.MaxHealth, 1)
target = math.max(0, math.min(1, target))
local last = entry.lastHealth
local ratio = target
if last then
ratio = last + (target - last) * 0.05
end
entry.lastHealth = ratio
draw_bar(0, entry.healthOutline, entry.healthFill,
boxX, boxY, boxHeight, ratio, health_color(ratio))
else
if entry.healthOutline then
entry.healthOutline.Visible = false
end
if entry.healthFill then
entry.healthFill.Visible = false
end
end
if drawArmor and entry.armorOutline and entry.armorFill then
local target = read_armor(character, humanoid)
local last = entry.lastArmor
local ratio = target
if last then
ratio = last + (target - last) * 0.05
end
entry.lastArmor = ratio
draw_bar(1, entry.armorOutline, entry.armorFill,
boxX, boxY, boxHeight, ratio, nil)
else
if entry.armorOutline then
entry.armorOutline.Visible = false
end
if entry.armorFill then
entry.armorFill.Visible = false
end
end
if drawSkeleton then
local map = character:FindFirstChild("UpperTorso") and R15_BONES or R6_BONES
for index = 1, #map do
local line = bone_line(entry, index)
local from = character:FindFirstChild(map[index][1])
local to = character:FindFirstChild(map[index][2])
if line and from and to and from:IsA("BasePart") and to:IsA("BasePart") then
local a = camera:WorldToViewportPoint(from.Position)
local b = camera:WorldToViewportPoint(to.Position)
if a.Z > 0 and b.Z > 0 then
line.From = Vector2.new(a.X, a.Y)
line.To = Vector2.new(b.X, b.Y)
line.Visible = true
else
line.Visible = false
end
elseif line then
line.Visible = false
end
end
for index = #map + 1, #entry.bones do
local line = entry.bones[index]
if line then
line.Visible = false
end
end
else
for _, line in ipairs(entry.bones) do
if line then
line.Visible = false
end
end
end
set_highlight(entry, character, drawHighlight)
end
end
end
end
local function step()
local ok, err = pcall(render)
if not ok then
warn("[drift esp] frame error: " .. tostring(err))
end
end
local connection = (RunService.PostSimulation or RunService.RenderStepped):Connect(step)
getgenv()[LOOP_KEY] = function()
pcall(function()
connection:Disconnect()
end)
for _, entry in pairs(cache) do
destroy(entry)
end
cache = {}
end
end
local okBuild, buildError = pcall(build_esp)
if not okBuild then
warn("[drift esp] failed: " .. tostring(buildError))
end
getgenv().TeaJujuMenu = menu
getgenv().TeaJujuFlags = flags
return menu

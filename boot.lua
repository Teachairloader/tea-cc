--[[
    tea.cc boot - key gate, patched drift, extras in one paste

        loadstring(game:HttpGet("<raw url>/boot.lua"))()

    Flow:
        1. gate.lua runs the key screen. Its own loader call is switched off so
           the menu that opens afterwards is the patched one this file builds.
        2. drift.lua is fetched, camlock is defaulted off at the source, compiled.
        3. tea-extras.lua is fetched (or taken from the copy embedded below) and
           runs the world changer, weather, cframe speed and orbit panels.

    Why the loader call is switched off: gate.lua pulls loader.lua from the
    repo, and loader.lua is a moving target. Booting drift from here keeps the
    key screen, keeps camlock disarmed, and cannot recurse into itself.

    If the gate's RUN_LOADER line ever changes shape, this falls back to letting
    the gate load its own chain and simply waits for the menu before adding the
    extras. Keys still gate access either way.
]]

local GATE_URL = "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/gate.lua"
local DRIFT_SOURCES = {
    "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/drift.lua",
    "https://raw.githubusercontent.com/Teachairloader/tea-cc/d59c66fc169c5002cbee77a842608e666eee54bb/drift.lua",
}
local EXTRAS_URL = "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/tea-extras.lua"
local MIN_SIZE = 20000
local WAIT_LIMIT = 900

local EXTRAS_FALLBACK = [==[
--[[
    tea.extras v2 - addon for tea.cc / drift

    Restores the full panel set the current build dropped:

        world changah   - lighting presets, sky/ground tint, ambient, fog colour,
                          brightness, time of day, fog distance, exposure,
                          fullbright, remove fog
        weather         - rain / snow / ash / fireflies, density, size, fall
                          speed, wind, colour, lightning
        cframe speed    - root CFrame movement, no WalkSpeed write
        orbit           - scriptable camera circling a pivot

    Run after the gate accepts a key, or standalone:

        loadstring(game:HttpGet("<raw url>/tea-extras.lua"))()

    Insert toggles the window. Right Shift hides it. Config persists to
    tea_extras.json in the executor workspace.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer

if getgenv().TeaExtras and getgenv().TeaExtras.destroy then
    pcall(getgenv().TeaExtras.destroy)
end

local CONFIG_PATH = "tea_extras.json"

local C = {
    bg = Color3.fromRGB(12, 12, 16),
    panel = Color3.fromRGB(20, 20, 27),
    row = Color3.fromRGB(32, 32, 41),
    accent = Color3.fromRGB(255, 121, 198),
    text = Color3.fromRGB(232, 232, 240),
    dim = Color3.fromRGB(138, 138, 152),
}

-- ------------------------------------------------------------------ state ---
local flags = {
    world_enabled = false,
    world_lighting = "Off",
    world_sky_tint = Color3.fromRGB(150, 190, 255),
    world_ground_tint = Color3.fromRGB(255, 255, 255),
    world_ambient = Color3.fromRGB(150, 150, 155),
    world_fog_color = Color3.fromRGB(140, 170, 220),
    world_fog_distance = 800,
    world_brightness = 2.5,
    world_time = 14,
    world_exposure = 0,
    world_fullbright = false,
    world_remove_fog = false,

    weather_type = "None",
    weather_density = 60,
    weather_size = 1,
    weather_fall = 100,
    weather_wind = 0,
    weather_color = Color3.fromRGB(230, 240, 255),
    weather_lightning = false,

    cframe_enabled = false,
    cframe_speed = 120,
    cframe_ground = true,

    orbit_enabled = false,
    orbit_pivot = "self",
    orbit_radius = 18,
    orbit_height = 6,
    orbit_speed = 45,
}

local COLOR_KEYS = {
    world_sky_tint = true,
    world_ground_tint = true,
    world_ambient = true,
    world_fog_color = true,
    weather_color = true,
}

local function encodeFlags()
    local out = {}
    for key, value in pairs(flags) do
        if typeof(value) == "Color3" then
            out[key] = { math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255) }
        else
            out[key] = value
        end
    end
    return HttpService:JSONEncode(out)
end

local function decodeFlags(body)
    local decoded = HttpService:JSONDecode(body)
    if type(decoded) ~= "table" then
        return
    end
    for key, value in pairs(decoded) do
        if flags[key] ~= nil then
            if COLOR_KEYS[key] then
                if type(value) == "table" and #value >= 3 then
                    flags[key] = Color3.fromRGB(value[1], value[2], value[3])
                end
            elseif type(value) == type(flags[key]) then
                flags[key] = value
            end
        end
    end
end

local function loadConfig()
    if type(isfile) ~= "function" or not isfile(CONFIG_PATH) then
        return
    end
    local okRead, body = pcall(readfile, CONFIG_PATH)
    if not okRead or type(body) ~= "string" then
        return
    end
    pcall(decodeFlags, body)
end

local function saveConfig()
    if type(writefile) ~= "function" then
        return
    end
    local okEncode, body = pcall(encodeFlags)
    if okEncode then
        pcall(writefile, CONFIG_PATH, body)
    end
end

loadConfig()

-- -------------------------------------------------------------------- ui ---
local function make(class, properties, parent)
    local instance = Instance.new(class)
    for key, value in pairs(properties) do
        instance[key] = value
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

local function guiParent()
    if type(gethui) == "function" then
        local ok, handle = pcall(gethui)
        if ok and handle then
            return handle
        end
    end
    return LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui")
end

local gui = make("ScreenGui", {
    Name = "TeaExtras",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, guiParent())

local main = make("Frame", {
    Size = UDim2.fromOffset(280, 540),
    Position = UDim2.new(0, 40, 0, 120),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    ClipsDescendants = false,
    Active = true,
}, gui)
make("UICorner", { CornerRadius = UDim.new(0, 8) }, main)
make("UIStroke", { Color = C.accent, Transparency = 0.6, Thickness = 1 }, main)

local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Active = true,
}, main)

make("TextLabel", {
    Size = UDim2.new(1, -70, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Text = "tea.extras",
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextColor3 = C.accent,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local closeButton = make("TextButton", {
    Size = UDim2.fromOffset(24, 24),
    Position = UDim2.new(1, -34, 0, 5),
    BackgroundColor3 = C.row,
    BackgroundTransparency = 1,
    Text = "x",
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextColor3 = C.dim,
    AutoButtonColor = false,
    BorderSizePixel = 0,
}, header)
make("UICorner", { CornerRadius = UDim.new(0, 4) }, closeButton)
closeButton.MouseButton1Click:Connect(function()
    main.Visible = false
    UIS.MouseIconEnabled = true
end)

local scroll = make("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -34),
    Position = UDim2.fromOffset(0, 34),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.accent,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)
make("UIPadding", {
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 8),
}, scroll)
make("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, scroll)

local LAYOUT = 0
local PAINTERS = {}

local function nextOrder()
    LAYOUT += 1
    return LAYOUT
end

local function repaintAll()
    for _, painter in ipairs(PAINTERS) do
        pcall(painter)
    end
end

local function section(title)
    local wrap = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0,
    }, scroll)
    wrap.LayoutOrder = nextOrder()
    make("UICorner", { CornerRadius = UDim.new(0, 6) }, wrap)
    make("UIStroke", { Color = C.row, Thickness = 1 }, wrap)

    local inner = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, wrap)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
    }, inner)
    make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, inner)

    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = title,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextColor3 = C.accent,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, inner).LayoutOrder = nextOrder()

    return inner
end

local function rowFrame(parent, height)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, parent)
    row.LayoutOrder = nextOrder()
    return row
end

local function toggle(parent, text, key, onChange)
    local row = rowFrame(parent, 26)

    make("TextLabel", {
        Size = UDim2.new(1, -26, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local box = make("Frame", {
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(1, -14, 0.5, -7),
        BackgroundColor3 = C.row,
        BorderSizePixel = 0,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(0, 3) }, box)

    local dot = make("Frame", {
        Size = UDim2.fromOffset(6, 6),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0,
        Visible = false,
    }, box)
    make("UICorner", { CornerRadius = UDim.new(0, 2) }, dot)

    local function paint()
        local on = flags[key] == true
        box.BackgroundColor3 = on and C.accent or C.row
        dot.Visible = on
    end

    local click = make("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, row)
    click.MouseButton1Click:Connect(function()
        flags[key] = not flags[key]
        paint()
        saveConfig()
        if onChange then
            onChange(flags[key])
        end
    end)

    table.insert(PAINTERS, paint)
    paint()
    return row
end

local function slider(parent, text, key, minimum, maximum, decimals, onChange)
    local row = rowFrame(parent, 36)

    make("TextLabel", {
        Size = UDim2.new(1, -54, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local valueLabel = make("TextLabel", {
        Size = UDim2.fromOffset(54, 16),
        Position = UDim2.new(1, -54, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextColor3 = C.accent,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)

    local track = make("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.fromOffset(0, 24),
        BackgroundColor3 = C.row,
        BorderSizePixel = 0,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(0, 2) }, track)

    local fill = make("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
    }, track)
    make("UICorner", { CornerRadius = UDim.new(0, 2) }, fill)

    local function paint()
        local value = flags[key]
        local alpha = (value - minimum) / (maximum - minimum)
        fill.Size = UDim2.new(math.clamp(alpha, 0, 1), 0, 1, 0)
        valueLabel.Text = string.format("%." .. decimals .. "f", value)
    end

    local function setFromX(x)
        local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local raw = minimum + (maximum - minimum) * alpha
        local step = 10 ^ decimals
        flags[key] = math.floor(raw * step + 0.5) / step
        paint()
        saveConfig()
        if onChange then
            onChange(flags[key])
        end
    end

    local dragging = false
    local hit = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.fromOffset(0, 14),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, row)

    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            setFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    table.insert(PAINTERS, paint)
    paint()
    return row
end

local function dropdown(parent, text, key, options, onChange)
    local row = rowFrame(parent, 26)

    make("TextLabel", {
        Size = UDim2.new(1, -96, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local valueButton = make("TextButton", {
        Size = UDim2.fromOffset(90, 20),
        Position = UDim2.new(1, -90, 0.5, -10),
        BackgroundColor3 = C.row,
        Text = tostring(flags[key]),
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextColor3 = C.accent,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(0, 4) }, valueButton)

    local function paint()
        valueButton.Text = tostring(flags[key])
    end

    valueButton.MouseButton1Click:Connect(function()
        local index = 1
        for position, option in ipairs(options) do
            if option == flags[key] then
                index = position
                break
            end
        end
        index = index % #options + 1
        flags[key] = options[index]
        paint()
        saveConfig()
        if onChange then
            onChange(flags[key])
        end
    end)

    table.insert(PAINTERS, paint)
    return row
end

local function hexOf(color)
    return string.format("%02X%02X%02X",
        math.round(color.R * 255),
        math.round(color.G * 255),
        math.round(color.B * 255))
end

-- colour row: swatch opens a channel flyout, values write straight into flags
local function colorRow(parent, text, key, onChange)
    local row = rowFrame(parent, 26)

    make("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local swatch = make("TextButton", {
        Size = UDim2.fromOffset(26, 16),
        Position = UDim2.new(1, -26, 0.5, -8),
        BackgroundColor3 = flags[key],
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(0, 3) }, swatch)
    make("UIStroke", { Color = C.dim, Transparency = 0.6, Thickness = 1 }, swatch)

    local function paint()
        swatch.BackgroundColor3 = flags[key]
    end

    local panel
    local function closePanel()
        if panel then
            panel:Destroy()
            panel = nil
        end
    end

    local function channelSlider(order, label, index)
        local channel = make("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
        }, panel)
        channel.LayoutOrder = order

        make("TextLabel", {
            Size = UDim2.new(1, -34, 0, 14),
            BackgroundTransparency = 1,
            Text = label,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextColor3 = C.text,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, channel)

        local valueLabel = make("TextLabel", {
            Size = UDim2.fromOffset(34, 14),
            Position = UDim2.new(1, -34, 0, 0),
            BackgroundTransparency = 1,
            Text = "",
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            TextColor3 = C.accent,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, channel)

        local track = make("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.fromOffset(0, 20),
            BackgroundColor3 = C.row,
            BorderSizePixel = 0,
        }, channel)
        make("UICorner", { CornerRadius = UDim.new(0, 2) }, track)

        local fill = make("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = C.accent,
            BorderSizePixel = 0,
        }, track)
        make("UICorner", { CornerRadius = UDim.new(0, 2) }, fill)

        local hit = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.fromOffset(0, 12),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
        }, channel)

        local function paint()
            local color = flags[key]
            local value = ({ color.R, color.G, color.B })[index] * 255
            fill.Size = UDim2.new(math.clamp(value / 255, 0, 1), 0, 1, 0)
            valueLabel.Text = tostring(math.round(value))
        end

        local function setFromX(x)
            local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            local value = math.round(alpha * 255)
            local color = flags[key]
            local r, g, b = color.R * 255, color.G * 255, color.B * 255
            if index == 1 then
                r = value
            elseif index == 2 then
                g = value
            else
                b = value
            end
            flags[key] = Color3.fromRGB(r, g, b)
            paint()
            saveConfig()
            if onChange then
                onChange(flags[key])
            end
        end

        local dragging = false
        hit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                setFromX(input.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragging then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                setFromX(input.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        table.insert(PAINTERS, paint)
        paint()
    end

    swatch.MouseButton1Click:Connect(function()
        if panel then
            closePanel()
            return
        end

        panel = make("Frame", {
            Size = UDim2.fromOffset(186, 148),
            Position = UDim2.fromOffset(
                swatch.AbsolutePosition.X - main.AbsolutePosition.X - 100,
                swatch.AbsolutePosition.Y - main.AbsolutePosition.Y + 20
            ),
            BackgroundColor3 = C.panel,
            BorderSizePixel = 0,
            ZIndex = 20,
        }, main)
        make("UICorner", { CornerRadius = UDim.new(0, 6) }, panel)
        make("UIStroke", { Color = C.accent, Transparency = 0.35, Thickness = 1 }, panel)
        make("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6),
        }, panel)
        make("UIListLayout", {
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, panel)

        local titleRow = make("Frame", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
        }, panel)
        titleRow.LayoutOrder = 0
        make("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            BackgroundTransparency = 1,
            Text = text .. "  #" .. hexOf(flags[key]),
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            TextColor3 = C.accent,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, titleRow)

        local closePanelButton = make("TextButton", {
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.new(1, -16, 0, 0),
            BackgroundTransparency = 1,
            Text = "x",
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextColor3 = C.dim,
            AutoButtonColor = false,
        }, titleRow)
        closePanelButton.MouseButton1Click:Connect(closePanel)

        channelSlider(1, "red", 1)
        channelSlider(2, "green", 2)
        channelSlider(3, "blue", 3)
    end)

    table.insert(PAINTERS, paint)
    paint()
    return row
end

local function button(parent, text, callback)
    local row = rowFrame(parent, 24)
    local click = make("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = C.row,
        Text = text,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextColor3 = C.text,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(0, 4) }, click)
    click.MouseButton1Click:Connect(callback)
    return row
end

-- drag the window
do
    local dragging = false
    local origin, startPosition
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            origin = input.Position
            startPosition = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - origin
            main.Position = UDim2.new(
                0, startPosition.X.Offset + delta.X,
                0, startPosition.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ----------------------------------------------------------------- world ---
local worldBackup = nil
local ownAtmosphere = nil
local ownTint = nil

local function ensureLighting()
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Name = "TeaAtmosphere"
        atmosphere.Parent = Lighting
        ownAtmosphere = atmosphere
    end

    local tint = Lighting:FindFirstChild("TeaWorldTint")
    if not tint then
        tint = Instance.new("ColorCorrectionEffect")
        tint.Name = "TeaWorldTint"
        tint.Brightness = 0
        tint.Contrast = 0
        tint.Saturation = 0
        tint.TintColor = Color3.fromRGB(255, 255, 255)
        tint.Parent = Lighting
        ownTint = tint
    end

    return atmosphere, tint
end

local function snapshotWorld()
    worldBackup = {
        brightness = Lighting.Brightness,
        clock = Lighting.ClockTime,
        fogStart = Lighting.FogStart,
        fogEnd = Lighting.FogEnd,
        fogColor = Lighting.FogColor,
        ambient = Lighting.Ambient,
        outdoor = Lighting.OutdoorAmbient,
        shadows = Lighting.GlobalShadows,
        exposure = Lighting.ExposureCompensation,
        diffuse = Lighting.EnvironmentDiffuseScale,
        specular = Lighting.EnvironmentSpecularScale,
        gravity = Workspace.Gravity,
        sky = Lighting:FindFirstChildOfClass("Sky"),
        clouds = Lighting:FindFirstChildOfClass("Clouds"),
        atmosphere = Lighting:FindFirstChildOfClass("Atmosphere"),
        atmosphereProps = nil,
        tint = Lighting:FindFirstChild("TeaWorldTint"),
    }

    local atmosphere = worldBackup.atmosphere
    if atmosphere then
        worldBackup.atmosphereProps = {
            color = atmosphere.Color,
            decay = atmosphere.Decay,
            density = atmosphere.Density,
            haze = atmosphere.Haze,
            glare = atmosphere.Glare,
        }
    end
end

local function applyWorld()
    if not worldBackup then
        snapshotWorld()
    end

    local atmosphere, tint = ensureLighting()

    Lighting.Brightness = flags.world_brightness
    Lighting.ClockTime = flags.world_time
    Lighting.GlobalShadows = not flags.world_fullbright
    Lighting.ExposureCompensation = flags.world_exposure
    Lighting.Ambient = flags.world_ambient
    Lighting.FogColor = flags.world_fog_color

    if flags.world_remove_fog then
        Lighting.FogStart = 0
        Lighting.FogEnd = 1e6
    else
        Lighting.FogStart = 0
        Lighting.FogEnd = math.max(flags.world_fog_distance, 1)
    end

    if flags.world_fullbright then
        Lighting.OutdoorAmbient = Color3.fromRGB(170, 170, 170)
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
    else
        Lighting.OutdoorAmbient = worldBackup.outdoor
        Lighting.EnvironmentDiffuseScale = worldBackup.diffuse
        Lighting.EnvironmentSpecularScale = worldBackup.specular
    end

    atmosphere.Color = flags.world_sky_tint
    atmosphere.Decay = Color3.fromRGB(80, 90, 110)
    atmosphere.Density = 0.3
    atmosphere.Haze = 0
    atmosphere.Glare = 0

    tint.TintColor = flags.world_ground_tint

    if worldBackup.sky then
        worldBackup.sky.Parent = Lighting
    end
    if worldBackup.clouds then
        worldBackup.clouds.Parent = Lighting
    end
end

local function restoreWorld()
    if not worldBackup then
        return
    end
    Lighting.Brightness = worldBackup.brightness
    Lighting.ClockTime = worldBackup.clock
    Lighting.FogStart = worldBackup.fogStart
    Lighting.FogEnd = worldBackup.fogEnd
    Lighting.FogColor = worldBackup.fogColor
    Lighting.Ambient = worldBackup.ambient
    Lighting.OutdoorAmbient = worldBackup.outdoor
    Lighting.GlobalShadows = worldBackup.shadows
    Lighting.ExposureCompensation = worldBackup.exposure
    Lighting.EnvironmentDiffuseScale = worldBackup.diffuse
    Lighting.EnvironmentSpecularScale = worldBackup.specular
    Workspace.Gravity = worldBackup.gravity

    if worldBackup.sky then
        worldBackup.sky.Parent = Lighting
    end
    if worldBackup.clouds then
        worldBackup.clouds.Parent = Lighting
    end
    local atmosphere = worldBackup.atmosphere
    local props = worldBackup.atmosphereProps
    if atmosphere and atmosphere.Parent and props then
        atmosphere.Color = props.color
        atmosphere.Decay = props.decay
        atmosphere.Density = props.density
        atmosphere.Haze = props.haze
        atmosphere.Glare = props.glare
    end
    if ownAtmosphere then
        ownAtmosphere:Destroy()
        ownAtmosphere = nil
    end
    if ownTint then
        ownTint:Destroy()
        ownTint = nil
    end
end

local LIGHTING_PRESETS = {
    Day = {
        world_time = 13.5,
        world_brightness = 2.5,
        world_exposure = 0,
        world_fullbright = true,
        world_remove_fog = false,
        world_fog_distance = 2000,
        world_fog_color = Color3.fromRGB(170, 200, 240),
        world_ambient = Color3.fromRGB(150, 150, 155),
        world_sky_tint = Color3.fromRGB(150, 195, 255),
        world_ground_tint = Color3.fromRGB(255, 255, 255),
    },
    Night = {
        world_time = 0,
        world_brightness = 1,
        world_exposure = -0.5,
        world_fullbright = false,
        world_remove_fog = false,
        world_fog_distance = 420,
        world_fog_color = Color3.fromRGB(18, 22, 38),
        world_ambient = Color3.fromRGB(48, 52, 72),
        world_sky_tint = Color3.fromRGB(12, 16, 34),
        world_ground_tint = Color3.fromRGB(210, 215, 255),
    },
    Sunset = {
        world_time = 17.6,
        world_brightness = 2,
        world_exposure = 0,
        world_fullbright = false,
        world_remove_fog = false,
        world_fog_distance = 900,
        world_fog_color = Color3.fromRGB(255, 150, 95),
        world_ambient = Color3.fromRGB(170, 120, 95),
        world_sky_tint = Color3.fromRGB(255, 140, 80),
        world_ground_tint = Color3.fromRGB(255, 220, 200),
    },
    Neon = {
        world_time = 0,
        world_brightness = 1.6,
        world_exposure = 1,
        world_fullbright = false,
        world_remove_fog = false,
        world_fog_distance = 320,
        world_fog_color = Color3.fromRGB(255, 0, 150),
        world_ambient = Color3.fromRGB(255, 60, 180),
        world_sky_tint = Color3.fromRGB(70, 0, 120),
        world_ground_tint = Color3.fromRGB(255, 180, 240),
    },
    Void = {
        world_time = 0,
        world_brightness = 0,
        world_exposure = -2,
        world_fullbright = false,
        world_remove_fog = false,
        world_fog_distance = 60,
        world_fog_color = Color3.fromRGB(0, 0, 0),
        world_ambient = Color3.fromRGB(0, 0, 0),
        world_sky_tint = Color3.fromRGB(0, 0, 0),
        world_ground_tint = Color3.fromRGB(120, 120, 120),
    },
}

-- ----------------------------------------------------------------- weather ---
local WEATHER_TYPES = {
    None = { texture = "", rateScale = 1 },
    Rain = { texture = "rbxassetid://241876428", fall = 240, size = 0.35, density = 900 },
    Snow = { texture = "rbxasset://textures/particles/smoke_main.dds", fall = 35, size = 0.9, density = 240 },
    Ash = { texture = "rbxasset://textures/particles/sparkles_main.dds", fall = 22, size = 0.5, density = 180 },
    Fireflies = { texture = "rbxasset://textures/particles/sparkles_main.dds", fall = -12, size = 0.45, density = 90 },
}

local weatherPart, weatherEmitter, weatherConnection
local lightningClock = 0
local lightningFlash = false

local function ensureWeather()
    if weatherPart and weatherPart.Parent then
        return
    end

    weatherPart = Instance.new("Part")
    weatherPart.Name = "TeaWeather"
    weatherPart.Size = Vector3.new(240, 1, 240)
    weatherPart.Transparency = 1
    weatherPart.Anchored = true
    weatherPart.CanCollide = false
    weatherPart.CanQuery = false
    weatherPart.CanTouch = false
    weatherPart.CastShadow = false
    weatherPart.Parent = Workspace

    weatherEmitter = Instance.new("ParticleEmitter")
    weatherEmitter.Name = "TeaWeatherEmitter"
    weatherEmitter.LightEmission = 0.6
    weatherEmitter.LightInfluence = 0
    weatherEmitter.EmissionDirection = Enum.NormalId.Bottom
    weatherEmitter.SpreadAngle = Vector2.new(8, 8)
    weatherEmitter.Rotation = NumberRange.new(0, 360)
    weatherEmitter.Lifetime = NumberRange.new(2, 3.5)
    weatherEmitter.Parent = weatherPart
end

local function updateWeather()
    local preset = WEATHER_TYPES[flags.weather_type] or WEATHER_TYPES.None

    if flags.weather_type == "None" then
        if weatherEmitter then
            weatherEmitter.Enabled = false
        end
        return
    end

    ensureWeather()

    weatherEmitter.Texture = preset.texture
    weatherEmitter.Enabled = true
    weatherEmitter.Rate = math.max(flags.weather_density, 1) * (preset.density and (preset.density / 240) or 1)
    weatherEmitter.Speed = NumberRange.new(flags.weather_fall * 0.25, flags.weather_fall * 0.4)
    weatherEmitter.Acceleration = Vector3.new(flags.weather_wind, -flags.weather_fall, 0)
    weatherEmitter.Size = NumberSequence.new(flags.weather_size)
    weatherEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 0.7),
    })
    weatherEmitter.Color = ColorSequence.new(flags.weather_color)
end

local function stopWeather()
    if weatherConnection then
        weatherConnection:Disconnect()
        weatherConnection = nil
    end
    if weatherPart then
        weatherPart:Destroy()
        weatherPart = nil
        weatherEmitter = nil
    end
    if lightningFlash then
        Lighting.Brightness = flags.world_brightness
        lightningFlash = false
    end
end

local function startWeather()
    if weatherConnection then
        return
    end
    weatherConnection = RunService.Heartbeat:Connect(function(delta)
        local camera = Workspace.CurrentCamera
        local character = LP.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local anchor = root and root.Position or (camera and camera.CFrame.Position)
        if not anchor then
            return
        end

        updateWeather()

        if weatherPart and weatherPart.Parent then
            weatherPart.CFrame = CFrame.new(anchor + Vector3.new(0, 26, 0))
        end

        if flags.weather_lightning and flags.weather_type ~= "None" then
            lightningClock -= delta
            if lightningClock <= 0 then
                lightningClock = math.random(40, 110) / 10
                lightningFlash = true
                Lighting.Brightness = math.max(flags.world_brightness, 6)
                task.delay(0.08, function()
                    lightningFlash = false
                    if flags.world_enabled then
                        Lighting.Brightness = flags.world_brightness
                    else
                        Lighting.Brightness = worldBackup and worldBackup.brightness or Lighting.Brightness
                    end
                end)
            end
        end
    end)
end

-- ----------------------------------------------------------- cframe speed ---
local speedConnection = nil

local function currentRig()
    local character = LP.Character
    if not character then
        return nil, nil
    end
    return character, character:FindFirstChild("HumanoidRootPart")
end

local function stopSpeed()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
end

local function startSpeed()
    if speedConnection then
        return
    end
    speedConnection = RunService.Heartbeat:Connect(function(delta)
        if not flags.cframe_enabled then
            return
        end

        local character, root = currentRig()
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not (root and humanoid) or humanoid.Health <= 0 then
            return
        end
        if flags.cframe_ground and humanoid.FloorMaterial == Enum.Material.Air then
            return
        end

        local direction = humanoid.MoveDirection
        if direction.Magnitude < 0.05 then
            return
        end

        -- humanoid already walks at its own WalkSpeed; add only the difference.
        local extra = flags.cframe_speed - humanoid.WalkSpeed
        if extra <= 0 then
            return
        end

        root.CFrame = root.CFrame + direction * extra * delta
    end)
end

-- ----------------------------------------------------------------- orbit ---
local orbitConnection = nil
local orbitAngle = 0
local savedCameraType = nil

local function orbitPivot()
    if flags.orbit_pivot == "self" then
        local character, root = currentRig()
        if not root then
            return nil
        end
        local head = character:FindFirstChild("Head")
        return (head and head.Position) or (root.Position + Vector3.new(0, 1.5, 0))
    end

    local bestPosition, bestDistance = nil, math.huge
    local _, selfRoot = currentRig()
    local origin = selfRoot and selfRoot.Position or Vector3.zero
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0 then
                local distance = (root.Position - origin).Magnitude
                if distance < bestDistance then
                    bestDistance, bestPosition = distance, root.Position
                end
            end
        end
    end
    return bestPosition
end

local function stopOrbit()
    if orbitConnection then
        orbitConnection:Disconnect()
        orbitConnection = nil
    end
    local camera = Workspace.CurrentCamera
    if camera and savedCameraType then
        camera.CameraType = savedCameraType
    end
    savedCameraType = nil
end

local function startOrbit()
    if orbitConnection then
        return
    end
    orbitAngle = 0
    orbitConnection = RunService.RenderStepped:Connect(function(delta)
        if not flags.orbit_enabled then
            return
        end
        local camera = Workspace.CurrentCamera
        local pivot = orbitPivot()
        if not camera or not pivot then
            return
        end
        if not savedCameraType then
            savedCameraType = camera.CameraType
        end
        orbitAngle = (orbitAngle + math.rad(flags.orbit_speed) * delta) % (math.pi * 2)
        camera.CameraType = Enum.CameraType.Scriptable
        local offset = Vector3.new(
            math.cos(orbitAngle) * flags.orbit_radius,
            flags.orbit_height,
            math.sin(orbitAngle) * flags.orbit_radius
        )
        camera.CFrame = CFrame.lookAt(pivot + offset, pivot)
    end)
end

-- ------------------------------------------------------------- wire to ui ---
local function worldEnable()
    if not flags.world_enabled then
        flags.world_enabled = true
        snapshotWorld()
    end
    applyWorld()
end

local function worldDisable()
    flags.world_enabled = false
    restoreWorld()
    worldBackup = nil
end

local worldSection = section("world changer")
dropdown(worldSection, "lighting", "world_lighting", { "Off", "Custom", "Day", "Night", "Sunset", "Neon", "Void" }, function(value)
    if value == "Off" then
        worldDisable()
        return
    end
    local preset = LIGHTING_PRESETS[value]
    if preset then
        for key, setting in pairs(preset) do
            flags[key] = setting
        end
    end
    worldEnable()
    saveConfig()
    repaintAll()
end)

colorRow(worldSection, "sky tint", "world_sky_tint", function()
    if flags.world_enabled then applyWorld() end
end)
colorRow(worldSection, "ground tint", "world_ground_tint", function()
    if flags.world_enabled then applyWorld() end
end)
colorRow(worldSection, "ambient", "world_ambient", function()
    if flags.world_enabled then applyWorld() end
end)
colorRow(worldSection, "fog", "world_fog_color", function()
    if flags.world_enabled then applyWorld() end
end)
slider(worldSection, "brightness", "world_brightness", 0, 10, 1, function()
    if flags.world_enabled then applyWorld() end
end)
slider(worldSection, "time of day", "world_time", 0, 24, 1, function()
    if flags.world_enabled then applyWorld() end
end)
slider(worldSection, "fog distance", "world_fog_distance", 50, 5000, 0, function()
    if flags.world_enabled then applyWorld() end
end)
slider(worldSection, "exposure", "world_exposure", -3, 3, 1, function()
    if flags.world_enabled then applyWorld() end
end)
toggle(worldSection, "fullbright", "world_fullbright", function()
    if flags.world_enabled then applyWorld() end
end)
toggle(worldSection, "remove fog", "world_remove_fog", function()
    if flags.world_enabled then applyWorld() end
end)

local weatherSection = section("weather")
dropdown(weatherSection, "type", "weather_type", { "None", "Rain", "Snow", "Ash", "Fireflies" }, function(value)
    if value ~= "None" then
        startWeather()
    end
    updateWeather()
    if value == "None" then
        stopWeather()
    end
end)
slider(weatherSection, "density", "weather_density", 1, 2000, 0, function()
    if weatherConnection then updateWeather() end
end)
slider(weatherSection, "size", "weather_size", 0.1, 8, 1, function()
    if weatherConnection then updateWeather() end
end)
slider(weatherSection, "fall speed", "weather_fall", 5, 500, 0, function()
    if weatherConnection then updateWeather() end
end)
slider(weatherSection, "wind", "weather_wind", -200, 200, 0, function()
    if weatherConnection then updateWeather() end
end)
colorRow(weatherSection, "colour", "weather_color", function()
    if weatherConnection then updateWeather() end
end)
toggle(weatherSection, "lightning", "weather_lightning")

-- cframe speed
local speedSection = section("cframe speed")
toggle(speedSection, "enabled", "cframe_enabled", function(on)
    if on then
        startSpeed()
    else
        stopSpeed()
    end
end)
toggle(speedSection, "grounded only", "cframe_ground")
slider(speedSection, "speed", "cframe_speed", 0, 500, 0)

-- orbit
local orbitSection = section("orbit")
toggle(orbitSection, "enabled", "orbit_enabled", function(on)
    if on then
        startOrbit()
    else
        stopOrbit()
    end
end)
dropdown(orbitSection, "pivot", "orbit_pivot", { "self", "nearest" })
slider(orbitSection, "radius", "orbit_radius", 2, 80, 0)
slider(orbitSection, "height", "orbit_height", -20, 60, 0)
slider(orbitSection, "degrees / sec", "orbit_speed", -360, 360, 0)

local footerSection = section("hotkeys")
make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundTransparency = 1,
    Text = "insert  window   right shift  hide",
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextColor3 = C.dim,
    TextXAlignment = Enum.TextXAlignment.Left,
}, footerSection).LayoutOrder = nextOrder()

-- ------------------------------------------------------------------ boot ---
if flags.weather_type ~= "None" then
    startWeather()
    updateWeather()
end
if flags.world_enabled then
    snapshotWorld()
    applyWorld()
end
if flags.cframe_enabled then
    startSpeed()
end
if flags.orbit_enabled then
    startOrbit()
end

-- ----------------------------------------------------------------- input ---
local inputConnection = UIS.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end
    if input.KeyCode == Enum.KeyCode.Insert then
        main.Visible = not main.Visible
        if main.Visible then
            UIS.MouseIconEnabled = true
        end
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = false
    end
end)

getgenv().TeaExtras = {
    flags = flags,
    gui = gui,
    applyWorld = applyWorld,
    updateWeather = updateWeather,
    destroy = function()
        pcall(stopSpeed)
        pcall(stopOrbit)
        pcall(stopWeather)
        pcall(restoreWorld)
        if inputConnection then
            inputConnection:Disconnect()
        end
        if gui then
            gui:Destroy()
        end
        getgenv().TeaExtras = nil
    end,
}
]==]

local function fetch(url, minimum)
    local ok, body = pcall(function()
        return game:HttpGet(url .. "?t=" .. tostring(os.time()))
    end)
    if ok and type(body) == "string" and #body >= minimum then
        return body
    end
    return nil
end

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
        hits += 1
    end
    parts[#parts + 1] = text:sub(index)
    return table.concat(parts), hits
end

-- ------------------------------------------------------------------- gate ---
local gateSource = fetch(GATE_URL, MIN_SIZE)
if not gateSource then
    return warn("[tea.boot] gate fetch failed - nothing to run")
end

local gated, gateHits = lit(gateSource, "local RUN_LOADER = true", "local RUN_LOADER = false")
local buildsMenu = gateHits > 0
if buildsMenu then
    gateSource = gated
    -- same reason: this file owns the extras pass, the gate must not race it.
    gateSource = lit(gateSource, "local RUN_EXTRAS = true", "local RUN_EXTRAS = false")
end

local gateChunk, gateError = loadstring(gateSource)
if not gateChunk then
    return warn("[tea.boot] gate compile failed: " .. tostring(gateError))
end

local gateOk, gateRunError = pcall(gateChunk)
if not gateOk then
    return warn("[tea.boot] gate run failed: " .. tostring(gateRunError))
end

-- ------------------------------------------------------------------ drift ---
local function runDrift()
    local drift
    for _, url in ipairs(DRIFT_SOURCES) do
        drift = fetch(url, MIN_SIZE)
        if drift then
            break
        end
    end
    if not drift then
        return warn("[tea.boot] drift fetch failed")
    end

    drift = drift:gsub("\r\n", "\n")

    -- camlock off at the source: the stock block ships aim_enabled = true, so
    -- the lock grabs the camera the frame the menu loads. Patch the same lit()
    -- call drift uses for its own edits, before drift compiles.
    local anchor = [==[
source = lit(
    source,
    'y = block(main, "combat", 1, y, "aimbot", {',
    'y = block(main, "combat", 1, y, "camlock", {'
)
]==]

    local patch = anchor .. [==[

source = lit(
    source,
    '    { k = "toggle", n = "enabled", f = "aim_enabled", d = true },',
    '    { k = "toggle", n = "enabled", f = "aim_enabled", d = false },'
)
]==]

    local patched, hits = lit(drift, anchor, patch)
    if hits > 0 then
        drift = patched
    else
        warn("[tea.boot] camlock anchor missing - relying on the flag clear")
    end

    local chunk, compileError = loadstring(drift)
    if not chunk then
        return warn("[tea.boot] drift compile failed: " .. tostring(compileError))
    end

    local ok, runError = pcall(chunk)
    if not ok then
        warn("[tea.boot] drift run failed: " .. tostring(runError))
    end
end

-- ----------------------------------------------------------------- extras ---
local function runExtras()
    local extras = fetch(EXTRAS_URL, MIN_SIZE) or EXTRAS_FALLBACK
    local chunk, compileError = loadstring(extras)
    if not chunk then
        return warn("[tea.boot] extras compile failed: " .. tostring(compileError))
    end
    local ok, runError = pcall(chunk)
    if not ok then
        warn("[tea.boot] extras run failed: " .. tostring(runError))
    end
end

local function clearCamlock()
    local menuFlags = getgenv().TeaJujuFlags
    if type(menuFlags) == "table" and menuFlags.aim_enabled ~= nil then
        menuFlags.aim_enabled = false
    end
end

-- ------------------------------------------------------------- key wait ---
task.spawn(function()
    local deadline = os.clock() + WAIT_LIMIT
    local accepted = false

    while os.clock() < deadline do
        if buildsMenu then
            local gate = getgenv().TeaGate
            if gate and gate.loading then
                accepted = true
                break
            end
        elseif getgenv().TeaJujuFlags then
            accepted = true
            break
        end
        task.wait(0.25)
    end

    if not accepted then
        return warn("[tea.boot] key never accepted - extras not loaded")
    end

    task.wait(0.2)

    if buildsMenu then
        runDrift()
        task.wait(0.3)
    end

    clearCamlock()
    runExtras()
    print("[tea.boot] up - key gated, camlock disarmed, extras loaded")
end)

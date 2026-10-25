--[[
    tea.cc - public entry point

    One line, no paste blocks:

        loadstring(game:HttpGet("https://raw.githubusercontent.com/Teachairloader/tea-cc/main/gate.lua"))()

    Flow: key screen -> key valid -> loading screen -> menu -> extras panel.
    loader.lua and drift.lua stay internal. tea-extras.lua is public and is

    Key list:
        https://raw.githubusercontent.com/Teachairloader/tea-cc/main/keys.txt
    one key per line, case sensitive, # starts a comment.

    Testing:
        getgenv().TeaGate.reset()    forget the stored key + key cache
        getgenv().TeaGate.destroy()  tear the whole thing down
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local KEY_URL = "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/keys.txt"
local LOADER_URL = "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/loader.lua"
local EXTRAS_URL = "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/tea-extras.lua"
local KEY_CACHE = "tea_gate_keys.txt"
local SAVED_KEY = "tea_gate_key.txt"

local ACCENT = Color3.fromRGB(255, 121, 198)   -- loading screen only
local WHITE = Color3.fromRGB(255, 255, 255)
local INK = Color3.fromRGB(10, 10, 12)
local SOFT_DOT = "rbxassetid://1316045217"
local REMEMBER = true
local RUN_LOADER = true
local RUN_EXTRAS = true

-- bar pacing: SHOW_RATE is how many seconds of work map to 94%, MIN_SHOW is the
-- floor so a warm start doesn't blink the screen.
local SHOW_RATE = 2.2
local MIN_SHOW = 1.2

local LOGO_CANDIDATES = {
    "https://cdn.discordapp.com/attachments/1548296803139588159/1563666441075433552/b6880dcf-d3ea-4db9-9cf0-d0d106621371-removebg-preview.png?ex=6ade755b&is=6add23db&hm=2fecd999d3819b303342ef84b6eaad2ba4ea083c5f64ee44438572b842c1bac2&",
    "https://raw.githubusercontent.com/panduh16/juju/main/assets/logo.png",
}

if getgenv().TeaGate and getgenv().TeaGate.destroy then
    pcall(getgenv().TeaGate.destroy)
end

-- ------------------------------------------------------------------ helpers ---
local function new(class, properties, parent)
    local instance = Instance.new(class)
    for key, value in pairs(properties) do
        instance[key] = value
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

local function read(path)
    if type(isfile) ~= "function" or not isfile(path) then
        return nil
    end
    local ok, body = pcall(readfile, path)
    if ok and type(body) == "string" then
        return body
    end
    return nil
end

local function write(path, body)
    if type(writefile) ~= "function" then
        return false
    end
    return (pcall(writefile, path, body))
end

local function remove(path)
    if type(delfile) ~= "function" or type(isfile) ~= "function" then
        return
    end
    if isfile(path) then
        pcall(delfile, path)
    end
end

local function resolve_logo()
    local path = "tea_loading_logo.png"

    for _, url in ipairs(LOGO_CANDIDATES) do
        local ok, bytes = pcall(function()
            return game:HttpGet(url)
        end)

        if ok and type(bytes) == "string" and #bytes > 1024 then
            if write(path, bytes) then
                local declared, asset = pcall(function()
                    return getcustomasset(path)
                end)
                if declared and type(asset) == "string" then
                    return asset
                end
            end
        end
    end

    return nil
end

local logo_asset = resolve_logo()

local function fade_property(element)
    if element:IsA("TextLabel") or element:IsA("TextBox") then
        return "TextTransparency"
    end
    return "ImageTransparency"
end

local function mark(parent, size)
    local frame = new("Frame", {
        Name = "LogoFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, parent)

    local content
    if logo_asset then
        content = new("ImageLabel", {
            Name = "Logo",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image = logo_asset,
            ImageColor3 = WHITE,
            ImageTransparency = 1,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 3,
        }, frame)
    else
        content = new("TextLabel", {
            Name = "LogoFallback",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBlack,
            Text = "TEA",
            TextSize = math.floor(size * 0.34),
            TextColor3 = WHITE,
            TextTransparency = 1,
            ZIndex = 3,
        }, frame)
    end

    return frame, content
end

local function gui_parent()
    return (typeof(gethui) == "function" and gethui()) or LP:WaitForChild("PlayerGui")
end

-- --------------------------------------------------------------------- keys ---
local function parse_keys(body)
    local set = {}
    for line in body:gmatch("[^" .. string.char(13) .. string.char(10) .. "]+") do
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed ~= "" and trimmed:sub(1, 1) ~= "#" then
            set[trimmed] = true
        end
    end
    return set
end

local function load_keys()
    local cached = read(KEY_CACHE)

    local ok, body = pcall(function()
        return game:HttpGet(KEY_URL .. "?t=" .. tostring(os.time()))
    end)

    if ok and type(body) == "string" and #body > 16 and not body:find("^404") then
        write(KEY_CACHE, body)
        return parse_keys(body), true
    end

    if cached then
        return parse_keys(cached), false
    end

    return {}, false
end

local keys, keys_online = load_keys()

-- loader.lua is ~1.5kb; pull it while the user is typing so accept() has nothing
-- left to fetch on the critical path
local loader_source
task.spawn(function()
    local ok, body = pcall(function()
        return game:HttpGet(LOADER_URL .. "?t=" .. tostring(os.time()))
    end)
    if ok and type(body) == "string" and #body > 200 then
        loader_source = body
    end
end)

-- ------------------------------------------------------------------- loading ---
local function run_loading(work)
    local gui = new("ScreenGui", {
        Name = "TeaLoading",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 500,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, gui_parent())

    local backdrop = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(6, 6, 8),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 1,
    }, gui)

    local stage = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(420, 320),
        BackgroundTransparency = 1,
        ZIndex = 2,
    }, backdrop)

    local halo = new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -60),
        Size = UDim2.fromOffset(720, 720),
        BackgroundTransparency = 1,
        Image = SOFT_DOT,
        ImageColor3 = ACCENT,
        ImageTransparency = 1,
        ZIndex = 2,
    }, stage)

    local logo_frame, content = mark(stage, 260)
    logo_frame.Position = UDim2.new(0.5, 0, 0.5, -60)

    local track = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 118),
        Size = UDim2.fromOffset(360, 2),
        BackgroundColor3 = WHITE,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, stage)

    local fill = new("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, track)

    new("UIGradient", { Color = ColorSequence.new(ACCENT, WHITE) }, fill)

    local status = new("TextLabel", {
        Position = UDim2.new(0.5, -180, 0.5, 132),
        Size = UDim2.fromOffset(240, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "starting",
        TextSize = 12,
        TextColor3 = Color3.fromRGB(150, 150, 160),
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, stage)

    local percent = new("TextLabel", {
        Position = UDim2.new(0.5, 60, 0.5, 132),
        Size = UDim2.fromOffset(120, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "0%",
        TextSize = 12,
        TextColor3 = Color3.fromRGB(215, 215, 222),
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 3,
    }, stage)

    local easing = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    TweenService:Create(logo_frame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(300, 300),
    }):Play()

    TweenService:Create(halo, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageTransparency = 0.86,
    }):Play()

    TweenService:Create(content, easing, { [fade_property(content)] = 0 }):Play()
    TweenService:Create(status, easing, { TextTransparency = 0.15 }):Play()
    TweenService:Create(percent, easing, { TextTransparency = 0 }):Play()
    TweenService:Create(track, easing, { BackgroundTransparency = 0.82 }):Play()

    local started = os.clock()
    local ready, failure = false, nil
    local shown = 0
    local finished = false
    local ticker

    task.spawn(function()
        local ok, err = pcall(work)
        if not ok then
            failure = tostring(err)
            warn("[tea.gate] " .. failure)
        end
        ready = true
    end)

    local function finish()
        if finished then
            return
        end
        finished = true

        if ticker then
            ticker:Disconnect()
            ticker = nil
        end

        local elapsed = os.clock() - started

        percent.Text = "100%"
        fill.Size = UDim2.fromScale(1, 1)

        if failure then
            status.Text = "loader failed"
            status.TextColor3 = Color3.fromRGB(255, 120, 120)
            task.wait(2.4)
        else
            status.Text = "ready"
            task.wait(0.12)
        end

        -- hard cut, no fade: the menu draws through the Drawing API, which sits
        -- above a ScreenGui. A fading cover would show it sliding out from under
        -- the bar. One frame, cover gone, menu already built.
        if gui then
            gui:Destroy()
            gui = nil
        end

        if not failure then
            print(string.format("[tea.gate] menu ready in %.2fs", elapsed))
        end
    end

    ticker = RunService.RenderStepped:Connect(function(dt)
        local elapsed = os.clock() - started
        local target = ready and 1 or math.min(0.94, 0.06 + (elapsed / SHOW_RATE) * 0.88)

        shown = shown + (target - shown) * math.min(1, dt * 6)
        if shown > 0.999 then
            shown = 1
        end

        fill.Size = UDim2.fromScale(shown, 1)
        percent.Text = string.format("%d%%", math.floor(shown * 100 + 0.5))

        local label
        if ready then
            label = failure and "loader failed" or "ready"
        elseif shown < 0.22 then
            label = "fetching loader"
        elseif shown < 0.48 then
            label = "fetching modules"
        elseif shown < 0.72 then
            label = "patching runtime"
        elseif shown < 0.9 then
            label = "building menu"
        else
            label = "finalising"
        end
        if status.Text ~= label then
            status.Text = label
        end

        local wave = (math.sin(os.clock() * 1.6) + 1) * 0.5
        halo.ImageTransparency = 0.78 + wave * 0.14

        if ready and shown >= 1 and elapsed >= MIN_SHOW then
            task.spawn(finish)
        end
    end)

    return {
        skip = function()
            task.spawn(finish)
        end,
        destroy = function()
            if ticker then
                ticker:Disconnect()
                ticker = nil
            end
            if gui then
                gui:Destroy()
                gui = nil
            end
        end,
    }
end

-- ---------------------------------------------------------------------- gate ---
local gate_gui = new("ScreenGui", {
    Name = "TeaGate",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 499,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, gui_parent())

local backdrop = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(6, 6, 8),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 1,
}, gate_gui)

local CARD_W = 400
local CARD_H = 350
local PAD = 24
local INNER = CARD_W - PAD * 2

local card = new("Frame", {
    Name = "Card",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.fromOffset(CARD_W, CARD_H),
    BackgroundColor3 = Color3.fromRGB(10, 10, 12),
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    ZIndex = 2,
}, backdrop)

new("UICorner", { CornerRadius = UDim.new(0, 3) }, card)

local card_stroke = new("UIStroke", {
    Color = WHITE,
    Transparency = 0.86,
    Thickness = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, card)

local header_left = new("TextLabel", {
    Position = UDim2.fromOffset(PAD, 12),
    Size = UDim2.fromOffset(INNER, 14),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "tea.cc",
    TextSize = 11,
    TextColor3 = Color3.fromRGB(215, 215, 222),
    TextTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
}, card)

local header_right = new("TextLabel", {
    Position = UDim2.fromOffset(PAD, 12),
    Size = UDim2.fromOffset(INNER, 14),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "ACCESS",
    TextSize = 10,
    TextColor3 = Color3.fromRGB(110, 110, 120),
    TextTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 3,
}, card)

local rule = new("Frame", {
    Position = UDim2.fromOffset(PAD, 34),
    Size = UDim2.fromOffset(INNER, 1),
    BackgroundColor3 = WHITE,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 3,
}, card)

local halo = new("ImageLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0, 118),
    Size = UDim2.fromOffset(340, 340),
    BackgroundTransparency = 1,
    Image = SOFT_DOT,
    ImageColor3 = WHITE,
    ImageTransparency = 1,
    ZIndex = 2,
}, card)

local logo_frame, logo_content = mark(card, 128)
logo_frame.Position = UDim2.new(0.5, 0, 0, 118)

local prompt = new("TextLabel", {
    Position = UDim2.fromOffset(PAD, 208),
    Size = UDim2.fromOffset(INNER, 12),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "A C C E S S   K E Y",
    TextSize = 10,
    TextColor3 = Color3.fromRGB(120, 120, 130),
    TextTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
}, card)

local box = new("Frame", {
    Position = UDim2.fromOffset(PAD, 226),
    Size = UDim2.fromOffset(INNER, 36),
    BackgroundColor3 = Color3.fromRGB(17, 17, 20),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 3,
}, card)

new("UICorner", { CornerRadius = UDim.new(0, 2) }, box)

local box_stroke = new("UIStroke", {
    Color = WHITE,
    Transparency = 1,
    Thickness = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, box)

local input = new("TextBox", {
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.new(1, -24, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "",
    PlaceholderText = "paste your key",
    PlaceholderColor3 = Color3.fromRGB(95, 95, 105),
    TextSize = 13,
    TextColor3 = Color3.fromRGB(240, 240, 245),
    TextTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 4,
}, box)

local submit = new("TextButton", {
    Position = UDim2.fromOffset(PAD, 274),
    Size = UDim2.fromOffset(INNER, 36),
    BackgroundColor3 = WHITE,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamSemibold,
    Text = "VERIFY",
    TextSize = 12,
    TextColor3 = INK,
    TextTransparency = 1,
    AutoButtonColor = false,
    ZIndex = 3,
}, card)

new("UICorner", { CornerRadius = UDim.new(0, 2) }, submit)

local submit_stroke = new("UIStroke", {
    Color = WHITE,
    Transparency = 1,
    Thickness = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, submit)

local feedback = new("TextLabel", {
    Position = UDim2.fromOffset(PAD, 320),
    Size = UDim2.fromOffset(INNER, 14),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = keys_online and "keys loaded" or "offline, using cache",
    TextSize = 10,
    TextColor3 = Color3.fromRGB(110, 110, 120),
    TextTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
}, card)

-- entrance
TweenService:Create(backdrop, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0,
}):Play()

local entrance = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
TweenService:Create(card, entrance, { BackgroundTransparency = 0.12 }):Play()
TweenService:Create(card_stroke, entrance, { Transparency = 0.86 }):Play()
TweenService:Create(rule, entrance, { BackgroundTransparency = 0.88 }):Play()
TweenService:Create(header_left, entrance, { TextTransparency = 0 }):Play()
TweenService:Create(header_right, entrance, { TextTransparency = 0 }):Play()
TweenService:Create(logo_content, entrance, { [fade_property(logo_content)] = 0 }):Play()
TweenService:Create(prompt, entrance, { TextTransparency = 0 }):Play()
TweenService:Create(box, entrance, { BackgroundTransparency = 0 }):Play()
TweenService:Create(box_stroke, entrance, { Transparency = 0.82 }):Play()
TweenService:Create(input, entrance, { TextTransparency = 0 }):Play()
TweenService:Create(submit, entrance, { BackgroundTransparency = 0 }):Play()
TweenService:Create(submit, entrance, { TextTransparency = 0 }):Play()
TweenService:Create(feedback, entrance, { TextTransparency = 0 }):Play()

TweenService:Create(halo, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    ImageTransparency = 0.94,
}):Play()

local pulse = RunService.RenderStepped:Connect(function()
    local wave = (math.sin(os.clock() * 1.4) + 1) * 0.5
    halo.ImageTransparency = 0.90 + wave * 0.07
end)

-- ------------------------------------------------------------------ lifecycle ---
local busy = false
local accepted = false

local function shake()
    local origin = card.Position
    for index = 1, 4 do
        local offset = (index % 2 == 0) and 5 or -5
        card.Position = origin + UDim2.fromOffset(offset, 0)
        task.wait(0.035)
    end
    card.Position = origin
end

local function accept()
    if accepted then
        return
    end
    accepted = true
    busy = true

    if pulse then
        pulse:Disconnect()
        pulse = nil
    end

    -- the loading layer goes up first and is opaque from frame one, so tearing
    -- the gate down underneath it can't flash the game through
    local loading = run_loading(function()
        local body = loader_source
        if not body then
            local ok, fetched = pcall(function()
                return game:HttpGet(LOADER_URL .. "?t=" .. tostring(os.time()))
            end)
            if not ok or type(fetched) ~= "string" or #fetched < 200 then
                error("loader fetch failed: " .. tostring(fetched), 0)
            end
            body = fetched
        end

        local chunk, compile_error = loadstring(body)
        if not chunk then
            error("loader compile failed: " .. tostring(compile_error), 0)
        end

        if RUN_LOADER then
            chunk()
        end

        -- extras ride behind the loader: a dead raw fetch must never take the
        -- menu down with it, so every step here is non-fatal.
        if RUN_EXTRAS then
            local ok_extra, extra = pcall(function()
                return game:HttpGet(EXTRAS_URL .. "?t=" .. tostring(os.time()))
            end)
            if ok_extra and type(extra) == "string" and #extra > 200 then
                local extra_chunk = loadstring(extra)
                if extra_chunk then
                    pcall(extra_chunk)
                end
            end
        end
    end)

    if gate_gui then
        gate_gui:Destroy()
        gate_gui = nil
    end

    if getgenv().TeaGate then
        getgenv().TeaGate.loading = loading
    end
end

local function verify()
    if busy or accepted then
        return
    end

    local key = input.Text:match("^%s*(.-)%s*$")
    if key == "" then
        feedback.Text = "enter a key"
        feedback.TextColor3 = Color3.fromRGB(255, 140, 140)
        shake()
        return
    end

    busy = true
    submit.Text = "CHECKING"
    feedback.Text = "checking"
    feedback.TextColor3 = Color3.fromRGB(110, 110, 120)

    if not keys[key] then
        local refreshed, online = load_keys()
        keys = refreshed
        keys_online = online
    end

    if keys[key] then
        feedback.Text = "accepted"
        feedback.TextColor3 = WHITE
        if REMEMBER then
            write(SAVED_KEY, key)
        end
        task.wait(0.12)
        accept()
        return
    end

    busy = false
    submit.Text = "VERIFY"
    feedback.Text = (#keys == 0) and "key server unreachable" or "invalid key"
    feedback.TextColor3 = Color3.fromRGB(255, 120, 120)
    shake()
end

submit.MouseButton1Click:Connect(verify)

input.Focused:Connect(function()
    TweenService:Create(box_stroke, TweenInfo.new(0.15), { Transparency = 0.35 }):Play()
end)

input.FocusLost:Connect(function(enter)
    TweenService:Create(box_stroke, TweenInfo.new(0.15), { Transparency = 0.82 }):Play()
    if enter then
        verify()
    end
end)

box.InputBegan:Connect(function(user_input)
    if user_input.UserInputType == Enum.UserInputType.MouseButton1 then
        input:CaptureFocus()
    end
end)

submit.MouseEnter:Connect(function()
    local tween = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(submit, tween, { BackgroundColor3 = INK, TextColor3 = WHITE }):Play()
    TweenService:Create(submit_stroke, tween, { Transparency = 0.35 }):Play()
end)

submit.MouseLeave:Connect(function()
    local tween = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(submit, tween, { BackgroundColor3 = WHITE, TextColor3 = INK }):Play()
    TweenService:Create(submit_stroke, tween, { Transparency = 1 }):Play()
end)

UserInputService.InputBegan:Connect(function(user_input, processed)
    if processed or accepted then
        return
    end
    if user_input.KeyCode == Enum.KeyCode.Return then
        verify()
    end
end)

-- --------------------------------------------------------------------- boot ---
if REMEMBER then
    local stored = read(SAVED_KEY)
    if stored then
        local trimmed = stored:match("^%s*(.-)%s*$")
        if trimmed and trimmed ~= "" and keys[trimmed] then
            input.Text = trimmed
            feedback.Text = "saved key - press verify"
            feedback.TextColor3 = Color3.fromRGB(150, 150, 160)
        else
            remove(SAVED_KEY)
        end
    end
end

-- --------------------------------------------------------------------- api ---
local TeaGate = { keys_online = keys_online }

function TeaGate.reset()
    remove(SAVED_KEY)
    remove(KEY_CACHE)
end

function TeaGate.destroy()
    if pulse then
        pulse:Disconnect()
        pulse = nil
    end
    if gate_gui then
        gate_gui:Destroy()
        gate_gui = nil
    end
    if TeaGate.loading and TeaGate.loading.destroy then
        pcall(TeaGate.loading.destroy)
    end
    getgenv().TeaGate = nil
end

getgenv().TeaGate = TeaGate

print("[tea.gate] loaded - " .. tostring(keys_online and "keys fetched" or "keys cached"))

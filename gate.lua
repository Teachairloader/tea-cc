--[[
    tea.cc - public entry point, no key

    One line, no paste blocks:

        loadstring(game:HttpGet("https://raw.githubusercontent.com/Teachairloader/tea-cc/main/gate.lua"))()

    Flow: loading screen -> loader.lua -> drift.lua -> menu, all in one paste.
    There is no key screen and no key list to fetch: the bar goes up on the same
    frame the file runs, loader.lua runs underneath it, and the bar covers the
    whole load instead of blinking for a frame.

    loader.lua and drift.lua stay internal; nothing else is handed out.

    Testing:
        getgenv().TeaGate.destroy()  tear the whole thing down
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

local LOADER_URL = "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/loader.lua"

local ACCENT = Color3.fromRGB(255, 121, 198)   -- loading screen only
local WHITE = Color3.fromRGB(255, 255, 255)
local SOFT_DOT = "rbxassetid://1316045217"
local RUN_LOADER = true

-- bar pacing: SHOW_RATE is how many seconds of work map to 94%, MIN_SHOW is the
-- floor so a warm start doesn't blink the screen.
local SHOW_RATE = 2.2
local MIN_SHOW = 1.2

-- The repo copy is first and permanent. A Discord attachment URL carries an
-- expiry in `ex`, so the second entry is only a stopgap for the day the repo
-- raw host is blocked.
local LOGO_CANDIDATES = {
    "https://raw.githubusercontent.com/Teachairloader/tea-cc/main/assets/logo.png",
    "https://media.discordapp.net/attachments/1537736136141701151/1563713376952262778/Logo.png.png?ex=6adff291&is=6adea111&hm=c093f47caae6c1b91576faa3a9a11d3953a22777ee029224402dd8687dc541e0&=",
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

local function write(path, body)
    if type(writefile) ~= "function" then
        return false
    end
    return (pcall(writefile, path, body))
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

-- ---------------------------------------------------------------------- boot ---
local TeaGate = {}

local function start()
    if TeaGate.loading then
        return
    end

    TeaGate.loading = run_loading(function()
        local ok, body = pcall(function()
            return game:HttpGet(LOADER_URL .. "?t=" .. tostring(os.time()))
        end)
        if not ok or type(body) ~= "string" or #body < 200 then
            error("loader fetch failed: " .. tostring(body), 0)
        end

        local chunk, compile_error = loadstring(body)
        if not chunk then
            error("loader compile failed: " .. tostring(compile_error), 0)
        end

        if RUN_LOADER then
            chunk()
        end
    end)
end

function TeaGate.destroy()
    if TeaGate.loading and TeaGate.loading.destroy then
        pcall(TeaGate.loading.destroy)
    end
    TeaGate.loading = nil
    getgenv().TeaGate = nil
end

getgenv().TeaGate = TeaGate

start()

print("[tea.gate] loaded - no key")

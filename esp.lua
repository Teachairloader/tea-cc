-- ======================================================================== esp ===
-- Overlay esp built on the projection math from the reference ESP: the box is
-- sized off the humanoid root part's screen height instead of Model:GetBoundingBox,
-- so it works on custom rigs, skinned meshes and games that break GetBoundingBox.
--
-- Text and bars are real gui instances in CoreGui; only the box is Drawing.
--
-- Runs two ways:
--   * inside drift/tea.cc, where `fget` exists: every setting comes from the
--     menu flags.
--   * pasted on its own: no menu exists, so the defaults below apply and
--     getgenv().drift_esp overrides them. Right shift toggles it.
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

    -- tea.cc's fget is a local upvalue in the host chunk; standalone it is nil.
    local standalone = type(fget) ~= "function"
    local manual = true

    local function get(name, default)
        if not standalone then
            local ok, value = pcall(fget, name, default)
            if ok and value ~= nil then
                return value
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

    -- CoreGui keeps the labels out of the game's own gui tree; PlayerGui is the
    -- fallback for executors that protect CoreGui.
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

    local guiInset = Vector2.new(0, 0)
    pcall(function()
        guiInset = game:GetService("GuiService"):GetGuiInset()
    end)

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

    -- everything this build owns, so a reload can tear the previous pass down
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

    local pool = {}
    local guiPool = {}
    getgenv()[DRAW_KEY] = pool
    getgenv()[GUI_KEY] = guiPool

    local function new(kind)
        local ok, object = pcall(function()
            return Drawing.new(kind)
        end)
        if not ok or object == nil then
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

    local function frame()
        local ok, object = pcall(function()
            local guiFrame = Instance.new("Frame")
            guiFrame.BackgroundColor3 = BLACK
            guiFrame.BorderSizePixel = 0
            guiFrame.BackgroundTransparency = 0.2
            guiFrame.Visible = false
            return guiFrame
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

            entry.healthOutline = frame()
            entry.healthFill = frame()
            entry.armorOutline = frame()
            entry.armorFill = frame()

            if entry.healthOutline then
                entry.healthOutline.Parent = gui
            end
            if entry.healthFill then
                entry.healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                entry.healthFill.BackgroundTransparency = 0
                entry.healthFill.Parent = entry.healthOutline or gui
            end
            if entry.armorOutline then
                entry.armorOutline.Parent = gui
            end
            if entry.armorFill then
                entry.armorFill.BackgroundColor3 = Color3.fromRGB(120, 180, 255)
                entry.armorFill.BackgroundTransparency = 0
                entry.armorFill.Parent = entry.armorOutline or gui
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

    -- games that ship an armor stat expose it either as a BodyEffects value
    -- (da hood style) or as an attribute; both are checked
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
        local enabled = manual and get("esp_ov_enabled", true) and camera ~= nil

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

        local maxDistance = get("esp_ov_max_distance", 500)
        local teamCheck = get("esp_ov_team", true)
        local textSize = get("esp_ov_text_size", 14)
        local widthScale = get("esp_ov_width", 0.28)
        local drawBox = get("esp_ov_box", true)
        local drawName = get("esp_ov_name", true)
        local drawDistance = get("esp_ov_distance", true)
        local drawTool = get("esp_ov_tool", false)
        local drawHealth = get("esp_ov_health", true)
        local drawArmor = get("esp_ov_armor", false)
        local drawSkeleton = get("esp_ov_skeleton", false)
        local drawHighlight = get("esp_ov_highlight", false)

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

                -- box height is derived from the root part's own screen height:
                -- one stud below and three studs above the root, halved. That
                -- gives a stable box on any rig, including custom ones where
                -- GetBoundingBox returns garbage or errors outright.
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
                    local guiY = boxY - guiInset.Y

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

                        local barWidth = 3
                        local barX = boxX - (barWidth + 4)

                        entry.healthOutline.Position = UDim2.new(0, barX - 1, 0, guiY - 1)
                        entry.healthOutline.Size = UDim2.new(0, barWidth + 2, 0, boxHeight + 2)
                        entry.healthOutline.Visible = true

                        entry.healthFill.Position = UDim2.new(0, 1, 0, (1 - ratio) * boxHeight + 1)
                        entry.healthFill.Size = UDim2.new(0, barWidth, 0, ratio * boxHeight)
                        entry.healthFill.BackgroundColor3 = health_color(ratio)
                        entry.healthFill.Visible = true
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

                        local barWidth = 3
                        local barX = boxX - (barWidth * 2 + 8)

                        entry.armorOutline.Position = UDim2.new(0, barX - 1, 0, guiY - 1)
                        entry.armorOutline.Size = UDim2.new(0, barWidth + 2, 0, boxHeight + 2)
                        entry.armorOutline.Visible = true

                        entry.armorFill.Position = UDim2.new(0, 1, 0, (1 - ratio) * boxHeight + 1)
                        entry.armorFill.Size = UDim2.new(0, barWidth, 0, ratio * boxHeight)
                        entry.armorFill.Visible = true
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

    -- PostSimulation matches the reference esp and keeps the overlay in step
    -- with the physics tick rather than the render tick
    if RunService.PostSimulation then
        RunService.PostSimulation:Connect(function()
            local ok, err = pcall(render)
            if not ok then
                warn("[drift esp] frame error: " .. tostring(err))
            end
        end)
    else
        RunService.RenderStepped:Connect(function()
            local ok, err = pcall(render)
            if not ok then
                warn("[drift esp] frame error: " .. tostring(err))
            end
        end)
    end
end

local okBuild, buildError = pcall(build_esp)
if not okBuild then
    warn("[drift esp] failed: " .. tostring(buildError))
end

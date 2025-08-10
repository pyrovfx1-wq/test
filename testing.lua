-- TOCHIPYRO Pet Size Visual Script for Grow a Garden
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Rainbow color generator
local function rainbowColor(t)
    return Color3.fromRGB(
        math.sin(t * 2) * 127 + 128,
        math.sin(t * 2 + 2) * 127 + 128,
        math.sin(t * 2 + 4) * 127 + 128
    )
end

-- Find held pet
local function getHeldPet()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Model") and not obj:FindFirstChildOfClass("Humanoid") then
            local nameLower = obj.Name:lower()
            if nameLower:find("pet") or nameLower:find("raccoon") or nameLower:find("ostrich") or nameLower:find("fox") then
                return obj
            end
        end
    end
    return nil
end

-- Scale pet naturally (visual only)
local function scaleModelWithJoints(model, scaleFactor)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Size = part.Size * scaleFactor
        elseif part:IsA("SpecialMesh") then
            part.Scale = part.Scale * scaleFactor
        elseif part:IsA("Motor6D") then
            local c0Pos, c0Rot = part.C0.Position, part.C0 - part.C0.Position
            local c1Pos, c1Rot = part.C1.Position, part.C1 - part.C1.Position
            part.C0 = CFrame.new(c0Pos * scaleFactor) * c0Rot
            part.C1 = CFrame.new(c1Pos * scaleFactor) * c1Rot
        end
    end
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Rainbow title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TOCHIPYRO"
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = MainFrame

spawn(function()
    local t = 0
    while task.wait(0.05) do
        Title.TextColor3 = rainbowColor(t)
        t += 0.05
    end
end)

-- Minimize button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
MinimizeButton.Text = "-"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextScaled = true
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinimizeButton.Parent = MainFrame

-- Size enlarge button
local SizeButton = Instance.new("TextButton")
SizeButton.Size = UDim2.new(1, -20, 0, 40)
SizeButton.Position = UDim2.new(0, 10, 0, 50)
SizeButton.Text = "Size Enlarge"
SizeButton.Font = Enum.Font.GothamBold
SizeButton.TextScaled = true
SizeButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SizeButton.Parent = MainFrame

SizeButton.MouseButton1Click:Connect(function()
    local pet = getHeldPet()
    if pet then
        scaleModelWithJoints(pet, 1.75)
    else
        warn("No held pet found.")
    end
end)

-- More button
local MoreButton = Instance.new("TextButton")
MoreButton.Size = UDim2.new(1, -20, 0, 40)
MoreButton.Position = UDim2.new(0, 10, 0, 100)
MoreButton.Text = "More"
MoreButton.Font = Enum.Font.GothamBold
MoreButton.TextScaled = true
MoreButton.BackgroundColor3 = Color3.fromRGB(255, 100, 255)
MoreButton.Parent = MainFrame

-- More frame
local MoreFrame = Instance.new("Frame")
MoreFrame.Size = UDim2.new(0, 250, 0, 150)
MoreFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MoreFrame.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
MoreFrame.BackgroundTransparency = 0.5
MoreFrame.BorderSizePixel = 0
MoreFrame.Visible = false
MoreFrame.Parent = ScreenGui

local Glow = Instance.new("UIStroke", MoreFrame)
Glow.Color = Color3.fromRGB(255, 0, 255)
Glow.Thickness = 3

local BypassButton = Instance.new("TextButton")
BypassButton.Size = UDim2.new(1, -20, 0, 40)
BypassButton.Position = UDim2.new(0, 10, 0, 10)
BypassButton.Text = "Bypass"
BypassButton.Font = Enum.Font.GothamBold
BypassButton.TextScaled = true
BypassButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
BypassButton.Parent = MoreFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(1, -20, 0, 40)
CloseButton.Position = UDim2.new(0, 10, 0, 60)
CloseButton.Text = "Close UI"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextScaled = true
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Parent = MoreFrame
CloseButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = false
end)

MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

-- Store all frames for minimize toggle
local guiElements = {MainFrame, MoreFrame}

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = true
    for _, ui in ipairs(guiElements) do
        ui.Visible = false
    end
end)

-- Toggle back with M key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.M then
        minimized = not minimized
        for _, ui in ipairs(guiElements) do
            ui.Visible = not minimized
        end
    end
end)

-- Make GUI draggable from title
local dragging, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

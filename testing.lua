-- TOCHIPYRO Script for Grow a Garden
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Rainbow Color Function
local function rainbowColor(t)
    local r = math.sin(t * 2) * 127 + 128
    local g = math.sin(t * 2 + 2) * 127 + 128
    local b = math.sin(t * 2 + 4) * 127 + 128
    return Color3.fromRGB(r, g, b)
end

-- Get Held Pet
local function getHeldPet()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Model") and not obj:FindFirstChildOfClass("Humanoid") then
            local nameLower = string.lower(obj.Name)
            if nameLower:find("pet") or nameLower:find("raccoon") or nameLower:find("ostrich") or nameLower:find("fox") then
                return obj
            end
        end
    end
    return nil
end

-- Keep same working enlargement logic from your last working script
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

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Dragging logic
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
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

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Title
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, -60, 0, 40)
TitleBar.Position = UDim2.new(0, 10, 0, 0)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "TOCHIPYRO"
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextScaled = true
TitleBar.Parent = MainFrame

-- Rainbow animation for title
spawn(function()
    local t = 0
    while TitleBar do
        TitleBar.TextColor3 = rainbowColor(t)
        t = t + 0.05
        task.wait(0.05)
    end
end)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextScaled = true
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
MinBtn.Parent = MainFrame
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child ~= TitleBar and child ~= MinBtn and child ~= CloseBtn then
            child.Visible = not minimized
        end
    end
    MainFrame.Size = minimized and UDim2.new(0, 300, 0, 40) or UDim2.new(0, 300, 0, 200)
end)

-- Size Enlarge Button
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
        print("Pet enlarged naturally:", pet.Name)
    else
        warn("No held pet found.")
    end
end)

-- TOCHIPYRO Script for Grow a Garden
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Function to create rainbow color
local function rainbowColor(t)
    local r = math.sin(t*2) * 127 + 128
    local g = math.sin(t*2 + 2) * 127 + 128
    local b = math.sin(t*2 + 4) * 127 + 128
    return Color3.fromRGB(r, g, b)
end

-- Find held pet
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

-- Scale pet naturally (preserve joints)
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

-- GUI creation
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0

-- Rainbow title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "TOCHIPYRO Script"
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true

-- Animate rainbow
spawn(function()
    local t = 0
    while true do
        Title.TextColor3 = rainbowColor(t)
        t = t + 0.05
        task.wait(0.05)
    end
end)

-- Size Enlarge Button
local SizeButton = Instance.new("TextButton", MainFrame)
SizeButton.Size = UDim2.new(1, -20, 0, 40)
SizeButton.Position = UDim2.new(0, 10, 0, 50)
SizeButton.Text = "Size Enlarge"
SizeButton.Font = Enum.Font.SourceSansBold
SizeButton.TextScaled = true
SizeButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SizeButton.MouseButton1Click:Connect(function()
    local pet = getHeldPet()
    if pet then
        scaleModelWithJoints(pet, 1.75) -- 75% bigger
        print("Pet enlarged naturally:", pet.Name)
    else
        warn("No held pet found.")
    end
end)

-- More Button
local MoreButton = Instance.new("TextButton", MainFrame)
MoreButton.Size = UDim2.new(1, -20, 0, 40)
MoreButton.Position = UDim2.new(0, 10, 0, 100)
MoreButton.Text = "More"
MoreButton.Font = Enum.Font.SourceSansBold
MoreButton.TextScaled = true
MoreButton.BackgroundColor3 = Color3.fromRGB(255, 100, 255)

-- Secondary UI
local MoreFrame = Instance.new("Frame", ScreenGui)
MoreFrame.Size = UDim2.new(0, 250, 0, 150)
MoreFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MoreFrame.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
MoreFrame.BackgroundTransparency = 0.5
MoreFrame.Visible = false
MoreFrame.BorderSizePixel = 0

-- Glow effect
local Glow = Instance.new("UIStroke", MoreFrame)
Glow.Color = Color3.fromRGB(255, 0, 255)
Glow.Thickness = 3

-- Bypass button
local BypassButton = Instance.new("TextButton", MoreFrame)
BypassButton.Size = UDim2.new(1, -20, 0, 40)
BypassButton.Position = UDim2.new(0, 10, 0, 10)
BypassButton.Text = "Bypass"
BypassButton.Font = Enum.Font.SourceSansBold
BypassButton.TextScaled = true
BypassButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

-- Close UI button
local CloseButton = Instance.new("TextButton", MoreFrame)
CloseButton.Size = UDim2.new(1, -20, 0, 40)
CloseButton.Position = UDim2.new(0, 10, 0, 60)
CloseButton.Text = "Close UI"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextScaled = true
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = false
end)

-- More button opens secondary UI
MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = true
end)

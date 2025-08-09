-- TOCHIPYRO Script (Grow a Garden - Held Pet Auto Detect)
-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TOCHIPYRO"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.BackgroundTransparency = 1

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundTransparency = 0.5
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0

-- Rainbow Title
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.Text = "TOCHIPYRO Script"
Title.TextColor3 = Color3.new(1, 0, 0)

-- Rainbow effect loop
task.spawn(function()
    local t = 0
    while task.wait(0.05) do
        Title.TextColor3 = Color3.fromHSV(t % 1, 1, 1)
        t += 0.01
    end
end)

-- Size Enlarge button
local SizeButton = Instance.new("TextButton")
SizeButton.Parent = Frame
SizeButton.Size = UDim2.new(1, -20, 0, 40)
SizeButton.Position = UDim2.new(0, 10, 0, 50)
SizeButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SizeButton.Text = "Size Enlarge"
SizeButton.TextScaled = true
SizeButton.Font = Enum.Font.SourceSansBold
SizeButton.TextColor3 = Color3.new(1, 1, 1)
SizeButton.BackgroundTransparency = 0.2

-- "More" button
local MoreButton = Instance.new("TextButton")
MoreButton.Parent = Frame
MoreButton.Size = UDim2.new(1, -20, 0, 40)
MoreButton.Position = UDim2.new(0, 10, 0, 100)
MoreButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
MoreButton.Text = "More"
MoreButton.TextScaled = true
MoreButton.Font = Enum.Font.SourceSansBold
MoreButton.TextColor3 = Color3.new(1, 1, 1)
MoreButton.BackgroundTransparency = 0.2

-- More UI
local MoreFrame = Instance.new("Frame")
MoreFrame.Parent = ScreenGui
MoreFrame.Size = UDim2.new(0, 200, 0, 150)
MoreFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MoreFrame.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
MoreFrame.BackgroundTransparency = 0.5
MoreFrame.Visible = false
MoreFrame.BorderSizePixel = 0

local Glow = Instance.new("UIStroke")
Glow.Parent = MoreFrame
Glow.Thickness = 3
Glow.Color = Color3.fromRGB(200, 100, 255)

-- Bypass button
local BypassButton = Instance.new("TextButton")
BypassButton.Parent = MoreFrame
BypassButton.Size = UDim2.new(1, -20, 0, 40)
BypassButton.Position = UDim2.new(0, 10, 0, 10)
BypassButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BypassButton.Text = "Bypass"
BypassButton.TextScaled = true
BypassButton.Font = Enum.Font.SourceSansBold
BypassButton.TextColor3 = Color3.new(1, 1, 1)

-- Close UI button
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = MoreFrame
CloseButton.Size = UDim2.new(1, -20, 0, 40)
CloseButton.Position = UDim2.new(0, 10, 0, 60)
CloseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CloseButton.Text = "Close UI"
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextColor3 = Color3.new(1, 1, 1)

-- More button toggle
MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

-- Close button
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Scale settings
local SCALE = 1.75

-- Function to find held pet by weld
local function getHeldPet()
    local char = game.Players.LocalPlayer.Character
    if not char then return nil end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Weld") or obj:IsA("Motor6D") then
            if obj.Part1 and obj.Part1.Parent and obj.Part1.Parent:IsA("Model") then
                local model = obj.Part1.Parent
                -- Skip player tools
                if not model:FindFirstChildOfClass("Humanoid") and model ~= char then
                    return model
                end
            end
        end
    end
    return nil
end

-- Size enlarge logic
SizeButton.MouseButton1Click:Connect(function()
    local pet = getHeldPet()
    if pet then
        for _, part in ipairs(pet:GetDescendants()) do
            if part:IsA("MeshPart") then
                part.Size = part.Size * SCALE
            elseif part:IsA("SpecialMesh") then
                part.Scale = part.Scale * SCALE
            end
        end
        print("Enlarged held pet:", pet.Name)
    else
        warn("No held pet found.")
    end
end)

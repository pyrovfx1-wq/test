-- Natural Pet Enlarger for Grow a Garden
-- TOCHIPYRO UI (50% transparency + proportional scaling)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TOCHIPYRO"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundTransparency = 0.5
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BorderSizePixel = 0

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.Text = "TOCHIPYRO Script"
Title.TextColor3 = Color3.new(1, 0, 0)

-- Rainbow Title
task.spawn(function()
    local t = 0
    while task.wait(0.05) do
        Title.TextColor3 = Color3.fromHSV(t % 1, 1, 1)
        t += 0.01
    end
end)

-- Buttons
local function createButton(name, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Parent = Frame
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.5
    btn.Text = name
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansBold
    btn.TextColor3 = Color3.new(1, 1, 1)
    return btn
end

local SizeButton = createButton("Size Enlarge", 50, Color3.fromRGB(50, 150, 50))
local MoreButton = createButton("More", 100, Color3.fromRGB(100, 50, 150))

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

local BypassButton = createButton("Bypass", 10, Color3.fromRGB(200, 50, 50))
BypassButton.Parent = MoreFrame

local CloseButton = createButton("Close UI", 60, Color3.fromRGB(50, 50, 50))
CloseButton.Parent = MoreFrame

-- Toggle More UI
MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

-- Close Button
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- PROPORTIONAL MODEL SCALING
local function scaleModelProportionally(model, scaleFactor)
    if not model.PrimaryPart then
        model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart")
        if not model.PrimaryPart then return end
    end

    local origin = model.PrimaryPart.Position

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Scale size
            part.Size = part.Size * scaleFactor
            -- Adjust position relative to PrimaryPart
            local offset = part.Position - origin
            part.Position = origin + offset * scaleFactor
        elseif part:IsA("SpecialMesh") then
            part.Scale = part.Scale * scaleFactor
        end
    end
end

-- Find held pet model
local function getHeldPet()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, weld in ipairs(char:GetDescendants()) do
        if weld:IsA("Weld") or weld:IsA("Motor6D") then
            if weld.Part1 and weld.Part1.Parent and weld.Part1.Parent:IsA("Model") then
                local model = weld.Part1.Parent
                -- Avoid avatar and tools
                if not model:FindFirstChildOfClass("Humanoid") and model.Parent ~= char and model.Parent ~= LocalPlayer.Backpack then
                    return model
                end
            end
        end
    end
    return nil
end

-- Enlarge button click
SizeButton.MouseButton1Click:Connect(function()
    local pet = getHeldPet()
    if pet then
        scaleModelProportionally(pet, 1.75)
        print("Pet enlarged naturally:", pet.Name)
    else
        warn("No held pet found.")
    end
end)

-- // TOCHIPYRO Script for Grow a Garden
if game.PlaceId ~= 8849628681 then -- Latest Grow a Garden place ID
    warn("This script only works in Grow a Garden.")
    return
end

-- Create main UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TOCHIPYRO_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Parent = ScreenGui

-- Rainbow title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "TOCHIPYRO Script"
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Rainbow effect
task.spawn(function()
    while Title do
        for hue = 0, 1, 0.01 do
            Title.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.05)
        end
    end
end)

-- Size Enlarge button
local SizeButton = Instance.new("TextButton")
SizeButton.Size = UDim2.new(1, -20, 0, 40)
SizeButton.Position = UDim2.new(0, 10, 0, 60)
SizeButton.Text = "Size Enlarge"
SizeButton.TextScaled = true
SizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SizeButton.Parent = MainFrame

-- Nearest pet enlarger
SizeButton.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local foundPet = false
    local nearestPet

    -- Search for nearest pet model
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= char and obj:FindFirstChildOfClass("Humanoid") == nil then
            if obj:FindFirstChildWhichIsA("MeshPart") or obj:FindFirstChildWhichIsA("SpecialMesh") then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part and (part.Position - hrp.Position).Magnitude < 10 then
                    nearestPet = obj
                    break
                end
            end
        end
    end

    if nearestPet then
        for _, part in ipairs(nearestPet:GetDescendants()) do
            if part:IsA("MeshPart") then
                part.Size = part.Size * 1.75
                foundPet = true
            elseif part:IsA("SpecialMesh") then
                part.Scale = part.Scale * 1.75
                foundPet = true
            elseif part:IsA("BasePart") and part.CustomPhysicalProperties then
                local props = part.CustomPhysicalProperties
                part.CustomPhysicalProperties = PhysicalProperties.new(
                    props.Density / 1.75,
                    props.Friction,
                    props.Elasticity,
                    props.FrictionWeight,
                    props.ElasticityWeight
                )
            end
        end
    else
        warn("No pet found near player.")
    end

    if foundPet then
        print("Pet enlarged visually + weight adjusted.")
    else
        warn("No pet mesh found in nearby model.")
    end
end)

-- "More" button
local MoreButton = Instance.new("TextButton")
MoreButton.Size = UDim2.new(1, -20, 0, 40)
MoreButton.Position = UDim2.new(0, 10, 0, 110)
MoreButton.Text = "More"
MoreButton.TextScaled = true
MoreButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MoreButton.Parent = MainFrame

-- More UI
local MoreFrame = Instance.new("Frame")
MoreFrame.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
MoreFrame.BackgroundTransparency = 0.5
MoreFrame.Size = UDim2.new(0, 300, 0, 150)
MoreFrame.Position = UDim2.new(0.4, 0, 0.6, 0)
MoreFrame.Visible = false
MoreFrame.Parent = ScreenGui

MoreFrame.ClipsDescendants = true
MoreFrame.BorderSizePixel = 0
MoreFrame.ZIndex = 2

-- Bypass button
local BypassButton = Instance.new("TextButton")
BypassButton.Size = UDim2.new(1, -20, 0, 40)
BypassButton.Position = UDim2.new(0, 10, 0, 10)
BypassButton.Text = "Bypass"
BypassButton.TextScaled = true
BypassButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
BypassButton.Parent = MoreFrame

-- Close UI button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(1, -20, 0, 40)
CloseButton.Position = UDim2.new(0, 10, 0, 60)
CloseButton.Text = "Close UI"
CloseButton.TextScaled = true
CloseButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
CloseButton.Parent = MoreFrame

-- Button functions
MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

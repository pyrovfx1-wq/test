-- TOCHIPYRO Script for Grow a Garden
if game.PlaceId ~= 126884695634066 then
    warn("This script only works in Grow a Garden.")
    return
end

-- Rainbow text function
local function rainbowText(textLabel)
    spawn(function()
        while true do
            for hue = 0, 1, 0.01 do
                textLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
                task.wait(0.03)
            end
        end
    end)
end

-- Main UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TOCHIPYRO_Script"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Text = "TOCHIPYRO Script"
rainbowText(Title)

-- Size Enlarge Button
local SizeButton = Instance.new("TextButton", MainFrame)
SizeButton.Size = UDim2.new(0.9, 0, 0, 40)
SizeButton.Position = UDim2.new(0.05, 0, 0.35, 0)
SizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeButton.Font = Enum.Font.GothamBold
SizeButton.TextScaled = true
SizeButton.Text = "Size Enlarge"

SizeButton.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end

    local foundPet = false
    local tool = char:FindFirstChildOfClass("Tool") -- Pet in hand

    if tool then
        for _, part in ipairs(tool:GetDescendants()) do
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
        warn("No tool (pet) found in hand.")
    end

    if foundPet then
        print("Pet enlarged visually + weight adjusted.")
    else
        warn("No pet mesh found in tool.")
    end
end)

-- More Button
local MoreButton = Instance.new("TextButton", MainFrame)
MoreButton.Size = UDim2.new(0.9, 0, 0, 40)
MoreButton.Position = UDim2.new(0.05, 0, 0.6, 0)
MoreButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MoreButton.Font = Enum.Font.GothamBold
MoreButton.TextScaled = true
MoreButton.Text = "More"

-- More UI
local MoreFrame = Instance.new("Frame", ScreenGui)
MoreFrame.Size = UDim2.new(0, 250, 0, 150)
MoreFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
MoreFrame.BackgroundTransparency = 0.5
MoreFrame.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
MoreFrame.Visible = false

-- Rounded corners for More UI
local UICorner = Instance.new("UICorner", MoreFrame)
UICorner.CornerRadius = UDim.new(0, 15)

-- Bypass Button
local BypassButton = Instance.new("TextButton", MoreFrame)
BypassButton.Size = UDim2.new(0.9, 0, 0, 40)
BypassButton.Position = UDim2.new(0.05, 0, 0.2, 0)
BypassButton.BackgroundColor3 = Color3.fromRGB(90, 0, 90)
BypassButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BypassButton.Font = Enum.Font.GothamBold
BypassButton.TextScaled = true
BypassButton.Text = "Bypass"

BypassButton.MouseButton1Click:Connect(function()
    print("Bypass Activated") -- Add your bypass code here
end)

-- Close UI Button
local CloseButton = Instance.new("TextButton", MoreFrame)
CloseButton.Size = UDim2.new(0.9, 0, 0, 40)
CloseButton.Position = UDim2.new(0.05, 0, 0.6, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextScaled = true
CloseButton.Text = "Close UI"

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Toggle More UI
MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

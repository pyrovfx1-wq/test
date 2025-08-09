-- TOCHIPYRO Script (No PlaceId check) for testing

-- Rainbow text function
local function rainbowText(textLabel)
    spawn(function()
        while textLabel.Parent do
            for hue = 0, 1, 0.02 do
                textLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
                task.wait(0.02)
            end
        end
    end)
end

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TOCHIPYRO_Script"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

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

-- Scale factor
local SCALE = 1.75

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

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local nearestPet
    local shortestDist = math.huge

    -- Search for pets in all workspace descendants
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not obj:FindFirstChildOfClass("Humanoid") then
            if string.find(string.lower(obj.Name), "raccoon") or string.find(string.lower(obj.Name), "ostrich") or string.find(string.lower(obj.Name), "fox") or string.find(string.lower(obj.Name), "pet") then
                local basePart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if basePart then
                    local dist = (basePart.Position - hrp.Position).Magnitude
                    if dist < shortestDist and dist <= 15 then
                        shortestDist = dist
                        nearestPet = obj
                    end
                end
            end
        end
    end

    if nearestPet then
        for _, part in ipairs(nearestPet:GetDescendants()) do
            if part:IsA("MeshPart") then
                part.Size = part.Size * SCALE
            elseif part:IsA("SpecialMesh") then
                part.Scale = part.Scale * SCALE
            end
        end
        print("Enlarged pet:", nearestPet.Name)
    else
        warn("No pet found near you.")
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
    print("Bypass Activated")
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

MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

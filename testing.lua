-- TOCHIPYRO Script for Grow a Garden with persistent pet enlargement

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local workspace = game:GetService("Workspace")

local ENLARGE_SCALE = 1.75
local enlargedPetNames = {}

-- Rainbow title color function
local function rainbowColor(t)
    local hue = (tick() * 0.5 + t) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Scale model function preserving joints & proportions
local function scaleModelWithJoints(model, scaleFactor)
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Size = obj.Size * scaleFactor
        elseif obj:IsA("SpecialMesh") then
            obj.Scale = obj.Scale * scaleFactor
        elseif obj:IsA("Motor6D") then
            obj.C0 = CFrame.new(obj.C0.Position * scaleFactor) * (obj.C0 - obj.C0.Position)
            obj.C1 = CFrame.new(obj.C1.Position * scaleFactor) * (obj.C1 - obj.C1.Position)
        end
    end
end

-- Mark pet name as enlarged for persistent tracking
local function markPetAsEnlarged(pet)
    if pet and pet.Name then
        enlargedPetNames[pet.Name] = true
    end
end

-- Try to find your held pet model in character
local function getHeldPet()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") then
            if not obj:FindFirstChildOfClass("Humanoid") then
                -- You can add additional filters here if you want
                return obj
            end
        end
    end
    return nil
end

-- Enlarge current held pet and mark it
local function enlargeCurrentHeldPet()
    local pet = getHeldPet()
    if pet then
        scaleModelWithJoints(pet, ENLARGE_SCALE)
        markPetAsEnlarged(pet)
        print("[TOCHIPYRO] Enlarged pet:", pet.Name)
    else
        warn("[TOCHIPYRO] No pet found to enlarge.")
    end
end

-- Listen for pets spawning in workspace and enlarge if tracked
workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and enlargedPetNames[child.Name] then
        -- Wait briefly for model to load parts
        task.wait(0.1)
        scaleModelWithJoints(child, ENLARGE_SCALE)
        print("[TOCHIPYRO] Re-applied enlargement to pet:", child.Name)
    end
end)

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TOCHIPYRO_Script"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 270, 0, 200)
MainFrame.Position = UDim2.new(0.5, -135, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "TOCHIPYRO Script"
Title.TextSize = 24
Title.Parent = MainFrame

-- Rainbow title color loop
task.spawn(function()
    while Title and Title.Parent do
        Title.TextColor3 = rainbowColor(0)
        task.wait(0.1)
    end
end)

local SizeButton = Instance.new("TextButton")
SizeButton.Size = UDim2.new(1, -20, 0, 40)
SizeButton.Position = UDim2.new(0, 10, 0, 50)
SizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SizeButton.TextColor3 = Color3.new(1, 1, 1)
SizeButton.Text = "Size Enlarge"
SizeButton.Font = Enum.Font.GothamBold
SizeButton.TextScaled = true
SizeButton.Parent = MainFrame

local MoreButton = Instance.new("TextButton")
MoreButton.Size = UDim2.new(1, -20, 0, 40)
MoreButton.Position = UDim2.new(0, 10, 0, 100)
MoreButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MoreButton.TextColor3 = Color3.new(1, 1, 1)
MoreButton.Text = "More"
MoreButton.Font = Enum.Font.GothamBold
MoreButton.TextScaled = true
MoreButton.Parent = MainFrame

local MoreFrame = Instance.new("Frame")
MoreFrame.Size = UDim2.new(0, 200, 0, 150)
MoreFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MoreFrame.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
MoreFrame.BackgroundTransparency = 0.5
MoreFrame.Visible = false
MoreFrame.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(200, 0, 200)
UIStroke.Parent = MoreFrame

local BypassButton = Instance.new("TextButton")
BypassButton.Size = UDim2.new(1, -20, 0, 40)
BypassButton.Position = UDim2.new(0, 10, 0, 10)
BypassButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BypassButton.TextColor3 = Color3.new(1, 1, 1)
BypassButton.Text = "Bypass"
BypassButton.Font = Enum.Font.GothamBold
BypassButton.TextScaled = true
BypassButton.Parent = MoreFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(1, -20, 0, 40)
CloseButton.Position = UDim2.new(0, 10, 0, 60)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Text = "Close UI"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextScaled = true
CloseButton.Parent = MoreFrame

-- Button connections
SizeButton.MouseButton1Click:Connect(enlargeCurrentHeldPet)

MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

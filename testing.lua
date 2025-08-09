--[[
   TOCHIPYRO Script for Grow a Garden
   Features:
   - Rainbow Title
   - Size Enlarge (Pets only, proportional & joint-preserving)
   - Persistent enlarged size on placed pets in garden
   - More Menu (Bypass + Close)
   - Works with all pet types in Grow a Garden
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Rainbow color function
local function rainbowColor(t)
    local hue = (tick() * 0.5 + t) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Universal pet detection
local function getHeldPet()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") then
            if not obj:FindFirstChildOfClass("Humanoid") and not obj:IsDescendantOf(LocalPlayer.Character:FindFirstChildWhichIsA("Tool") or Instance.new("Folder")) then
                local partCount = 0
                for _, p in ipairs(obj:GetDescendants()) do
                    if p:IsA("BasePart") then
                        partCount += 1
                    end
                end
                if partCount >= 3 then
                    return obj
                end
            end
        end
    end
    return nil
end

-- Natural pet scaling
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

-- Enlarged scale factor constant
local ENLARGE_SCALE = 1.75

-- Persist enlargement on pets spawned in workspace
workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child:GetAttribute("IsEnlarged") then
        -- Delay to allow parts to load fully
        task.defer(function()
            scaleModelWithJoints(child, child:GetAttribute("EnlargeScale") or ENLARGE_SCALE)
            print("[TOCHIPYRO] Persistent enlarge applied to pet:", child.Name)
        end)
    end
end)

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 200)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Rainbow Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.Text = "TOCHIPYRO Script"
Title.TextSize = 24
Title.Parent = MainFrame

-- Size Enlarge Button
local SizeButton = Instance.new("TextButton")
SizeButton.Size = UDim2.new(1, -20, 0, 40)
SizeButton.Position = UDim2.new(0, 10, 0, 50)
SizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SizeButton.TextColor3 = Color3.new(1, 1, 1)
SizeButton.Text = "Size Enlarge"
SizeButton.Parent = MainFrame

-- More Button
local MoreButton = Instance.new("TextButton")
MoreButton.Size = UDim2.new(1, -20, 0, 40)
MoreButton.Position = UDim2.new(0, 10, 0, 100)
MoreButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MoreButton.TextColor3 = Color3.new(1, 1, 1)
MoreButton.Text = "More"
MoreButton.Parent = MainFrame

-- More Menu
local MoreFrame = Instance.new("Frame")
MoreFrame.Size = UDim2.new(0, 200, 0, 150)
MoreFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MoreFrame.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
MoreFrame.BackgroundTransparency = 0.5
MoreFrame.Visible = false
MoreFrame.Parent = ScreenGui

-- Glow effect (UIStroke)
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(200, 0, 200)
UIStroke.Parent = MoreFrame

-- Bypass Button
local BypassButton = Instance.new("TextButton")
BypassButton.Size = UDim2.new(1, -20, 0, 40)
BypassButton.Position = UDim2.new(0, 10, 0, 10)
BypassButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BypassButton.TextColor3 = Color3.new(1, 1, 1)
BypassButton.Text = "Bypass"
BypassButton.Parent = MoreFrame

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(1, -20, 0, 40)
CloseButton.Position = UDim2.new(0, 10, 0, 60)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Text = "Close UI"
CloseButton.Parent = MoreFrame

-- Button Logic
SizeButton.MouseButton1Click:Connect(function()
    local pet = getHeldPet()
    if pet then
        scaleModelWithJoints(pet, ENLARGE_SCALE)
        pet:SetAttribute("IsEnlarged", true)
        pet:SetAttribute("EnlargeScale", ENLARGE_SCALE)
        print("[TOCHIPYRO] Pet enlarged:", pet.Name)
    else
        warn("[TOCHIPYRO] No held pet found.")
    end
end)

MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Rainbow title update loop
task.spawn(function()
    while task.wait(0.1) do
        Title.TextColor3 = rainbowColor(0)
    end
end)

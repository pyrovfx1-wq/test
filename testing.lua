--[[  
   TOCHIPYRO Script for Grow a Garden  
   Features:
   - Rainbow Title
   - Visual Size Enlarge toggle (client-only clone, original pet hidden locally)
   - Works for all pets
   - More menu with Bypass and Close UI
   - 50% transparent GUI
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

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

-- Visual clone management
local activeClone = nil
local cloneUpdateConnection = nil

local function createVisualClone(model, scaleFactor)
    -- Clean up old clone
    if activeClone then
        if cloneUpdateConnection then
            cloneUpdateConnection:Disconnect()
            cloneUpdateConnection = nil
        end
        activeClone:Destroy()
        activeClone = nil
    end

    local clone = model:Clone()
    clone.Name = model.Name .. "_VisualClone"
    clone.Parent = workspace

    -- Scale parts and meshes
    for _, obj in ipairs(clone:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Size = obj.Size * scaleFactor
            obj.Transparency = 0
            obj.CanCollide = false
            obj.Anchored = true
        elseif obj:IsA("SpecialMesh") then
            obj.Scale = obj.Scale * scaleFactor
        elseif obj:IsA("Motor6D") then
            obj.C0 = CFrame.new(obj.C0.Position * scaleFactor) * (obj.C0 - obj.C0.Position)
            obj.C1 = CFrame.new(obj.C1.Position * scaleFactor) * (obj.C1 - obj.C1.Position)
        end
    end

    -- Hide original pet parts locally
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 1
        end
    end

    -- Position clone on original pet continuously
    local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
    local originalPrimaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")

    if primaryPart and originalPrimaryPart then
        clone:SetPrimaryPartCFrame(originalPrimaryPart.CFrame)

        cloneUpdateConnection = RunService.RenderStepped:Connect(function()
            if clone and clone.PrimaryPart and originalPrimaryPart then
                clone:SetPrimaryPartCFrame(originalPrimaryPart.CFrame)
            end
        end)
    end

    activeClone = clone
end

local function removeVisualClone(model)
    if activeClone then
        activeClone:Destroy()
        activeClone = nil
    end

    if cloneUpdateConnection then
        cloneUpdateConnection:Disconnect()
        cloneUpdateConnection = nil
    end

    -- Restore original pet parts transparency
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 0
        end
    end
end

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
SizeButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SizeButton.TextColor3 = Color3.new(1, 1, 1)
SizeButton.Text = "Size Enlarge"
SizeButton.Parent = MainFrame

-- More Button
local MoreButton = Instance.new("TextButton")
MoreButton.Size = UDim2.new(1, -20, 0, 40)
MoreButton.Position = UDim2.new(0, 10, 0, 100)
MoreButton.BackgroundColor3 = Color3.fromRGB(255, 100, 255)
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
BypassButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
BypassButton.TextColor3 = Color3.new(1, 1, 1)
BypassButton.Text = "Bypass"
BypassButton.Parent = MoreFrame

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(1, -20, 0, 40)
CloseButton.Position = UDim2.new(0, 10, 0, 60)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Text = "Close UI"
CloseButton.Parent = MoreFrame

-- Visual enlarge toggle state
local visualScaleFactor = 1.75
local isVisualEnlarged = false

-- Button Logic
SizeButton.MouseButton1Click:Connect(function()
    local pet = getHeldPet()
    if not pet then
        warn("No held pet found.")
        return
    end

    if not isVisualEnlarged then
        createVisualClone(pet, visualScaleFactor)
        isVisualEnlarged = true
        SizeButton.Text = "Restore Size"
    else
        removeVisualClone(pet)
        isVisualEnlarged = false
        SizeButton.Text = "Size Enlarge"
    end
end)

MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    if isVisualEnlarged then
        local pet = getHeldPet()
        if pet then
            removeVisualClone(pet)
        end
    end
    ScreenGui:Destroy()
end)

-- Rainbow title update loop
task.spawn(function()
    while task.wait(0.1) do
        Title.TextColor3 = rainbowColor(0)
    end
end)

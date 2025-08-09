-- TOCHIPYRO Script (Grow a Garden) - Simple Working Version

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local workspace = game:GetService("Workspace")

local ENLARGE_SCALE = 1.75

-- Rainbow color helper
local function rainbowColor(t)
    local hue = (tick() * 0.5 + t) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Simple scaling function with weight effects
local function scaleModel(model, scaleFactor)
    if not model or not model.Parent then return end
    
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Size = obj.Size * scaleFactor
            
            -- Add weight effect - increase mass
            obj.CustomPhysicalProperties = PhysicalProperties.new(
                0.7 * scaleFactor, -- Density (heavier)
                0.5, -- Friction  
                0, -- Elasticity
                1, -- ElasticityWeight
                1  -- FrictionWeight
            )
            
        elseif obj:IsA("SpecialMesh") then
            obj.Scale = obj.Scale * scaleFactor
            
        elseif obj:IsA("Motor6D") then
            obj.C0 = CFrame.new(obj.C0.Position * scaleFactor) * (obj.C0 - obj.C0.Position)
            obj.C1 = CFrame.new(obj.C1.Position * scaleFactor) * (obj.C1 - obj.C1.Position)
            
        elseif obj:IsA("Humanoid") then
            -- Make pet move slower (heavier feel)
            obj.WalkSpeed = obj.WalkSpeed * 0.6 -- 40% slower
            obj.JumpPower = obj.JumpPower * 0.7 -- 30% less jump
        end
    end
    
    -- Add heavy step sound effect
    task.spawn(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxasset://sounds/impact_wood.ogg"
        sound.Volume = 0.3
        sound.Pitch = 0.8
        sound.Parent = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        
        if sound.Parent then
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 2)
        end
    end)
    
    print("[TOCHIPYRO] Enlarged pet with weight effects:", model.Name)
end

-- Find pet in character
local function getHeldPet()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") and not obj:FindFirstChildOfClass("Humanoid") then
            return obj
        end
    end
    
    return nil
end

-- Main enlarge function
local function enlargeCurrentPet()
    local pet = getHeldPet()
    if pet then
        scaleModel(pet, ENLARGE_SCALE)
    else
        print("[TOCHIPYRO] No pet found to enlarge. Make sure you have a pet equipped.")
    end
end

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TOCHIPYRO_Script"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 190)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -95)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "TOCHIPYRO Script"
Title.TextSize = 28
Title.Parent = MainFrame

-- Rainbow title animation
task.spawn(function()
    while Title and Title.Parent do
        Title.TextColor3 = rainbowColor(0)
        task.wait(0.1)
    end
end)

local SizeButton = Instance.new("TextButton")
SizeButton.Size = UDim2.new(1, -20, 0, 40)
SizeButton.Position = UDim2.new(0, 10, 0, 55)
SizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SizeButton.TextColor3 = Color3.new(1, 1, 1)
SizeButton.Text = "Size Enlarge + Weight"
SizeButton.Font = Enum.Font.GothamBold
SizeButton.TextScaled = true
SizeButton.Parent = MainFrame

local MoreButton = Instance.new("TextButton")
MoreButton.Size = UDim2.new(1, -20, 0, 40)
MoreButton.Position = UDim2.new(0, 10, 0, 105)
MoreButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MoreButton.TextColor3 = Color3.new(1, 1, 1)
MoreButton.Text = "More"
MoreButton.Font = Enum.Font.GothamBold
MoreButton.TextScaled = true
MoreButton.Parent = MainFrame

local MoreFrame = Instance.new("Frame")
MoreFrame.Size = UDim2.new(0, 210, 0, 150)
MoreFrame.Position = UDim2.new(0.5, -105, 0.5, -75)
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
CloseButton.Position = UDim2.new(0, 10, 0, 65)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Text = "Close UI"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextScaled = true
CloseButton.Parent = MoreFrame

-- Button Events
SizeButton.MouseButton1Click:Connect(enlargeCurrentPet)

MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

BypassButton.MouseButton1Click:Connect(function()
    print("[TOCHIPYRO] Bypass pressed (placeholder).")
end)

print("[TOCHIPYRO] Simple pet enlarger loaded successfully!")

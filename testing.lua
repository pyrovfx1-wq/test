-- TOCHIPYRO Script (Grow a Garden) with simple realistic weight effects

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local ENLARGE_SCALE = 1.75
local WEIGHT_MULTIPLIER = 2.0 -- Simple weight increase

-- Containers to monitor for pet spawns
local petContainers = {
    workspace,
    workspace:FindFirstChild("Pets"),
    workspace:FindFirstChild("PetSlots"),
    workspace:FindFirstChild("GardenSlots"),
}

local enlargedPetIds = {}
local petUpdateLoops = {}

-- Rainbow color helper
local function rainbowColor(t)
    local hue = (tick() * 0.5 + t) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Simplified scaling function with basic weight physics
local function scaleModelWithJoints(model, scaleFactor)
    if not model or not model.Parent then return end
    
    -- Scale all parts and add simple weight effects
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- Scale the part
            obj.Size = obj.Size * scaleFactor
            
            -- Simple weight increase
            if obj.AssemblyMass then
                obj.AssemblyMass = obj.AssemblyMass * WEIGHT_MULTIPLIER
            end
            
            -- Force network ownership for better replication
            pcall(function()
                if obj.CanSetNetworkOwnership then
                    obj:SetNetworkOwner(LocalPlayer)
                end
            end)
            
        elseif obj:IsA("SpecialMesh") then
            obj.Scale = obj.Scale * scaleFactor
            
        elseif obj:IsA("Motor6D") then
            -- Scale joint positions
            local c0Pos = obj.C0.Position * scaleFactor
            local c1Pos = obj.C1.Position * scaleFactor
            obj.C0 = CFrame.new(c0Pos) * (obj.C0 - obj.C0.Position)
            obj.C1 = CFrame.new(c1Pos) * (obj.C1 - obj.C1.Position)
            
        elseif obj:IsA("Weld") then
            -- Scale weld positions
            local c0Pos = obj.C0.Position * scaleFactor
            local c1Pos = obj.C1.Position * scaleFactor
            obj.C0 = CFrame.new(c0Pos) * (obj.C0 - obj.C0.Position)
            obj.C1 = CFrame.new(c1Pos) * (obj.C1 - obj.C1.Position)
            
        elseif obj:IsA("Humanoid") then
            -- Slow down movement for heavier feel
            local originalWalkSpeed = obj:GetAttribute("OriginalWalkSpeed") or obj.WalkSpeed
            local originalJumpPower = obj:GetAttribute("OriginalJumpPower") or obj.JumpPower
            
            obj:SetAttribute("OriginalWalkSpeed", originalWalkSpeed)
            obj:SetAttribute("OriginalJumpPower", originalJumpPower)
            
            obj.WalkSpeed = originalWalkSpeed / scaleFactor
            obj.JumpPower = originalJumpPower / WEIGHT_MULTIPLIER
        end
    end
    
    -- Add simple heavy step sound effect
    task.spawn(function()
        local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        if not primaryPart then return end
        
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxasset://sounds/impact_wood.ogg"
        sound.Volume = 0.5
        sound.Pitch = 0.8 / scaleFactor -- Lower pitch for bigger size
        sound.Parent = primaryPart
        sound:Play()
        
        -- Clean up sound after playing
        game:GetService("Debris"):AddItem(sound, 3)
    end)
    
    -- Mark the model as enlarged
    model:SetAttribute("TOCHIPYRO_Enlarged", true)
    model:SetAttribute("TOCHIPYRO_Scale", scaleFactor)
    
    print("[TOCHIPYRO] Applied enlargement with weight effects!")
end

-- Get unique pet ID
local function getPetUniqueId(petModel)
    if not petModel then return nil end
    
    local id = petModel:GetAttribute("PetID") or 
               petModel:GetAttribute("UniqueID") or
               petModel:GetAttribute("OwnerUserId") or
               petModel:GetAttribute("PetGUID")
    
    if id then return tostring(id) end
    
    local owner = petModel:GetAttribute("Owner") or LocalPlayer.Name
    return petModel.Name .. "_" .. owner
end

-- Track pet ID for persistent enlargement
local function markPetAsEnlarged(pet)
    local id = getPetUniqueId(pet)
    if id then
        enlargedPetIds[id] = true
    end
end

-- Monitor pet for re-enlargement
local function startPetMonitoring(pet)
    local id = getPetUniqueId(pet)
    if not id then return end
    
    -- Stop existing monitoring
    if petUpdateLoops[id] then
        petUpdateLoops[id]:Disconnect()
    end
    
    -- Start new monitoring
    petUpdateLoops[id] = RunService.Heartbeat:Connect(function()
        if not pet or not pet.Parent then
            petUpdateLoops[id]:Disconnect()
            petUpdateLoops[id] = nil
            return
        end
        
        -- Re-apply enlargement if needed
        if enlargedPetIds[id] and not pet:GetAttribute("TOCHIPYRO_Enlarged") then
            task.wait(0.1)
            scaleModelWithJoints(pet, ENLARGE_SCALE)
        end
    end)
end

-- Handle new pets
local function onPetAdded(pet)
    if not pet:IsA("Model") then return end
    
    task.wait(0.2) -- Wait for pet to load
    
    local id = getPetUniqueId(pet)
    if not id then return end
    
    startPetMonitoring(pet)
    
    if enlargedPetIds[id] then
        task.wait(0.1)
        scaleModelWithJoints(pet, ENLARGE_SCALE)
    end
    
    -- Monitor for ancestry changes
    pet.AncestryChanged:Connect(function()
        if pet.Parent and enlargedPetIds[id] then
            task.wait(0.1)
            scaleModelWithJoints(pet, ENLARGE_SCALE)
        end
    end)
end

-- Setup container monitoring
for _, container in ipairs(petContainers) do
    if container then
        container.ChildAdded:Connect(onPetAdded)
        container.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("Model") and descendant:FindFirstChildWhichIsA("BasePart") then
                task.spawn(function()
                    onPetAdded(descendant)
                end)
            end
        end)
    end
end

-- Monitor player character
local function setupCharacterMonitoring()
    if LocalPlayer.Character then
        LocalPlayer.Character.ChildAdded:Connect(onPetAdded)
        LocalPlayer.Character.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("Model") and descendant:FindFirstChildWhichIsA("BasePart") then
                task.spawn(function()
                    onPetAdded(descendant)
                end)
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(setupCharacterMonitoring)
if LocalPlayer.Character then
    setupCharacterMonitoring()
end

-- Find current pet
local function getHeldPet()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- Check character for pets
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") and not obj:FindFirstChildOfClass("Humanoid") and obj ~= char then
            return obj
        end
    end
    
    -- Check garden slots
    local gardenSlots = workspace:FindFirstChild("GardenSlots")
    if gardenSlots then
        for _, slot in ipairs(gardenSlots:GetChildren()) do
            for _, obj in ipairs(slot:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") then
                    local owner = obj:GetAttribute("Owner") or obj:GetAttribute("OwnerUserId")
                    if owner == LocalPlayer.Name or owner == LocalPlayer.UserId then
                        return obj
                    end
                end
            end
        end
    end
    
    return nil
end

-- Main enlargement function
local function enlargeCurrentHeldPet()
    local pet = getHeldPet()
    if pet then
        scaleModelWithJoints(pet, ENLARGE_SCALE)
        markPetAsEnlarged(pet)
        startPetMonitoring(pet)
        
        -- Force position update for replication
        if pet.PrimaryPart then
            local originalCFrame = pet.PrimaryPart.CFrame
            pet.PrimaryPart.CFrame = originalCFrame + Vector3.new(0, 0.01, 0)
            task.wait(0.1)
            pet.PrimaryPart.CFrame = originalCFrame
        end
        
        print("[TOCHIPYRO] Enlarged pet with weight effects:", pet.Name)
    else
        -- Search in containers
        local foundPet = false
        for _, container in ipairs(petContainers) do
            if container then
                for _, obj in ipairs(container:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") and not obj:FindFirstChildOfClass("Humanoid") then
                        local owner = obj:GetAttribute("Owner") or obj:GetAttribute("OwnerUserId")
                        if owner == LocalPlayer.Name or owner == LocalPlayer.UserId then
                            scaleModelWithJoints(obj, ENLARGE_SCALE)
                            markPetAsEnlarged(obj)
                            startPetMonitoring(obj)
                            foundPet = true
                            break
                        end
                    end
                end
                if foundPet then break end
            end
        end
        
        if not foundPet then
            warn("[TOCHIPYRO] No pet found to enlarge.")
        end
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
SizeButton.Text = "Size Enlarge (+ Weight)"
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
SizeButton.MouseButton1Click:Connect(enlargeCurrentHeldPet)

MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    -- Clean up monitoring loops
    for id, connection in pairs(petUpdateLoops) do
        if connection then
            connection:Disconnect()
        end
    end
    ScreenGui:Destroy()
end)

BypassButton.MouseButton1Click:Connect(function()
    print("[TOCHIPYRO] Bypass pressed (placeholder).")
end)

print("[TOCHIPYRO] Pet enlarger with simple weight effects loaded!")

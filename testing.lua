-- TOCHIPYRO Script (Grow a Garden) with improved visibility and persistence

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ENLARGE_SCALE = 1.75
local WEIGHT_MULTIPLIER = 3.0 -- How much heavier the pet feels
local GRAVITY_MULTIPLIER = 1.5 -- Increased gravity effect

-- Containers to monitor for pet spawns
local petContainers = {
    workspace,
    workspace:FindFirstChild("Pets"),
    workspace:FindFirstChild("PetSlots"),
    workspace:FindFirstChild("GardenSlots"), -- Added garden slots
}

local enlargedPetIds = {}
local petConnections = {}
local petUpdateLoops = {}

-- Rainbow color helper
local function rainbowColor(t)
    local hue = (tick() * 0.5 + t) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Enhanced scaling function with realistic weight physics
local function scaleModelWithJoints(model, scaleFactor)
    if not model or not model.Parent then return end
    
    -- Scale all parts and meshes
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- Scale the part
            obj.Size = obj.Size * scaleFactor
            
            -- Apply realistic weight physics
            local originalMass = obj.Mass
            obj.Mass = originalMass * (scaleFactor * WEIGHT_MULTIPLIER)
            
            -- Adjust physics properties for heavier feel
            obj.Material = Enum.Material.Concrete -- Heavier material feel
            
            -- Create BodyVelocity for weight effects (if pet moves)
            local bodyVel = obj:FindFirstChild("TOCHIPYRO_Weight")
            if not bodyVel then
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.Name = "TOCHIPYRO_Weight"
                bodyVel.MaxForce = Vector3.new(0, math.huge, 0)
                bodyVel.Velocity = Vector3.new(0, -workspace.Gravity * GRAVITY_MULTIPLIER, 0)
                bodyVel.Parent = obj
            end
            
            -- Add ground impact effect
            local function addGroundImpact()
                local raycast = workspace:Raycast(obj.Position, Vector3.new(0, -5, 0))
                if raycast then
                    -- Create dust effect on ground contact
                    local dust = Instance.new("Explosion")
                    dust.Position = raycast.Position
                    dust.BlastRadius = scaleFactor * 10
                    dust.BlastPressure = 0 -- No damage
                    dust.Visible = false -- Just the effect
                    dust.Parent = workspace
                    
                    -- Screen shake effect for heavy landing
                    local camera = workspace.CurrentCamera
                    if camera then
                        local originalCFrame = camera.CFrame
                        for i = 1, 10 do
                            camera.CFrame = originalCFrame + Vector3.new(
                                math.random(-1, 1) * scaleFactor * 0.5,
                                math.random(-1, 1) * scaleFactor * 0.5,
                                math.random(-1, 1) * scaleFactor * 0.5
                            )
                            task.wait(0.05)
                        end
                        camera.CFrame = originalCFrame
                    end
                end
            end
            
            -- Monitor for landing impacts
            local lastVelocity = obj.Velocity
            obj:GetPropertyChangedSignal("Velocity"):Connect(function()
                if lastVelocity.Y < -10 and obj.Velocity.Y > -5 then
                    addGroundImpact()
                end
                lastVelocity = obj.Velocity
            end)
            
            -- Force network ownership for better replication
            if obj.CanSetNetworkOwnership then
                pcall(function()
                    obj:SetNetworkOwner(LocalPlayer)
                end)
            end
            
        elseif obj:IsA("SpecialMesh") then
            obj.Scale = obj.Scale * scaleFactor
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            -- Preserve texture scaling
            if obj.StudsPerTileU then
                obj.StudsPerTileU = obj.StudsPerTileU * scaleFactor
                obj.StudsPerTileV = obj.StudsPerTileV * scaleFactor
            end
        elseif obj:IsA("Motor6D") or obj:IsA("Weld") or obj:IsA("WeldConstraint") then
            -- Better joint scaling with weight consideration
            if obj:IsA("Motor6D") then
                local c0Pos = obj.C0.Position * scaleFactor
                local c1Pos = obj.C1.Position * scaleFactor
                obj.C0 = CFrame.new(c0Pos) * (obj.C0 - obj.C0.Position)
                obj.C1 = CFrame.new(c1Pos) * (obj.C1 - obj.C1.Position)
                
                -- Reduce motor strength for heavier feel
                if obj:FindFirstChild("MaxTorque") then
                    obj.MaxTorque = obj.MaxTorque / WEIGHT_MULTIPLIER
                end
            elseif obj:IsA("Weld") then
                local c0Pos = obj.C0.Position * scaleFactor
                local c1Pos = obj.C1.Position * scaleFactor
                obj.C0 = CFrame.new(c0Pos) * (obj.C0 - obj.C0.Position)
                obj.C1 = CFrame.new(c1Pos) * (obj.C1 - obj.C1.Position)
            end
        elseif obj:IsA("Humanoid") then
            -- Slow down movement for heavy feel
            obj.WalkSpeed = obj.WalkSpeed / (scaleFactor * 0.8)
            obj.JumpPower = obj.JumpPower / WEIGHT_MULTIPLIER
        end
    end
    
    -- Add ambient heavy breathing sound effect
    task.spawn(function()
        while model.Parent and model:GetAttribute("TOCHIPYRO_Enlarged") do
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxasset://sounds/impact_water.mp3" -- Heavy step sound
            sound.Volume = 0.3 * scaleFactor
            sound.Pitch = 0.7 / scaleFactor -- Lower pitch for bigger size
            sound.Parent = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            sound:Play()
            
            sound.Ended:Connect(function()
                sound:Destroy()
            end)
            
            task.wait(2 + math.random(1, 3)) -- Random heavy breathing intervals
        end
    end)
    
    -- Mark the model as enlarged with weight
    model:SetAttribute("TOCHIPYRO_Enlarged", true)
    model:SetAttribute("TOCHIPYRO_Scale", scaleFactor)
    model:SetAttribute("TOCHIPYRO_Weighted", true)
    
    print("[TOCHIPYRO] Applied realistic weight physics to enlarged pet!")
end

-- Get unique pet ID with better fallbacks
local function getPetUniqueId(petModel)
    if not petModel then return nil end
    
    -- Try multiple attribute methods
    local id = petModel:GetAttribute("PetID") or 
               petModel:GetAttribute("UniqueID") or
               petModel:GetAttribute("OwnerUserId") or
               petModel:GetAttribute("PetGUID")
    
    if id then return tostring(id) end
    
    -- Fallback to name + some unique identifier
    local owner = petModel:GetAttribute("Owner") or LocalPlayer.Name
    return petModel.Name .. "_" .. owner
end

-- Track pet ID to keep it enlarged persistently
local function markPetAsEnlarged(pet)
    local id = getPetUniqueId(pet)
    if id then
        enlargedPetIds[id] = true
        print("[TOCHIPYRO] Marked pet for persistent enlargement:", id)
    end
end

-- Continuous monitoring function for each pet
local function startPetMonitoring(pet)
    local id = getPetUniqueId(pet)
    if not id then return end
    
    -- Stop existing monitoring for this pet
    if petUpdateLoops[id] then
        petUpdateLoops[id]:Disconnect()
    end
    
    -- Start new monitoring loop
    petUpdateLoops[id] = RunService.Heartbeat:Connect(function()
        if not pet or not pet.Parent then
            petUpdateLoops[id]:Disconnect()
            petUpdateLoops[id] = nil
            return
        end
        
        -- Check if pet needs re-enlargement and weight physics
        if enlargedPetIds[id] and not pet:GetAttribute("TOCHIPYRO_Enlarged") then
            task.wait(0.1) -- Small delay to ensure stability
            scaleModelWithJoints(pet, ENLARGE_SCALE)
            print("[TOCHIPYRO] Re-applied enlargement with weight physics to pet:", pet.Name)
        end
    end)
end

-- Enhanced pet detection with better monitoring
local function onPetAdded(pet)
    if not pet:IsA("Model") then return end
    
    -- Wait a moment for the pet to fully load
    task.wait(0.2)
    
    local id = getPetUniqueId(pet)
    if not id then return end
    
    -- Start monitoring this pet
    startPetMonitoring(pet)
    
    -- If this pet should be enlarged, do it
    if enlargedPetIds[id] then
        task.wait(0.1)
        scaleModelWithJoints(pet, ENLARGE_SCALE)
        print("[TOCHIPYRO] Auto-enlarged pet on spawn:", pet.Name)
    end
    
    -- Monitor for when pet gets removed/moved
    pet.AncestryChanged:Connect(function()
        if pet.Parent then
            -- Pet moved to new container, re-monitor
            task.wait(0.1)
            if enlargedPetIds[id] then
                scaleModelWithJoints(pet, ENLARGE_SCALE)
            end
        end
    end)
end

-- Enhanced container monitoring
local function setupContainerMonitoring()
    for _, container in ipairs(petContainers) do
        if container then
            container.ChildAdded:Connect(onPetAdded)
            container.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("Model") and descendant:FindFirstChildWhichIsA("BasePart") then
                    onPetAdded(descendant)
                end
            end)
        end
    end
    
    -- Also monitor player's character for pet equipping
    local function setupCharacterMonitoring()
        if LocalPlayer.Character then
            LocalPlayer.Character.ChildAdded:Connect(onPetAdded)
            LocalPlayer.Character.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("Model") and descendant:FindFirstChildWhichIsA("BasePart") then
                    onPetAdded(descendant)
                end
            end)
        end
    end
    
    LocalPlayer.CharacterAdded:Connect(setupCharacterMonitoring)
    if LocalPlayer.Character then
        setupCharacterMonitoring()
    end
end

-- Setup container monitoring
setupContainerMonitoring()

-- Find the currently held/equipped pet model
local function getHeldPet()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- Check character for pet models
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") and not obj:FindFirstChildOfClass("Humanoid") and obj ~= char then
            return obj
        end
    end
    
    -- Check garden slots if available
    local gardenSlots = workspace:FindFirstChild("GardenSlots")
    if gardenSlots then
        for _, slot in ipairs(gardenSlots:GetChildren()) do
            for _, obj in ipairs(slot:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") and obj:GetAttribute("Owner") == LocalPlayer.Name then
                    return obj
                end
            end
        end
    end
    
    return nil
end

-- Enhanced enlargement function
local function enlargeCurrentHeldPet()
    local pet = getHeldPet()
    if pet then
        scaleModelWithJoints(pet, ENLARGE_SCALE)
        markPetAsEnlarged(pet)
        startPetMonitoring(pet)
        
        -- Force a small position change to trigger replication
        if pet.PrimaryPart then
            local originalCFrame = pet.PrimaryPart.CFrame
            pet.PrimaryPart.CFrame = originalCFrame + Vector3.new(0, 0.01, 0)
            task.wait(0.1)
            pet.PrimaryPart.CFrame = originalCFrame
        end
        
        print("[TOCHIPYRO] Enlarged pet with realistic weight:", pet.Name)
    else
        -- Try to find pets in other locations
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
                            print("[TOCHIPYRO] Found and enlarged pet with weight physics:", obj.Name)
                            foundPet = true
                            break
                        end
                    end
                end
                if foundPet then break end
            end
        end
        
        if not foundPet then
            warn("[TOCHIPYRO] No pet found to enlarge. Make sure you have a pet equipped or in your garden.")
        end
    end
end

-- GUI Creation (keeping original design)

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
SizeButton.Text = "Size Enlarge"
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
        connection:Disconnect()
    end
    ScreenGui:Destroy()
end)

BypassButton.MouseButton1Click:Connect(function()
    print("[TOCHIPYRO] Bypass pressed (placeholder).")
end)

print("[TOCHIPYRO] Enhanced pet enlarger loaded with improved visibility and persistence!")

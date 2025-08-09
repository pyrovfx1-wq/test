-- TOCHIPYRO Script (Grow a Garden) with improved visibility and persistence

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ENLARGE_SCALE = 1.75
local WEIGHT_MULTIPLIER = 2.5 -- How much to multiply the weight by

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
local originalWeights = {} -- Store original weights

-- Function to increase pet weight visually
local function increasePetWeight(petModel)
    if not petModel then return end
    
    local id = getPetUniqueId(petModel)
    if not id then return end
    
    -- Common weight attribute names in pet games
    local weightAttributes = {
        "Weight", "weight", "WeightKG", "Mass", "mass", "PetWeight", "petWeight"
    }
    
    local weightFound = false
    local originalWeight = nil
    
    -- Try to find existing weight attributes
    for _, attrName in ipairs(weightAttributes) do
        local currentWeight = petModel:GetAttribute(attrName)
        if currentWeight and type(currentWeight) == "number" then
            originalWeight = currentWeight
            weightFound = true
            break
        end
    end
    
    -- Store original weight if not already stored
    if not originalWeights[id] then
        originalWeights[id] = {}
    end
    
    -- If we found existing weight, use it
    if weightFound and originalWeight then
        if not originalWeights[id]["Weight"] then
            originalWeights[id]["Weight"] = originalWeight
        end
        local newWeight = originalWeights[id]["Weight"] * WEIGHT_MULTIPLIER
        petModel:SetAttribute("Weight", newWeight)
        print("[TOCHIPYRO] Increased weight from", originalWeight, "to", newWeight, "kg")
    else
        -- If no weight found, check common default values based on pet type/rarity
        local baseWeight = 2.5 -- Default base weight in kg (Normal pet range)
        
        -- Try to determine pet rarity/type for more realistic base weight
        local petName = petModel.Name:lower()
        if string.find(petName, "huge") or string.find(petName, "giant") then
            baseWeight = 6.0 -- Huge pet range
        elseif string.find(petName, "titanic") then
            baseWeight = 8.5 -- Titanic pet range  
        elseif string.find(petName, "godly") then
            baseWeight = 9.5 -- Godly pet range
        elseif string.find(petName, "small") or string.find(petName, "tiny") then
            baseWeight = 0.7 -- Small pet range
        end
        
        originalWeights[id]["Weight"] = baseWeight
        local newWeight = baseWeight * WEIGHT_MULTIPLIER
        
        petModel:SetAttribute("Weight", newWeight)
        print("[TOCHIPYRO] Created Weight attribute:", newWeight, "kg (base:", baseWeight, "kg)")
    end
    
    -- Try to update GUI elements immediately
    task.spawn(function()
        for i = 1, 5 do -- Try multiple times in case GUI loads later
            updateWeightGUI(petModel)
            task.wait(0.5)
        end
    end)
end

-- Function to update weight display in GUI elements
local function updateWeightGUI(petModel)
    if not petModel then return end
    
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local newWeight = petModel:GetAttribute("Weight") or petModel:GetAttribute("weight")
    if not newWeight then return end
    
    -- Search for pet viewing GUI (the "View" dialog that shows pet stats)
    local function searchAndUpdateGUI(parent)
        for _, gui in ipairs(parent:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextBox") then
                local text = gui.Text
                
                -- Look for weight-related text patterns
                if string.find(text:lower(), "weight") or 
                   string.match(text, "%d+%.?%d*%s*kg") or
                   string.match(text, "weight:%s*%d+%.?%d*") then
                    
                    -- Update the weight value in the text
                    local updatedText = string.gsub(text, "(%d+%.?%d*)(%s*kg)", string.format("%.1f", newWeight) .. "%2")
                    updatedText = string.gsub(updatedText, "(weight:%s*)(%d+%.?%d*)", "%1" .. string.format("%.1f", newWeight))
                    updatedText = string.gsub(updatedText, "(%d+%.?%d*)(%s*KG)", string.format("%.1f", newWeight) .. "%2")
                    
                    if updatedText ~= text then
                        gui.Text = updatedText
                        print("[TOCHIPYRO] Updated weight display:", updatedText)
                    end
                end
                
                -- Also check for standalone number + kg pattern
                if string.match(text, "^%d+%.?%d*%s*[Kk][Gg]$") then
                    gui.Text = string.format("%.1f kg", newWeight)
                    print("[TOCHIPYRO] Updated standalone weight:", gui.Text)
                end
            end
        end
    end
    
    -- Search in PlayerGui for pet view dialogs
    searchAndUpdateGUI(playerGui)
    
    -- Also search in StarterGui in case some elements are there
    local starterGui = game:GetService("StarterGui")
    if starterGui then
        searchAndUpdateGUI(starterGui)
    end
    
    -- Search in the pet model itself for any attached GUIs
    searchAndUpdateGUI(petModel)
end

-- Add a continuous GUI monitor for weight updates
local function startWeightGUIMonitor(petModel)
    local id = getPetUniqueId(petModel)
    if not id then return end
    
    task.spawn(function()
        while petModel and petModel.Parent and enlargedPetIds[id] do
            updateWeightGUI(petModel)
            task.wait(1) -- Check every second
        end
    end)
end
local function restoreOriginalWeight(petModel)
    if not petModel then return end
    
    local id = getPetUniqueId(petModel)
    if not id or not originalWeights[id] then return end
    
    -- Restore all original weight attributes
    for attrName, originalValue in pairs(originalWeights[id]) do
        petModel:SetAttribute(attrName, originalValue)
    end
    
    updateWeightGUI(petModel)
    print("[TOCHIPYRO] Restored original weight for pet:", petModel.Name)
end
local function rainbowColor(t)
    local hue = (tick() * 0.5 + t) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Enhanced scaling function with better joint handling
local function scaleModelWithJoints(model, scaleFactor)
    if not model or not model.Parent then return end
    
    -- Scale all parts and meshes
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Size = obj.Size * scaleFactor
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
            -- Better joint scaling
            if obj:IsA("Motor6D") then
                local c0Pos = obj.C0.Position * scaleFactor
                local c1Pos = obj.C1.Position * scaleFactor
                obj.C0 = CFrame.new(c0Pos) * (obj.C0 - obj.C0.Position)
                obj.C1 = CFrame.new(c1Pos) * (obj.C1 - obj.C1.Position)
            elseif obj:IsA("Weld") then
                local c0Pos = obj.C0.Position * scaleFactor
                local c1Pos = obj.C1.Position * scaleFactor
                obj.C0 = CFrame.new(c0Pos) * (obj.C0 - obj.C0.Position)
                obj.C1 = CFrame.new(c1Pos) * (obj.C1 - obj.C1.Position)
            end
        end
    end
    
    -- Mark the model as enlarged
    model:SetAttribute("TOCHIPYRO_Enlarged", true)
    model:SetAttribute("TOCHIPYRO_Scale", scaleFactor)
    
    -- Also increase the weight
    increasePetWeight(model)
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
        
        -- Check if pet needs re-enlargement
        if enlargedPetIds[id] and not pet:GetAttribute("TOCHIPYRO_Enlarged") then
            task.wait(0.1) -- Small delay to ensure stability
            scaleModelWithJoints(pet, ENLARGE_SCALE)
            increasePetWeight(pet) -- Also re-apply weight increase
            print("[TOCHIPYRO] Re-applied enlargement to pet:", pet.Name)
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
        
        print("[TOCHIPYRO] Enlarged pet:", pet.Name)
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
                            print("[TOCHIPYRO] Found and enlarged pet:", obj.Name)
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

local RestoreButton = Instance.new("TextButton")
RestoreButton.Size = UDim2.new(1, -20, 0, 40)
RestoreButton.Position = UDim2.new(0, 10, 0, 105)
RestoreButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RestoreButton.TextColor3 = Color3.new(1, 1, 1)
RestoreButton.Text = "Restore Weight"
RestoreButton.Font = Enum.Font.GothamBold
RestoreButton.TextScaled = true
RestoreButton.Parent = MoreFrame
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(1, -20, 0, 40)
CloseButton.Position = UDim2.new(0, 10, 0, 105)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Text = "Close UI"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextScaled = true
CloseButton.Parent = MoreFrame

-- Adjust MoreFrame size to fit new button
MoreFrame.Size = UDim2.new(0, 210, 0, 200)

-- Button Events
SizeButton.MouseButton1Click:Connect(enlargeCurrentHeldPet)

MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

RestoreButton.MouseButton1Click:Connect(function()
    local pet = getHeldPet()
    if pet then
        restoreOriginalWeight(pet)
        print("[TOCHIPYRO] Weight restored for current pet")
    else
        warn("[TOCHIPYRO] No pet found to restore weight")
    end
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

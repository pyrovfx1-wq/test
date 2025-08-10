-- TOCHIPYRO Enhanced Pet Enlarger with Trade Protection for Grow a Garden

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local ENLARGE_SCALE = 1.75
local WEIGHT_MULTIPLIER = 2.5

-- Store pet data with more robust tracking
local enlargedPetData = {}
local petUpdateLoops = {}
local originalWeights = {}
local petOwnershipHistory = {}

-- Enhanced pet identification system
local function getExtendedPetId(petModel)
    if not petModel then return nil end
    
    -- Try multiple identification methods
    local petId = petModel:GetAttribute("PetID") 
    local ownerId = petModel:GetAttribute("OwnerUserId") or petModel:GetAttribute("Owner")
    local petName = petModel.Name
    local petType = petModel:GetAttribute("PetType") or petModel:GetAttribute("Type")
    
    -- Create composite ID for better tracking
    local compositeId = string.format("%s_%s_%s_%s", 
        petId or "unknown", 
        ownerId or "noowner", 
        petName or "noname", 
        petType or "notype"
    )
    
    return compositeId, {
        id = petId,
        owner = ownerId,
        name = petName,
        type = petType,
        model = petModel
    }
end

-- Deep find Weight NumberValue inside pet model
local function findWeightNumberValue(model)
    for _, obj in ipairs(model:GetDescendants()) do
        if obj.Name:lower():find("weight") and obj:IsA("NumberValue") then
            return obj
        end
    end
    return nil
end

-- Enhanced scaling with better joint preservation
local function scaleModelWithJoints(model, scaleFactor)
    if model:GetAttribute("TOCHIPYRO_Processing") then
        return -- Prevent recursive scaling
    end
    
    model:SetAttribute("TOCHIPYRO_Processing", true)
    
    -- Store original sizes if not already stored
    local compositeId, petData = getExtendedPetId(model)
    if compositeId and not enlargedPetData[compositeId] then
        enlargedPetData[compositeId] = {
            originalSizes = {},
            originalScales = {},
            originalC0 = {},
            originalC1 = {},
            petData = petData,
            enlarged = false
        }
        
        -- Store original values
        for _, obj in ipairs(model:GetDescendants()) do
            if obj:IsA("BasePart") then
                enlargedPetData[compositeId].originalSizes[obj] = obj.Size
            elseif obj:IsA("SpecialMesh") then
                enlargedPetData[compositeId].originalScales[obj] = obj.Scale
            elseif obj:IsA("Motor6D") then
                enlargedPetData[compositeId].originalC0[obj] = obj.C0
                enlargedPetData[compositeId].originalC1[obj] = obj.C1
            end
        end
    end
    
    -- Apply scaling
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

    model:SetAttribute("TOCHIPYRO_Enlarged", true)
    model:SetAttribute("TOCHIPYRO_Scale", scaleFactor)
    model:SetAttribute("TOCHIPYRO_Timestamp", tick())
    
    if compositeId then
        enlargedPetData[compositeId].enlarged = true
    end
    
    model:SetAttribute("TOCHIPYRO_Processing", false)
    
    print("[TOCHIPYRO] Successfully scaled pet:", model.Name)
end

-- Enhanced weight modification
local function increaseWeight(petModel)
    local weightValue = findWeightNumberValue(petModel)
    if not weightValue then
        warn("[TOCHIPYRO] Could not find Weight NumberValue in pet:", petModel.Name)
        return
    end

    local compositeId = getExtendedPetId(petModel)
    if not compositeId then
        warn("[TOCHIPYRO] Pet missing unique ID, skipping weight update")
        return
    end

    -- Store original weight
    if not originalWeights[compositeId] then
        originalWeights[compositeId] = weightValue.Value
    end

    local newWeight = originalWeights[compositeId] * WEIGHT_MULTIPLIER
    weightValue.Value = newWeight
    
    -- Set multiple weight attributes for redundancy
    petModel:SetAttribute("Weight", newWeight)
    petModel:SetAttribute("weight", newWeight)
    petModel:SetAttribute("TOCHIPYRO_Weight", newWeight)
    petModel:SetAttribute("TOCHIPYRO_OriginalWeight", originalWeights[compositeId])

    print(string.format("[TOCHIPYRO] Weight updated from %.2f to %.2f for pet %s", originalWeights[compositeId], newWeight, petModel.Name))
end

-- Enhanced pet monitoring with ownership tracking
local function startEnhancedPetMonitor(petModel)
    local compositeId, petData = getExtendedPetId(petModel)
    if not compositeId then return end

    -- Store ownership history
    petOwnershipHistory[compositeId] = {
        currentOwner = petData.owner,
        previousOwner = petOwnershipHistory[compositeId] and petOwnershipHistory[compositeId].currentOwner,
        lastSeen = tick(),
        model = petModel
    }

    if petUpdateLoops[compositeId] then
        petUpdateLoops[compositeId]:Disconnect()
    end

    petUpdateLoops[compositeId] = RunService.Heartbeat:Connect(function()
        if not petModel or not petModel.Parent then
            if petUpdateLoops[compositeId] then
                petUpdateLoops[compositeId]:Disconnect()
                petUpdateLoops[compositeId] = nil
            end
            return
        end

        -- Check if pet needs re-enlargement
        local shouldBeEnlarged = enlargedPetData[compositeId] and enlargedPetData[compositeId].enlarged
        local isCurrentlyEnlarged = petModel:GetAttribute("TOCHIPYRO_Enlarged")
        local lastTimestamp = petModel:GetAttribute("TOCHIPYRO_Timestamp") or 0
        
        -- Re-enlarge if needed (handles trade resets)
        if shouldBeEnlarged and (not isCurrentlyEnlarged or tick() - lastTimestamp > 1) then
            task.wait(0.1) -- Small delay to let the game settle
            scaleModelWithJoints(petModel, ENLARGE_SCALE)
            increaseWeight(petModel)
            print("[TOCHIPYRO] Reapplied enlargement after reset/trade:", petModel.Name)
        end
        
        -- Monitor for ownership changes
        local currentOwner = petModel:GetAttribute("OwnerUserId") or petModel:GetAttribute("Owner")
        if currentOwner and petOwnershipHistory[compositeId].currentOwner ~= currentOwner then
            print("[TOCHIPYRO] Detected ownership change for pet:", petModel.Name)
            petOwnershipHistory[compositeId].previousOwner = petOwnershipHistory[compositeId].currentOwner
            petOwnershipHistory[compositeId].currentOwner = currentOwner
            
            -- Re-apply enlargement after ownership change
            if shouldBeEnlarged then
                task.wait(0.5) -- Longer wait for trade completion
                scaleModelWithJoints(petModel, ENLARGE_SCALE)
                increaseWeight(petModel)
                print("[TOCHIPYRO] Reapplied enlargement after ownership change:", petModel.Name)
            end
        end
    end)
end

-- Enhanced pet finding with multiple search locations
local function getAllPets()
    local pets = {}
    local char = LocalPlayer.Character
    
    -- Search character
    if char then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") and not obj:FindFirstChildOfClass("Humanoid") and obj ~= char then
                table.insert(pets, obj)
            end
        end
    end
    
    -- Search workspace locations
    local searchLocations = {
        workspace:FindFirstChild("Pets"),
        workspace:FindFirstChild("PetSlots"),
        workspace:FindFirstChild("GardenSlots"),
        workspace:FindFirstChild("PlayerPets"),
        workspace
    }
    
    for _, location in pairs(searchLocations) do
        if location then
            for _, obj in ipairs(location:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") then
                    local owner = obj:GetAttribute("Owner") or obj:GetAttribute("OwnerUserId")
                    if owner == LocalPlayer.Name or owner == tostring(LocalPlayer.UserId) or not owner then
                        table.insert(pets, obj)
                    end
                end
            end
        end
    end
    
    return pets
end

-- Enhanced pet enlargement function
local function enlargeAllFoundPets()
    local pets = getAllPets()
    local enlargedCount = 0
    
    for _, pet in pairs(pets) do
        local compositeId = getExtendedPetId(pet)
        if compositeId then
            scaleModelWithJoints(pet, ENLARGE_SCALE)
            increaseWeight(pet)
            startEnhancedPetMonitor(pet)
            enlargedCount = enlargedCount + 1
            
            -- Small delay between pets to prevent overwhelming
            task.wait(0.1)
        end
    end
    
    print(string.format("[TOCHIPYRO] Enlarged %d pets", enlargedCount))
    return enlargedCount
end

-- Global pet monitoring for automatic enlargement
local function onPetAdded(pet)
    if not pet:IsA("Model") then return end

    task.wait(0.2) -- Allow for proper initialization

    local compositeId, petData = getExtendedPetId(pet)
    if not compositeId then return end

    startEnhancedPetMonitor(pet)

    -- Auto-enlarge if this pet was previously enlarged
    if enlargedPetData[compositeId] and enlargedPetData[compositeId].enlarged then
        task.wait(0.3) -- Additional wait for trade/respawn scenarios
        scaleModelWithJoints(pet, ENLARGE_SCALE)
        increaseWeight(pet)
        print("[TOCHIPYRO] Auto-enlarged returning pet:", pet.Name)
    end
end

-- Set up global monitoring
local petContainers = {
    workspace,
    workspace:FindFirstChild("Pets"),
    workspace:FindFirstChild("PetSlots"),
    workspace:FindFirstChild("GardenSlots"),
    workspace:FindFirstChild("PlayerPets")
}

for _, container in pairs(petContainers) do
    if container then
        container.ChildAdded:Connect(onPetAdded)
        container.DescendantAdded:Connect(function(obj)
            if obj:IsA("Model") then
                onPetAdded(obj)
            end
        end)
    end
end

-- Character monitoring
local function setupCharacterMonitoring()
    if LocalPlayer.Character then
        LocalPlayer.Character.ChildAdded:Connect(onPetAdded)
        LocalPlayer.Character.DescendantAdded:Connect(function(obj)
            if obj:IsA("Model") then
                onPetAdded(obj)
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(setupCharacterMonitoring)
setupCharacterMonitoring()

-- Create Enhanced GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TOCHIPYRO_Enhanced_Script"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "TOCHIPYRO Enhanced"
Title.TextSize = 18
Title.Parent = TitleBar

-- Rainbow title effect
spawn(function()
    while Title and Title.Parent do
        for h = 0, 1, 0.01 do
            if Title and Title.Parent then
                Title.TextColor3 = Color3.fromHSV(h, 1, 1)
                task.wait(0.03)
            else
                break
            end
        end
    end
end)

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Text = "_"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 20
MinimizeButton.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -70, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.Parent = TitleBar

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Enlarge Button
local EnlargeButton = Instance.new("TextButton")
EnlargeButton.Size = UDim2.new(1, -20, 0, 35)
EnlargeButton.Position = UDim2.new(0, 10, 0, 10)
EnlargeButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
EnlargeButton.TextColor3 = Color3.new(1, 1, 1)
EnlargeButton.Text = "Enlarge All Pets"
EnlargeButton.Font = Enum.Font.GothamBold
EnlargeButton.TextScaled = true
EnlargeButton.Parent = ContentFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 55)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Enhanced anti-trade reset ready!"
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.TextSize = 12
StatusLabel.TextScaled = true
StatusLabel.Parent = ContentFrame

-- Info Label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 60)
InfoLabel.Position = UDim2.new(0, 10, 0, 90)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Text = "Features:\n• Trade-resistant scaling\n• Auto re-enlargement\n• Enhanced pet tracking"
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
InfoLabel.TextSize = 11
InfoLabel.TextScaled = true
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Parent = ContentFrame

-- Button functionality
EnlargeButton.MouseButton1Click:Connect(function()
    local count = enlargeAllFoundPets()
    StatusLabel.Text = string.format("Enlarged %d pets with protection!", count)
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    
    task.spawn(function()
        task.wait(3)
        if StatusLabel and StatusLabel.Parent then
            StatusLabel.Text = "Enhanced anti-trade reset active!"
            StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        end
    end)
end)

-- Minimize functionality
local isMinimized = false
local originalSize = MainFrame.Size

MinimizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        MainFrame.Size = originalSize
        ContentFrame.Visible = true
        MinimizeButton.Text = "_"
        isMinimized = false
    else
        MainFrame.Size = UDim2.new(0, 300, 0, 40)
        ContentFrame.Visible = false
        MinimizeButton.Text = "+"
        isMinimized = true
    end
end)

-- Close functionality
CloseButton.MouseButton1Click:Connect(function()
    -- Clean up all monitoring loops
    for id, loop in pairs(petUpdateLoops) do
        if loop then
            loop:Disconnect()
        end
    end
    ScreenGui:Destroy()
end)

-- Auto-enlarge existing pets on script load
task.spawn(function()
    task.wait(2) -- Wait for game to load
    print("[TOCHIPYRO] Auto-scanning for existing pets...")
    enlargeAllFoundPets()
end)

print("[TOCHIPYRO] Enhanced Pet Enlarger with Trade Protection loaded!")
print("[TOCHIPYRO] Features: Anti-reset scaling, ownership tracking, enhanced monitoring")

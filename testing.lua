-- TOCHIPYRO Client-Side Visual Pet Enlarger for Grow a Garden
-- Only YOU see the enlarged pets - other players see normal size

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local ENLARGE_SCALE = 1.75
local WEIGHT_MULTIPLIER = 2.5

-- Store visual-only enlargements
local enlargedPets = {}
local monitorLoop = nil

-- Enhanced pet identification - more persistent across trades/gifts
local function getPetId(petModel)
    if not petModel then return nil end
    
    -- Try multiple identification methods for better persistence
    local petId = petModel:GetAttribute("PetID")
    local petName = petModel.Name
    local petType = petModel:GetAttribute("PetType") or petModel:GetAttribute("Type")
    
    -- Create a more robust ID that persists across ownership changes
    if petId then
        return petId -- Use official pet ID if available
    else
        -- Fallback to name + type combination
        return petName .. "_" .. (petType or "unknown") .. "_" .. tostring(petModel:GetDebugId())
    end
end

-- Find weight value
local function findWeight(model)
    for _, obj in ipairs(model:GetDescendants()) do
        if obj.Name:lower() == "weight" and obj:IsA("NumberValue") then
            return obj
        end
    end
    return nil
end

-- Client-side visual scaling ONLY
local function visuallyEnlargePet(petModel)
    if not petModel or not petModel.Parent then return end
    
    local petId = getPetId(petModel)
    if not petId then return end
    
    -- Skip if already processing
    if petModel:GetAttribute("TOCHIPYRO_Processing") then return end
    petModel:SetAttribute("TOCHIPYRO_Processing", true)
    
    -- Store original values if not stored
    if not enlargedPets[petId] then
        enlargedPets[petId] = {
            model = petModel,
            originalSizes = {},
            originalScales = {},
            originalC0 = {},
            originalC1 = {},
            originalWeight = nil,
            enlarged = false
        }
        
        -- Store all original values
        for _, obj in ipairs(petModel:GetDescendants()) do
            if obj:IsA("BasePart") then
                enlargedPets[petId].originalSizes[obj] = obj.Size
            elseif obj:IsA("SpecialMesh") then
                enlargedPets[petId].originalScales[obj] = obj.Scale
            elseif obj:IsA("Motor6D") then
                enlargedPets[petId].originalC0[obj] = obj.C0
                enlargedPets[petId].originalC1[obj] = obj.C1
            end
        end
        
        -- Store original weight
        local weightValue = findWeight(petModel)
        if weightValue then
            enlargedPets[petId].originalWeight = weightValue.Value
        end
    end
    
    -- Apply visual scaling (CLIENT-SIDE ONLY)
    for _, obj in ipairs(petModel:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Size = obj.Size * ENLARGE_SCALE
        elseif obj:IsA("SpecialMesh") then
            obj.Scale = obj.Scale * ENLARGE_SCALE
        elseif obj:IsA("Motor6D") then
            obj.C0 = CFrame.new(obj.C0.Position * ENLARGE_SCALE) * (obj.C0 - obj.C0.Position)
            obj.C1 = CFrame.new(obj.C1.Position * ENLARGE_SCALE) * (obj.C1 - obj.C1.Position)
        end
    end
    
    -- Visual weight change (CLIENT-SIDE ONLY)
    local weightValue = findWeight(petModel)
    if weightValue and enlargedPets[petId].originalWeight then
        weightValue.Value = enlargedPets[petId].originalWeight * WEIGHT_MULTIPLIER
        petModel:SetAttribute("Weight", weightValue.Value)
    end
    
    enlargedPets[petId].enlarged = true
    enlargedPets[petId].model = petModel
    petModel:SetAttribute("TOCHIPYRO_Visual", true)
    petModel:SetAttribute("TOCHIPYRO_Processing", false)
    
    print("[TOCHIPYRO] Visually enlarged pet (client-side only):", petModel.Name)
end

-- Reset pet to original size (if needed)
local function resetPetVisual(petModel)
    local petId = getPetId(petModel)
    if not petId or not enlargedPets[petId] then return end
    
    local data = enlargedPets[petId]
    
    -- Reset sizes
    for obj, originalSize in pairs(data.originalSizes) do
        if obj and obj.Parent then
            obj.Size = originalSize
        end
    end
    
    -- Reset scales
    for obj, originalScale in pairs(data.originalScales) do
        if obj and obj.Parent then
            obj.Scale = originalScale
        end
    end
    
    -- Reset joints
    for obj, originalC0 in pairs(data.originalC0) do
        if obj and obj.Parent then
            obj.C0 = originalC0
        end
    end
    
    for obj, originalC1 in pairs(data.originalC1) do
        if obj and obj.Parent then
            obj.C1 = originalC1
        end
    end
    
    -- Reset weight
    if data.originalWeight then
        local weightValue = findWeight(petModel)
        if weightValue then
            weightValue.Value = data.originalWeight
            petModel:SetAttribute("Weight", data.originalWeight)
        end
    end
    
    petModel:SetAttribute("TOCHIPYRO_Visual", false)
    data.enlarged = false
    
    print("[TOCHIPYRO] Reset pet visual to original size:", petModel.Name)
end

-- Find all pets in the game (including other players' pets for visual-only enlargement)
local function getAllPetsInGame()
    local pets = {}
    
    -- Check workspace pets
    if workspace:FindFirstChild("Pets") then
        for _, pet in ipairs(workspace.Pets:GetChildren()) do
            if pet:IsA("Model") then
                table.insert(pets, pet)
            end
        end
    end
    
    -- Check ALL players' characters (not just local player)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, obj in ipairs(player.Character:GetChildren()) do
                if obj:IsA("Model") and obj ~= player.Character and obj:FindFirstChildWhichIsA("BasePart") then
                    table.insert(pets, obj)
                end
            end
        end
    end
    
    -- Check garden slots and pet containers
    local petContainers = {
        workspace:FindFirstChild("GardenSlots"),
        workspace:FindFirstChild("PetSlots"),
        workspace:FindFirstChild("PlayerPets")
    }
    
    for _, container in ipairs(petContainers) do
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") then
                    table.insert(pets, obj)
                end
            end
        end
    end
    
    return pets
end

-- Auto-enlargement system
local autoEnlargeEnabled = false

-- Enhanced monitoring system - automatically enlarges all pets when enabled
local function startVisualMonitoring()
    if monitorLoop then
        monitorLoop:Disconnect()
    end
    
    monitorLoop = RunService.Heartbeat:Connect(function()
        if not autoEnlargeEnabled then return end
        
        -- Check every pet in the game
        local allPets = getAllPetsInGame()
        
        for _, pet in ipairs(allPets) do
            local petId = getPetId(pet)
            if petId then
                -- Auto-enlarge ALL pets when auto mode is enabled
                if not enlargedPets[petId] or not enlargedPets[petId].enlarged then
                    visuallyEnlargePet(pet)
                elseif not pet:GetAttribute("TOCHIPYRO_Visual") then
                    -- Reapply if visual is missing
                    visuallyEnlargePet(pet)
                else
                    -- Check if size got reset and reapply
                    local firstPart = pet:FindFirstChildWhichIsA("BasePart")
                    if firstPart and enlargedPets[petId].originalSizes[firstPart] then
                        local currentSize = firstPart.Size
                        local expectedSize = enlargedPets[petId].originalSizes[firstPart] * ENLARGE_SCALE
                        
                        local sizeDifference = (currentSize - expectedSize).Magnitude
                        if sizeDifference > 0.1 then
                            visuallyEnlargePet(pet)
                        end
                    end
                end
            end
        end
    end)
end

-- Function to enlarge current held pet
local function enlargeCurrentPet()
    local char = LocalPlayer.Character
    if not char then return false, "No character found!" end
    
    -- Find pet in character
    local pet = nil
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Model") and obj ~= char and obj:FindFirstChildWhichIsA("BasePart") and not obj:FindFirstChildOfClass("Humanoid") then
            pet = obj
            break
        end
    end
    
    if not pet then return false, "No pet found in character!" end
    
    visuallyEnlargePet(pet)
    return true, "Pet visually enlarged: " .. pet.Name
end

-- Function to enlarge ALL pets in the game (visual only for you)
local function enlargeAllPets()
    local allPets = getAllPetsInGame()
    local count = 0
    
    for _, pet in ipairs(allPets) do
        visuallyEnlargePet(pet)
        count = count + 1
        task.wait(0.1) -- Small delay to prevent lag
    end
    
    return count
end

-- Function to reset all visual enlargements
local function resetAllPets()
    for petId, data in pairs(enlargedPets) do
        if data.model and data.model.Parent then
            resetPetVisual(data.model)
        end
    end
    enlargedPets = {}
end

-- Start the visual monitoring
startVisualMonitoring()

-- Enhanced pet spawn monitoring - automatically enlarges new pets when auto mode is on
local function onPetSpawned(pet)
    if not pet:IsA("Model") then return end
    
    task.wait(0.5) -- Wait for pet to fully load
    
    if autoEnlargeEnabled then
        -- Auto-enlarge any new pet that spawns
        visuallyEnlargePet(pet)
        print("[TOCHIPYRO] Auto-enlarged new pet:", pet.Name)
    else
        -- Check if this pet was previously enlarged
        local petId = getPetId(pet)
        if petId and enlargedPets[petId] and enlargedPets[petId].enlarged then
            visuallyEnlargePet(pet)
            print("[TOCHIPYRO] Reapplied visual enlargement to returning pet:", pet.Name)
        end
    end
end

-- Monitor for new pets
if workspace:FindFirstChild("Pets") then
    workspace.Pets.ChildAdded:Connect(onPetSpawned)
end

-- Monitor character pets
local function setupCharacterMonitoring()
    if LocalPlayer.Character then
        LocalPlayer.Character.ChildAdded:Connect(onPetSpawned)
    end
end

LocalPlayer.CharacterAdded:Connect(setupCharacterMonitoring)
setupCharacterMonitoring()

-- Simple GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TOCHIPYRO_Visual_Only"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 130)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BackgroundTransparency = 0.4
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 1, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "TOCHIPYRO Visual Only"
Title.TextSize = 16
Title.Parent = TitleBar

-- Rainbow title
spawn(function()
    while Title and Title.Parent do
        for h = 0, 1, 0.02 do
            if Title and Title.Parent then
                Title.TextColor3 = Color3.fromHSV(h, 1, 1)
                task.wait(0.05)
            else
                break
            end
        end
    end
end)

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

-- Toggle Button (Enable/Disable Auto-Enlargement)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -20, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 60)
ToggleButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Text = "Enable Auto-Enlarge All Pets"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 16
ToggleButton.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 115)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Click to enable automatic pet enlargement!"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 150)
StatusLabel.TextSize = 12
StatusLabel.TextScaled = true
StatusLabel.Parent = MainFrame

-- Toggle Button function
ToggleButton.MouseButton1Click:Connect(function()
    autoEnlargeEnabled = not autoEnlargeEnabled
    
    if autoEnlargeEnabled then
        -- Enable auto-enlarge mode
        ToggleButton.Text = "Disable Auto-Enlarge"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
        StatusLabel.Text = "AUTO-ENLARGE ON - All pets will appear huge!"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        -- Immediately enlarge all existing pets
        local allPets = getAllPetsInGame()
        local count = 0
        for _, pet in ipairs(allPets) do
            visuallyEnlargePet(pet)
            count = count + 1
        end
        
        print(string.format("[TOCHIPYRO] Auto-enlarge enabled! Enlarged %d existing pets", count))
    else
        -- Disable auto-enlarge mode
        ToggleButton.Text = "Enable Auto-Enlarge All Pets"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
        StatusLabel.Text = "AUTO-ENLARGE OFF - Click to enable"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 150)
        
        print("[TOCHIPYRO] Auto-enlarge disabled")
    end
end)

-- Close functionality
CloseButton.MouseButton1Click:Connect(function()
    if monitorLoop then
        monitorLoop:Disconnect()
    end
    -- Don't reset pets when closing - keep enlargements active
    ScreenGui:Destroy()
end)

print("[TOCHIPYRO] Auto Pet Enlarger loaded!")
print("[TOCHIPYRO] Features:")
print("[TOCHIPYRO] - Click once to enable auto-enlarge mode")
print("[TOCHIPYRO] - ALL pets will automatically appear huge (visual only)")
print("[TOCHIPYRO] - New pets auto-enlarge when they spawn")
print("[TOCHIPYRO] - Persistent through trades/gifts")
print("[TOCHIPYRO] - Toggle on/off anytime!")

-- TOCHIPYRO Script (Grow a Garden) with pet enlargement and weight increase

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local ENLARGE_SCALE = 1.75
local WEIGHT_MULTIPLIER = 2.5

-- Containers to monitor for pet spawns
local petContainers = {
    workspace,
    workspace:FindFirstChild("Pets"),
    workspace:FindFirstChild("PetSlots"),
    workspace:FindFirstChild("GardenSlots"),
}

local enlargedPetIds = {}
local petConnections = {}
local petUpdateLoops = {}
local originalWeights = {}

-- Simple weight increase function
local function increaseWeightDisplay(petModel)
    if not petModel then return end
    
    local id = getPetUniqueId(petModel)
    if not id then return end
    
    -- Try to find existing weight in the pet's attributes/values
    local currentWeight = nil
    local weightSources = {
        petModel:FindFirstChild("Weight"),
        petModel:FindFirstChild("weight"),
        petModel:GetAttribute("Weight"),
        petModel:GetAttribute("weight"),
        petModel:GetAttribute("WeightKG")
    }
    
    for _, source in ipairs(weightSources) do
        if source then
            if type(source) == "number" then
                currentWeight = source
                break
            elseif source.Value then
                currentWeight = source.Value
                break
            end
        end
    end
    
    -- If no weight found, set a default based on pet name
    if not currentWeight then
        currentWeight = 2.5 -- Default weight
        if string.find(petModel.Name:lower(), "huge") then
            currentWeight = 6.0
        elseif string.find(petModel.Name:lower(), "titanic") then
            currentWeight = 8.5
        end
    end
    
    -- Store original weight
    if not originalWeights[id] then
        originalWeights[id] = currentWeight
    end
    
    -- Calculate new weight
    local newWeight = originalWeights[id] * WEIGHT_MULTIPLIER
    
    -- Set the new weight in various places
    petModel:SetAttribute("Weight", newWeight)
    petModel:SetAttribute("weight", newWeight)
    
    -- Create or update weight value objects
    local weightValue = petModel:FindFirstChild("Weight") or Instance.new("NumberValue")
    weightValue.Name = "Weight"
    weightValue.Value = newWeight
    weightValue.Parent = petModel
    
    print("[TOCHIPYRO] Weight increased from", currentWeight, "kg to", newWeight, "kg")
    
    -- Force update any GUI that might be showing this
    updateAllWeightDisplays(newWeight, petModel.Name)
end

-- Function to update weight displays in GUI
function updateAllWeightDisplays(newWeight, petName)
    local playerGui = LocalPlayer.PlayerGui
    
    -- Search through all GUI elements
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextBox") then
            local text = gui.Text
            
            -- Check if this text contains weight information
            if string.find(text, "kg") or string.find(text:lower(), "weight") then
                
                -- Try different patterns to update weight
                local patterns = {
                    "(%d+%.?%d*)%s*kg", -- "5.2 kg"
                    "(%d+%.?%d*)%s*KG", -- "5.2 KG" 
                    "weight:%s*(%d+%.?%d*)", -- "Weight: 5.2"
                    "weight%s*(%d+%.?%d*)", -- "Weight 5.2"
                }
                
                for _, pattern in ipairs(patterns) do
                    if string.match(text, pattern) then
                        local newText = string.gsub(text, pattern, string.format("%.1f", newWeight))
                        if newText ~= text then
                            gui.Text = newText
                            print("[TOCHIPYRO] Updated GUI weight display:", newText)
                        end
                    end
                end
                
                -- Also try to replace any standalone kg values
                if string.match(text, "^%d+%.?%d*%s*kg$") then
                    gui.Text = string.format("%.1f kg", newWeight)
                    print("[TOCHIPYRO] Updated standalone weight:", gui.Text)
                end
            end
        end
    end
    
    -- Also try to update any pet info panels that might be open
    task.spawn(function()
        for i = 1, 10 do
            task.wait(0.2)
            for _, gui in ipairs(playerGui:GetDescendants()) do
                if gui:IsA("TextLabel") and gui.Visible then
                    local text = gui.Text
                    if string.find(text, "kg") and (string.find(text, petName) or string.find(gui.Parent.Name, "Pet") or string.find(gui.Parent.Name, "Info")) then
                        local newText = string.gsub(text, "%d+%.?%d*", string.format("%.1f", newWeight))
                        if newText ~= text then
                            gui.Text = newText
                            print("[TOCHIPYRO] Updated pet info weight:", newText)
                        end
                    end
                end
            end
        end
    end)
end

-- Rainbow color helper
local function rainbowColor(t)
    local hue = (tick() * 0.5 + t) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Scale model parts & joints preserving proportions
local function scaleModelWithJoints(model, scaleFactor)
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Size = obj.Size * scaleFactor
            if obj.CanSetNetworkOwnership then
                pcall(function()
                    obj:SetNetworkOwner(LocalPlayer)
                end)
            end
        elseif obj:IsA("SpecialMesh") then
            obj.Scale = obj.Scale * scaleFactor
        elseif obj:IsA("Motor6D") then
            obj.C0 = CFrame.new(obj.C0.Position * scaleFactor) * (obj.C0 - obj.C0.Position)
            obj.C1 = CFrame.new(obj.C1.Position * scaleFactor) * (obj.C1 - obj.C1.Position)
        end
    end
    
    -- Mark the model as enlarged
    model:SetAttribute("TOCHIPYRO_Enlarged", true)
    model:SetAttribute("TOCHIPYRO_Scale", scaleFactor)
    
    -- Also increase the weight display
    increaseWeightDisplay(model)
end

-- Get unique pet ID or fallback to name
function getPetUniqueId(petModel)
    if not petModel then return nil end
    return petModel:GetAttribute("PetID") or petModel:GetAttribute("OwnerUserId") or petModel.Name
end

-- Track pet ID to keep it enlarged persistently
local function markPetAsEnlarged(pet)
    local id = getPetUniqueId(pet)
    if id then
        enlargedPetIds[id] = true
    end
end

-- Continuous monitoring function for each pet
local function startPetMonitoring(pet)
    local id = getPetUniqueId(pet)
    if not id then return end
    
    if petUpdateLoops[id] then
        petUpdateLoops[id]:Disconnect()
    end
    
    petUpdateLoops[id] = RunService.Heartbeat:Connect(function()
        if not pet or not pet.Parent then
            petUpdateLoops[id]:Disconnect()
            petUpdateLoops[id] = nil
            return
        end
        
        if enlargedPetIds[id] and not pet:GetAttribute("TOCHIPYRO_Enlarged") then
            task.wait(0.1)
            scaleModelWithJoints(pet, ENLARGE_SCALE)
            print("[TOCHIPYRO] Re-applied enlargement to pet:", pet.Name)
        end
    end)
end

-- Enhanced pet detection with better monitoring
local function onPetAdded(pet)
    if not pet:IsA("Model") then return end
    
    task.wait(0.2)
    
    local id = getPetUniqueId(pet)
    if not id then return end
    
    startPetMonitoring(pet)
    
    if enlargedPetIds[id] then
        task.wait(0.1)
        scaleModelWithJoints(pet, ENLARGE_SCALE)
        print("[TOCHIPYRO] Auto-enlarged pet on spawn:", pet.Name)
    end
    
    pet.AncestryChanged:Connect(function()
        if pet.Parent then
            task.wait(0.1)
            if enlargedPetIds[id] then
                scaleModelWithJoints(pet, ENLARGE_SCALE)
            end
        end
    end)
end

-- Setup container monitoring
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

-- Monitor player's character
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

-- Find the currently held/equipped pet model
local function getHeldPet()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") and not obj:FindFirstChildOfClass("Humanoid") and obj ~= char then
            return obj
        end
    end
    
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
        
        if pet.PrimaryPart then
            local originalCFrame = pet.PrimaryPart.CFrame
            pet.PrimaryPart.CFrame = originalCFrame + Vector3.new(0, 0.01, 0)
            task.wait(0.1)
            pet.PrimaryPart.CFrame = originalCFrame
        end
        
        print("[TOCHIPYRO] Enlarged pet:", pet.Name)
    else
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
BypassButton.Text = "Update All Weights"
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

BypassButton.MouseButton1Click:Connect(function()
    -- Force update all weight displays
    local pet = getHeldPet()
    if pet then
        local weight = pet:GetAttribute("Weight") or 25.0
        updateAllWeightDisplays(weight, pet.Name)
        print("[TOCHIPYRO] Forced weight display update")
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    for id, connection in pairs(petUpdateLoops) do
        connection:Disconnect()
    end
    ScreenGui:Destroy()
end)

print("[TOCHIPYRO] Pet enlarger with weight display loaded!")

-- TOCHIPYRO Enhanced Pet Enlarger for Grow a Garden

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local ENLARGE_SCALE = 1.75
local WEIGHT_MULTIPLIER = 2.5

-- Store pet IDs enlarged
local enlargedPetIds = {}
local petUpdateLoops = {}
local originalWeights = {}
-- Store original sizes for each pet part to detect resets
local originalPartSizes = {}

-- Store original part sizes for reset detection
local function storeOriginalSizes(petModel)
    local id = getPetUniqueId(petModel)
    if not id then return end
    
    originalPartSizes[id] = {}
    for _, obj in ipairs(petModel:GetDescendants()) do
        if obj:IsA("BasePart") then
            originalPartSizes[id][obj] = obj.Size
        end
    end
end

-- Check if pet has been visually reset (size returned to normal)
local function isPetVisuallyReset(petModel)
    local id = getPetUniqueId(petModel)
    if not id or not originalPartSizes[id] then return false end
    
    for part, originalSize in pairs(originalPartSizes[id]) do
        if part and part.Parent then
            local expectedSize = originalSize * ENLARGE_SCALE
            local currentSize = part.Size
            -- Check if size is significantly different from expected enlarged size
            if math.abs(currentSize.X - expectedSize.X) > 0.1 then
                return true
            end
        end
    end
    return false
end

-- Deep find Weight NumberValue inside pet model
local function findWeightNumberValue(model)
    for _, obj in ipairs(model:GetDescendants()) do
        if obj.Name:lower() == "weight" and obj:IsA("NumberValue") then
            return obj
        end
    end
    return nil
end

-- Get unique pet ID fallback function
local function getPetUniqueId(petModel)
    if not petModel then return nil end
    return petModel:GetAttribute("PetID") or petModel:GetAttribute("OwnerUserId") or petModel.Name
end

-- Scale pet parts and joints properly
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

    model:SetAttribute("TOCHIPYRO_Enlarged", true)
    model:SetAttribute("TOCHIPYRO_Scale", scaleFactor)
end

-- Increase pet weight in the model and GUI
local function increaseWeight(petModel)
    local weightValue = findWeightNumberValue(petModel)
    if not weightValue then
        warn("[TOCHIPYRO] Could not find Weight NumberValue in pet:", petModel.Name)
        return
    end

    local id = getPetUniqueId(petModel)
    if not id then
        warn("[TOCHIPYRO] Pet missing unique ID, skipping weight update")
        return
    end

    -- Store original weight once
    if not originalWeights[id] then
        originalWeights[id] = weightValue.Value
    end

    local newWeight = originalWeights[id] * WEIGHT_MULTIPLIER
    weightValue.Value = newWeight
    petModel:SetAttribute("Weight", newWeight)
    petModel:SetAttribute("weight", newWeight)

    print(string.format("[TOCHIPYRO] Weight updated from %.2f to %.2f for pet %s", originalWeights[id], newWeight, petModel.Name))

    -- Try to refresh GUI - best effort
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if (gui:IsA("TextLabel") or gui:IsA("TextBox")) and gui.Text:lower():find("kg") then
                gui.Text = string.gsub(gui.Text, "%d+%.?%d*", string.format("%.1f", newWeight))
            end
        end
    end
end

-- Mark pet ID as enlarged for persistence
local function markPetAsEnlarged(petModel)
    local id = getPetUniqueId(petModel)
    if id then
        enlargedPetIds[id] = true
    end
end

-- Monitoring pet to reapply scale + weight when respawned or reequipped
local function startPetMonitor(petModel)
    local id = getPetUniqueId(petModel)
    if not id then return end

    if petUpdateLoops[id] then
        petUpdateLoops[id]:Disconnect()
        petUpdateLoops[id] = nil
    end

    petUpdateLoops[id] = RunService.Heartbeat:Connect(function()
        if not petModel or not petModel.Parent then
            if petUpdateLoops[id] then
                petUpdateLoops[id]:Disconnect()
                petUpdateLoops[id] = nil
            end
            return
        end

        if enlargedPetIds[id] then
            -- Check if pet lost its enlarged attribute OR if visually reset
            local needsReapply = not petModel:GetAttribute("TOCHIPYRO_Enlarged") or isPetVisuallyReset(petModel)
            
            if needsReapply then
                -- Store original sizes before reapplying
                if not originalPartSizes[id] then
                    storeOriginalSizes(petModel)
                end
                -- reapply scale and weight if lost
                scaleModelWithJoints(petModel, ENLARGE_SCALE)
                increaseWeight(petModel)
                print("[TOCHIPYRO] Reapplied enlargement to pet:", petModel.Name)
            end
        end
    end)
end

-- Find currently held pet model (try character descendants & garden slots)
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
                if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") then
                    local owner = obj:GetAttribute("Owner") or obj:GetAttribute("OwnerUserId")
                    if owner == LocalPlayer.Name or owner == tostring(LocalPlayer.UserId) then
                        return obj
                    end
                end
            end
        end
    end

    return nil
end

-- Enlarge current held pet (scale + weight + persist)
local function enlargeCurrentPet()
    local pet = getHeldPet()
    if not pet then
        warn("[TOCHIPYRO] No held pet found to enlarge!")
        return
    end

    -- Store original sizes before enlarging
    storeOriginalSizes(pet)
    scaleModelWithJoints(pet, ENLARGE_SCALE)
    increaseWeight(pet)
    markPetAsEnlarged(pet)
    startPetMonitor(pet)

    print("[TOCHIPYRO] Enlarged pet:", pet.Name)
end

-- Monitor pets added to workspace/garden/pet slots to auto-enlarge if previously marked
local function onPetAdded(pet)
    if not pet:IsA("Model") then return end

    task.wait(0.1) -- allow for initial setup

    local id = getPetUniqueId(pet)
    if not id then return end

    startPetMonitor(pet)

    if enlargedPetIds[id] then
        -- Store original sizes before auto-enlarging
        storeOriginalSizes(pet)
        scaleModelWithJoints(pet, ENLARGE_SCALE)
        increaseWeight(pet)
        print("[TOCHIPYRO] Auto-enlarged pet on spawn:", pet.Name)
    end
end

-- Connect pet add events on containers
local petContainers = {
    workspace,
    workspace:FindFirstChild("Pets"),
    workspace:FindFirstChild("PetSlots"),
    workspace:FindFirstChild("GardenSlots"),
}
for _, container in pairs(petContainers) do
    if container then
        container.ChildAdded:Connect(onPetAdded)
    end
end

-- Character pet add monitoring
local function setupCharacterMonitoring()
    if LocalPlayer.Character then
        LocalPlayer.Character.ChildAdded:Connect(onPetAdded)
    end
end

LocalPlayer.CharacterAdded:Connect(setupCharacterMonitoring)
setupCharacterMonitoring()

-- Create movable GUI with minimize function

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TOCHIPYRO_Script"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 140)
MainFrame.Position = UDim2.new(0, 50, 0, 50) -- Start at top-left instead of center
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true -- Make the frame draggable

-- Title Bar for better dragging experience
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BackgroundTransparency = 0.3
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
TitleBar.Active = true

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0) -- Leave space for minimize button
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "TOCHIPYRO Script"
Title.TextSize = 20
Title.Parent = TitleBar

-- Rainbow text effect
spawn(function()
    while Title and Title.Parent do
        for h = 0, 1, 0.01 do
            if Title and Title.Parent then
                Title.TextColor3 = Color3.fromHSV(h, 1, 1)
                task.wait(0.02)
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

-- Content Frame (what gets hidden/shown)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local SizeButton = Instance.new("TextButton")
SizeButton.Size = UDim2.new(1, -20, 0, 40)
SizeButton.Position = UDim2.new(0, 10, 0, 10)
SizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SizeButton.TextColor3 = Color3.new(1, 1, 1)
SizeButton.Text = "Size Enlarge + Weight"
SizeButton.Font = Enum.Font.GothamBold
SizeButton.TextScaled = true
SizeButton.Parent = ContentFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 60)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Ready to enlarge pets!"
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.TextSize = 14
StatusLabel.TextScaled = true
StatusLabel.Parent = ContentFrame

-- Minimize/Restore functionality
local isMinimized = false
local originalSize = MainFrame.Size

MinimizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        -- Restore
        MainFrame.Size = originalSize
        ContentFrame.Visible = true
        MinimizeButton.Text = "_"
        isMinimized = false
    else
        -- Minimize
        MainFrame.Size = UDim2.new(0, 280, 0, 40)
        ContentFrame.Visible = false
        MinimizeButton.Text = "+"
        isMinimized = true
    end
end)

-- Close functionality
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Button functionality
SizeButton.MouseButton1Click:Connect(function()
    enlargeCurrentPet()
    StatusLabel.Text = "Pet enlarged!"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    
    -- Reset status after 2 seconds
    task.wait(2)
    if StatusLabel and StatusLabel.Parent then
        StatusLabel.Text = "Ready to enlarge pets!"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    end
end)

-- Make the GUI draggable by the title bar
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("[TOCHIPYRO] Pet enlarger with movable GUI loaded!")

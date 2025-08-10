-- TOCHIPYRO Clean Pet Enlarger with Trade Fix for Grow a Garden

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local ENLARGE_SCALE = 1.75
local WEIGHT_MULTIPLIER = 2.5

-- Simple tracking - only what we need
local enlargedPets = {}
local monitorConnections = {}

-- Simple pet ID function
local function getPetId(petModel)
    if not petModel then return nil end
    return petModel:GetAttribute("PetID") or petModel:GetAttribute("OwnerUserId") or petModel.Name .. "_" .. tostring(petModel:GetDebugId())
end

-- Clean weight finding
local function findWeight(model)
    for _, obj in ipairs(model:GetDescendants()) do
        if obj.Name:lower() == "weight" and obj:IsA("NumberValue") then
            return obj
        end
    end
    return nil
end

-- Simple scaling function
local function scalePet(model, scale)
    if model:GetAttribute("TOCHIPYRO_Scaling") then
        return -- Prevent conflicts
    end
    
    model:SetAttribute("TOCHIPYRO_Scaling", true)
    
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Size = obj.Size * scale
        elseif obj:IsA("SpecialMesh") then
            obj.Scale = obj.Scale * scale
        elseif obj:IsA("Motor6D") then
            obj.C0 = CFrame.new(obj.C0.Position * scale) * (obj.C0 - obj.C0.Position)
            obj.C1 = CFrame.new(obj.C1.Position * scale) * (obj.C1 - obj.C1.Position)
        end
    end
    
    model:SetAttribute("TOCHIPYRO_Enlarged", true)
    model:SetAttribute("TOCHIPYRO_Scaling", false)
end

-- Simple weight increase
local function increaseWeight(petModel)
    local weightValue = findWeight(petModel)
    if weightValue then
        local petId = getPetId(petModel)
        if petId and not enlargedPets[petId] then
            enlargedPets[petId] = {
                originalWeight = weightValue.Value,
                enlarged = true
            }
        end
        
        if enlargedPets[petId] then
            weightValue.Value = enlargedPets[petId].originalWeight * WEIGHT_MULTIPLIER
            petModel:SetAttribute("Weight", weightValue.Value)
        end
    end
end

-- Light monitoring - only check every 2 seconds and only for size resets
local function startLightMonitoring(petModel)
    local petId = getPetId(petModel)
    if not petId then return end
    
    -- Clean up existing connection
    if monitorConnections[petId] then
        monitorConnections[petId]:Disconnect()
    end
    
    -- Very light monitoring - only check occasionally
    local lastCheck = tick()
    monitorConnections[petId] = RunService.Heartbeat:Connect(function()
        if not petModel or not petModel.Parent then
            if monitorConnections[petId] then
                monitorConnections[petId]:Disconnect()
                monitorConnections[petId] = nil
            end
            return
        end
        
        -- Only check every 2 seconds to reduce lag
        if tick() - lastCheck < 2 then
            return
        end
        lastCheck = tick()
        
        -- Only check if we know this pet should be enlarged
        if enlargedPets[petId] and enlargedPets[petId].enlarged then
            -- Simple check - if the enlarged attribute is gone, reapply
            if not petModel:GetAttribute("TOCHIPYRO_Enlarged") then
                scalePet(petModel, ENLARGE_SCALE)
                increaseWeight(petModel)
            end
        end
    end)
end

-- Find current held pet - simplified
local function getCurrentPet()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- Check character first
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Model") and obj ~= char and obj:FindFirstChildWhichIsA("BasePart") and not obj:FindFirstChildOfClass("Humanoid") then
            return obj
        end
    end
    
    -- Check workspace pets
    local pets = workspace:FindFirstChild("Pets")
    if pets then
        for _, obj in ipairs(pets:GetChildren()) do
            if obj:IsA("Model") then
                local owner = obj:GetAttribute("Owner") or obj:GetAttribute("OwnerUserId")
                if owner == LocalPlayer.Name or owner == tostring(LocalPlayer.UserId) then
                    return obj
                end
            end
        end
    end
    
    return nil
end

-- Main enlarge function - clean and simple
local function enlargePet()
    local pet = getCurrentPet()
    if not pet then
        return false, "No pet found!"
    end
    
    local petId = getPetId(pet)
    if not petId then
        return false, "Pet has no ID!"
    end
    
    -- Scale the pet
    scalePet(pet, ENLARGE_SCALE)
    
    -- Increase weight
    increaseWeight(pet)
    
    -- Start light monitoring
    startLightMonitoring(pet)
    
    return true, "Pet enlarged: " .. pet.Name
end

-- Simple pet spawn monitoring - only for new pets
local function onNewPet(pet)
    if not pet:IsA("Model") then return end
    
    -- Wait a bit for pet to initialize
    task.wait(0.5)
    
    local petId = getPetId(pet)
    if petId and enlargedPets[petId] and enlargedPets[petId].enlarged then
        -- This pet was enlarged before, re-enlarge it
        scalePet(pet, ENLARGE_SCALE)
        increaseWeight(pet)
        startLightMonitoring(pet)
    end
end

-- Set up minimal monitoring for new pets only
if workspace:FindFirstChild("Pets") then
    workspace.Pets.ChildAdded:Connect(onNewPet)
end

-- Character monitoring
LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(onNewPet)
end)

if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(onNewPet)
end

-- Simple GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TOCHIPYRO_Clean_Script"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 120)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BackgroundTransparency = 0.3
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "TOCHIPYRO Clean"
Title.TextSize = 16
Title.Parent = TitleBar

-- Rainbow effect - simplified
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

-- Close Button only
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

-- Content
local EnlargeButton = Instance.new("TextButton")
EnlargeButton.Size = UDim2.new(1, -20, 0, 35)
EnlargeButton.Position = UDim2.new(0, 10, 0, 45)
EnlargeButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
EnlargeButton.TextColor3 = Color3.new(1, 1, 1)
EnlargeButton.Text = "Enlarge Pet"
EnlargeButton.Font = Enum.Font.GothamBold
EnlargeButton.TextSize = 16
EnlargeButton.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 90)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Ready - Clean version with trade fix"
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.TextSize = 12
StatusLabel.TextScaled = true
StatusLabel.Parent = MainFrame

-- Button functionality
EnlargeButton.MouseButton1Click:Connect(function()
    local success, message = enlargePet()
    StatusLabel.Text = message
    StatusLabel.TextColor3 = success and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    
    -- Reset status after 3 seconds
    task.spawn(function()
        task.wait(3)
        if StatusLabel and StatusLabel.Parent then
            StatusLabel.Text = "Ready - Clean version with trade fix"
            StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        end
    end)
end)

-- Close functionality
CloseButton.MouseButton1Click:Connect(function()
    -- Clean up all connections
    for _, connection in pairs(monitorConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    ScreenGui:Destroy()
end)

print("[TOCHIPYRO] Clean Pet Enlarger loaded - Lightweight version with trade protection")

-- TOCHIPYRO — Local-only Pet Enlarger (draggable UI, full minimize, robust reapply)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

if not LocalPlayer then return end

-- config
local SCALE_FACTOR = 1.75

-- tables
local enlargedTemplates = {}   -- keyed by template name -> scaleFactor
local scaledInstances = {}     -- model instance -> true (to avoid double-scaling)

-- helpers
local function isModelLikelyPet(model)
    if not model or not model:IsA("Model") then return false end
    if model:FindFirstChildOfClass("Humanoid") then return false end
    local partCount = 0
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            partCount = partCount + 1
            if partCount >= 2 then break end
        end
    end
    return partCount >= 2
end

local function safeCFrameScale(cf, scale)
    -- preserve rotation, scale only position
    local pos = cf.Position * scale
    return CFrame.new(pos) * (cf - cf.Position)
end

local function scaleModelWithJoints(model, factor)
    if not model or not model:IsA("Model") then return end
    if scaledInstances[model] then return end

    -- try to choose a deterministic order to reduce weirdness
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("SpecialMesh") then
            pcall(function() obj.Scale = obj.Scale * factor end)
        end
    end

    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            pcall(function() obj.Size = obj.Size * factor end)
        end
    end

    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            local ok, c0, c1 = pcall(function() return obj.C0, obj.C1 end)
            if ok and c0 and c1 then
                pcall(function() obj.C0 = safeCFrameScale(c0, factor) end)
                pcall(function() obj.C1 = safeCFrameScale(c1, factor) end)
            end
        end
    end

    -- mark to avoid double-scaling this same instance
    scaledInstances[model] = true
    pcall(function() model:SetAttribute("TOCHIPYRO_Enlarged", true) end)
end

-- get held pet (tries reasonably hard)
local function getHeldPet()
    local char = LocalPlayer.Character
    if not char then return nil end
    -- prefer models directly under char first
    for _, obj in ipairs(char:GetChildren()) do
        if isModelLikelyPet(obj) then
            return obj
        end
    end
    -- fallback: deeper search
    for _, obj in ipairs(char:GetDescendants()) do
        if isModelLikelyPet(obj) then
            return obj
        end
    end
    -- last resort: nearest model within short radius
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local best, bestDist = nil, math.huge
        for _, m in ipairs(Workspace:GetDescendants()) do
            if isModelLikelyPet(m) then
                local base = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                if base then
                    local d = (base.Position - hrp.Position).Magnitude
                    if d < bestDist and d <= 15 then
                        bestDist, best = d, m
                    end
                end
            end
        end
        return best
    end
    return nil
end

-- apply scaling for any model matching stored template names
local function tryApplyTemplateScale(model)
    if not model or not model:IsA("Model") then return end
    if scaledInstances[model] then return end
    local tname = model.Name
    local factor = enlargedTemplates[tname]
    if factor then
        -- small wait to allow parts to appear
        task.spawn(function()
            task.wait(0.06)
            scaleModelWithJoints(model, factor)
            -- also attempt to mark children so reparenting doesn't re-trigger wrong
        end)
    end
end

-- event: whenever a new descendant appears in workspace, check for template match
Workspace.DescendantAdded:Connect(function(desc)
    -- If it's a Model itself or contained within a Model, find top model
    local model = desc
    while model and not model:IsA("Model") do
        model = model.Parent
    end
    if model and isModelLikelyPet(model) then
        tryApplyTemplateScale(model)
    end
end)

-- GUI: create (destroy existing if present)
local existing = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("TOCHIPYRO_GUI")
if existing then existing:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "TOCHIPYRO_GUI"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 340, 0, 190)
frame.Position = UDim2.new(0.35, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 0
frame.ZIndex = 5

-- TitleBar (use TextButton to capture input for dragging)
local titleBar = Instance.new("TextButton", frame)
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundTransparency = 1
titleBar.AutoButtonColor = false

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "TOCHIPYRO"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextScaled = true
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Rainbow animation
task.spawn(function()
    local t = 0
    while gui.Parent do
        local c = Color3.fromHSV((tick()*0.12) % 1, 1, 1)
        titleLabel.TextColor3 = c
        t += 1
        task.wait(0.06)
    end
end)

-- Minimize & Close buttons (stay visible when minimized)
local btnMin = Instance.new("TextButton", titleBar)
btnMin.Size = UDim2.new(0, 32, 0, 24)
btnMin.Position = UDim2.new(1, -74, 0, 8)
btnMin.Text = "—"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextScaled = true
btnMin.BackgroundColor3 = Color3.fromRGB(255,170,0)

local btnClose = Instance.new("TextButton", titleBar)
btnClose.Size = UDim2.new(0, 32, 0, 24)
btnClose.Position = UDim2.new(1, -36, 0, 8)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextScaled = true
btnClose.BackgroundColor3 = Color3.fromRGB(255,60,60)

-- main content container (so we can hide/show easily)
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Size = UDim2.new(1, -20, 1, -60)
content.Position = UDim2.new(0, 10, 0, 50)
content.BackgroundTransparency = 1

-- Enlarge button
local enlargeBtn = Instance.new("TextButton", content)
enlargeBtn.Size = UDim2.new(1, 0, 0, 40)
enlargeBtn.Position = UDim2.new(0, 0, 0, 0)
enlargeBtn.Text = "Enlarge Held Pet (Local Only)"
enlargeBtn.Font = Enum.Font.SourceSansBold
enlargeBtn.TextScaled = true
enlargeBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)

enlargeBtn.MouseButton1Click:Connect(function()
    local pet = getHeldPet()
    if pet then
        local tname = pet.Name or ("Pet_" .. tostring(math.random(10000)))
        enlargedTemplates[tname] = SCALE_FACTOR
        scaleModelWithJoints(pet, SCALE_FACTOR)
        print("[TOCHIPYRO] Enlarged local held pet:", tname)
    else
        warn("[TOCHIPYRO] No held pet detected.")
    end
end)

-- small spacer and info label
local infoLabel = Instance.new("TextLabel", content)
infoLabel.Size = UDim2.new(1, 0, 0, 24)
infoLabel.Position = UDim2.new(0, 0, 0, 48)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Enlarged pets are local visuals only."
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 14
infoLabel.TextColor3 = Color3.fromRGB(200,200,200)

-- Minimize logic
local minimized = false
local originalSize = frame.Size
btnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- hide content, resize to title only
        content.Visible = false
        frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 40)
    else
        content.Visible = true
        frame.Size = originalSize
    end
end)

-- Close
btnClose.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Draggable titleBar (manual)
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if dragging and dragStart and startPos then
            local delta = input.Position - dragStart
            local newX = startPos.X.Scale
            local newY = startPos.Y.Scale
            local newXOff = startPos.X.Offset + delta.X
            local newYOff = startPos.Y.Offset + delta.Y
            frame.Position = UDim2.new(newX, newXOff, newY, newYOff)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Also try to re-apply scale to any currently existing matching models on load
for _, inst in ipairs(Workspace:GetDescendants()) do
    if inst:IsA("Model") and enlargedTemplates[inst.Name] then
        tryApplyTemplateScale(inst)
    end
end

print("[TOCHIPYRO] UI loaded (draggable + full minimize).")

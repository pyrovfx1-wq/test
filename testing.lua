-- TOCHIPYRO Script (Improved Size Enlarge for Grow a Garden)
-- PlaceId check (Grow a Garden)
if game.PlaceId ~= 126884695634066 then
    warn("This script only works in Grow a Garden.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local SCALE = 1.75
local SCALE_CUBE = SCALE * SCALE * SCALE

-- remove previous TOCHIPYRO if exists
pcall(function()
    local prev = game.CoreGui:FindFirstChild("TOCHIPYRO_Script")
    if prev then prev:Destroy() end
end)

-- Helpers
local function mulVec3(v, s)
    return Vector3.new(v.X * s, v.Y * s, v.Z * s)
end

local function safeGetCustomProps(part)
    local ok, props = pcall(function() return part.CustomPhysicalProperties end)
    if ok and props then
        return props
    end
    return nil
end

local function adjustPhysicalProperties(part, scale)
    -- make mass roughly similar to original by dividing density by scale^3
    local props = safeGetCustomProps(part)
    local density = 1
    local friction = 0.3
    local elasticity = 0
    local frictionWeight = 1
    local elasticityWeight = 1

    if props then
        density = props.Density or density
        friction = props.Friction or friction
        elasticity = props.Elasticity or elasticity
        frictionWeight = props.FrictionWeight or frictionWeight
        elasticityWeight = props.ElasticityWeight or elasticityWeight
    end

    local newDensity = density / (scale * scale * scale)
    pcall(function()
        part.CustomPhysicalProperties = PhysicalProperties.new(newDensity, friction, elasticity, frictionWeight, elasticityWeight)
    end)
    -- ensure it's not marked massless (so physics apply when applicable)
    pcall(function() part.Massless = false end)
end

-- store clone connections so we can clean up later
local activeClones = {}             -- [clone] = connection

-- find candidate models/tools/accessories that likely represent the pet you're holding
local function findHeldPetCandidates()
    local candidates = {}
    local char = LocalPlayer.Character
    if char then
        -- Tools & Accessories in the character (common place for held pets)
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") or v:IsA("Accessory") or v:IsA("Model") then
                table.insert(candidates, v)
            end
        end
    end

    -- Search workspace for models that are welded/attached to your character or have an Owner reference
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            local added = false
            -- Owner ObjectValue pattern
            local ownerObj = obj:FindFirstChild("Owner")
            if ownerObj and ownerObj.Value == LocalPlayer then
                table.insert(candidates, obj); added = true
            end
            if not added then
                -- attribute pattern
                local ownerAttr = obj:GetAttribute("Owner") or obj:GetAttribute("OwnerUserId") or obj:GetAttribute("owner")
                if ownerAttr then
                    if tostring(ownerAttr) == tostring(LocalPlayer.UserId) or tostring(ownerAttr) == LocalPlayer.Name then
                        table.insert(candidates, obj); added = true
                    end
                end
            end
            if not added then
                -- welded to character pattern (WeldConstraint/Weld/Motor6D)
                for _, d in ipairs(obj:GetDescendants()) do
                    if d:IsA("WeldConstraint") or d:IsA("Weld") or d:IsA("Motor6D") then
                        local p0 = d.Part0
                        local p1 = d.Part1
                        if (p0 and p0:IsDescendantOf(char)) or (p1 and p1:IsDescendantOf(char)) then
                            table.insert(candidates, obj)
                            break
                        end
                    end
                end
            end
        end
    end

    return candidates
end

-- fallback: make a client-only visual clone of a model and scale it, then follow original
local function spawnVisualCloneAndFollow(originalModel)
    local ok, clone = pcall(function() return originalModel:Clone() end)
    if not ok or not clone then return nil end

    -- choose a primary part for setting CFrame
    local firstPart
    for _, p in ipairs(clone:GetDescendants()) do
        if p:IsA("BasePart") then
            firstPart = p
            break
        end
    end
    if not firstPart then
        clone:Destroy()
        return nil
    end

    clone.PrimaryPart = firstPart

    -- scale all parts/meshes in the clone
    for _, p in ipairs(clone:GetDescendants()) do
        if p:IsA("SpecialMesh") then
            p.Scale = p.Scale * SCALE
        elseif p:IsA("MeshPart") and p:IsA("BasePart") then
            p.Size = mulVec3(p.Size, SCALE)
        elseif p:IsA("BasePart") then
            p.Size = mulVec3(p.Size, SCALE)
        end
        if p:IsA("BasePart") then
            p.Anchored = true
            p.CanCollide = false
        end
    end

    -- parent clone locally to workspace (client-side in executor environment)
    clone.Parent = workspace
    -- position clone to the original's model frame if possible
    pcall(function()
        local cframe = originalModel:GetModelCFrame()
        if clone.PrimaryPart then
            clone:SetPrimaryPartCFrame(cframe)
        end
    end)

    -- create a RenderStepped connection to keep clone visually aligned with original
    local conn = RunService.RenderStepped:Connect(function()
        local ok2, cframe = pcall(function() return originalModel:GetModelCFrame() end)
        if ok2 and cframe and clone.PrimaryPart then
            clone:SetPrimaryPartCFrame(cframe)
        end
    end)

    activeClones[clone] = conn
    return clone
end

-- attempt to scale in-place; if error or blocked, return false for that model
local function tryScaleModelInPlace(model)
    local scaledAnything = false

    for _, desc in ipairs(model:GetDescendants()) do
        -- SpecialMesh (mesh on a Part) -> scale mesh AND the parent BasePart
        if desc:IsA("SpecialMesh") then
            local parent = desc.Parent
            if parent and parent:IsA("BasePart") then
                local ok = pcall(function()
                    -- store original on the part as attribute (for later toggling if needed)
                    if not parent:GetAttribute("TOCHIPYRO_OrigSize") then
                        parent:SetAttribute("TOCHIPYRO_OrigSize", parent.Size)
                    end
                    parent.Size = mulVec3(parent.Size, SCALE)
                    desc.Scale = desc.Scale * SCALE
                    adjustPhysicalProperties(parent, SCALE)
                end)
                if ok then scaledAnything = true else return false end
            end
        elseif desc:IsA("MeshPart") then
            local ok = pcall(function()
                if not desc:GetAttribute("TOCHIPYRO_OrigSize") then
                    desc:SetAttribute("TOCHIPYRO_OrigSize", desc.Size)
                end
                desc.Size = mulVec3(desc.Size, SCALE)
                adjustPhysicalProperties(desc, SCALE)
            end)
            if ok then scaledAnything = true else return false end
        elseif desc:IsA("BasePart") then
            -- Regular part (no mesh) -> scale size
            local ok = pcall(function()
                if not desc:GetAttribute("TOCHIPYRO_OrigSize") then
                    desc:SetAttribute("TOCHIPYRO_OrigSize", desc.Size)
                end
                desc.Size = mulVec3(desc.Size, SCALE)
                adjustPhysicalProperties(desc, SCALE)
            end)
            if ok then scaledAnything = true else return false end
        end
    end

    return scaledAnything
end

-- main enlarge routine: tries to scale in place; if blocked, uses a client-side clone
local function enlargeHeldPet()
    if not LocalPlayer then return end
    local char = LocalPlayer.Character
    if not char then
        warn("No character found.")
        return
    end

    local candidates = findHeldPetCandidates()
    if #candidates == 0 then
        warn("No held pet candidates found.")
        return
    end

    local anyWorked = false
    for _, cand in ipairs(candidates) do
        local success = false
        -- if candidate is a Tool/Accessory: they usually enclose the mesh parts
        success = pcall(tryScaleModelInPlace, cand)
        if success then
            print("[TOCHIPYRO] Scaled in place:", cand:GetFullName())
            anyWorked = true
        else
            -- fallback to visual clone
            local clone = spawnVisualCloneAndFollow(cand)
            if clone then
                print("[TOCHIPYRO] Spawned client visual clone for:", cand:GetFullName())
                anyWorked = true
            else
                warn("[TOCHIPYRO] Could not scale or clone:", cand:GetFullName())
            end
        end
    end

    if anyWorked then
        print("[TOCHIPYRO] Pet enlarged visually and weight adjusted (where possible).")
    else
        warn("[TOCHIPYRO] No method worked to enlarge held pet.")
    end
end

-- GUI creation (kept simple / same name)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TOCHIPYRO_Script"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Text = "TOCHIPYRO Script"

-- simple rainbow effect for the title
spawn(function()
    while Title and Title.Parent do
        for h = 0, 1, 0.02 do
            Title.TextColor3 = Color3.fromHSV(h, 1, 1)
            task.wait(0.02)
        end
    end
end)

local SizeButton = Instance.new("TextButton", MainFrame)
SizeButton.Size = UDim2.new(0.9, 0, 0, 40)
SizeButton.Position = UDim2.new(0.05, 0, 0.35, 0)
SizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeButton.Font = Enum.Font.GothamBold
SizeButton.TextScaled = true
SizeButton.Text = "Size Enlarge"

SizeButton.MouseButton1Click:Connect(function()
    enlargeHeldPet()
end)

-- More button, More UI, Bypass, Close - same as before (kept minimal)
local MoreButton = Instance.new("TextButton", MainFrame)
MoreButton.Size = UDim2.new(0.9, 0, 0, 40)
MoreButton.Position = UDim2.new(0.05, 0, 0.6, 0)
MoreButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MoreButton.Font = Enum.Font.GothamBold
MoreButton.TextScaled = true
MoreButton.Text = "More"

local MoreFrame = Instance.new("Frame", ScreenGui)
MoreFrame.Size = UDim2.new(0, 250, 0, 150)
MoreFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
MoreFrame.BackgroundTransparency = 0.5
MoreFrame.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
MoreFrame.Visible = false
local UICorner = Instance.new("UICorner", MoreFrame)
UICorner.CornerRadius = UDim.new(0, 15)

local BypassButton = Instance.new("TextButton", MoreFrame)
BypassButton.Size = UDim2.new(0.9, 0, 0, 40)
BypassButton.Position = UDim2.new(0.05, 0, 0.2, 0)
BypassButton.BackgroundColor3 = Color3.fromRGB(90, 0, 90)
BypassButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BypassButton.Font = Enum.Font.GothamBold
BypassButton.TextScaled = true
BypassButton.Text = "Bypass"

local CloseButton = Instance.new("TextButton", MoreFrame)
CloseButton.Size = UDim2.new(0.9, 0, 0, 40)
CloseButton.Position = UDim2.new(0.05, 0, 0.6, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextScaled = true
CloseButton.Text = "Close UI"

BypassButton.MouseButton1Click:Connect(function()
    print("[TOCHIPYRO] Bypass pressed (placeholder).")
end)
CloseButton.MouseButton1Click:Connect(function()
    -- cleanup clones & connections
    for clone, conn in pairs(activeClones) do
        pcall(function() conn:Disconnect() end)
        pcall(function() if clone and clone.Parent then clone:Destroy() end end)
    end
    activeClones = {}
    pcall(function() ScreenGui:Destroy() end)
end)
MoreButton.MouseButton1Click:Connect(function()
    MoreFrame.Visible = not MoreFrame.Visible
end)

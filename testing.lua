-- TOCHIPYRO Diagnostics + Robust Size Enlarge for Grow a Garden
if game.PlaceId ~= 126884695634066 then
    warn("This script only works in Grow a Garden (expected PlaceId 126884695634066).")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local SCALE = 1.75
local MAX_NEAR_DISTANCE = 12 -- studs to consider "nearby"

-- cleanup previous GUI/clones
pcall(function()
    local prev = game.CoreGui:FindFirstChild("TOCHIPYRO_Script")
    if prev then prev:Destroy() end
end)

local activeClones = {} -- [clone] = conn

local function mulVec3(v, s)
    return Vector3.new(v.X * s, v.Y * s, v.Z * s)
end

local function storeOriginal(part)
    -- store original sizes/scale/attachment positions for potential revert
    pcall(function()
        if part:IsA("BasePart") and not part:GetAttribute("TOCHIPYRO_OrigSize") then
            part:SetAttribute("TOCHIPYRO_OrigSize", tostring(part.Size))
        end
        if part:IsA("SpecialMesh") and not part:GetAttribute("TOCHIPYRO_OrigMeshScale") then
            part:SetAttribute("TOCHIPYRO_OrigMeshScale", tostring(part.Scale))
        end
        if part:IsA("MeshPart") and not part:GetAttribute("TOCHIPYRO_OrigSize") then
            part:SetAttribute("TOCHIPYRO_OrigSize", tostring(part.Size))
        end
        if part:IsA("Attachment") and not part:GetAttribute("TOCHIPYRO_OrigPos") then
            part:SetAttribute("TOCHIPYRO_OrigPos", tostring(part.Position))
        end
    end)
end

local function tryScaleInPlace(model)
    local scaled = false
    -- iterate but stop if error on any part (we pcall each operation)
    for _, desc in ipairs(model:GetDescendants()) do
        -- SpecialMesh on a BasePart
        if desc:IsA("SpecialMesh") then
            local parent = desc.Parent
            if parent and parent:IsA("BasePart") then
                local ok = pcall(function()
                    storeOriginal(parent)
                    storeOriginal(desc)
                    -- scale both parent and mesh (some games rely on either)
                    parent.Size = mulVec3(parent.Size, SCALE)
                    desc.Scale = desc.Scale * SCALE
                    scaled = true
                end)
                if not ok then return false end
            end
        elseif desc:IsA("MeshPart") then
            local ok = pcall(function()
                storeOriginal(desc)
                desc.Size = mulVec3(desc.Size, SCALE)
                scaled = true
            end)
            if not ok then return false end
        elseif desc:IsA("BasePart") then
            local ok = pcall(function()
                -- can still scale simple parts (caps, seats, etc.)
                storeOriginal(desc)
                desc.Size = mulVec3(desc.Size, SCALE)
                scaled = true
            end)
            if not ok then return false end
        elseif desc:IsA("Attachment") then
            local ok = pcall(function()
                storeOriginal(desc)
                desc.Position = mulVec3(desc.Position, SCALE)
            end)
            if not ok then return false end
        end
    end

    -- attempt to adjust CustomPhysicalProperties if available
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                local props = part.CustomPhysicalProperties
                if props then
                    part.CustomPhysicalProperties = PhysicalProperties.new(
                        props.Density / (SCALE * SCALE * SCALE),
                        props.Friction,
                        props.Elasticity,
                        props.FrictionWeight,
                        props.ElasticityWeight
                    )
                    part.Massless = false
                end
            end)
        end
    end

    return scaled
end

local function spawnVisualCloneAndFollow(originalModel)
    local ok, clone = pcall(function() return originalModel:Clone() end)
    if not ok or not clone then return nil end

    -- find a primary part
    local primary
    for _, p in ipairs(clone:GetDescendants()) do
        if p:IsA("BasePart") then
            primary = p
            break
        end
    end
    if not primary then clone:Destroy(); return nil end
    clone.PrimaryPart = primary

    -- scale clone parts/meshes & make non-colliding/anchored
    for _, p in ipairs(clone:GetDescendants()) do
        if p:IsA("SpecialMesh") then
            p.Scale = p.Scale * SCALE
        elseif p:IsA("MeshPart") then
            p.Size = mulVec3(p.Size, SCALE)
        elseif p:IsA("BasePart") then
            p.Size = mulVec3(p.Size, SCALE)
            p.Anchored = true
            p.CanCollide = false
        elseif p:IsA("Attachment") then
            p.Position = mulVec3(p.Position, SCALE)
        end
    end

    clone.Parent = workspace

    -- follow original model's GetModelCFrame if available
    local conn = RunService.RenderStepped:Connect(function()
        local ok2, cframe = pcall(function() return originalModel:GetModelCFrame() end)
        if ok2 and cframe and clone.PrimaryPart then
            clone:SetPrimaryPartCFrame(cframe)
        end
    end)
    activeClones[clone] = conn
    return clone
end

-- collect candidate pet models using multiple heuristics
local function collectCandidates()
    local cand = {}
    local added = {}
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    -- 1) Models in workspace with Owner ObjectValue or Owner attribute
    for _, m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Model") then
            local ownerObj = m:FindFirstChild("Owner")
            local ownerAttr = m:GetAttribute and (m:GetAttribute("Owner") or m:GetAttribute("OwnerUserId") or m:GetAttribute("owner"))
            local ownerMatch = (ownerObj and ownerObj.Value == LocalPlayer) or (ownerAttr and (tostring(ownerAttr) == tostring(LocalPlayer.UserId) or tostring(ownerAttr) == LocalPlayer.Name))
            if ownerMatch then
                if not added[m] then cand[#cand+1] = {model = m, reason = "Owner match"}; added[m]=true end
            end
        end
    end

    -- 2) Models welded/connected to character via constraints or welds
    if char then
        for _, m in ipairs(workspace:GetChildren()) do
            if m:IsA("Model") and not m:IsDescendantOf(char) then
                for _, d in ipairs(m:GetDescendants()) do
                    if (d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("Motor6D")) then
                        local p0 = d.Part0; local p1 = d.Part1
                        if (p0 and p0:IsDescendantOf(char)) or (p1 and p1:IsDescendantOf(char)) then
                            if not added[m] then cand[#cand+1] = {model = m, reason = "Welded to character"}; added[m]=true end
                            break
                        end
                    end
                end
            end
        end
    end

    -- 3) Nearby models with mesh parts (within MAX_NEAR_DISTANCE)
    if hrp then
        for _, m in ipairs(workspace:GetChildren()) do
            if m:IsA("Model") and not m:IsDescendantOf(char) then
                local mesh = m:FindFirstChildWhichIsA("MeshPart") or m:FindFirstChildWhichIsA("SpecialMesh")
                local base = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                if mesh and base then
                    local dist = (base.Position - hrp.Position).Magnitude
                    if dist <= MAX_NEAR_DISTANCE then
                        if not added[m] then cand[#cand+1] = {model = m, reason = ("Nearby (%.2f studs)"):format(dist)}; added[m]=true end
                    end
                end
            end
        end
    end

    -- 4) Tools or Accessories parented to character (rare for some pet systems)
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if (v:IsA("Tool") or v:IsA("Accessory") or v:IsA("Model")) and not added[v] then
                -- only add if it contains mesh part
                if v:FindFirstChildWhichIsA("MeshPart") or v:FindFirstChildWhichIsA("SpecialMesh") then
                    cand[#cand+1] = {model = v, reason = "Tool/Accessory in character"}
                    added[v] = true
                end
            end
        end
    end

    return cand
end

-- public functions: detect & enlarge
local function detectAndPrint()
    local list = collectCandidates()
    if #list == 0 then
        print("[TOCHIPYRO] No candidates found by heuristics.")
        return
    end
    print("[TOCHIPYRO] Candidates:")
    for i, entry in ipairs(list) do
        local m = entry.model
        local reason = entry.reason
        local primary = (m.PrimaryPart and m.PrimaryPart.Name) or (m:FindFirstChildWhichIsA("BasePart") and m:FindFirstChildWhichIsA("BasePart").Name) or "no basepart"
        local meshCount = #m:GetDescendants()
        print(("  [%d] %s  | parent=%s  | reason=%s  | primary=%s"):format(i, m:GetFullName(), tostring(m.Parent), reason, primary))
        -- list some mesh types inside model
        for _, d in ipairs(m:GetDescendants()) do
            if d:IsA("MeshPart") then
                print(("      - MeshPart: %s (Size=%s)"):format(d:GetFullName(), tostring(d.Size)))
            elseif d:IsA("SpecialMesh") then
                print(("      - SpecialMesh: %s (Scale=%s)"):format(d:GetFullName(), tostring(d.Scale)))
            end
        end
    end
end

local function enlargeNearestCandidate()
    local candidates = collectCandidates()
    if #candidates == 0 then
        warn("[TOCHIPYRO] No candidates to enlarge.")
        return
    end

    -- pick the best candidate (prefer Owner match, then welded, then nearest)
    table.sort(candidates, function(a,b)
        local priority = {["Owner match"]=3, ["Welded to character"]=2}
        local pa = priority[a.reason] or 1
        local pb = priority[b.reason] or 1
        if pa == pb then
            -- fallback to distance if both near
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and a.model.PrimaryPart and b.model.PrimaryPart then
                return (a.model.PrimaryPart.Position - hrp.Position).Magnitude < (b.model.PrimaryPart.Position - hrp.Position).Magnitude
            end
            return a.reason < b.reason
        end
        return pa > pb
    end)

    for _, entry in ipairs(candidates) do
        local m = entry.model
        -- attempt in-place scale
        local ok, result = pcall(function() return tryScaleInPlace(m) end)
        if ok and result then
            print("[TOCHIPYRO] Scaled in place:", m:GetFullName(), " reason=", entry.reason)
            return
        else
            -- fallback to visual clone
            local clone = spawnVisualCloneAndFollow(m)
            if clone then
                print("[TOCHIPYRO] Visual clone shown for:", m:GetFullName(), " reason=", entry.reason)
                return
            else
                warn("[TOCHIPYRO] Could not scale or clone:", m:GetFullName())
            end
        end
    end
    warn("[TOCHIPYRO] All candidates failed to be enlarged.")
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "TOCHIPYRO_Script"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 220)
frame.Position = UDim2.new(0.35, 0, 0.35, 0)
frame.BackgroundTransparency = 0.5
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Parent = gui

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,48)
title.BackgroundTransparency = 1
title.Text = "TOCHIPYRO Script"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

task.spawn(function()
    while title.Parent do
        for h=0,1,0.02 do
            title.TextColor3 = Color3.fromHSV(h,1,1)
            task.wait(0.02)
        end
    end
end)

local detectBtn = Instance.new("TextButton", frame)
detectBtn.Position = UDim2.new(0.05,0,0,56)
detectBtn.Size = UDim2.new(0.9,0,0,36)
detectBtn.Text = "Detect"
detectBtn.TextScaled = true
detectBtn.Parent = frame

local sizeBtn = Instance.new("TextButton", frame)
sizeBtn.Position = UDim2.new(0.05,0,0,100)
sizeBtn.Size = UDim2.new(0.9,0,0,36)
sizeBtn.Text = "Size Enlarge"
sizeBtn.TextScaled = true
sizeBtn.Parent = frame

local infoLbl = Instance.new("TextLabel", frame)
infoLbl.Position = UDim2.new(0.05,0,0,144)
infoLbl.Size = UDim2.new(0.9,0,0,64)
infoLbl.Text = "Pick up or stand near pet, click Detect then Size Enlarge. Check executor output for logs."
infoLbl.TextWrapped = true
infoLbl.TextScaled = false
infoLbl.BackgroundTransparency = 1
infoLbl.TextColor3 = Color3.fromRGB(220,220,220)

local cleanupBtn = Instance.new("TextButton", frame)
cleanupBtn.Position = UDim2.new(0.05,0,0,176)
cleanupBtn.Size = UDim2.new(0.44,0,0,28)
cleanupBtn.Text = "Clear Clones"
cleanupBtn.TextScaled = true
cleanupBtn.Parent = frame

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Position = UDim2.new(0.51,0,0,176)
closeBtn.Size = UDim2.new(0.44,0,0,28)
closeBtn.Text = "Close UI"
closeBtn.TextScaled = true
closeBtn.Parent = frame

detectBtn.MouseButton1Click:Connect(function()
    detectAndPrint()
end)
sizeBtn.MouseButton1Click:Connect(function()
    enlargeNearestCandidate()
end)

cleanupBtn.MouseButton1Click:Connect(function()
    for clone, conn in pairs(activeClones) do
        pcall(function() conn:Disconnect() end)
        pcall(function() if clone and clone.Parent then clone:Destroy() end end)
    end
    activeClones = {}
    print("[TOCHIPYRO] Cleared visual clones.")
end)

closeBtn.MouseButton1Click:Connect(function()
    -- cleanup clones first
    for clone, conn in pairs(activeClones) do
        pcall(function() conn:Disconnect() end)
        pcall(function() if clone and clone.Parent then clone:Destroy() end end)
    end
    activeClones = {}
    pcall(function() gui:Destroy() end)
end)

print("[TOCHIPYRO] Ready. Use Detect then Size Enlarge. If still not working, paste the executor output here.")

-- TOCHIPYRO Diagnostics + Robust Held-Pet Enlarge
-- Paste this into your executor while inside the Grow a Garden session.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local SCALE = 1.75
local MAX_NEAR = 15

-- Create GUI parented to PlayerGui (more reliable for showing in-game)
local parentGui = LocalPlayer:FindFirstChild("PlayerGui") or game.CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "TOCHIPYRO_Diag"
gui.ResetOnSpawn = false
gui.Parent = parentGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 380, 0, 220)
frame.Position = UDim2.new(0.5, -190, 0.5, -110)
frame.BackgroundTransparency = 0.45
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "TOCHIPYRO — Detect & Enlarge"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)

local detectBtn = Instance.new("TextButton", frame)
detectBtn.Size = UDim2.new(0.48, -10, 0, 44)
detectBtn.Position = UDim2.new(0, 10, 0, 50)
detectBtn.Text = "Detect"
detectBtn.Font = Enum.Font.Gotham
detectBtn.TextScaled = true

local enlargeBtn = Instance.new("TextButton", frame)
enlargeBtn.Size = UDim2.new(0.48, -10, 0, 44)
enlargeBtn.Position = UDim2.new(0.52, 0, 0, 50)
enlargeBtn.Text = "Size Enlarge"
enlargeBtn.Font = Enum.Font.Gotham
enlargeBtn.TextScaled = true

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1, -20, 0, 88)
info.Position = UDim2.new(0, 10, 0, 104)
info.BackgroundTransparency = 1
info.TextWrapped = true
info.Text = "Steps: 1) Pick up a pet. 2) Click Detect → copy console output here. 3) Click Size Enlarge."
info.TextColor3 = Color3.fromRGB(220,220,220)
info.Font = Enum.Font.Gotham
info.TextSize = 14

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(1, -20, 0, 28)
closeBtn.Position = UDim2.new(0, 10, 1, -36)
closeBtn.Text = "Close UI"
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextScaled = true

-- Helper to safely print limited info (avoid huge dumps)
local function safePrintLine(...)
    local t = {}
    for i=1, select("#", ...) do
        local v = select(i, ...)
        table.insert(t, tostring(v))
    end
    print(table.concat(t, " "))
end

-- Diagnostic collector
local function runDetect()
    pcall(function()
        safePrintLine("=== TOCHIPYRO DETECT ===")
        safePrintLine("PlaceId:", game.PlaceId)
        safePrintLine("Player:", LocalPlayer.Name, "UserId:", LocalPlayer.UserId)
        safePrintLine("GUI parent:", gui.Parent and gui.Parent:GetFullName() or "nil")
        safePrintLine("PlayerGui children:")
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _,c in ipairs(pg:GetChildren()) do
                safePrintLine("  -", c.Name, c.ClassName)
            end
        else
            safePrintLine("  - PlayerGui not found")
        end

        -- Character listing (short)
        local char = LocalPlayer.Character
        if char then
            safePrintLine("Character children (top-level):")
            for _,c in ipairs(char:GetChildren()) do
                safePrintLine("  -", c.Name, c.ClassName)
            end
        else
            safePrintLine("Character not found")
        end

        -- Look for Owner ObjectValues or Owner attributes in workspace
        safePrintLine("Searching workspace for Owner ObjectValue / owner attribute:")
        local foundOwner = false
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ObjectValue") and (v.Name == "Owner" or v.Name == "owner") and v.Value == LocalPlayer then
                safePrintLine("  Owner ObjectValue -> model:", v.Parent:GetFullName())
                foundOwner = true
            end
            if v:IsA("Instance") and v:GetAttribute and (v:GetAttribute("Owner") or v:GetAttribute("owner") or v:GetAttribute("OwnerUserId")) then
                local a = v:GetAttribute("Owner") or v:GetAttribute("owner") or v:GetAttribute("OwnerUserId")
                if tostring(a) == tostring(LocalPlayer.UserId) or tostring(a) == LocalPlayer.Name then
                    safePrintLine("  Owner attr -> model:", v:GetFullName())
                    foundOwner = true
                end
            end
        end
        if not foundOwner then safePrintLine("  (none found)") end

        -- Find models welded to character
        safePrintLine("Searching for welded/attached models (Weld/WeldConstraint/Motor6D):")
        local printed = {}
        for _,inst in ipairs(workspace:GetDescendants()) do
            if inst:IsA("Weld") or inst:IsA("WeldConstraint") or inst:IsA("Motor6D") then
                local p0 = inst.Part0
                local p1 = inst.Part1
                if (p0 and p0:IsDescendantOf(char)) or (p1 and p1:IsDescendantOf(char)) then
                    local modelCandidate = p0 and p0.Parent or p1 and p1.Parent
                    -- climb up to model if needed
                    while modelCandidate and not modelCandidate:IsA("Model") do modelCandidate = modelCandidate.Parent end
                    if modelCandidate and not printed[modelCandidate] then
                        printed[modelCandidate] = true
                        safePrintLine("  Welded model:", modelCandidate:GetFullName())
                    end
                end
            end
        end

        -- Nearby mesh models
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            safePrintLine("Nearby mesh models within", MAX_NEAR, "studs:")
            for _,m in ipairs(workspace:GetDescendants()) do
                if m:IsA("Model") and not m:IsDescendantOf(char) then
                    local base = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                    if base then
                        local dist = (base.Position - hrp.Position).Magnitude
                        if dist <= MAX_NEAR and (m:FindFirstChildWhichIsA("MeshPart") or m:FindFirstChildWhichIsA("SpecialMesh")) then
                            safePrintLine("  Nearby:", m:GetFullName(), "dist:", string.format("%.2f", dist))
                        end
                    end
                end
            end
        else
            safePrintLine("HumanoidRootPart not found (can't check nearby).")
        end

        -- Tools in character
        safePrintLine("Tools / Accessories in Character:")
        if char then
            for _,c in ipairs(char:GetChildren()) do
                if c:IsA("Tool") or c:IsA("Accessory") then
                    safePrintLine("  -", c.Name, c.ClassName, " children:", #c:GetDescendants())
                end
            end
        end

        safePrintLine("=== END DETECT ===")
    end)
end

-- Try to find the held pet model using multiple heuristics
local function findHeldPetModel()
    local char = LocalPlayer.Character
    if not char then return nil, "no character" end

    -- 1) Welded models to character parts (most reliable)
    for _,inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("Weld") or inst:IsA("WeldConstraint") or inst:IsA("Motor6D") then
            local p0, p1 = inst.Part0, inst.Part1
            if p0 and p0:IsDescendantOf(char) and p1 and p1.Parent then
                local model = p1.Parent
                while model and not model:IsA("Model") do model = model.Parent end
                if model and not model:IsDescendantOf(char) then return model, "weld_Part1_parent" end
            end
            if p1 and p1:IsDescendantOf(char) and p0 and p0.Parent then
                local model = p0.Parent
                while model and not model:IsA("Model") do model = model.Parent end
                if model and not model:IsDescendantOf(char) then return model, "weld_Part0_parent" end
            end
        end
    end

    -- 2) Owner ObjectValue or owner attribute in workspace
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ObjectValue") and (v.Name=="Owner" or v.Name=="owner") and v.Value == LocalPlayer then
            return v.Parent, "owner_objectvalue"
        end
        if v.GetAttribute then
            local a = v:GetAttribute("Owner") or v:GetAttribute("owner") or v:GetAttribute("OwnerUserId")
            if a and (tostring(a) == tostring(LocalPlayer.UserId) or tostring(a) == LocalPlayer.Name) then
                return v, "owner_attribute"
            end
        end
    end

    -- 3) Models parented to character (rare) - find model descendants inside char that are not player limbs
    for _,m in ipairs(char:GetDescendants()) do
        if m:IsA("Model") and not m:FindFirstChildOfClass("Humanoid") then
            return m, "model_under_character"
        end
    end

    -- 4) Nearby mesh model fallback (closest mesh model)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local best, bestDist = nil, math.huge
    if hrp then
        for _,m in ipairs(workspace:GetDescendants()) do
            if m:IsA("Model") and not m:IsDescendantOf(char) then
                local base = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                if base and (m:FindFirstChildWhichIsA("MeshPart") or m:FindFirstChildWhichIsA("SpecialMesh")) then
                    local d = (base.Position - hrp.Position).Magnitude
                    if d < bestDist and d <= MAX_NEAR then
                        bestDist = d
                        best = m
                    end
                end
            end
        end
        if best then return best, "nearest_mesh_fallback" end
    end

    return nil, "not_found"
end

-- Attempt in-place scaling (MeshPart / SpecialMesh / BasePart / Attachment)
local function tryScaleInPlace(model)
    local scaled = false
    for _,desc in ipairs(model:GetDescendants()) do
        if desc:IsA("SpecialMesh") then
            local ok, _ = pcall(function()
                desc.Scale = desc.Scale * SCALE
            end)
            if ok then scaled = true else return false end
        elseif desc:IsA("MeshPart") then
            local ok, _ = pcall(function()
                desc.Size = desc.Size * SCALE
            end)
            if ok then scaled = true else return false end
        elseif desc:IsA("BasePart") then
            local ok, _ = pcall(function()
                desc.Size = desc.Size * SCALE
            end)
            if ok then scaled = true else return false end
        elseif desc:IsA("Attachment") then
            pcall(function() desc.Position = desc.Position * SCALE end)
        end
    end
    return scaled
end

-- Fallback: client-side visual clone that follows original (anchored)
local activeClones = {}
local function spawnVisualClone(original)
    local ok, clone = pcall(function() return original:Clone() end)
    if not ok or not clone then return nil end
    -- find a primary part
    local primary
    for _,p in ipairs(clone:GetDescendants()) do
        if p:IsA("BasePart") then primary = p; break end
    end
    if not primary then clone:Destroy(); return nil end
    clone.PrimaryPart = primary
    for _,p in ipairs(clone:GetDescendants()) do
        if p:IsA("SpecialMesh") then p.Scale = p.Scale * SCALE
        elseif p:IsA("MeshPart") then p.Size = p.Size * SCALE
        elseif p:IsA("BasePart") then p.Size = p.Size * SCALE; p.Anchored = true; p.CanCollide = false
        elseif p:IsA("Attachment") then p.Position = p.Position * SCALE end
    end
    clone.Parent = workspace
    local conn = RunService.RenderStepped:Connect(function()
        local ok2, cframe = pcall(function() return original:GetModelCFrame() end)
        if ok2 and cframe and clone.PrimaryPart then
            clone:SetPrimaryPartCFrame(cframe)
        end
    end)
    activeClones[clone] = conn
    return clone
end

-- Enlarge handler
local function enlargeHeldPet()
    local pet, reason = findHeldPetModel()
    if not pet then
        safePrintLine("[TOCHIPYRO] No held pet found (reason:", reason .. ")")
        return
    end
    safePrintLine("[TOCHIPYRO] Candidate pet:", pet:GetFullName(), "reason:", reason)
    local ok, scaled = pcall(function() return tryScaleInPlace(pet) end)
    if ok and scaled then
        safePrintLine("[TOCHIPYRO] Scaled in place:", pet:GetFullName())
        return
    end
    -- fallback clone
    local clone = spawnVisualClone(pet)
    if clone then
        safePrintLine("[TOCHIPYRO] Spawned visual clone for:", pet:GetFullName())
        return
    end
    safePrintLine("[TOCHIPYRO] All methods failed for:", pet:GetFullName())
end

-- wire buttons
detectBtn.MouseButton1Click:Connect(runDetect)
enlargeBtn.MouseButton1Click:Connect(enlargeHeldPet)
closeBtn.MouseButton1Click:Connect(function()
    for cl,conn in pairs(activeClones) do
        pcall(function() conn:Disconnect() end)
        pcall(function() if cl and cl.Parent then cl:Destroy() end end)
    end
    gui:Destroy()
end)

print("[TOCHIPYRO] GUI loaded. Click Detect, then pick up a pet and click Size Enlarge. Paste Detect output if it still fails.")

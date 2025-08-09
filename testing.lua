-- TOCHIPYRO: PlaceId-printing + Robust Held-Pet Enlarge (no PlaceId guard)
-- Paste into your executor while in the game session you want to test.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    error("LocalPlayer not found (run in Roblox client with executor).")
end

-- Immediately print PlaceId so we know which place you're in
print("[TOCHIPYRO] Current PlaceId:", game.PlaceId, "  |  UniverseId:", tostring(game.GameId or game:GetService("MarketplaceService") and nil))

-- UI parent: prefer PlayerGui, fallback to CoreGui (some executors require CoreGui)
local parentGui = LocalPlayer:FindFirstChild("PlayerGui") or game.CoreGui

-- Cleanup previous GUI if present
pcall(function()
    local existing = parentGui:FindFirstChild("TOCHIPYRO_Diag")
    if existing then existing:Destroy() end
end)

-- Settings
local SCALE = 1.75
local MAX_NEAR = 15

-- Safe print helper
local function safePrintLine(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts+1] = tostring(select(i, ...)) end
    print(table.concat(parts, " "))
end

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "TOCHIPYRO_Diag"
gui.ResetOnSpawn = false
gui.Parent = parentGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 420, 0, 240)
frame.Position = UDim2.new(0.5, -210, 0.5, -120)
frame.BackgroundTransparency = 0.45
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,44)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "TOCHIPYRO — Detect & Enlarge"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)

local detectBtn = Instance.new("TextButton", frame)
detectBtn.Size = UDim2.new(0.48, -10, 0, 48)
detectBtn.Position = UDim2.new(0, 10, 0, 54)
detectBtn.Text = "Detect"
detectBtn.Font = Enum.Font.Gotham
detectBtn.TextScaled = true

local enlargeBtn = Instance.new("TextButton", frame)
enlargeBtn.Size = UDim2.new(0.48, -10, 0, 48)
enlargeBtn.Position = UDim2.new(0.52, 0, 0, 54)
enlargeBtn.Text = "Size Enlarge"
enlargeBtn.Font = Enum.Font.Gotham
enlargeBtn.TextScaled = true

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1, -20, 0, 96)
info.Position = UDim2.new(0, 10, 0, 110)
info.BackgroundTransparency = 1
info.TextWrapped = true
info.Text = "Steps: 1) Pick up a pet. 2) Click Detect → copy console output here. 3) Click Size Enlarge."
info.TextColor3 = Color3.fromRGB(220,220,220)
info.Font = Enum.Font.Gotham
info.TextSize = 14

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(1, -20, 0, 30)
closeBtn.Position = UDim2.new(0, 10, 1, -40)
closeBtn.Text = "Close UI"
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextScaled = true

-- Helpers for detecting pet
local function collectWeldedModels(char)
    local found = {}
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("Weld") or inst:IsA("WeldConstraint") or inst:IsA("Motor6D") then
            local p0, p1 = inst.Part0, inst.Part1
            if (p0 and p0:IsDescendantOf(char)) or (p1 and p1:IsDescendantOf(char)) then
                -- determine the other side's model
                local other = nil
                if p0 and p0:IsDescendantOf(char) and p1 and p1.Parent then other = p1.Parent end
                if p1 and p1:IsDescendantOf(char) and p0 and p0.Parent then other = p0.Parent end
                while other and not other:IsA("Model") do other = other.Parent end
                if other and not other:IsDescendantOf(char) then found[other] = true end
            end
        end
    end
    local list = {}
    for m,_ in pairs(found) do table.insert(list, m) end
    return list
end

local function findOwnerTaggedModels()
    local list = {}
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ObjectValue") and (v.Name == "Owner" or v.Name == "owner") and v.Value == LocalPlayer then
            table.insert(list, v.Parent)
        end
        if v.GetAttribute then
            local a = v:GetAttribute("Owner") or v:GetAttribute("owner") or v:GetAttribute("OwnerUserId")
            if a and (tostring(a) == tostring(LocalPlayer.UserId) or tostring(a) == LocalPlayer.Name) then
                table.insert(list, v)
            end
        end
    end
    return list
end

local function nearbyMeshModels(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    local out = {}
    for _,m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Model") and not m:IsDescendantOf(char) then
            local base = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
            if base and (m:FindFirstChildWhichIsA("MeshPart") or m:FindFirstChildWhichIsA("SpecialMesh")) then
                local d = (base.Position - hrp.Position).Magnitude
                if d <= MAX_NEAR then out[#out+1] = {model = m, dist = d} end
            end
        end
    end
    table.sort(out, function(a,b) return a.dist < b.dist end)
    local res = {}
    for _,e in ipairs(out) do res[#res+1] = e.model end
    return res
end

-- Attempt to pick a candidate pet (prioritize welded -> owner tag -> nearby)
local function findHeldPetModel()
    local char = LocalPlayer.Character
    if not char then return nil, "no character" end

    local welded = collectWeldedModels(char)
    if #welded > 0 then return welded[1], "welded_to_char" end

    local ownerTagged = findOwnerTaggedModels()
    if #ownerTagged > 0 then return ownerTagged[1], "owner_tag" end

    local underChar = {}
    for _,desc in ipairs(char:GetDescendants()) do
        if desc:IsA("Model") and not desc:FindFirstChildOfClass("Humanoid") then table.insert(underChar, desc) end
    end
    if #underChar > 0 then return underChar[1], "model_under_char" end

    local nearby = nearbyMeshModels(char)
    if #nearby > 0 then return nearby[1], "nearby_mesh" end

    return nil, "not_found"
end

-- Try in-place scaling (MeshPart/SpecialMesh/BasePart/Attachment)
local function tryScaleInPlace(model)
    local scaled = false
    for _,desc in ipairs(model:GetDescendants()) do
        if desc:IsA("SpecialMesh") then
            local ok = pcall(function() desc.Scale = desc.Scale * SCALE end)
            if ok then scaled = true else return false end
        elseif desc:IsA("MeshPart") then
            local ok = pcall(function() desc.Size = desc.Size * SCALE end)
            if ok then scaled = true else return false end
        elseif desc:IsA("BasePart") then
            local ok = pcall(function() desc.Size = desc.Size * SCALE end)
            if ok then scaled = true else return false end
        elseif desc:IsA("Attachment") then
            pcall(function() desc.Position = desc.Position * SCALE end)
        end
    end
    return scaled
end

-- fallback: visual client-only clone that follows original
local activeClones = {}
local function spawnVisualCloneAndFollow(originalModel)
    local ok, clone = pcall(function() return originalModel:Clone() end)
    if not ok or not clone then return nil end
    -- pick first BasePart as primary
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
        local ok2, cframe = pcall(function() return originalModel:GetModelCFrame() end)
        if ok2 and cframe and clone.PrimaryPart then clone:SetPrimaryPartCFrame(cframe) end
    end)
    activeClones[clone] = conn
    return clone
end

-- Enlarge action
local function enlargeHeldPet()
    local pet, reason = findHeldPetModel()
    if not pet then safePrintLine("[TOCHIPYRO] No held pet found (", reason, ")"); return end
    safePrintLine("[TOCHIPYRO] Candidate:", pet:GetFullName(), "reason:", reason)
    local ok, worked = pcall(function() return tryScaleInPlace(pet) end)
    if ok and worked then
        safePrintLine("[TOCHIPYRO] Scaled in place:", pet:GetFullName()); return
    end
    local clone = spawnVisualCloneAndFollow(pet)
    if clone then safePrintLine("[TOCHIPYRO] Visual clone shown for:", pet:GetFullName()); return end
    safePrintLine("[TOCHIPYRO] Failed to enlarge:", pet:GetFullName())
end

-- Detect / Print diagnostics
local function runDetect()
    pcall(function()
        safePrintLine("=== TOCHIPYRO DETECT ===")
        safePrintLine("PlaceId:", game.PlaceId)
        safePrintLine("Player:", LocalPlayer.Name, "UserId:", LocalPlayer.UserId)
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        safePrintLine("PlayerGui present:", tostring(pg ~= nil))
        -- top-level character children
        local char = LocalPlayer.Character
        if char then
            safePrintLine("Character top-level children:")
            for _,c in ipairs(char:GetChildren()) do safePrintLine("  -", c.Name, c.ClassName) end
        else safePrintLine("Character not found") end
        -- welded models
        safePrintLine("Welded / attached models found (short list):")
        for _,m in ipairs(collectWeldedModels(char)) do safePrintLine("  -", m:GetFullName()) end
        -- owner-tagged
        safePrintLine("Owner-tagged models (short list):")
        for _,m in ipairs(findOwnerTaggedModels()) do safePrintLine("  -", (m and m:GetFullName()) or tostring(m)) end
        -- nearby mesh models
        safePrintLine("Nearby mesh models (short list):")
        for _,m in ipairs(nearbyMeshModels(char)) do safePrintLine("  -", m:GetFullName()) end
        safePrintLine("=== END DETECT ===")
    end)
end

-- Buttons
detectBtn.MouseButton1Click:Connect(runDetect)
enlargeBtn.MouseButton1Click:Connect(function()
    -- ensure character is loaded
    if not LocalPlayer.Character then safePrintLine("[TOCHIPYRO] Character not loaded yet.") return end
    enlargeHeldPet()
end)
closeBtn.MouseButton1Click:Connect(function()
    for cl,conn in pairs(activeClones) do
        pcall(function() conn:Disconnect() end)
        pcall(function() if cl and cl.Parent then cl:Destroy() end end)
    end
    gui:Destroy()
end)

safePrintLine("[TOCHIPYRO] Ready. Click Detect, then pick up a pet and click Size Enlarge.")

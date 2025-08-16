-- TOCHIPYRO — Grow a Garden UI (visual-only)
-- Delta/Syn/KRNL safe. Purely cosmetic: changes "Every 6.57m" -> "Every 0.15m" in Pet Loadout view text.
-- If you want to hard-lock to a place, add a PlaceId check yourself.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- choose best parent for exploit UIs
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")

----------------------------------------------------------------
-- UI
----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TOCHIPYRO_UI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = parentGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 320, 0, 220)
main.Position = UDim2.new(0.5, -160, 0.5, -110)
main.BackgroundColor3 = Color3.new(0, 0, 0)
main.BackgroundTransparency = 0.5 -- 50%
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -40, 0, 34)
title.Position = UDim2.new(0, 10, 0, 6)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.Text = "TOCHIPYRO"
title.Parent = main

-- rainbow
task.spawn(function()
    local h = 0
    while screenGui.Parent do
        h = (h + 0.01) % 1
        title.TextColor3 = Color3.fromHSV(h, 1, 1)
        task.wait(0.05)
    end
end)

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -36, 0, 4)
minimize.Text = "-"
minimize.TextScaled = true
minimize.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimize.Parent = main

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        main.Size = UDim2.new(0, 320, 0, 44)
    else
        main.Size = UDim2.new(0, 320, 0, 220)
    end
end)

local function makeBtn(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.86, 0, 0, 44)
    b.Position = UDim2.new(0.07, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    b.TextColor3 = Color3.fromRGB(230, 230, 230)
    b.Font = Enum.Font.SourceSansBold
    b.TextScaled = true
    b.Text = text
    b.Parent = main
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 10)
    return b
end)

----------------------------------------------------------------
-- VISUAL-ONLY COOLDOWN REWRITER
----------------------------------------------------------------
local reduceEnabled = false
local originals = setmetatable({}, {__mode = "k"}) -- weak keys: TextLabel -> original text
local watched = setmetatable({}, {__mode = "k"})   -- TextLabel -> connection

-- keywords to help target Pet Loadout / Pet View hierarchy
local TARGET_KEYWORDS = {"loadout","pet","view","petview"}

local function nameHasKeyword(inst)
    local n = inst.Name and inst.Name:lower() or ""
    for _,kw in ipairs(TARGET_KEYWORDS) do
        if n:find(kw) then return true end
    end
    return false
end

local function isInTargetArea(inst)
    local cur, depth = inst, 0
    while cur and depth < 8 do
        if nameHasKeyword(cur) then return true end
        cur = cur.Parent
        depth += 1
    end
    return false
end

-- change "Every 6.57m" / "Every 6:57m" / "Every 2h" etc. to "Every 0.15m"
local function rewriteText(s)
    local new = s
    new = new:gsub("Every%s*[%d%d:%.]+%s*[smhd]", "Every 0.15m")
    new = new:gsub("every%s*[%d%d:%.]+%s*[smhd]", "every 0.15m")
    return new
end

local function looksLikeCooldownLine(s)
    local lower = string.lower(s)
    if not lower:find("every") then return false end
    -- has a time token like 6.57m or 6:57m or 2h
    return lower:find("[%d:%.]+%s*[smhd]") ~= nil
end

local function processLabel(lbl)
    if not lbl or not lbl:IsA("TextLabel") then return end
    if not isInTargetArea(lbl) then return end

    -- attach watcher once
    if not watched[lbl] then
        watched[lbl] = lbl:GetPropertyChangedSignal("Text"):Connect(function()
            if reduceEnabled and looksLikeCooldownLine(lbl.Text) then
                if not originals[lbl] then originals[lbl] = lbl.Text end
                lbl.Text = rewriteText(lbl.Text)
            end
        end)
        lbl.AncestryChanged:Connect(function(_, parent)
            if not parent then
                -- clean up
                if watched[lbl] then
                    pcall(function() watched[lbl]:Disconnect() end)
                    watched[lbl] = nil
                end
                originals[lbl] = nil
            end
        end)
    end

    if reduceEnabled and looksLikeCooldownLine(lbl.Text) then
        if not originals[lbl] then originals[lbl] = lbl.Text end
        lbl.Text = rewriteText(lbl.Text)
    end
end

local function scanAll()
    for _, d in ipairs(PlayerGui:GetDescendants()) do
        if d:IsA("TextLabel") then processLabel(d) end
    end
end

-- react to new GUI becoming visible (like opening Pet Loadout view)
local descConn = PlayerGui.DescendantAdded:Connect(function(obj)
    if obj:IsA("TextLabel") then
        -- tiny delay to let game set the text first
        task.defer(function() processLabel(obj) end)
    end
end)

-- periodic refresher (in case the game rewrites the text each frame)
task.spawn(function()
    while screenGui.Parent do
        if reduceEnabled then scanAll() end
        task.wait(0.3)
    end
end)

-- toggle behavior
local function restoreAll()
    for lbl, original in pairs(originals) do
        if lbl and lbl.Parent and type(original) == "string" then
            lbl.Text = original
        end
    end
    table.clear(originals)
end

reduceBtn.MouseButton1Click:Connect(function()
    reduceEnabled = not reduceEnabled
    reduceBtn.Text = "Reduce Cooldown: " .. (reduceEnabled and "ON" or "OFF")
    if reduceEnabled then
        scanAll()
    else
        restoreAll()
    end
end)

-- Dragging system
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
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

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- initial quick pass (in case Pet Loadout is already open)
scanAll()

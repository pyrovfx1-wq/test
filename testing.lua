-- TOCHIPYRO UI Script (Grow a Garden Only)
-- Works on any Roblox Executor
-- Fake visual cooldown on pet panel

if game.PlaceId ~= 126884695634066 then -- Replace with Grow a Garden place ID
    warn("TOCHIPYRO only works on Grow a Garden!")
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TOCHIPYRO_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.5
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true

-- Round corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = mainFrame

-- Title Bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "TOCHIPYRO"
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.Parent = mainFrame

-- Rainbow title effect
task.spawn(function()
    local hue = 0
    while task.wait(0.05) do
        hue = (hue + 0.01) % 1
        title.TextColor3 = Color3.fromHSV(hue, 1, 1)
    end
end)

-- Minimize button
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -30, 0, 0)
minimize.Text = "-"
minimize.TextScaled = true
minimize.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimize.Parent = mainFrame

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        mainFrame.Size = UDim2.new(0, 300, 0, 30)
    else
        mainFrame.Size = UDim2.new(0, 300, 0, 200)
    end
end)

-- Fake cooldown visual handler
local reduceEnabled = false
local function addFakeCooldown(petButton)
    if not petButton then return end
    local fakeBar = petButton:FindFirstChild("FakeCooldown")
    if fakeBar then fakeBar:Destroy() end

    local bar = Instance.new("Frame")
    bar.Name = "FakeCooldown"
    bar.Size = UDim2.new(1, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bar.BackgroundTransparency = 0.5
    bar.ZIndex = 10
    bar.Parent = petButton

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(1, 0, 1, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.TextColor3 = Color3.new(1, 1, 1)
    timerLabel.Font = Enum.Font.SourceSansBold
    timerLabel.TextScaled = true
    timerLabel.Text = "15"
    timerLabel.ZIndex = 11
    timerLabel.Parent = bar

    -- Countdown visually from 15 → 0
    task.spawn(function()
        for i = 15, 0, -1 do
            if not bar.Parent then return end
            timerLabel.Text = tostring(i)
            task.wait(1)
        end
        bar:Destroy()
    end)
end

-- Reduce Cooldown Button (Toggle)
local reduceCooldown = Instance.new("TextButton")
reduceCooldown.Size = UDim2.new(0.8, 0, 0, 40)
reduceCooldown.Position = UDim2.new(0.1, 0, 0.2, 0)
reduceCooldown.Text = "Reduce Cooldown: OFF"
reduceCooldown.Font = Enum.Font.SourceSansBold
reduceCooldown.TextScaled = true
reduceCooldown.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
reduceCooldown.Parent = mainFrame

reduceCooldown.MouseButton1Click:Connect(function()
    reduceEnabled = not reduceEnabled
    if reduceEnabled then
        reduceCooldown.Text = "Reduce Cooldown: ON"
    else
        reduceCooldown.Text = "Reduce Cooldown: OFF"
    end
end)

-- Hook into pet ability buttons (visual only)
local PetGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PetView", 10) -- adjust name if different
if PetGui then
    for _, petButton in pairs(PetGui:GetDescendants()) do
        if petButton:IsA("ImageButton") or petButton:IsA("TextButton") then
            petButton.MouseButton1Click:Connect(function()
                if reduceEnabled then
                    addFakeCooldown(petButton)
                end
            end)
        end
    end
end

-- Bypass Button
local bypassBtn = Instance.new("TextButton")
bypassBtn.Size = UDim2.new(0.8, 0, 0, 40)
bypassBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
bypassBtn.Text = "Bypass"
bypassBtn.Font = Enum.Font.SourceSansBold
bypassBtn.TextScaled = true
bypassBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
bypassBtn.Parent = mainFrame

bypassBtn.MouseButton1Click:Connect(function()
    print("Bypass Activated!") -- put your bypass code here
end)

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.8, 0, 0, 40)
closeBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
closeBtn.Text = "Close UI"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextScaled = true
closeBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

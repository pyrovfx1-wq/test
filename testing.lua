-- TOCHIPYRO UI Script (Grow a Garden Only)
-- Fake visual cooldown in pet info panel (changes to 0.15m)

if game.PlaceId ~= 126884695634066 then -- put actual Grow a Garden place ID here
    warn("TOCHIPYRO only works on Grow a Garden!")
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- UI
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
screenGui.Name = "TOCHIPYRO_UI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.5
mainFrame.Active = true
mainFrame.Draggable = true

local UICorner = Instance.new("UICorner", mainFrame)
UICorner.CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -40, 0, 30)
title.Text = "TOCHIPYRO"
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.BackgroundTransparency = 1

task.spawn(function()
    local hue = 0
    while task.wait(0.05) do
        hue = (hue + 0.01) % 1
        title.TextColor3 = Color3.fromHSV(hue, 1, 1)
    end
end)

local minimize = Instance.new("TextButton", mainFrame)
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -30, 0, 0)
minimize.Text = "-"
minimize.TextScaled = true

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        mainFrame.Size = UDim2.new(0, 300, 0, 30)
    else
        mainFrame.Size = UDim2.new(0, 300, 0, 200)
    end
end)

-- Toggle button
local reduceEnabled = false
local reduceCooldown = Instance.new("TextButton", mainFrame)
reduceCooldown.Size = UDim2.new(0.8, 0, 0, 40)
reduceCooldown.Position = UDim2.new(0.1, 0, 0.2, 0)
reduceCooldown.Text = "Reduce Cooldown: OFF"
reduceCooldown.Font = Enum.Font.SourceSansBold
reduceCooldown.TextScaled = true
reduceCooldown.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

reduceCooldown.MouseButton1Click:Connect(function()
    reduceEnabled = not reduceEnabled
    reduceCooldown.Text = "Reduce Cooldown: " .. (reduceEnabled and "ON" or "OFF")
end)

-- Function to visually change pet cooldown text
local function updatePetText()
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Text:lower():find("every") then
            if reduceEnabled then
                -- change any "Every X.XXm" to "Every 0.15m"
                obj.Text = obj.Text:gsub("Every%s[%d%.]+[mh]", "Every 0.15m")
            end
        end
    end
end

-- Keep updating in background
task.spawn(function()
    while true do
        task.wait(0.5)
        if reduceEnabled then
            updatePetText()
        end
    end
end)

-- Other buttons
local bypassBtn = Instance.new("TextButton", mainFrame)
bypassBtn.Size = UDim2.new(0.8, 0, 0, 40)
bypassBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
bypassBtn.Text = "Bypass"
bypassBtn.Font = Enum.Font.SourceSansBold
bypassBtn.TextScaled = true
bypassBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0.8, 0, 0, 40)
closeBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
closeBtn.Text = "Close UI"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextScaled = true
closeBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 50)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

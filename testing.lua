local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Item names to display in spin
local itemPool = {
    "Crown Of Thorns",
    "Elk",
    "Calla Lily",
    "Mandrake",
    "Cyclamen",
    "Griffin",
    "Rose",
    "Sunflower",
    "Orchid",
    "Dandelion"
}

-- Function to make chest with spin animation
local function spawnChest(cframe, finalItem)
    local chest = Instance.new("Model", workspace)
    chest.Name = "RainbowSkyrootChest"

    -- Base
    local base = Instance.new("Part", chest)
    base.Size = Vector3.new(4, 2, 3)
    base.Anchored = true
    base.CFrame = cframe
    base.Color = Color3.fromRGB(90, 60, 40)
    base.Name = "Base"

    -- Lid
    local lid = Instance.new("Part", chest)
    lid.Size = Vector3.new(4, 1, 3)
    lid.Anchored = true
    lid.CFrame = base.CFrame * CFrame.new(0, 1.5, 0)
    lid.Color = Color3.fromRGB(120, 80, 50)
    lid.Name = "Lid"

    -- Rainbow band
    local band = Instance.new("Part", chest)
    band.Size = Vector3.new(4.2, 0.2, 3.2)
    band.Anchored = true
    band.Material = Enum.Material.Neon
    band.CFrame = base.CFrame * CFrame.new(0, 0.6, 0)
    band.Name = "Band"

    -- Animate lid opening
    local openTween = TweenService:Create(
        lid,
        TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = lid.CFrame * CFrame.Angles(math.rad(-100), 0, 0)}
    )
    openTween:Play()

    -- Animate rainbow color
    local t = 0
    RunService.RenderStepped:Connect(function(dt)
        if not band.Parent then return end
        t += dt * 0.5
        local hue = t % 1
        band.Color = Color3.fromHSV(hue, 1, 1)
    end)

    -- BillboardGui for spin
    local billboard = Instance.new("BillboardGui", chest)
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.TextColor3 = Color3.new(1,1,1)

    -- Spin animation (random items until stop)
    task.spawn(function()
        local totalTime = 3 -- how long spin lasts
        local elapsed = 0
        while elapsed < totalTime do
            elapsed += 0.1
            -- Pick a random item
            label.Text = itemPool[math.random(1, #itemPool)]
            task.wait(0.1 + elapsed * 0.05) -- slows down gradually
        end
        -- Final guaranteed item
        label.Text = finalItem
        label.TextColor3 = Color3.fromRGB(0, 255, 127)
    end)

    -- Auto destroy after 10s
    task.delay(10, function()
        if chest then chest:Destroy() end
    end)
end

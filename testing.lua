-- Local-only Enlarged Pets in Grow a Garden with UI (Draggable + Full Minimize)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Store pet names & scale factors
local enlargedPetTemplates = {}

-- Rainbow color function
local function rainbowColor(t)
    local r = math.sin(t * 2) * 127 + 128
    local g = math.sin(t * 2 + 2) * 127 + 128
    local b = math.sin(t * 2 + 4) * 127 + 128
    return Color3.fromRGB(r, g, b)
end

-- Scale pet model (preserve proportions & joints)
local function scalePetModel(petModel, scaleFactor)
	if not petModel or not petModel:IsA("Model") then return end
	for _, obj in ipairs(petModel:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Size = obj.Size * scaleFactor
		elseif obj:IsA("SpecialMesh") then
			obj.Scale = obj.Scale * scaleFactor
		elseif obj:IsA("Motor6D") then
			local c0Pos, c0Rot = obj.C0.Position, obj.C0 - obj.C0.Position
			local c1Pos, c1Rot = obj.C1.Position, obj.C1 - obj.C1.Position
			obj.C0 = CFrame.new(c0Pos * scaleFactor) * c0Rot
			obj.C1 = CFrame.new(c1Pos * scaleFactor) * c1Rot
		end
	end
end

-- Detect currently held pet
local function getHeldPet()
	local char = LocalPlayer.Character
	if not char then return nil end
	for _, obj in ipairs(char:GetChildren()) do
		if obj:IsA("Model") and not obj:FindFirstChildOfClass("Humanoid") then
			if obj:FindFirstChildWhichIsA("BasePart") then
				return obj
			end
		end
	end
	return nil
end

-- GUI creation
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "TOCHIPYRO_GUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 180)
frame.Position = UDim2.new(0.35, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true -- make it movable

-- Rainbow title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "TOCHIPYRO"
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true

-- Rainbow animation
spawn(function()
	local t = 0
	while gui.Parent do
		title.TextColor3 = rainbowColor(t)
		t = t + 0.05
		task.wait(0.05)
	end
end)

-- Enlarge button
local enlargeBtn = Instance.new("TextButton", frame)
enlargeBtn.Size = UDim2.new(1, -20, 0, 40)
enlargeBtn.Position = UDim2.new(0, 10, 0, 50)
enlargeBtn.Text = "Enlarge Held Pet (Local Only)"
enlargeBtn.Font = Enum.Font.SourceSansBold
enlargeBtn.TextScaled = true
enlargeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

enlargeBtn.MouseButton1Click:Connect(function()
	local pet = getHeldPet()
	if pet then
		local name = pet.Name
		enlargedPetTemplates[name] = 1.75
		scalePetModel(pet, 1.75)
		print("Enlarged pet locally:", name)
	else
		warn("No held pet found.")
	end
end)

-- Minimize button
local minimizeBtn = Instance.new("TextButton", frame)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextScaled = true
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)

-- Close button
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextScaled = true
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

-- Minimize toggle
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		frame.Size = UDim2.new(0, 320, 0, 40) -- shrink to title bar
	else
		frame.Size = UDim2.new(0, 320, 0, 180) -- restore size
	end
	for _, child in ipairs(frame:GetChildren()) do
		if child ~= title and child ~= minimizeBtn and child ~= closeBtn then
			child.Visible = not minimized
		end
	end
end)

-- Close button hides GUI
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Auto enlarge matching pets
workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("Model") and enlargedPetTemplates[desc.Name] then
		task.wait(0.05)
		scalePetModel(desc, enlargedPetTemplates[desc.Name])
	end
end)

-- Local-only Enlarged Pets in Grow a Garden
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Store pet names & scale factors
local enlargedPetTemplates = {}

-- Function: scale a pet model (preserve proportions & joints)
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

-- GUI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.35, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(1, -20, 0, 40)
button.Position = UDim2.new(0, 10, 0, 50)
button.Text = "Enlarge Held Pet (Local Only)"
button.Font = Enum.Font.SourceSansBold
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

-- Click enlarge
button.MouseButton1Click:Connect(function()
	local pet = getHeldPet()
	if pet then
		local name = pet.Name
		enlargedPetTemplates[name] = 1.75 -- store
		scalePetModel(pet, 1.75)
		print("Enlarged pet locally:", name)
	else
		warn("No held pet found.")
	end
end)

-- Auto enlarge any matching pet (owned by you or others)
workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("Model") and enlargedPetTemplates[desc.Name] then
		task.wait(0.05) -- let parts load
		scalePetModel(desc, enlargedPetTemplates[desc.Name])
	end
end)

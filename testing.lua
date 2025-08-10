-- Grow a Garden - Persistent Pet Enlargement (Local Visual Only, Unique Pet IDs)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Table to store pets we have enlarged (by unique ID)
local enlargedPets = {}

-- Get unique identifier for a model
local function getPetId(model)
	if typeof(model) == "Instance" then
		if model.GetDebugId then
			return model:GetDebugId()
		else
			return model:GetFullName()
		end
	end
	return tostring(model)
end

-- Function to detect if a model is a pet
local function isPetModel(model)
	if not model:IsA("Model") then return false end
	if model:FindFirstChildOfClass("Humanoid") then return false end
	if model:FindFirstChildWhichIsA("BasePart") then
		-- Optional: expand keywords for other pets
		local nameLower = string.lower(model.Name)
		if nameLower:find("pet") or nameLower:find("raccoon") or nameLower:find("ostrich")
		or nameLower:find("fox") or nameLower:find("bunny") or nameLower:find("duck") then
			return true
		end
	end
	return false
end

-- Scale pet naturally
local function scaleModelWithJoints(model, scaleFactor)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Size = part.Size * scaleFactor
		elseif part:IsA("SpecialMesh") then
			part.Scale = part.Scale * scaleFactor
		elseif part:IsA("Motor6D") then
			local c0Pos, c0Rot = part.C0.Position, part.C0 - part.C0.Position
			local c1Pos, c1Rot = part.C1.Position, part.C1 - part.C1.Position
			part.C0 = CFrame.new(c0Pos * scaleFactor) * c0Rot
			part.C1 = CFrame.new(c1Pos * scaleFactor) * c1Rot
		end
	end
end

-- Function to enlarge a pet and remember it
local function enlargePet(pet, factor)
	if not pet or not pet:IsDescendantOf(workspace) then return end
	scaleModelWithJoints(pet, factor)
	local petId = getPetId(pet)
	enlargedPets[petId] = factor
	print("Enlarged pet:", pet.Name, "ID:", petId, "Factor:", factor)
end

-- Detect held pet
local function getHeldPet()
	local char = LocalPlayer.Character
	if not char then return nil end
	for _, obj in ipairs(char:GetChildren()) do
		if isPetModel(obj) then
			return obj
		end
	end
	return nil
end

-- Reapply enlargement when pets spawn
workspace.DescendantAdded:Connect(function(desc)
	if isPetModel(desc) then
		local petId = getPetId(desc)
		if enlargedPets[petId] then
			task.wait(0.2) -- Let it load fully
			scaleModelWithJoints(desc, enlargedPets[petId])
			print("Re-applied enlargement to:", desc.Name, "ID:", petId)
		end
	end
end)

-- GUI creation
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Pet Size Control"
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Enlarge button
local SizeButton = Instance.new("TextButton", MainFrame)
SizeButton.Size = UDim2.new(1, -20, 0, 40)
SizeButton.Position = UDim2.new(0, 10, 0, 50)
SizeButton.Text = "Enlarge Held Pet"
SizeButton.Font = Enum.Font.SourceSansBold
SizeButton.TextScaled = true
SizeButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SizeButton.MouseButton1Click:Connect(function()
	local pet = getHeldPet()
	if pet then
		enlargePet(pet, 1.75) -- 75% bigger
	else
		warn("No held pet found.")
	end
end)

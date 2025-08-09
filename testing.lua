-- TOCHIPYRO: quick debug probe (paste into executor)
pcall(function()
    print("=== TOCHIPYRO DEBUG START ===")

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    print("LocalPlayer:", LocalPlayer and LocalPlayer.Name or "nil")

    local placeIdOk, placeId = pcall(function() return game.PlaceId end)
    print("PlaceId:", placeIdOk and placeId or "error")

    -- Try make a tiny visual indicator (PlayerGui preferred, fallback CoreGui)
    local guiParent = nil
    if LocalPlayer then
        guiParent = LocalPlayer:FindFirstChild("PlayerGui")
    end
    if not guiParent then
        guiParent = game.CoreGui
    end
    pcall(function()
        local s = Instance.new("ScreenGui")
        s.Name = "TOCHIPYRO_DEBUG_GUI"
        s.ResetOnSpawn = false
        s.Parent = guiParent
        local t = Instance.new("TextLabel", s)
        t.Size = UDim2.new(0,200,0,30)
        t.Position = UDim2.new(0,10,0,10)
        t.Text = "TOCHIPYRO DEBUG RUNNING"
        t.TextScaled = true
        t.BackgroundTransparency = 0.6
        t.TextColor3 = Color3.fromRGB(255,255,255)
        delay(6, function() pcall(function() s:Destroy() end) end)
    end)

    if not LocalPlayer then
        print("No LocalPlayer found. Are you running this on the client/executor?")
        return
    end

    local char = LocalPlayer.Character
    print("Character present:", char ~= nil)
    if not char then
        print("Character nil. Wait a few seconds then rerun the script.")
        return
    end

    -- list top-level children of Character
    print("\n-- Character children --")
    for _, c in ipairs(char:GetChildren()) do
        print(string.format("  %s  |  %s", c.Name, c.ClassName))
    end

    -- check for Tools and list contents
    print("\n-- Tools / Accessories in Character --")
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") or v:IsA("Accessory") then
            print(" TOOL/ACCESSORY:", v:GetFullName(), v.ClassName)
            for _, d in ipairs(v:GetDescendants()) do
                if d:IsA("BasePart") or d:IsA("MeshPart") or d:IsA("SpecialMesh") or d:IsA("Attachment") then
                    print("    ->", d.ClassName, d:GetFullName())
                end
            end
        end
    end

    -- print equipped tool (if any)
    local equipped = char:FindFirstChildOfClass("Tool")
    print("\nEquipped tool:", equipped and equipped.Name or "none")

    -- List welds / weldconstraints / motor6D in workspace that reference Character
    print("\n-- Constraints in workspace referencing your Character --")
    local count = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("Motor6D") then
            local p0Name = (d.Part0 and d.Part0:GetFullName()) or "nil"
            local p1Name = (d.Part1 and d.Part1:GetFullName()) or "nil"
            local referencesChar = (d.Part0 and d.Part0:IsDescendantOf(char)) or (d.Part1 and d.Part1:IsDescendantOf(char))
            if referencesChar then
                count = count + 1
                print(string.format("  [%d] %s  | part0=%s | part1=%s | referencesChar=%s", count, d:GetFullName(), p0Name, p1Name, tostring(referencesChar)))
            end
        end
    end
    if count == 0 then print("  (none found pointing to your Character)") end

    -- List models in workspace that have an Owner ObjectValue or Owner attribute matching you
    print("\n-- Models with Owner object/attribute --")
    local ownerCount = 0
    for _, m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Model") then
            local ownerObj = m:FindFirstChild("Owner")
            local ownerAttr = nil
            if m.GetAttribute then
                ownerAttr = m:GetAttribute("Owner") or m:GetAttribute("OwnerUserId") or m:GetAttribute("owner")
            end
            local match = false
            if ownerObj and ownerObj.Value == LocalPlayer then match = true end
            if ownerAttr and (tostring(ownerAttr) == tostring(LocalPlayer.UserId) or tostring(ownerAttr) == LocalPlayer.Name) then match = true end
            if match then
                ownerCount = ownerCount + 1
                print(" ", ownerCount, m:GetFullName(), "ownerObj=", tostring(ownerObj), "ownerAttr=", tostring(ownerAttr))
            end
        end
    end
    if ownerCount == 0 then print("  (no Owner matches found)") end

    -- list nearby models (basic heuristic)
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if hrp then
        print("\n-- Nearby Models (within 12 studs) --")
        local nearCount = 0
        for _, m in ipairs(workspace:GetChildren()) do
            if m:IsA("Model") and not m:IsDescendantOf(char) then
                local base = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                if base then
                    local dist = (base.Position - hrp.Position).Magnitude
                    if dist <= 12 then
                        nearCount = nearCount + 1
                        local meshInfo = {}
                        for _, d in ipairs(m:GetDescendants()) do
                            if d:IsA("MeshPart") then table.insert(meshInfo, "MeshPart:"..d.Name) end
                            if d:IsA("SpecialMesh") then table.insert(meshInfo, "SpecialMesh:"..d.Name) end
                        end
                        print(string.format("  [%d] %s dist=%.2f meshes=%s", nearCount, m:GetFullName(), dist, table.concat(meshInfo,",") ))
                    end
                end
            end
        end
        if nearCount == 0 then print("  (no nearby models with meshes within 12 studs)") end
    else
        print("No HRP found; cannot list nearby models.")
    end

    -- Print a short message on how to proceed
    print("\n=== DEBUG COMPLETE ===")
    print("If the UI didn't appear or nothing printed, try running: print('hello from executor') to confirm the executor is executing client code.")
end)

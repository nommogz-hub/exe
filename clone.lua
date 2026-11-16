local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G
if env.SideClonesCleanup then
	pcall(env.SideClonesCleanup)
end

-- ===== الإعدادات =====
local OFFSET = 5            -- المسافة بين كل نسخة والتي قبلها
local PER_SIDE = 1          -- عدد النسخ في كل جهة
local GHOST = true          -- true = نسخ متوهجة، false = نسخ بشكلك الأصلي
local COLOR = Color3.fromRGB(0, 170, 255)
local TRANSPARENCY = 0.4
-- =====================

local clones = {}
local renderCon
local charCon

local function clearClones()
	for _, c in ipairs(clones) do
		c.model:Destroy()
	end
	table.clear(clones)
end

local function buildClones(char)
	clearClones()
	char.Archivable = true
	local origDesc = char:GetDescendants()

	local offsets = {}
	for i = 1, PER_SIDE do
		table.insert(offsets, -OFFSET * i)
		table.insert(offsets, OFFSET * i)
	end

	for _, off in ipairs(offsets) do
		local model = char:Clone()
		if model then
			model.Name = "SideClone"
			local cloneDesc = model:GetDescendants()

			local list = {}
			for i, d in ipairs(cloneDesc) do
				local o = origDesc[i]
				if d:IsA("BasePart") and o and o:IsA("BasePart") then
					table.insert(list, {orig = o, part = d})
				end
			end

			for _, d in ipairs(cloneDesc) do
				if d:IsA("BaseScript") or d:IsA("Humanoid") then
					d:Destroy()
				elseif GHOST and d:IsA("Decal") then
					d:Destroy()
				end
			end

			for _, p in ipairs(list) do
				local part = p.part
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				if GHOST and part.Transparency < 1 then
					part.Material = Enum.Material.Neon
					part.Color = COLOR
					part.Transparency = TRANSPARENCY
				end
			end

			model.Parent = workspace
			table.insert(clones, {model = model, offset = off, pairs = list})
		end
	end
end

renderCon = RunService.RenderStepped:Connect(function()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	for _, c in ipairs(clones) do
		local shift = root.CFrame.RightVector * c.offset
		for _, p in ipairs(c.pairs) do
			if p.orig.Parent then
				p.part.CFrame = p.orig.CFrame + shift
			end
		end
	end
end)

local function onChar(char)
	char:WaitForChild("HumanoidRootPart")
	task.wait(0.5)
	buildClones(char)
end

charCon = player.CharacterAdded:Connect(onChar)
if player.Character then
	task.spawn(onChar, player.Character)
end

env.SideClonesCleanup = function()
	if renderCon then renderCon:Disconnect() end
	if charCon then charCon:Disconnect() end
	clearClones()
	env.SideClonesCleanup = nil
end

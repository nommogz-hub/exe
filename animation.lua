local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G
if env.WalkAnimCleanup then
	pcall(env.WalkAnimCleanup)
	env.WalkAnimCleanup = nil
end

local ACCENT = Color3.fromRGB(0, 170, 255)
local DARK = Color3.fromRGB(25, 25, 30)

local function pack(name, i1, i2, w, r, j, f, c, s, si)
	return {name = name, idle1 = i1, idle2 = i2, walk = w, run = r,
		jump = j, fall = f, climb = c, swim = s, swimidle = si}
end

local DEFAULT = pack("Default", 507766666, 507766951, 507777826, 507767714, 507765000, 507767968, 507765644, 507784897, 507785072)

local PACKS = {
	DEFAULT,
	pack("Zombie", 616158929, 616160636, 616168032, 616163682, 616161997, 616157476, 616156119, 616165109, 616166655),
	pack("Elder", 845397899, 845400520, 845403856, 845386501, 845398858, 845396048, 845392038, 845401742, 845403127),
	pack("Ninja", 656117400, 656118341, 656121766, 656118852, 656117878, 656115606, 656114359, 656119721, 656121397),
	pack("Robot", 616088211, 616089559, 616095330, 616091570, 616090535, 616087089, 616086039, 616092998, 616094091),
	pack("Cartoony", 742637544, 742638445, 742640026, 742638842, 742637942, 742637151, 742636889, 0, 0),
	pack("Levitation", 616006778, 616008087, 616013216, 616010382, 616008936, 616005863, 616003713, 616011509, 616012453),
	pack("Mage", 707742142, 707855907, 707897309, 707861613, 707853694, 707829716, 707826056, 707876443, 707894699),
	pack("Werewolf", 1083195517, 1083214717, 1083178339, 1083216690, 1083218792, 1083189019, 1083182000, 1083222527, 1083225406),
	pack("Stylish", 616136790, 616138447, 616146177, 616140816, 616139451, 616134815, 616133594, 616143378, 616144772),
	pack("Vampire", 1083445855, 1083450166, 1083473930, 1083462077, 1083455352, 1083443587, 1083439238, 1083464683, 1083467779),
	pack("Knight", 657595757, 657568135, 657552124, 657564596, 658409194, 657600338, 658360781, 657560551, 657557095),
	pack("Astronaut", 891621366, 891633237, 891667138, 891636393, 891627522, 891617961, 891609353, 891639666, 891663592),
	pack("Bubbly", 910004836, 910009958, 910034870, 910025107, 910016857, 910001910, 909997997, 910028158, 910030921),
	pack("Pirate", 750781874, 750782770, 750785693, 750783738, 750782230, 750780242, 750779899, 750784579, 750785176),
	pack("Toy", 782841498, 782845736, 782843345, 782842708, 782847020, 782846423, 782843869, 782844582, 782845186),
	pack("Superhero", 616111295, 616113536, 616122287, 616117076, 616115533, 616108001, 616104706, 616119360, 616120861),
}

local connections = {}
local current = nil
local gui
local statusLabel

local function setStatus(text)
	if statusLabel then statusLabel.Text = text end
end

local function setId(animate, folder, child, id)
	if not id or id == 0 then return end
	local f = animate:FindFirstChild(folder)
	local a = f and f:FindFirstChild(child)
	if a then
		a.AnimationId = "rbxassetid://" .. tostring(id)
	end
end

local function apply(set)
	local char = player.Character
	local animate = char and char:FindFirstChild("Animate")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not animate or not hum then
		setStatus("No Animate script found")
		return
	end
	if hum.RigType ~= Enum.HumanoidRigType.R15 then
		setStatus("R15 characters only")
		return
	end

	current = set
	animate.Disabled = true
	for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
		t:Stop()
	end

	setId(animate, "idle", "Animation1", set.idle1)
	setId(animate, "idle", "Animation2", set.idle2)
	setId(animate, "walk", "WalkAnim", set.walk)
	setId(animate, "run", "RunAnim", set.run)
	setId(animate, "jump", "JumpAnim", set.jump)
	setId(animate, "fall", "FallAnim", set.fall)
	setId(animate, "climb", "ClimbAnim", set.climb)
	setId(animate, "swim", "Swim", set.swim)
	setId(animate, "swimidle", "SwimIdle", set.swimidle)

	task.wait()
	animate.Disabled = false
	setStatus("Active: " .. (set.name or "Custom"))
end

-- الواجهة
gui = Instance.new("ScreenGui")
gui.Name = "WalkAnimGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 70, 0, 50)
toggle.Position = UDim2.new(0, 10, 0.5, -25)
toggle.BackgroundColor3 = ACCENT
toggle.Text = "ANIM"
toggle.TextScaled = true
toggle.Parent = gui
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 12)

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 260, 0, 340)
panel.Position = UDim2.new(0, 90, 0.5, -170)
panel.BackgroundColor3 = DARK
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -60, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 5)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextScaled = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "Pick a walk style"
statusLabel.Parent = panel

local xBtn = Instance.new("TextButton")
xBtn.Size = UDim2.new(0, 30, 0, 30)
xBtn.Position = UDim2.new(1, -40, 0, 5)
xBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
xBtn.Text = "X"
xBtn.TextColor3 = Color3.new(1, 1, 1)
xBtn.TextScaled = true
xBtn.Parent = panel
Instance.new("UICorner", xBtn).CornerRadius = UDim.new(1, 0)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 0, 210)
list.Position = UDim2.new(0, 10, 0, 40)
list.BackgroundTransparency = 1
list.ScrollBarThickness = 6
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.Parent = list

for _, set in ipairs(PACKS) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -8, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	btn.Text = set.name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.Parent = list
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	table.insert(connections, btn.MouseButton1Click:Connect(function()
		apply(set)
	end))
end

local walkBox = Instance.new("TextBox")
walkBox.Size = UDim2.new(0.5, -15, 0, 30)
walkBox.Position = UDim2.new(0, 10, 0, 258)
walkBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
walkBox.PlaceholderText = "Walk ID"
walkBox.Text = ""
walkBox.TextColor3 = Color3.new(1, 1, 1)
walkBox.TextScaled = true
walkBox.ClearTextOnFocus = false
walkBox.Parent = panel
Instance.new("UICorner", walkBox).CornerRadius = UDim.new(0, 8)

local runBox = Instance.new("TextBox")
runBox.Size = UDim2.new(0.5, -15, 0, 30)
runBox.Position = UDim2.new(0.5, 5, 0, 258)
runBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
runBox.PlaceholderText = "Run ID (optional)"
runBox.Text = ""
runBox.TextColor3 = Color3.new(1, 1, 1)
runBox.TextScaled = true
runBox.ClearTextOnFocus = false
runBox.Parent = panel
Instance.new("UICorner", runBox).CornerRadius = UDim.new(0, 8)

local customBtn = Instance.new("TextButton")
customBtn.Size = UDim2.new(1, -20, 0, 34)
customBtn.Position = UDim2.new(0, 10, 0, 296)
customBtn.BackgroundColor3 = ACCENT
customBtn.Text = "Apply custom ID"
customBtn.TextScaled = true
customBtn.Parent = panel
Instance.new("UICorner", customBtn).CornerRadius = UDim.new(0, 8)

table.insert(connections, customBtn.MouseButton1Click:Connect(function()
	local w = tonumber(walkBox.Text)
	local r = tonumber(runBox.Text)
	if not w then
		setStatus("Enter a walk ID number")
		return
	end
	local set = {}
	for k, v in pairs(DEFAULT) do set[k] = v end
	set.name = "Custom"
	set.walk = w
	set.run = r or w
	apply(set)
end))

table.insert(connections, toggle.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end))

local function destroyAll()
	for _, con in ipairs(connections) do
		con:Disconnect()
	end
	table.clear(connections)
	current = nil
	local char = player.Character
	local animate = char and char:FindFirstChild("Animate")
	if animate then
		-- أعد الأنيميشن الافتراضي
		local saved = current
		apply(DEFAULT)
	end
	if gui then
		gui:Destroy()
		gui = nil
	end
	env.WalkAnimCleanup = nil
end

table.insert(connections, xBtn.MouseButton1Click:Connect(destroyAll))

-- أعد التطبيق بعد الموت/إعادة الظهور
table.insert(connections, player.CharacterAdded:Connect(function(char)
	char:WaitForChild("Animate", 10)
	task.wait(1)
	if current then apply(current) end
end))

env.WalkAnimCleanup = destroyAll

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local env = (getgenv and getgenv()) or _G
if env.CombinedCleanup then
	pcall(env.CombinedCleanup)
	env.CombinedCleanup = nil
end

-- ===== إعدادات النسخ =====
local CLONE_DISTANCE = 6        -- المسافة بين النسخ
local PER_SIDE = 1              -- عدد النسخ في كل جهة

-- ===== إعدادات الاندفاع =====
local DASH_DISTANCE = 180
local DASH_DURATION = 5
local DASH_COOLDOWN = 3
local ANIM_SPEED = 0.08
local GHOST_INTERVAL = 0.25
local FADE_TIME = 2
local ZOOM_FOV = 55
local COLOR = Color3.fromRGB(0, 170, 255)
-- ===========================

local connections = {}
local destroyed = false
local clonesEnabled = true
local realCF = nil
local wantGhost = false
local canDash = true
local dashCon = nil
local originalFov = camera.FieldOfView
local gui

local offsets = {0}
for i = 1, PER_SIDE do
	table.insert(offsets, -CLONE_DISTANCE * i)
	table.insert(offsets, CLONE_DISTANCE * i)
end

local function getRoot()
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function setAnimSpeed(h, speed)
	if not h then return end
	for _, track in ipairs(h:GetPlayingAnimationTracks()) do
		track:AdjustSpeed(speed)
	end
end

local function ghost(c)
	if destroyed or not c then return end
	local m = Instance.new("Model")
	m.Name = "DashGhost"
	for _, p in ipairs(c:GetChildren()) do
		if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
			local n = p:Clone()
			n:ClearAllChildren()
			n.Anchored = true
			n.CanCollide = false
			n.Material = Enum.Material.Neon
			n.Color = COLOR
			n.Transparency = 0.35
			n.CFrame = p.CFrame
			n.Parent = m
			TweenService:Create(n, TweenInfo.new(FADE_TIME), {Transparency = 1}):Play()
		end
	end
	m.Parent = workspace
	task.delay(FADE_TIME + 0.1, function()
		if m then m:Destroy() end
	end)
end

local function ease(t)
	return t * t * (3 - 2 * t)
end

-- قبل الرسم: رجّعني لمكاني الحقيقي، ثم أنشئ الظل إن لزم
table.insert(connections, RunService.RenderStepped:Connect(function()
	if realCF then
		local root = getRoot()
		if root then root.CFrame = realCF end
		realCF = nil
	end
	if wantGhost then
		wantGhost = false
		ghost(player.Character)
	end
end))

-- بعد الفيزياء: انقلني لمكان جانبي عشوائي (هذا اللي يشوفه الناس)
table.insert(connections, RunService.Heartbeat:Connect(function()
	if destroyed or not clonesEnabled then return end
	local root = getRoot()
	if not root then return end
	local off = offsets[math.random(1, #offsets)]
	if off == 0 then return end
	realCF = root.CFrame
	root.CFrame = realCF * CFrame.new(off, 0, 0)
end))

local function dash()
	if destroyed or not canDash then return end
	local c = player.Character
	local r = c and c:FindFirstChild("HumanoidRootPart")
	local h = c and c:FindFirstChildOfClass("Humanoid")
	if not r or not h or h.Health <= 0 then return end

	canDash = false

	local d = h.MoveDirection
	if d.Magnitude < 0.1 then d = r.CFrame.LookVector end
	d = Vector3.new(d.X, 0, d.Z).Unit

	TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = ZOOM_FOV}):Play()

	local t0 = tick()
	local last = 0
	local prevProgress = 0

	dashCon = RunService.Heartbeat:Connect(function(dt)
		local e = tick() - t0

		if e >= DASH_DURATION or h.Health <= 0 then
			dashCon:Disconnect()
			dashCon = nil
			r.AssemblyLinearVelocity = Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
			setAnimSpeed(h, 1)
			TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = originalFov}):Play()
			return
		end

		setAnimSpeed(h, ANIM_SPEED)

		local progress = ease(e / DASH_DURATION)
		local step = (progress - prevProgress) * DASH_DISTANCE
		prevProgress = progress
		local speed = step / math.max(dt, 1/240)

		r.AssemblyLinearVelocity = d * speed + Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)

		if e - last >= GHOST_INTERVAL then
			last = e
			wantGhost = true
		end
	end)

	task.delay(DASH_COOLDOWN + DASH_DURATION, function()
		canDash = true
	end)
end

local function destroyAll()
	if destroyed then return end
	destroyed = true

	if dashCon then
		dashCon:Disconnect()
		dashCon = nil
	end
	for _, con in ipairs(connections) do
		con:Disconnect()
	end
	table.clear(connections)

	local root = getRoot()
	if realCF and root then
		root.CFrame = realCF
	end
	realCF = nil
	if root then
		root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	end

	local char = player.Character
	setAnimSpeed(char and char:FindFirstChildOfClass("Humanoid"), 1)
	camera.FieldOfView = originalFov

	for _, obj in ipairs(workspace:GetChildren()) do
		if obj.Name == "DashGhost" then obj:Destroy() end
	end

	if gui then
		gui:Destroy()
		gui = nil
	end
	env.CombinedCleanup = nil
end

env.CombinedCleanup = destroyAll

-- الواجهة
gui = Instance.new("ScreenGui")
gui.Name = "CombinedGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local dashBtn = Instance.new("TextButton")
dashBtn.Size = UDim2.new(0, 90, 0, 90)
dashBtn.Position = UDim2.new(1, -120, 1, -190)
dashBtn.BackgroundColor3 = COLOR
dashBtn.Text = "DASH"
dashBtn.TextScaled = true
dashBtn.Parent = gui
Instance.new("UICorner", dashBtn).CornerRadius = UDim.new(1, 0)

local cloneBtn = Instance.new("TextButton")
cloneBtn.Size = UDim2.new(0, 120, 0, 50)
cloneBtn.Position = UDim2.new(1, -135, 1, -250)
cloneBtn.BackgroundColor3 = COLOR
cloneBtn.Text = "CLONES: ON"
cloneBtn.TextScaled = true
cloneBtn.Parent = gui
Instance.new("UICorner", cloneBtn).CornerRadius = UDim.new(0, 12)

local xBtn = Instance.new("TextButton")
xBtn.Size = UDim2.new(0, 40, 0, 40)
xBtn.Position = UDim2.new(1, -60, 1, -300)
xBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
xBtn.Text = "X"
xBtn.TextColor3 = Color3.new(1, 1, 1)
xBtn.TextScaled = true
xBtn.Parent = gui
Instance.new("UICorner", xBtn).CornerRadius = UDim.new(1, 0)

table.insert(connections, dashBtn.MouseButton1Click:Connect(dash))
table.insert(connections, cloneBtn.MouseButton1Click:Connect(function()
	clonesEnabled = not clonesEnabled
	cloneBtn.Text = clonesEnabled and "CLONES: ON" or "CLONES: OFF"
	cloneBtn.BackgroundColor3 = clonesEnabled and COLOR or Color3.fromRGB(120, 120, 120)
end))
table.insert(connections, xBtn.MouseButton1Click:Connect(destroyAll))

table.insert(connections, UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.Q then
		dash()
	elseif i.KeyCode == Enum.KeyCode.X then
		destroyAll()
	end
end))

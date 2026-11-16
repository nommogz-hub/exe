local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- تنظيف النسخة السابقة (إن وجدت)
local env = (getgenv and getgenv()) or _G
if env.DashCleanup then
	pcall(env.DashCleanup)
	env.DashCleanup = nil
end

-- ===== الإعدادات =====
local DASH_DISTANCE = 180
local DASH_DURATION = 5
local DASH_COOLDOWN = 3
local ANIM_SPEED = 0.08
local CLONE_INTERVAL = 0.1
local FADE_TIME = 2
local CAMERA_ZOOM_FOV = 55
local CLONE_COLOR = Color3.fromRGB(0, 170, 255)
-- =====================

local canDash = true
local destroyed = false
local connections = {}
local activeDashCon = nil
local originalFov = camera.FieldOfView
local gui

local function setAnimSpeed(h, speed)
	if not h then return end
	for _, track in ipairs(h:GetPlayingAnimationTracks()) do
		track:AdjustSpeed(speed)
	end
end

local function ghost(c)
	if destroyed then return end
	local m = Instance.new("Model")
	m.Name = "DashGhost"
	for _, p in ipairs(c:GetChildren()) do
		if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
			local n = p:Clone()
			n:ClearAllChildren()
			n.Anchored = true
			n.CanCollide = false
			n.Material = Enum.Material.Neon
			n.Color = CLONE_COLOR
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

	TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = CAMERA_ZOOM_FOV}):Play()

	local t0 = tick()
	local last = 0
	local prevProgress = 0

	activeDashCon = RunService.Heartbeat:Connect(function(dt)
		local e = tick() - t0

		if e >= DASH_DURATION or h.Health <= 0 then
			activeDashCon:Disconnect()
			activeDashCon = nil
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

		if e - last >= CLONE_INTERVAL then
			last = e
			ghost(c)
		end
	end)

	task.delay(DASH_COOLDOWN + DASH_DURATION, function()
		canDash = true
	end)
end

-- دالة الحذف الكامل
local function destroyAll()
	if destroyed then return end
	destroyed = true

	if activeDashCon then
		activeDashCon:Disconnect()
		activeDashCon = nil
	end

	for _, con in ipairs(connections) do
		con:Disconnect()
	end
	table.clear(connections)

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	setAnimSpeed(hum, 1)
	if root then
		root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	end

	camera.FieldOfView = originalFov

	for _, obj in ipairs(workspace:GetChildren()) do
		if obj.Name == "DashGhost" then
			obj:Destroy()
		end
	end

	if gui then
		gui:Destroy()
		gui = nil
	end

	env.DashCleanup = nil
end

env.DashCleanup = destroyAll

-- الواجهة
gui = Instance.new("ScreenGui")
gui.Name = "DashGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local b = Instance.new("TextButton")
b.Size = UDim2.new(0, 90, 0, 90)
b.Position = UDim2.new(1, -120, 1, -200)
b.BackgroundColor3 = CLONE_COLOR
b.Text = "DASH"
b.TextScaled = true
b.Parent = gui
Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

local x = Instance.new("TextButton")
x.Size = UDim2.new(0, 40, 0, 40)
x.Position = UDim2.new(1, -60, 1, -245)
x.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
x.Text = "X"
x.TextColor3 = Color3.new(1, 1, 1)
x.TextScaled = true
x.Parent = gui
Instance.new("UICorner", x).CornerRadius = UDim.new(1, 0)

table.insert(connections, b.MouseButton1Click:Connect(dash))
table.insert(connections, x.MouseButton1Click:Connect(destroyAll))

table.insert(connections, UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.Q then
		dash()
	elseif i.KeyCode == Enum.KeyCode.X then
		destroyAll()
	end
end))

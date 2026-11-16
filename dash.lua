local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ===== الإعدادات =====
local DASH_DISTANCE = 180      -- المسافة بالستود (بعيدة جداً)
local DASH_DURATION = 5        -- المدة بالثواني (أكثر = أبطأ)
local DASH_COOLDOWN = 3
local ANIM_SPEED = 0.08        -- سرعة الأنيميشن (أقل = أبطأ، 0.08 = سلو موشن قوي)
local CLONE_INTERVAL = 0.25    -- كل كم ثانية يظهر ظل
local FADE_TIME = 2            -- مدة تلاشي الظل
local CAMERA_ZOOM_FOV = 55     -- زاوية الكاميرا وقت الاندفاع (أقل = تقريب أكثر)
local CLONE_COLOR = Color3.fromRGB(0, 170, 255)
-- =====================

local canDash = true

local function ghost(c)
	local m = Instance.new("Model")
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
	task.delay(FADE_TIME + 0.1, function() m:Destroy() end)
end

local function setAnimSpeed(h, speed)
	for _, track in ipairs(h:GetPlayingAnimationTracks()) do
		track:AdjustSpeed(speed)
	end
end

-- منحنى تسارع/تباطؤ ناعم (يبدأ ببطء، يسرع بالوسط، يبطئ بالنهاية)
local function ease(t)
	return t * t * (3 - 2 * t)
end

local function dash()
	if not canDash then return end
	local c = player.Character
	local r = c and c:FindFirstChild("HumanoidRootPart")
	local h = c and c:FindFirstChildOfClass("Humanoid")
	if not r or not h or h.Health <= 0 then return end

	canDash = false

	local d = h.MoveDirection
	if d.Magnitude < 0.1 then d = r.CFrame.LookVector end
	d = Vector3.new(d.X, 0, d.Z).Unit

	local startFov = camera.FieldOfView
	TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = CAMERA_ZOOM_FOV}):Play()

	local t0 = tick()
	local last = 0
	local prevProgress = 0
	local con
	con = RunService.Heartbeat:Connect(function()
		local e = tick() - t0

		if e >= DASH_DURATION or h.Health <= 0 then
			con:Disconnect()
			r.AssemblyLinearVelocity = Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
			setAnimSpeed(h, 1)
			TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = startFov}):Play()
			return
		end

		setAnimSpeed(h, ANIM_SPEED)

		-- السرعة الحالية مشتقة من منحنى التسارع
		local progress = ease(e / DASH_DURATION)
		local step = (progress - prevProgress) * DASH_DISTANCE
		prevProgress = progress
		local dt = RunService.Heartbeat:Wait and 1/60 or 1/60
		local speed = step * 60

		r.AssemblyLinearVelocity = d * speed + Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)

		if e - last >= CLONE_INTERVAL then
			last = e
			ghost(c)
		end
	end)

	task.delay(DASH_COOLDOWN + DASH_DURATION, function() canDash = true end)
end

local gui = Instance.new("ScreenGui")
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
b.MouseButton1Click:Connect(dash)

UIS.InputBegan:Connect(function(i, gp)
	if not gp and i.KeyCode == Enum.KeyCode.Q then dash() end
end)

-- LocalScript (Client) - Dash with afterimage effect
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ===== الإعدادات (عدّلها كما تريد) =====
local DASH_KEY = Enum.KeyCode.Q      -- زر الكمبيوتر
local DASH_SPEED = 100               -- سرعة الاندفاع
local DASH_DURATION = 0.25           -- مدة الاندفاع بالثواني
local DASH_COOLDOWN = 1              -- الانتظار قبل الاندفاع التالي
local CLONE_INTERVAL = 0.03          -- كل كم ثانية يظهر ظل جديد
local FADE_TIME = 0.5                -- مدة تلاشي الظل
local CLONE_COLOR = Color3.fromRGB(0, 170, 255)
-- ======================================

local canDash = true

-- إنشاء ظل واحد من الشخصية
local function createAfterimage(character)
	local clone = Instance.new("Model")
	clone.Name = character.Name .. "_Clone"

	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart")
			and part.Name ~= "HumanoidRootPart"
			and part.Transparency < 1
			and not part.Parent:IsA("Accessory") then

			local newPart = part:Clone()
			newPart:ClearAllChildren()
			newPart.Anchored = true
			newPart.CanCollide = false
			newPart.CanQuery = false
			newPart.CanTouch = false
			newPart.Material = Enum.Material.Neon
			newPart.Color = CLONE_COLOR
			newPart.Transparency = 0.5
			newPart.CFrame = part.CFrame
			newPart.Parent = clone

			TweenService:Create(
				newPart,
				TweenInfo.new(FADE_TIME),
				{Transparency = 1}
			):Play()
		end
	end

	clone.Parent = workspace

	-- حذف الظل بعد انتهاء التلاشي
	task.delay(FADE_TIME + 0.1, function()
		clone:Destroy()
	end)
end

-- تنفيذ الاندفاع
local function dash()
	if not canDash then return end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then return end

	canDash = false

	-- الاتجاه: حسب الحركة الحالية، وإن كان واقفاً فللأمام
	local direction = humanoid.MoveDirection
	if direction.Magnitude < 0.1 then
		direction = root.CFrame.LookVector
	end
	direction = Vector3.new(direction.X, 0, direction.Z).Unit

	local startTime = tick()
	local lastClone = 0
	local connection

	connection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime

		if elapsed >= DASH_DURATION or humanoid.Health <= 0 then
			connection:Disconnect()
			root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
			return
		end

		root.AssemblyLinearVelocity = direction * DASH_SPEED
			+ Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)

		if elapsed - lastClone >= CLONE_INTERVAL then
			lastClone = elapsed
			createAfterimage(character)
		end
	end)

	task.delay(DASH_COOLDOWN, function()
		canDash = true
	end)
end

-- زر الكمبيوتر
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == DASH_KEY then
		dash()
	end
end)

-- زر الجوال على الشاشة
local gui = Instance.new("ScreenGui")
gui.Name = "DashGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 90, 0, 90)
button.Position = UDim2.new(1, -120, 1, -200)
button.BackgroundColor3 = CLONE_COLOR
button.Text = "DASH"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

button.MouseButton1Click:Connect(dash)

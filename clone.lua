local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G
if env.TeleClonesCleanup then
	pcall(env.TeleClonesCleanup)
end

-- ===== الإعدادات =====
local DISTANCE = 6      -- المسافة بين كل نسخة والتي قبلها
local PER_SIDE = 1      -- عدد النسخ في كل جهة (1 = يمين ويسار، 2 = اثنتين في كل جهة)
-- =====================

local offsets = {0}
for i = 1, PER_SIDE do
	table.insert(offsets, -DISTANCE * i)
	table.insert(offsets, DISTANCE * i)
end

local enabled = true
local index = 0
local realCF = nil

local function getRoot()
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

-- قبل رسم الشاشة: رجّعني لمكاني الحقيقي
local preCon = RunService.RenderStepped:Connect(function()
	if realCF then
		local root = getRoot()
		if root then root.CFrame = realCF end
		realCF = nil
	end
end)

-- بعد الفيزياء: انقلني للمكان الجانبي (هذا اللي يُرسل للسيرفر)
local postCon = RunService.Heartbeat:Connect(function()
	if not enabled then return end
	local root = getRoot()
	if not root then return end
	index = index % #offsets + 1
	local off = offsets[index]
	if off == 0 then return end
	realCF = root.CFrame
	root.CFrame = realCF * CFrame.new(off, 0, 0)
end)

-- الواجهة
local gui = Instance.new("ScreenGui")
gui.Name = "TeleClonesGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local b = Instance.new("TextButton")
b.Size = UDim2.new(0, 110, 0, 50)
b.Position = UDim2.new(1, -140, 1, -200)
b.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
b.Text = "CLONES: ON"
b.TextScaled = true
b.Parent = gui
Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)

local x = Instance.new("TextButton")
x.Size = UDim2.new(0, 40, 0, 40)
x.Position = UDim2.new(1, -60, 1, -250)
x.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
x.Text = "X"
x.TextColor3 = Color3.new(1, 1, 1)
x.TextScaled = true
x.Parent = gui
Instance.new("UICorner", x).CornerRadius = UDim.new(1, 0)

local function destroyAll()
	preCon:Disconnect()
	postCon:Disconnect()
	if realCF then
		local root = getRoot()
		if root then root.CFrame = realCF end
		realCF = nil
	end
	gui:Destroy()
	env.TeleClonesCleanup = nil
end

b.MouseButton1Click:Connect(function()
	enabled = not enabled
	b.Text = enabled and "CLONES: ON" or "CLONES: OFF"
	b.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(120, 120, 120)
end)
x.MouseButton1Click:Connect(destroyAll)

UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.X then destroyAll() end
end)

env.TeleClonesCleanup = destroyAll

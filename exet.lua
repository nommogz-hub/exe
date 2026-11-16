local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptExecutorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 2. Main Window Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 450, 0, 300)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- 3. Title Bar (Draggable)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Script Runner UI"
titleLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- 4. Code Editor TextBox
local codeBox = Instance.new("TextBox")
codeBox.Name = "CodeBox"
codeBox.Size = UDim2.new(1, -20, 1, -90)
codeBox.Position = UDim2.new(0, 10, 0, 45)
codeBox.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
codeBox.TextColor3 = Color3.fromRGB(220, 220, 220)
codeBox.PlaceholderText = "-- Enter your Lua code here..."
codeBox.Text = 'print("Hello from Executor UI!")'
codeBox.Font = Enum.Font.Code
codeBox.TextSize = 14
codeBox.TextXAlignment = Enum.TextXAlignment.Left
codeBox.TextYAlignment = Enum.TextYAlignment.Top
codeBox.MultiLine = true
codeBox.ClearTextOnFocus = false
codeBox.Parent = mainFrame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = codeBox

-- 5. Action Buttons
local executeBtn = Instance.new("TextButton")
executeBtn.Name = "ExecuteButton"
executeBtn.Size = UDim2.new(0, 100, 0, 30)
executeBtn.Position = UDim2.new(0, 10, 1, -38)
executeBtn.BackgroundColor3 = Color3.fromRGB(65, 130, 230)
executeBtn.Text = "Execute"
executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
executeBtn.Font = Enum.Font.GothamSemibold
executeBtn.TextSize = 13
executeBtn.Parent = mainFrame

local execCorner = Instance.new("UICorner")
execCorner.CornerRadius = UDim.new(0, 6)
execCorner.Parent = executeBtn

local clearBtn = Instance.new("TextButton")
clearBtn.Name = "ClearButton"
clearBtn.Size = UDim2.new(0, 100, 0, 30)
clearBtn.Position = UDim2.new(0, 120, 1, -38)
clearBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
clearBtn.Text = "Clear"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.GothamSemibold
clearBtn.TextSize = 13
clearBtn.Parent = mainFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 6)
clearCorner.Parent = clearBtn

-- 6. Button Logic
clearBtn.MouseButton1Click:Connect(function()
	codeBox.Text = ""
end)

executeBtn.MouseButton1Click:Connect(function()
	local source = codeBox.Text
	if source == "" then return end
	
	-- Note: Requires loadstring enabled (e.g., Studio Plugins or Server-side with LoadStringEnabled)
	if loadstring then
		local func, err = loadstring(source)
		if func then
			task.spawn(func)
		else
			warn("Syntax Error:", err)
		end
	else
		warn("loadstring() is not available in this environment.")
	end
end)

-- 7. Simple Drag Functionality
local dragging, dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

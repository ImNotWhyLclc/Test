local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 120)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 160, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Clicker OFF"
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = frame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0, 160, 0, 40)
speedInput.Position = UDim2.new(0, 10, 0, 60)
speedInput.PlaceholderText = "Speed"
speedInput.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.ClearTextOnFocus = false
speedInput.Text = "0.01"
speedInput.Parent = frame

local clicking = false
local clickSpeed = 0.01

toggleButton.MouseButton1Click:Connect(function()
	clicking = not clicking
	toggleButton.Text = clicking and "Auto Clicker on" or "Auto Clicker off"
end)

speedInput.FocusLost:Connect(function()
	local val = tonumber(speedInput.Text)
	if val and val > 0 then
		clickSpeed = val
	else
		speedInput.Text = tostring(clickSpeed)
	end
end)

spawn(function()
	while true do
		if clicking then
			local VirtualUser = game:GetService("VirtualUser")
			VirtualUser:CaptureController()
			VirtualUser:ClickButton1(Vector2.new())
		end
		wait(clickSpeed)
	end
end)

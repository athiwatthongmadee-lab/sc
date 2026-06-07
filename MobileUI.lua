-- MobileUI.lua
-- ระบบ UI สำหรับการเล่นบนมือถือ
-- ✅ ใส่ที่: StarterPlayer > StarterPlayerScripts (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- สร้าง ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileControlGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ตัวแปรสำหรับจอยสติ๊ก
local touchStartPos = nil
local joystickActive = false

-- สร้างพื้นหลังจอยสติ๊ก
local joystickBackground = Instance.new("Frame")
joystickBackground.Name = "JoystickBackground"
joystickBackground.Size = UDim2.new(0, 150, 0, 150)
joystickBackground.Position = UDim2.new(0, 20, 0.85, -75)
joystickBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
joystickBackground.BackgroundTransparency = 0.5
joystickBackground.BorderSizePixel = 0
joystickBackground.Parent = screenGui

-- สร้างจุดจอยสติ๊ก
local joystickKnob = Instance.new("Frame")
joystickKnob.Name = "JoystickKnob"
joystickKnob.Size = UDim2.new(0, 80, 0, 80)
joystickKnob.Position = UDim2.new(0.5, -40, 0.5, -40)
joystickKnob.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
joystickKnob.BackgroundTransparency = 0.3
joystickKnob.BorderSizePixel = 0
joystickKnob.Parent = joystickBackground

-- สร้างมุมจอยสติ๊ก
local uiCornerJoystick = Instance.new("UICorner")
uiCornerJoystick.CornerRadius = UDim.new(1, 0)
uiCornerJoystick.Parent = joystickKnob

-- สร้างปุ่มโจมตี
local attackButton = Instance.new("TextButton")
attackButton.Name = "AttackButton"
attackButton.Size = UDim2.new(0, 100, 0, 100)
attackButton.Position = UDim2.new(1, -130, 0.85, -50)
attackButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
attackButton.BackgroundTransparency = 0.3
attackButton.Text = "⚔️\nAttack"
attackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
attackButton.TextSize = 16
attackButton.Font = Enum.Font.GothamBold
attackButton.BorderSizePixel = 0
attackButton.Parent = screenGui

-- สร้างมุมปุ่มโจมตี
local uiCornerAttack = Instance.new("UICorner")
uiCornerAttack.CornerRadius = UDim.new(1, 0)
uiCornerAttack.Parent = attackButton

-- สร้างปุ่มกระโดด
local jumpButton = Instance.new("TextButton")
jumpButton.Name = "JumpButton"
jumpButton.Size = UDim2.new(0, 100, 0, 100)
jumpButton.Position = UDim2.new(1, -240, 0.85, -50)
jumpButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
jumpButton.BackgroundTransparency = 0.3
jumpButton.Text = "⬆️\nJump"
jumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpButton.TextSize = 16
jumpButton.Font = Enum.Font.GothamBold
jumpButton.BorderSizePixel = 0
jumpButton.Parent = screenGui

-- สร้างมุมปุ่มกระโดด
local uiCornerJump = Instance.new("UICorner")
uiCornerJump.CornerRadius = UDim.new(1, 0)
uiCornerJump.Parent = jumpButton

-- สร้างตัวแสดง HP
local healthLabel = Instance.new("TextLabel")
healthLabel.Name = "HealthLabel"
healthLabel.Size = UDim2.new(0, 200, 0, 50)
healthLabel.Position = UDim2.new(0.5, -100, 0, 10)
healthLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
healthLabel.BackgroundTransparency = 0.5
healthLabel.Text = "❤️ HP: 100/100"
healthLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
healthLabel.TextSize = 20
healthLabel.Font = Enum.Font.GothamBold
healthLabel.BorderSizePixel = 0
healthLabel.Parent = screenGui

-- สร้างแถบ HP
local healthBar = Instance.new("Frame")
healthBar.Name = "HealthBar"
healthBar.Size = UDim2.new(0, 200, 0, 20)
healthBar.Position = UDim2.new(0.5, -100, 0, 55)
healthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
healthBar.BackgroundTransparency = 0.5
healthBar.BorderSizePixel = 0
healthBar.Parent = screenGui

local healthFill = Instance.new("Frame")
healthFill.Name = "HealthFill"
healthFill.Size = UDim2.new(1, 0, 1, 0)
healthFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
healthFill.BorderSizePixel = 0
healthFill.Parent = healthBar

-- ฟังก์ชันจำลองจอยสติ๊ก
local function updateJoystick(touchPos)
	if not touchPos then return end
	
	local backgroundCenter = joystickBackground.AbsolutePosition + joystickBackground.AbsoluteSize * 0.5
	local delta = touchPos - backgroundCenter
	local distance = math.sqrt(delta.X^2 + delta.Y^2)
	local maxDistance = joystickBackground.AbsoluteSize.X * 0.5
	
	if distance > maxDistance then
		delta = delta / distance * maxDistance
	end
	
	joystickKnob.Position = UDim2.new(0.5, delta.X - 40, 0.5, delta.Y - 40)
end

-- ฟังก์ชันรีเซ็ตจอยสติ๊ก
local function resetJoystick()
	joystickKnob.Position = UDim2.new(0.5, -40, 0.5, -40)
	joystickActive = false
end

-- เหตุการณ์ Touch
local function onTouchBegan(touch, gameProcessed)
	if gameProcessed then return end
	
	local touchPos = touch.Position
	local bgAbsPos = joystickBackground.AbsolutePosition
	local bgAbsSize = joystickBackground.AbsoluteSize
	
	if touchPos.X >= bgAbsPos.X and touchPos.X <= bgAbsPos.X + bgAbsSize.X and
	   touchPos.Y >= bgAbsPos.Y and touchPos.Y <= bgAbsPos.Y + bgAbsSize.Y then
		touchStartPos = touchPos
		joystickActive = true
	end
end

local function onTouchMoved(touch, gameProcessed)
	if joystickActive and touchStartPos then
		updateJoystick(touch.Position)
	end
end

local function onTouchEnded(touch, gameProcessed)
	if joystickActive then
		resetJoystick()
	end
end

-- เชื่อมต่อเหตุการณ์ Touch
UserInputService.TouchBegan:Connect(onTouchBegan)
UserInputService.TouchMoved:Connect(onTouchMoved)
UserInputService.TouchEnded:Connect(onTouchEnded)

-- ปุ่มกระโดด
jumpButton.MouseButton1Click:Connect(function()
	humanoid:Jump()
	print("⬆️ กระโดด!")
end)

-- ปุ่มโจมตี
attackButton.MouseButton1Click:Connect(function()
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		-- ค้นหาศัตรูในระยะ
		local enemiesNearby = workspace:FindPartBoundsInRadius(rootPart.Position, 20)
		
		for _, part in pairs(enemiesNearby) do
			if part.Parent and part.Parent:FindFirstChild("Humanoid") then
				local enemyHumanoid = part.Parent:FindFirstChild("Humanoid")
				if enemyHumanoid and part.Parent ~= character then
					enemyHumanoid:TakeDamage(25)
					print("💥 โจมตี: " .. part.Parent.Name)
				end
			end
		end
	end
end)

-- ปรับปรุง HP ตัวแสดง
local maxHealth = humanoid.MaxHealth
humanoid.HealthChanged:Connect(function(health)
	local healthPercent = math.max(0, health / maxHealth)
	healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
	healthLabel.Text = "❤️ HP: " .. math.floor(health) .. "/" .. math.floor(maxHealth)
	
	if healthPercent < 0.3 then
		healthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	elseif healthPercent < 0.6 then
		healthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
	else
		healthFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
	end
end)

print("✅ MobileUI โหลดแล้ว!")

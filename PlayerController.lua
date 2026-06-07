-- PlayerController.lua
-- ระบบควบคุมผู้เล่นสำหรับเกม Roblox Combat
-- ✅ ใส่ที่: StarterPlayer > StarterCharacterScripts (LocalScript)
-- รองรับการเล่นบนมือถือและพีซี

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ตัวแปรการเคลื่อนไหว
local moveSpeed = 16
local jumpPower = 50
local isMoving = false
local moveDirection = Vector3.new(0, 0, 0)

-- ตัวแปรการต่อสู้
local attackCooldown = 0
local attackDamage = 25
local attackRange = 20
local isAttacking = false

-- ฟังก์ชันสำหรับการวิ่ง
local function movePlayer(direction)
	if character and humanoid and humanoid.Health > 0 then
		humanoid:Move(direction, false)
	end
end

-- ฟังก์ชันสำหรับการกระโดด
local function jump()
	if character and humanoid and humanoid.Health > 0 then
		humanoid:Jump()
	end
end

-- ฟังก์ชันสำหรับการโจมตี
local function attack()
	if attackCooldown <= 0 and not isAttacking then
		isAttacking = true
		attackCooldown = 1 -- Cooldown 1 วินาที
		
		-- ค้นหาศัตรูในระยะ
		local enemiesNearby = workspace:FindPartBoundsInRadius(rootPart.Position, attackRange)
		
		for _, part in pairs(enemiesNearby) do
			if part.Parent and part.Parent:FindFirstChild("Humanoid") then
				local enemyHumanoid = part.Parent:FindFirstChild("Humanoid")
				if enemyHumanoid and part.Parent ~= character then
					enemyHumanoid:TakeDamage(attackDamage)
					print("💥 โจมตี: " .. part.Parent.Name .. " ได้รับความเสียหาย " .. attackDamage)
				end
			end
		end
		
		isAttacking = false
	end
end

-- ควบคุมด้วยแป้นพิมพ์ (พีซี)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.W then
		moveDirection = moveDirection + Vector3.new(0, 0, -1)
	elseif input.KeyCode == Enum.KeyCode.A then
		moveDirection = moveDirection + Vector3.new(-1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.S then
		moveDirection = moveDirection + Vector3.new(0, 0, 1)
	elseif input.KeyCode == Enum.KeyCode.D then
		moveDirection = moveDirection + Vector3.new(1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.Space then
		jump()
	elseif input.KeyCode == Enum.KeyCode.E then
		attack()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.W then
		moveDirection = moveDirection - Vector3.new(0, 0, -1)
	elseif input.KeyCode == Enum.KeyCode.A then
		moveDirection = moveDirection - Vector3.new(-1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.S then
		moveDirection = moveDirection - Vector3.new(0, 0, 1)
	elseif input.KeyCode == Enum.KeyCode.D then
		moveDirection = moveDirection - Vector3.new(1, 0, 0)
	end
end)

-- ลูปการเคลื่อนไหวหลัก
game:GetService("RunService").RenderStepped:Connect(function()
	-- ปรับปรุง Cooldown
	if attackCooldown > 0 then
		attackCooldown = attackCooldown - game:GetService("RunService").RenderStepped:Wait()
	end
	
	-- ปรับปรุงการเคลื่อนไหว
	if moveDirection.Magnitude > 0 then
		movePlayer(moveDirection.Unit)
	end
end)

print("✅ PlayerController โหลดแล้ว!")

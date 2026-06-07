-- CombatSystem.lua
-- ระบบการต่อสู้ (Combat System) สำหรับเกม Roblox
-- ✅ ใส่ที่: ServerScriptService (คลิกขวา → Insert Object → Script)

local Players = game:GetService("Players")

-- ตัวแปรการต่อสู้
local combatConfig = {
	attackDamage = 25,
	attackCooldown = 1,
	attackRange = 25,
	knockbackForce = 50,
	attackAnimation = "Attack"
}

-- ฟังก์ชันสำหรับการโจมตี
local function performAttack(attacker, attackerRootPart)
	-- ค้นหาศัตรูในระยะ
	local enemiesInRange = workspace:FindPartBoundsInRadius(attackerRootPart.Position, combatConfig.attackRange)
	
	for _, part in pairs(enemiesInRange) do
		if part.Parent and part.Parent:FindFirstChild("Humanoid") then
			local targetHumanoid = part.Parent:FindFirstChild("Humanoid")
			local targetRootPart = part.Parent:FindFirstChild("HumanoidRootPart")
			
			-- ตรวจสอบว่าไม่ใช่ตัวเองหรือเพื่อนสนิท
			if targetHumanoid and targetRootPart and part.Parent ~= attacker then
				-- ทำความเสียหาย
				targetHumanoid:TakeDamage(combatConfig.attackDamage)
				
				-- เพิ่ม Knockback
				local direction = (targetRootPart.Position - attackerRootPart.Position).Unit
				targetRootPart.AssemblyLinearVelocity = targetRootPart.AssemblyLinearVelocity + direction * combatConfig.knockbackForce
				
				print("💥 " .. attacker.Name .. " โจมตี " .. part.Parent.Name .. " เสียหาย: " .. combatConfig.attackDamage)
				
				-- ปล่อยเอฟเฟคเนื้อดุ
				createHitEffect(targetRootPart)
			end
		end
	end
end

-- ฟังก์ชันสร้างเอฟเฟคการโจมตี
local function createHitEffect(targetPart)
	local effect = Instance.new("Part")
	effect.Shape = Enum.PartType.Ball
	effect.Size = Vector3.new(1, 1, 1)
	effect.Color = Color3.fromRGB(255, 100, 50)
	effect.CanCollide = false
	effect.CFrame = targetPart.CFrame
	effect.TopSurface = Enum.SurfaceType.Smooth
	effect.BottomSurface = Enum.SurfaceType.Smooth
	effect.Parent = workspace
	
	-- ลบเอฟเฟคหลังจาก 0.3 วินาที
	game:GetService("Debris"):AddItem(effect, 0.3)
end

-- ฟังก์ชันสำหรับการป้องกัน (Block)
local function performBlock(character)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		print("🛡️ " .. character.Name .. " ป้องกัน!")
		
		-- ปล่อยเอฟเฟคป้องกัน
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local blockEffect = Instance.new("Part")
			blockEffect.Shape = Enum.PartType.Ball
			blockEffect.Size = Vector3.new(2, 2, 2)
			blockEffect.Color = Color3.fromRGB(100, 150, 255)
			blockEffect.CanCollide = false
			blockEffect.CFrame = rootPart.CFrame
			blockEffect.TopSurface = Enum.SurfaceType.Smooth
			blockEffect.BottomSurface = Enum.SurfaceType.Smooth
			blockEffect.Parent = workspace
			
			game:GetService("Debris"):AddItem(blockEffect, 0.5)
		end
	end
end

-- ฟังก์ชันสำหรับจัดการการเสียหาย
local function onDamageTaken(humanoid, damage)
	print("⚠️ ได้รับความเสียหาย: " .. damage)
end

-- ฟังก์ชันสำหรับการตายของผู้เล่น
local function onCharacterDied(character, humanoid)
	print("💀 " .. character.Name .. " ตาย!")
	
	-- สร้างเอฟเฟคการตาย
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		for i = 1, 5 do
			local particle = Instance.new("Part")
			particle.Shape = Enum.PartType.Ball
			particle.Size = Vector3.new(0.5, 0.5, 0.5)
			particle.Color = Color3.fromRGB(200, 50, 50)
			particle.CanCollide = false
			particle.CFrame = rootPart.CFrame + Vector3.new(math.random(-2, 2), math.random(2, 4), math.random(-2, 2))
			particle.TopSurface = Enum.SurfaceType.Smooth
			particle.BottomSurface = Enum.SurfaceType.Smooth
			particle.Parent = workspace
			
			local velocity = Vector3.new(math.random(-20, 20), math.random(10, 30), math.random(-20, 20))
			particle.AssemblyLinearVelocity = velocity
			
			game:GetService("Debris"):AddItem(particle, 2)
		end
	end
end

-- ฟังก์ชันสำหรับเชื่อมต่อระบบต่อสู้กับผู้เล่น
local function setupCombatForPlayer(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	
	-- เชื่อมต่อการเสียหาย
	humanoid.Damaged:Connect(function(damage)
		onDamageTaken(humanoid, damage)
	end)
	
	-- เชื่อมต่อการตาย
	humanoid.Died:Connect(function()
		onCharacterDied(character, humanoid)
	end)
end

-- เชื่อมต่อกับผู้เล่นใหม่
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		wait(0.1) -- รอให้โครงสร้างโหลดเสร็จ
		setupCombatForPlayer(player)
	end)
end)

-- เชื่อมต่อกับผู้เล่นที่มีอยู่
for _, player in pairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(function(character)
		wait(0.1)
		setupCombatForPlayer(player)
	end)
end

print("✅ CombatSystem โหลดแล้ว!")

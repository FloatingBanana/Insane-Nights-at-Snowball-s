local snowball = {
    camera = 4,
    step = 1,
    moveList = {},
	AI = 0,
	
	door_fade = 0
}

local function wayGen()
	local move = {4,5}
	local roomLB, roomS, roomH = 0,0,0
	
	math.randomseed(os.time())
	
	while move[#move] ~= -1 do
		if move[#move] == 5 then
			if random(1,3) == 1 and roomLB < 2 then
				toLast(move, boolto(random(1,2)==1,6,7))
				toLast(move, 5)
				roomLB = roomLB + 1
			else
				toLast(move, 9)
			end
		end
		
		if move[#move] == 9 then
			if random(1,3) == 1 and roomS < 2 then
				toLast(move, 5)
				roomS = roomS + 1
			else
				toLast(move, 10)
				if random(1,4) == 1 and roomH < 3 then
					toLast(move, 9)
					roomH = roomH + 1
				else
					toLast(move, -1)
				end
			end
		end
	end
	return move
end

local stepTimer = 45
local pose = 0
local poses = {
	[4] = 1,
	[10] = 4
}

local from, to, staticTime = 0,0,0
local doorTimer, jumpsTimer = 0,0

function snowball:enter()
	from, to, staticTime = 0,0,0
	doorTimer, jumpsTimer = 0,0
	self.moveList = wayGen()
	self.camera = 4
	self.step = 1
	stepTimer = random(45, 55) - self.AI
end

function snowball:draw()
	lg.draw(res.moves.snowball[self.camera + pose * .1], -tracker, 0, 0, lowgraphics)
end

function snowball:update()
	if staticTime > 0 then
		if camera == from or camera == to then
			staticInt = 175
		end
		staticTime = staticTime - dt
	else
		from, to, staticTime = 0,0,0
	end
	
	self.danger = self.camera == -1

	if self.camera > 0 then
		stepTimer = stepTimer - lume.random(0.5, 1.5) * dt

		if random(1, 35) == 1 and floor(Ftimer * 50) % 250 == 0 and camera ~= self.camera then
			pose = random(0, poses[self.camera] or 0)
		end
	
		if stepTimer <= 0 then
			stepTimer = 30 - self.AI
			
			if (camera == self.camera or camera == self.moveList[self.step + 1]) and not controlPanel and cameraUp then
				from, to, staticTime = self.camera, self.moveList[self.step + 1], 3
			end
			pose = 0
			
			self.step = self.step + 1
			self.camera = self.moveList[self.step]
        
			if self.step == #self.moveList then
				jumpsTimer, doorTimer = 13 - self.AI/2, 5 + self.AI/2

				self.door_fade = 0
				
				sound = res.sounds.deepsteps:clone()
				sound:setRelative(true)
				sound:setPosition(-1, 0, 0)
				sound:setVolume(0.8)
				sound:play()
			end
		end
	else
		doorTimer = doorTimer - boolto(leftDoor) * lume.random(0.5,1.5) * dt
		jumpsTimer = jumpsTimer - boolto(not leftDoor) * lume.random(0.5,1.5) * dt

		self.door_fade = min(self.door_fade + 3 * dt, 1)
    
		if doorTimer <= 0 then
			doorTimer = 3
			to = 5
			stepTimer = 45 - self.AI
			
			self.step = 2
			self.camera = 5
			self.moveList = wayGen()
		end

		if jumpsTimer <= 0 and not leftDoor and (cameraUp or turnBackTimer == 5) then
			jumpscare("snowball")
		end
	end
end

return snowball
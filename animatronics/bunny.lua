local bunny = {
	camera = 4,
	step = 1,
	moveList = {},
	AI = 1,
	danger = false,

	door_fade = 0
}

local function wayGen()
	local move = {4,5}
	local roomH, roomF, roomS, roomP, roomBS = 0, 0, 0, 0, 0
	
	math.randomseed(os.time())
	
	while move[#move] ~= -2 and move[#move] ~= -3 do
		if move[#move] == 5 then
			toLast(move, boolto(random(1,2)==1,1,11))
		end
		
		if move[#move] == 11 then
			if roomH < 2 and random(1,3) == 1 then
				roomH = roomH + 1
				
				if random(1,3) == 1 then
					lume.push(move,12,11)
				end
				toLast(move, 5)
			else
				lume.push(move,12,-2)
			end
		elseif move[#move] == 1 then
			if roomS < 1 and random(1,3) == 1 then
				roomS = roomS + 1
				toLast(move, 5)
			else
				if roomF < 2 and random(1,2) == 1 then
					roomF = roomF + 1
					lume.push(move,2,1)
				end
				toLast(move, 13)
			end
		elseif move[#move] == 13 then
			if roomBS < 1 and random(1,3) == 1 then
				roomBS = roomBS + 1
				toLast(move, 1)
			elseif roomP < 2 and random(1,3) == 1 then
				roomP = roomP + 1
				toLast(move, boolto(random(1,2)==1,3,14))
				toLast(move, 13)
			else
				toLast(move, -3)
			end
		end
	end
	
	return move
end

local stepTimer = 40
local pose = 1
local poses = {
	[4] = 1,
	[5] = 1,
	[14] = 1
}

local from, to, staticTime = 0,0,0
local doorTimer, jumpsTimer = 0,0

function bunny:enter()
	stepTimer = random(40, 50) - self.AI
	jumpsTimer, doorTimer = 0,0
	from, to, staticTime = 0,0,0
	self.camera = 4
	self.step = 1
	self.moveList = wayGen()
end

function bunny:draw()
	lg.draw(res.moves.bunny[self.camera + pose * .1], -tracker, 0, 0, lowgraphics)
end

function bunny:update()
	if staticTime > 0 then
		if camera == from or camera == to then
			staticInt = 0.7
		end
		
		staticTime = staticTime - dt
	else
		from, to, staticTime = 0,0,0
	end
	
	self.danger = self.step == #self.moveList

	if self.camera > 0 then 
		stepTimer = stepTimer - lume.random(0.5,2.5) * dt

		if random(1,35) == 1 and floor(Ftimer*50) % 250 == 0 and camera ~= self.camera then
			pose = random(0, poses[self.camera] or 0)
		end

		if stepTimer <= 0 then
			stepTimer = 30 - self.AI
			
			if (camera == self.camera or camera == self.moveList[self.step + 1]) and not controlPanel and cameraUp then
				from, to, staticTime = self.camera, self.moveList[self.step + 1], 4
			end
			
			pose = 0
			self.step = self.step + 1
			self.camera = self.moveList[self.step]
			
			if self.camera == -2 then
				jumpsTimer, doorTimer = 12.5 - self.AI/2, 3 + self.AI/3

				self.door_fade = 0
				
				sound = res.sounds.deepsteps:clone()
				sound:setRelative(true)
				sound:setPosition(1, 0, 0)
				sound:setVolume(0.5)
				sound:play()
			end
			if self.camera == -3 then
				jumpsTimer, doorTimer = 13 - self.AI/2, 2.5 + self.AI/3

				self.door_fade = 0
				
				sound = res.sounds.vent:clone()
				sound:setRelative(true)
				sound:setPosition(1, 0, 0)
				sound:setVolume(0.5)
				sound:play()
			end
		end
	else
		local readyToAttack = (not rightDoor and self.camera == -2) or (not duct and self.camera == -3)
		
		doorTimer = doorTimer - boolto(not readyToAttack, dt)
		jumpsTimer = jumpsTimer - boolto(readyToAttack, dt)

		self.door_fade = min(self.door_fade + 3 * dt, 1)

		if doorTimer <= 0 then
			doorTimer = 3
			to = 5
			stepTimer = 35 - self.AI
			self.camera = 5
			self.step = 1
			self.moveList = wayGen()
		end

		if jumpsTimer <= 0 and readyToAttack and (cameraUp or turnBackTimer == 5) then
			jumpscare("bunny")
		end
	end
end

return bunny
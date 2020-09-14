local larry = {
	camera = 7,
	step = 1,
	AI = 0,
	danger = false
}

local stepTimer = 45

local mctimer = 0
local doorTimer, jumpsTimer = 0,0

function larry:enter()
	from, staticTime = 0,0
	doorTimer, jumpsTimer = 0,0
	self.camera = 7
	self.step = 1
	stepTimer = random(45, 55) - self.AI
	mctimer = 6.5 - self.AI/4
end

function larry:draw()
	if self.step > 1 then
		lg.draw(res.moves.larry[self.step-1], -tracker, 0, 0, lowgraphics)
	end
end

function larry:update()
	--Spawn a mini-clown in a random camera
	if mctimer <= 0 then
		mctimer = 8 - self.AI/4
		
		local validClowns = emptyTable()
		local validCameras = emptyTable()

		for i=1, 5 do
			if not lume.all(clownsData[i].vis) then
				validClowns[#validClowns+1] = i
			end
		end
		
		if #validClowns > 0 then
			local rngClown = lume.randomchoice(validClowns)
			
			for i=1, 14 do
				if not clownsData[rngClown].vis[i] then
					validCameras[#validCameras+1] = i
				end
			end

			local rngCamera = lume.randomchoice(validCameras)
			clownsData[rngClown].vis[rngCamera] = true
			
			updateClowns()
			if camera == rngCamera then
				staticInt = 0.7
			end
		end

		recicleTable(validClowns)
		recicleTable(validCameras)
	end
	
	self.danger = self.step == 6

	if self.camera == 7 then
		if camera ~= 7 then
			mctimer = mctimer - lume.random(0.5,1) * dt
			stepTimer = stepTimer - lume.random(0.5, 1.5) * dt
		elseif not cameraUp or controlPanel then
			mctimer = mctimer - lume.random(0.25,0.5) * dt
			stepTimer = stepTimer - lume.random(0.25,0.75) * dt
		end
		
		if stepTimer <= 0 then
			stepTimer = 45 - self.AI
			self.step = self.step + 1
			
			if camera == 7 then
				staticInt = 0.7
			end
		end
		
		if self.step == 6 then
			self.camera = -random(1, 2)
			doorTimer = 6 + self.AI/4
			jumpsTimer = 8 - self.AI/3
			
			sound = res.sounds.deepsteps:clone()
			sound:setRelative(true)
			sound:setPosition(boolto(self.camera == -1, -1, 1), 0, 0)
			sound:setVolume(0.3)
			sound:play()
		end
	else
		local readyToAttack = (not leftDoor and self.camera == -1) or (not rightDoor and self.camera == -2)
		
		jumpsTimer = jumpsTimer - boolto(readyToAttack, dt)
		doorTimer = doorTimer - boolto(not readyToAttack, dt)
	
		if doorTimer <= 0 then
			self.camera = 7
			self.step = 1
			stepTimer = 45 - self.AI
			if camera == 7 then
				staticInt = 0.7
			end
		end
		if jumpsTimer <= 0 and readyToAttack and (cameraUp or turnBackTimer == 5) then
			jumpscare("larry")
		end
	end
end

return larry
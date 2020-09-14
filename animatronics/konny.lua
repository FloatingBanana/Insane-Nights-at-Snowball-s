local konny = {
	camera = 8,
	step = 1,
	AI = 0
}

local stepTimer = 0
local jumpsTimer = 0

local laughtime = 0

local from, staticTime = 0,0

function konny:enter()
	stepTimer = 30 - self.AI
	self.camera = 8
	self.step = 1
	self.cameraWarn = false
	jumpsTimer = 0
	from, staticTime = 0,0
end

function konny:draw()
	if self.step < 3 then
		lg.draw(res.moves.konny[self.step], -tracker, 0, 0, lowgraphics)
	end
end

function konny:update()
	self.danger = self.step == 3

	self.cameraWarn = false
	if self.step < 3 then
		if (oxygenPercent > 70 and oxygen) or (oxygenPercent < 30 and not oxygen) then
			stepTimer = stepTimer - lume.random(.5, 1.5) * dt
			self.cameraWarn = true

		elseif stepTimer < 30 - self.AI then
			stepTimer = stepTimer + 0.15 * dt
		end
		
		if stepTimer < 0 then
			stepTimer = 30 - self.AI
			self.step = self.step + 1
			
			if camera == self.camera then
				staticInt = 0.7
			end
			
			if self.step == 3 then
				self.camera = -random(1, 2)
				jumpsTimer = 12 - self.AI/2

				laughtime = 0
			end
		end
	else
		local readyToAttack = (self.camera == -1 and not leftDoor) or (self.camera == -2 and not rightDoor)
		jumpsTimer = jumpsTimer - boolto(readyToAttack, dt)

		laughtime = laughtime - dt

		if laughtime <= 0 then
			res.sounds.konnylaugh:stop()
			res.sounds.konnylaugh:setRelative(true)
			res.sounds.konnylaugh:setPosition(boolto(self.camera == -1, -1, 1), 0, 0)
			res.sounds.konnylaugh:setVolume(0.5)
			res.sounds.konnylaugh:play()

			laughtime = 10
		end
		
		if jumpsTimer <= 0 and readyToAttack and (cameraUp or turnBackTimer == 5) then
			jumpscare("konny")
		end
	end
end

return konny
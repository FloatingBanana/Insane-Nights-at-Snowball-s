local endo = {
	camera = 10,
	AI = 1,
	step = 1
}

local stepTimer = 0
local doorTimer = 0

function endo:enter()
	self.camera = 10
	self.step = 1

	doorTimer = 0
	stepTimer = 35 - self.AI

	res.sounds.metalscrap:setPosition(-1, 0, 0)
	res.sounds.metalscrap:setVolume(0.7)
end

function endo:draw()
	lg.draw(res.moves.endo[self.step], -tracker, 0, 0, lowgraphics)
end

function endo:update()
	if self.camera == 10 then
		stepTimer = stepTimer - lume.random(0.5, 1.5) * dt
		
		if stepTimer <= 0 then
			stepTimer = 35 - self.AI
			self.step = self.step + 1
			
			if camera == self.camera then
				staticInt = 0.7
			end

			if self.step == 3 then
				self.camera = -1
				doorTimer = 6 + self.AI * .75
				
				if dbg.load_voices then
					local voice = res.voices.endo[random(1, 3)]
					
					voice:setPosition(-1, 0, 0)
					voice:setVolume(0.7)
					voice:play()
				end
			end
		end
	else
		doorTimer = doorTimer - dt
		
		--Open door
		if leftDoor then
			leftDoor = not leftDoor

			res.sounds.door:stop()
			res.sounds.door:setPitch(lume.random(0.9,1))
			res.sounds.door:play()
		end
		
		if not res.sounds.metalscrap:isPlaying() then
			res.sounds.metalscrap:play()
		end

		if doorTimer <= 0 then
			res.sounds.metalscrap:stop()
			self.camera = 10
			self.step = 1
			stepTimer = random(35,45) - self.AI
			
			if camera == self.camera then
				staticInt = 0.7
			end
		end
	end
end

return endo
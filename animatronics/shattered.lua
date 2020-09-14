local shattered = {
	camera = 0,
	step = 0,
	AI = 0
}


local stepTimer = 0
local jumpsTimer = 0

local moveList = {1,2,5,6,7,8,9,10,13,14}

local from, to, staticTime = 0,0,0

function shattered:enter()
	from, to, staticTime = 0,0,0
	self.camera = 0
	self.step = 0
	stepTimer = lume.random(25, 35) - self.AI/2
end

function shattered:draw()
	lg.draw(res.moves.shattered[self.camera], -tracker, 0, 0, lowgraphics)
end

function shattered:update()
	if staticTime > 0 then
		staticTime = staticTime - dt
		
		if camera == from or camera == to then
			staticInt = 0.7
		else
			staticTime = 0
		end
	else
		from, to, staticTime = 0,0,0
	end

	if self.step < 6 then
		if stepTimer > 0 then
			stepTimer = stepTimer - lume.random(0.6, 1.5) * dt
		else
			from = self.camera
			self.camera = moveList[random(1, #moveList)]
			to = self.camera
			self.step = self.step + 1
			stepTimer = 25 - self.AI/2
			staticTime = 3
			
			if self.step >= 6 then
				jumpsTimer =  10 - self.AI/3
				
				if cameraUp then
					gamestates.office:keypressed("w")
				end
				
				timer.every(.5, function()
					local r = random(1,3)

					if  r == 1 then
						gamestates.office:keypressed("d")
					elseif r == 2 then
						gamestates.office:keypressed("a")
					else
						gamestates.office:keypressed("f")
					end
				
					if cameraUp and not controlPanel then
						camera = random(1,14)
						staticInt = 0.7
						
						res.sounds.camerachange:stop()
						res.sounds.camerachange:setPitch(lume.random(0.9,1))
						res.sounds.camerachange:play()
					end
					
					return not jumpscaring
				end)
			end
		end
	else
		if jumpsTimer > 0 then
			jumpsTimer = jumpsTimer - lume.random(0.5,1.3) * dt
			
			if roomlight <= 0.6 then
				roomlight = 0.8
			end
		else
			jumpscare("shattered")
		end
	end
end

return shattered
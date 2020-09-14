local beavy = {
	step = 1,
	AI = 0,
	danger = false
}

local stepTimer = 0

function beavy:enter()
	stepTimer = 7
	self.step = 1

	res.sounds.singlestep:setVolume(.7)
end

function beavy:draw()
	if beavy.step < 4 then
		lg.draw(res.moves.beavy[beavy.step], -tracker, 0, 0, lowgraphics)
	end
end

function beavy:update()
	self.danger = self.step >= 3

	if not isBack then
		stepTimer = stepTimer - dt

		if stepTimer <= 0 then
			stepTimer = 5
			
			if random(1, 25) <= self.AI/2 then
				res.sounds.singlestep:play()

				self.step = self.step + 1
				stepTimer = 10
			end
		end
	
		if self.step == 4 then
			isBack = true
			tabletAnim = false
			
			jumpscare("beavy")
		end
	end
end

return beavy
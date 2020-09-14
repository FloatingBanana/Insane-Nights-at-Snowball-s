local snsnowball = {
    cam = 9,
    entering = false,
}

local stepTimer = 0
local step = 0
local moveList = {}
local sndoor = 0
local snfront = 0
local snjumps = 0

local poseAlt = 0
local from, to, staticTime = 0, 0, 0

local function wayGen()
	local move = {9, 8}

	math.randomseed(os.time())

	while move[#move] > 0 do
		if move[#move] == 8 then
			toLast(move, 5)
		end

		if move[#move] == 5 then
			if random(1, 6) == 1 then
				toLast(move, 8)
			elseif random(1, 3) == 1 then
				toLast(move, -1)
			elseif random(1, 4) == 1 then
				toLast(move, boolto(random(1, 2) == 1, 1, 3))
				toLast(move, 5)
			else
				toLast(move, boolto(random(1, 2) == 1, 2, 4))
			end
		end

		if move[#move] == 2 then
			if random(1, 3) == 1 then
				toLast(move, 5)
			else
				toLast(move, 6)
				toLast(move, boolto(random(1,5) == 1, 2, -2))
			end
		end

		if move[#move] == 4 then
			if random(1, 3) == 1 then
				toLast(move, 5)
			else
				toLast(move, 7)
				toLast(move, boolto(random(1,5) == 1, 4, -3))
			end
		end
    end
    
	return move
end

function snsnowball:enter()
	self.cam = 9
	poseAlt = 1
	step = 1
	stepTimer = 30
	moveList = wayGen()

	res.sounds.vent:setVolume(0.5)
end

function snsnowball:draw(tracker)
    lg.draw(res.move[self.cam * poseAlt], -tracker, 0, 0, lowgraphics)
end

function snsnowball:update()
    if self.cam > 0 then
		stepTimer = stepTimer - lume.random(0.5, 2 + (self.office.heat - 60)/15) * dt

		if stepTimer <= 0 then
			step = step + 1
			stepTimer = 18 - self.office.hour * 2
			self.cam = moveList[step]
            
            if res.move[self.cam * 0.1] and random(1, 2) == 1 then
                poseAlt = 0.1
            else
                poseAlt = 1
            end
			
			if (self.office.camera == self.cam or self.office.camera == moveList[step - 1]) and self.office.tabletAnim then
				from, to, staticTime = moveList[step-1], self.cam, lume.random(2, 3)
			end

			if self.cam == 6 or self.cam == 7 then
				res.sounds.vent:play()
			end

			if self.cam < 0 then
				if self.cam == -1 then
                    snfront = lume.random(6, 12)
                    
                    res.sounds.deepsteps:play()
                    
					self.entering = true

					timer.after(4, function()
						self.entering = false
					end)
				else
					sndoor = lume.random(4, 6)
					snfront = lume.random(3.5, 7)
                end
			end
		end
	else

		-- Snowball on ducts
		if self.cam == -2 or self.cam == -3 then
			local val = (self.office.heat - 60)/30

			if self.cam == -2 and self.office.leftDoor or self.cam == -3 and self.office.rightDoor then
				sndoor = sndoor - lume.random(0.2, 1.8 + val) * dt
			else
				snfront = snfront - lume.random(0.4, 1.6 + val) * dt
			end
			
			if sndoor <= 0 then
				self.cam = 9
				step = 2
				moveList = wayGen()
			end
		end
		
		-- Time for entering the office
		if self.cam == -1 then
			local val = (self.office.heat - 60)/30

			if self.office.cameraUp or self.office.leaksUp then
				snfront = snfront - lume.random(0.6, 1.4 + val) * dt
			else
				snfront = snfront - lume.random(0.3, 0.7 + val) * dt
			end
		end
		
		-- Snowball enters the office
		if snfront <= 0 and (self.office.cameraUp or self.office.leaksUp or self.office.roomlight >= 0.95) then

			--Turn tablet down when snowball enters
			if self.cam ~= -4 and not self.office.anyFixing and random(1, 4) == 1 and self.office.tabletType ~= "shock" then
				self.office.tabletAnim = false
			end
			
			snjumps = 8 - self.office.hour/2
            
			self.cam = -4
		end
		
		-- ANCHOR Front jumpscare
		if self.cam == -4 and not self.office.controlShock then
			if self.office.roomlight < 0.7 and not self.office.jumpscaring and not self.office.cameraUp then
				self.office.roomlight = 0.9
			end
			
			if snjumps > 0 then
				snjumps = snjumps - lume.random(0.5, 1.5 + (self.office.heat - 60)/45) * dt
			else
				self.office.jumpscaring = true
                self.office.tabletAnim = false
                
				res.sounds.jump1:play()
			end
		end
	end
	
	if staticTime > 0 then
		if self.office.camera == from or self.office.camera == to then
			self.office.staticInt = 0.7
		end
		
		staticTime = staticTime - dt
	else
		from, to, staticTime = 0, 0, 0
	end
end

return snsnowball
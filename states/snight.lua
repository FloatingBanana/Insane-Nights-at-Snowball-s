local snight = {
	heat = 60,
	camera = 4,
	hour = 0,
	tabletAnim = false,
	leaksUp = false,
	cameraUp = false,
	jumpscaring = false,
	roomlight = 1,
	anyFixing = false,
	staticInt = 0,
	controlShock = false,
	leftDoor = false,
	rightDoor = false,
	tabletType = "monitor"
}

local snowball = require "animatronics.snsnowball"

--General
local power = 100
local tracker = 300

local camMove = 200
local danger = false
local light = false

local camMoveDir = 0
local tabletAnimTime = 0
local jumpsAnim = 0.1
local uiFade = 0
local powerout = false
local frontWaitError = 10
local pullcamOver = false
local tmaxAnim = 10

local camButtons = {
	{x = 696, y = 398},
	{x = 696, y = 454},
	{x = 889, y = 398},
	{x = 889, y = 454},
	{x = 792, y = 398},
	{x = 713, y = 540},
	{x = 870, y = 540},
	{x = 830, y = 350},
	{x = 830, y = 300}
}

local leaks = {}
for i=1, #camButtons do
	leaks[i] = {fixtime = 0, fixing = false}
end

local moveList = {}
local stepTimer = 30

local nErrors = 0
local leaksStep = 10

--TODO Comentar e ancorar

local leaksbackquad = lg.newQuad(0, 0, 841, 660, 841, 660)

local heatdistortion = lg.newShader("shaders/heat.glsl")
local heatsh = chain(1000, 675)
heatsh:append(heatdistortion)

function snight:enter(arg)
	fade(false, 1)
	lang = glang.office
	
	--Reset
	snight.camera = 4
	power = 100
	snight.heat = 60
	tracker = 300
	snight.leftDoor = false
	snight.rightDoor = false
	snight.controlShock = false
	snight.cameraUp = false
	snight.jumpscaring = false
	snight.tabletAnim = false
	powerout = false
	camMoveDir = 0
	tabletAnimTime = 0
	jumpsAnim = 0.1
	frontWaitError = 10

	snowball.office = snight
	snowball:enter()
	
	--Reset leaks
	for _, l in ipairs(leaks) do
		l.fixtime = 0
		l.fixing = false
	end
	
	res.door_left = animation.newSequence(res.door_left, 25)
	res.door_right = animation.newSequence(res.door_right, 25)
	
	res.misc.leaksback:setWrap("mirroredrepeat","mirroredrepeat")
	res.misc.fire:setFilter("nearest","nearest")

	perspective:send("depth", 2.5)
	chain.clearAppended()
	chain.resize(1000, 675)
	chain.append(perspective)

	local vfx = dbg.vis_effects
	if vfx == "Default" then
		chain.setActive(lowgraphics < 3)
		heatsh:setActive(lowgraphics < 3)
	else
		chain.setActive(vfx == "Aways")
		heatsh:setActive(vfx == "Aways")
	end
end


function snight:draw()
	if snight.heat > 70 then
		heatsh:start()
	end

	if snight.leaksUp then
		leaksbackquad:setViewport(Ftimer * 50 % 1742, Ftimer * 25 % 1350, 841, 670, 841, 660)
		lg.draw(res.misc.leaksback, leaksbackquad, 0, 0, 0, 1000/841)

		lg.setColor(1,1,1,1-uiFade)
		lg.draw(res.misc.map, (1000 - res.misc.map:getWidth() * 1.5)/2, (675 - res.misc.map:getHeight() * 1.5)/2, 0, 1.5, 1.5)

		setFont(25)
		lg.print(lang.leaks..nErrors, 20 + uiFade * 6, 10, 0)

		for i, button in pairs(camButtons) do			
			local buttonFade = 1 - uiFade

			if leaks[i].fixing then
				lg.setColor(0.9, 1, 0.2, buttonFade)
				lg.rectangle("fill", button.x * 1.5 - 730 + uiFade * 6, button.y * 1.5 - 337, 61, 57)

				lg.setColor(0.8, 1, 0.2, buttonFade)
				lg.draw(res.misc.fire, button.x * 1.5 - 730 + uiFade * 6, button.y * 1.5 - 337, 0, 0.7, 0.7)

				setFont(25)
				lg.setColor(1,1,1)
				lg.printf(lang.fixing, 680, 595, 300, "center")

				lg.rectangle("fill", 680, 630, 300 * (1 - leaks[i].fixtime/8), 40)

				lg.setLineWidth(3)
				lg.rectangle("line", 680, 630, 300, 40)

				lg.setLineWidth(1)
			else
				lg.setColor(0.25, 0.25, 0.25, buttonFade)
				lg.rectangle("fill", button.x * 1.5 - 730 + uiFade * 6, button.y * 1.5 - 337, 61, 57)
			
				if leaks[i].fixtime > 0 then
					lg.setColor(0.48, 0.1, 0.1, 1 - uiFade)
				else
					lg.setColor(0.12, 0.12, 0.22, 1 - uiFade)
				end
				lg.draw(res.misc.fire, button.x * 1.5 - 730 + uiFade * 6, button.y * 1.5 - 337, 0, 0.7, 0.7)
			end

			lg.setColor(1, 1, 1, buttonFade)
			lg.rectangle("line", button.x * 1.5 - 730 + uiFade * 6, button.y * 1.5 - 337, 61, 57)
		end

		lg.setColor(1, 1, 1, 1)
	elseif not snight.cameraUp then
	--camera down
		chain.start()

		if power > 0 then
			if snowball.cam == -4 and not snight.jumpscaring then
				lg.draw(res.room.snoffice, -tracker, 0, 0 , lowgraphics)
			else
				lg.draw(res.room[boolto(snowball.cam==-2, "doorleft_sn", "doorleft")], -tracker, 0, 0 , lowgraphics)
				lg.draw(res.room[boolto(snowball.cam==-3, "doorright_sn", "doorright")], 1100 - tracker, 0, 0 , lowgraphics)
				
				if light and not snowball.entering then
					lg.draw(res.room[boolto(snowball.cam == -1, "lightsnow", "lighton")], 500 - tracker, 0, 0 , lowgraphics)
				else
					lg.draw(res.room.lightoff, 500 - tracker, 0, 0, lowgraphics)
				end
			end

			--Left door
			res.door_left:draw(-tracker, -20, 0, lowgraphics)
			--Right door
			res.door_right:draw(-tracker, -20, 0, lowgraphics)
			
			lg.draw(res.room.desk, 650 - res.room.desk:getWidth()/2 * lowgraphics-tracker * 0.5, 0, 0, lowgraphics)
		else
			-- Power out
			lg.draw(res.room.powerout, -tracker, 0, 0, lowgraphics)
			lg.draw(res.room.desk_pd, 650-res.room.desk_pd:getWidth()/2 * lowgraphics-tracker * 0.5, 0, 0, lowgraphics)
		end

		chain.stop()
		

		--Tablet animation
		local animTime = floor(tabletAnimTime)

		if animTime > 0 and animTime < tmaxAnim then
			if snight.tabletType == "monitor" then
				lg.draw(res.tablet[animTime], 0, 0, 0, lowgraphics)

			elseif snight.tabletType == "leaks" then
				lg.draw(res.leaksm[animTime], 0, 0, 0, lowgraphics)

			else
				lg.draw(res.shock[animTime], 728, 209, 0, lowgraphics)
			end
		end

		if snight.tabletType == "shock" and tabletAnimTime >= tmaxAnim  then
			lg.draw(res.shock[13], 728, 209, 0, lowgraphics)
		end
	else
		if leaks[snight.camera].fixtime == 0 then
			chain.start()
			
			if snowball.cam == snight.camera then
				snowball:draw(tracker)
			else
				lg.draw(res.cam[snight.camera], -tracker, 0, 0, lowgraphics)
			end

			chain.stop()

			if dbg.show_static then
				local anim = Ftimer * 30

				lg.setColor(0.8, 0.8, 1, 0.3 + snight.staticInt)
				lg.draw(static, 500, 337, 0, boolto(floor(anim % 2) == 1, -1, 1), boolto(anim % 4 < 2 , 1, -1), 500, 337)
			end
		else
			setFont("OCRAEXT", 45)
			
			local txth = fontHeight(lang.overheat, 700)
			local red = sin(Ftimer/2 % 1 * pi)
			
			lg.printf(lang.overheat, 150, 337 - txth/2, 700, "center")
			
			lg.setColor(1, red, red, 1)
			lg.draw(res.misc.fire, 382, 206, 0, 3)
		end

		if dbg.show_game_ui then
			lg.setColor(1, 1, 1, 1)
			lg.draw(res.misc.map, wWidth - res.misc.map:getWidth() - 10, wHeight - res.misc.map:getHeight() - 40)

			--camera buttons
			lg.setLineWidth(2)
			for i, button in ipairs(camButtons) do
				local fade = (9 - uiFade * 9)/i

				lg.setColor(1, 1, 1, fade)
				lg.rectangle("line", button.x, button.y, 50, 30)

				if snight.camera == i then
					lg.setColor(0.8, 0.8, 0, fade)
				else
					lg.setColor(0.4, 0.4, 0.4, fade)
				end

				lg.rectangle("fill", button.x + 1, button.y + 1, 48, 28)
				lg.setColor(1, 1, 1, fade)

				setFont("small_font", 13)
				lg.print("cam "..i, button.x + 1, button.y + 4)
			end
		end
		lg.setColor(1, 1, 1, 1)
	end
    
	if snight.jumpscaring then
		if res.jumpscare[ceil(jumpsAnim)] then
			lg.draw(res.jumpscare[ceil(jumpsAnim)],0,0,0,lowgraphics)
		end
	end
	
	lg.setColor(1, 0, 0, (snight.heat - 60)/360)
	lg.rectangle("fill", 0, 0, wWidth, wHeight)

	lg.setColor(0, 0, 0, snight.roomlight)
	lg.rectangle("fill", 0, 0, wWidth, wHeight)

	if power > 0 and dbg.show_game_ui then
		setFont(35)
		
		lg.setColor(1, 1 - (snight.heat - 60)/60, 1 - (snight.heat - 60)/60, 1)
		lg.print(floor(snight.heat).."°", 910, 585, 0)

		setFont("OCRAEXT", 30)
		lg.setColor(1, 1, 1, 1)
		lg.print(lang.power..ceil(power).."%", 20, 595, 0)
		
		if not pullcamOver and not snight.jumpscaring then
			local pullcamS = 1/res.misc.pullcam:getWidth()

			if not snight.leaksUp and not (tabletAnimTime > 0 and snight.tabletType == "shock") then
				lg.draw(res.misc.pullcam, 350, 631, 0, pullcamS * 400, 1)
			end

			if not snight.cameraUp and not (tabletAnimTime > 0 and snight.tabletType == "shock") then
				lg.setColor(0.4,0.5,1)
				lg.draw(res.misc.pullcam, 30, 631, 0, pullcamS * 300, 1)
			end

			if not snight.cameraUp and not snight.leaksUp then
				lg.setColor(0.4, 1, 0.5)
				lg.draw(res.misc.pullcam, 770, 631, 0, pullcamS * 200, 1)
			end
		end
		lg.setColor(1, 1, 1)
		setFont("OCRAEXT", 25)
		lg.printf(lang.snight, wWidth - 300, 5, 280, "right")

		setFont("OCRAEXT", 45)
		lg.printf(boolto(snight.hour > 1, floor(snight.hour), 12).."AM", wWidth - 150, 30, 130, "right")
	end
	
	if snight.heat > 70 then
		heatsh:stop()
	end
end

function snight:update()
	snowball:update()

	-- ANCHOR Jumpscare
	if snight.jumpscaring then
		if res.jumpscare then
			jumpsAnim = min(jumpsAnim + 20 * dt, #res.jumpscare)
			
			if jumpsAnim >= #res.jumpscare then
				loadgamestate("gameover", "sn")
				return
			end
		else
			loadgamestate("gameover", "sn")
			return
		end
		
		snight.tabletAnim = false
	end

	-- ANCHOR Counters

	--Static intensity
	snight.staticInt = max(snight.staticInt - 0.8 * dt, 0)
	--Office lighting
	snight.roomlight = max(snight.roomlight - 0.7 * dt, 0)
	--Building heat
	snight.heat = clamp(snight.heat + boolto(nErrors > 0, nErrors * 1.5, -1.5) * dt, 60, 120)
	--UI Fading
	uiFade = max(uiFade - boolto(snight.leaksUp, 2, 1) * dt, 0)
	--Tablet animation
	tabletAnimTime = clamp(tabletAnimTime + boolto(snight.tabletAnim, 35, -35) * dt, 0, tmaxAnim + 1)
	--Left door animation
	res.door_left:update(dt)
	--Right door animation
	res.door_right:update(dt)
	--hour
	snight.hour = Ftimer / 60
	
	-- ANCHOR Flashlight
	if leaks[5].fixtime == 0 then
		light = (love.keyboard.isDown("lctrl") or (mouseOver(500 - tracker, 0, 600, 675) and lm.isDown(1))) and not snight.cameraUp and not snight.leaksUp
	end
	
	if snight.heat > 70 and heatsh:setActive() then
		heatdistortion:send("vars", Ftimer * 5 % (pi * 4), (snight.heat - 70)/12)
	end
	
	-- ANCHOR Block flashlight sound
	if light and snowball.entering then
		res.sounds.flashlighterror:play()
	else
		res.sounds.flashlighterror:stop()
	end
	
	nErrors = 0
	snight.anyFixing = false
	
	-- ANCHOR Fix leaks
	for i, leak in ipairs(leaks) do
		if leak.fixing then
			snight.anyFixing = true
			
			if leak.fixtime > 0 then
				leak.fixtime = leak.fixtime - dt
			else
				leak.fixing = false
				leak.fixtime = 0
			end
		end
		
		if leak.fixtime > 0 then
			nErrors = nErrors + 1
		end
	end
	
	-- ANCHOR Generate leaks
	if not powerout then
		leaksStep = leaksStep - lume.random(0, 2) * dt
		
		if leaksStep <= 0 then
			leaksStep = 10 - snight.hour/3

			if random(1, 5) == 1 then
				while nErrors < 9 do
					local leak = lume.randomchoice(leaks)

					if leak.fixtime <= 0 then
						leak.fixtime = 7
						
						break
					end
				end
			end
		end

		--Create a leak if snowball is waiting in the hall for too long
		if snowball.cam == -4 then
			frontWaitError = frontWaitError - dt

			if frontWaitError <= 0 then
				frontWaitError = 10

				while nErrors < 9 do
					local leak = lume.randomchoice(leaks)

					if leak.fixtime <= 0 then
						leak.fixtime = 7
						
						break
					end
				end
			end
		else
			frontWaitError = 10
		end

		-- ANCHOR Ambiance music
		if snowball.cam < 0 or snowball.cam == 6 or snowball.cam == 7 then
			danger = true
		else
			danger = false
		end

		if danger then
			changeMusic("caution")
		else
			if snight.hour < 3 then
				changeMusic("safe")
			elseif not res.musics.safe:isPlaying() then
				changeMusic("amb2")
			end
		end
	end
	
	
	if snight.heat >= 100 and snowball.cam > -4 and not snight.controlShock then
		snight.roomlight = sin(Ftimer * 2 % pi)
	end

	--Office camera
	if not snight.cameraUp then
		if #dialogList == 0 and (not isMobile or lm.isDown(1)) then
			tracker = clamp(tracker + (floor(RXmouse/200) - 2) * 200 * dt, 0, 600)
		end
	else
		tracker = clamp(tracker + camMove * dt, 0, 336)
		camMoveDir = camMoveDir + dt
		
		if camMoveDir > 5 then
			camMoveDir = 0
			camMove = -camMove
		end
	end

	-- ANCHOR Power consumption
	power = max(power - (boolto(snight.cameraUp or snight.leaksUp, 0.3) + boolto(light, 0.2) + boolto(snight.leftDoor, 0.6) + boolto(snight.rightDoor, 0.6)) * dt, 0)

	-- ANCHOR Pull camera
	if RYmouse > 631 and power > 0 and not snight.anyFixing and not snight.controlShock and (not isMobile or lm.isDown(1)) then
		if not pullcamOver then
			if tabletAnimTime == 0 then
				if mouseOver(350, 631, 400, 34) then
					snight.tabletType = "monitor"
					tmaxAnim = #res.tablet
				end
				
				if mouseOver(30, 631, 300, 34) then
					snight.tabletType = "leaks"
					tmaxAnim = #res.leaksm
				end
				
				if mouseOver(770, 631, 200, 34) then
					snight.tabletType = "shock"
					tmaxAnim = #res.shock
				end
			end
			if mouseOver(350, 631, 400, 34) or mouseOver(30, 631, 300, 34) or mouseOver(770, 631, 200, 34) then
				snight.tabletAnim = not snight.tabletAnim
				pullcamOver = true
				
				if snight.tabletAnim then
					res.sounds.cameraup:setPitch(lume.random(0.7, 1))
					res.sounds.cameraup:play()
				else
					res.sounds.cameradown:setPitch(lume.random(0.7, 1))
					res.sounds.cameradown:play()
				end
			end
		end
	elseif tabletAnimTime % (tmaxAnim+1) == 0 then
		pullcamOver = false
	end
 
	-- ANCHOR camera toggle
	if snight.tabletType == "monitor" then
		if snight.tabletAnim and tabletAnimTime > tmaxAnim then
			if not snight.cameraUp then 
				snight.staticInt = 0.7
				uiFade = 1
			end
			
			snight.cameraUp = true
		else
			snight.cameraUp = false
		end
	elseif snight.tabletType == "leaks" then
		if not snight.leaksUp then
			uiFade = 1
		end
		
		snight.leaksUp = snight.tabletAnim and tabletAnimTime > tmaxAnim
	end
	
	-- ANCHOR Powerout
	if power <= 0 then
		if not powerout then
			for i, sound in pairs(res.sounds) do
				sound:stop()
			end
			
			res.musics[currMusic]:stop()
			res.sounds.powerdown:play()

			timer.script(function(wait)
				wait(random(4,8))
				
				res.sounds.deepsteps:play()
				
				wait(random(3,6))
				
				snight.jumpscaring = true
				res.sounds.jump1:play()
			end)

			powerout = true
		end

		if snight.tabletAnim then
			snight.tabletAnim = false
			
			res.sounds.cameradown:setPitch(lume.random(0.7,1))
			res.sounds.cameradown:play()
		end
		
		if snight.leftDoor then
			snight.leftDoor = false
			
			res.sounds.door:stop()
			res.sounds.door:setPitch(lume.random(0.9,1))
			res.sounds.door:play()
		end
		
		if snight.rightDoor then
			snight.rightDoor = false
			
			res.sounds.door:stop()
			res.sounds.door:setPitch(lume.random(0.9,1))
			res.sounds.door:play()
		end
		
		if snowball.cam == -4 then
			snight.jumpscaring = true
			
			res.sounds.jump1:play()
		end
	end

	if snight.hour >= 6 then
		fade(true, 1.5, "sixam")
	end
end

function snight:exit()
	res.musics[currMusic]:stop()
	la.stop(res.sounds)
end

function snight:mousepressed(x, y)
	if snight.cameraUp then
		for i, button in ipairs(camButtons) do
			if mouseOver(button.x, button.y, 50, 30) and snight.camera ~= i then
				snight.camera = i
				snight.staticInt = 0.7
				
				res.sounds.camerachange:stop()
				res.sounds.camerachange:setPitch(lume.random(0.9, 1))
				res.sounds.camerachange:play()
			end
		end
	elseif snight.leaksUp then
		for i, button in ipairs(camButtons) do
			if mouseOver(button.x * 1.5 - 750 + 20, button.y * 1.5 - 337, 61, 57) and not snight.anyFixing and leaks[i].fixtime > 0 then
				leaks[i].fixing = true
			end
		end
	elseif power > 0 then
		if mouseOver(170 - tracker, 440, 175, 235) then
			self:keypressed("a")
		end	
		
		if mouseOver(1250 - tracker, 440, 175, 235) then
			self:keypressed("d")
		end
		
		if mouseOver(799, 361, 128, 138) and not snight.controlShock and snight.tabletType == "shock" and snight.tabletAnim then
			snight.controlShock = true
			
			res.sounds.shock:stop()
			res.sounds.shock:play()
			
			timer.script(function(wait)
				for i=1, 3 do
					snight.roomlight = 1
					power = power - 1
					
					wait(0.3)
				end
				
				snight.roomlight = 1
				power = power - 1
				snight.controlShock = false
				
				if snowball.cam == -4 then
					snowball:enter()
				end
			end)
		end
	end
end

function snight:keypressed(k)
	if power > 0 and not snight.cameraUp and not snight.leaksUp then
		if leaks[6].fixtime == 0 then
			if k == "a" and not res.door_left:isPlaying() then
				snight.leftDoor = not snight.leftDoor
				
				res.door_left:setRewind(not snight.leftDoor):play()

				res.sounds.door:stop()
				res.sounds.door:setPitch(lume.random(0.9, 1))
				res.sounds.door:play()
			end
		end
		if leaks[7].fixtime == 0 then
			if k == "d" and not res.door_right:isPlaying() then
				snight.rightDoor = not snight.rightDoor

				res.door_right:setRewind(not snight.rightDoor):play()

				res.sounds.door:stop()
				res.sounds.door:setPitch(lume.random(0.9, 1))
				res.sounds.door:play()
			end
		end
	end
end

return snight
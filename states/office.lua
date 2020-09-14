local office = {}

local oxdisplay = lg.newCanvas(200, 20)
local clownsCanvas

--General
night = 1
local hour = 0
local energy = 100

tracker = 150
camera = 4

leftDoor = false
rightDoor = false
duct = false
cameraUp = false
isBack = false
jumpscaring = false
controlPanel = false

local corrsig = false
local locpoint = false
oxygen = true

oxygenPercent = 50

tabletAnim = false
staticInt = 0
local alucin = 1
local camMove = 200
local controlShock = false
local drawingVis = false
local powerout = false
roomlight = 1

local camMoveDir = 0
local tabletAnimTime = 0
local ldoorAnim = 1
local rdoorAnim = 1
local ductAnim = 1
local camAnim = 0
local pullcamOver = false
turnBackTimer = 0

local rsfxtimer = 0
local rsfxplayed = {}

local camButtons = {
	{x = 819, y = 308},
	{x = 923, y = 309},
	{x = 871, y = 416},
	{x = 690, y = 255},
	{x = 694, y = 336},
	{x = 553, y = 291},
	{x = 548, y = 390},
	{x = 577, y = 475},
	{x = 636, y = 430},
	{x = 636, y = 522},
	{x = 731, y = 430},
	{x = 731, y = 522},
	{x = 811, y = 460},
	{x = 873, y = 532}
}

local camErr = {
	{n = "camsys", fixing = false, error = false, count = 0, fixtime = 0, counterfade = 0},
	{n = "powersys", fixing = false, error = false, count = 0, fixtime = 0, counterfade = 0},
	{n = "locpoint", fixing = false, error = false, count = 0, fixtime = 0, counterfade = 0},
	{n = "corrsig", fixing = false, error = false, count = 0, fixtime = 0, counterfade = 0}
}
local controlPanelScreen = require "controlpanel"
controlPanelScreen.errors = camErr

local camAnimation = {1,3,1,1,2,1,1,1,1,1,2,1,2,1}
local camAnimSpeed = {0,20,0,0,1.5,0,0,0,0,0,1.5,0,1.7,0}

--Animatronics
local anm = {
	larry = require "animatronics.larry",
	endo = require "animatronics.endo",
	snowball = require "animatronics.snowball",
	bunny = require "animatronics.bunny",
	konny = require "animatronics.konny",
	shattered = require "animatronics.shattered"
}
local beavy = require "animatronics.beavy"

clownsData = {
	{vis = {}, anim = 5},
	{vis = {}, anim = 4},
	{vis = {}, anim = 3},
	{vis = {}, anim = 2},
	{vis = {}, anim = 1}
}

function updateClowns()
	lg.setCanvas(clownsCanvas)
	lg.clear()
	lg.origin()
	for i, clown in ipairs(clownsData) do
		if clown.vis[camera] then
			lg.draw(res.miniclowns[clown.anim])
		end
	end
	lg.setCanvas()
end

local jumpsAnim = animation.newSequence({}, 0)
function jumpscare(anim)
	if dbg.load_jumpscares then
		if not jumpscaring then
			jumpsAnim:setAllImages(res.jumpscares[anim])
			:setSpeed(25)
			:stop()
			:play()
			.onFinish = function(self)
				self:setAllImages(emptyTable())
				loadgamestate("gameover", anim)
			end
			jumpscaring = true

			isBack = anim == "beavy"
			if anim == "shattered" then
				res.sounds.jump2:setVolume(.7)
				res.sounds.jump2:play()
			else
				res.sounds.jump1:setVolume(.7)
				res.sounds.jump1:play()
			end
		end
	else
		loadgamestate("gameover", anim)
	end
end

--TODO Adicionar as alucinações
function office:enter(arg)
	fade(false, 1)
	
	-- ANCHOR Reseting values
	camera = 4
	energy = 100
	leftDoor = false
	rightDoor = false
	duct = false
	cameraUp = false
	isBack = false
	jumpscaring = false
	controlPanel = false
	corrsig = false
	locpoint = false
	oxygen = true
	oxygenPercent = 0
	tabletAnim = false
	camMoveDir = 0
	tabletAnimTime = 0
	turnBackTimer = 0
	rsfxtimer = random(15,50)
	rsfxplayed = {}
	drawingVis = night >= 1 and night <= 4 and not savedata.drawings[night]
	powerout = false
	currMusic = ""
	
	--Reset errors
	for i, err in ipairs(camErr) do
		err.fixing = false
		err.error = false
		err.fixtime = 0
		err.count = 0
		err.counterfade = 0
	end
	
	-- ANCHOR Setting AIs
	if night == 1 then
		anm.snowball.AI = 2; anm.bunny.AI = 3; anm.larry.AI = 0; anm.konny.AI = 0; beavy.AI = 0; anm.shattered.AI = 0; anm.endo.AI = 0
	elseif night == 2 then
		anm.snowball.AI = 3; anm.bunny.AI = 4; anm.larry.AI = 5; anm.konny.AI = 0; beavy.AI = 0; anm.shattered.AI = 0; anm.endo.AI = 0
	elseif night == 3 then
		anm.snowball.AI = 5; anm.bunny.AI = 6; anm.larry.AI = 7; anm.konny.AI = 3; beavy.AI = 4; anm.shattered.AI = 0; anm.endo.AI = 0
	elseif night == 4 then
		anm.snowball.AI = 7; anm.bunny.AI = 7; anm.larry.AI = 9; anm.konny.AI = 5; beavy.AI = 6; anm.shattered.AI = 0; anm.endo.AI = 4
	elseif night == 5 then
		anm.snowball.AI = 9; anm.bunny.AI = 10; anm.larry.AI = 11; anm.konny.AI = 7; beavy.AI = 7; anm.shattered.AI = 0; anm.endo.AI = 6
	elseif night == 6 then
		anm.snowball.AI = 12; anm.bunny.AI = 12; anm.larry.AI = 13; anm.konny.AI = 9; beavy.AI = 8;anm. shattered.AI = 10; anm.endo.AI = 8
	elseif night == 7 then
		anm.snowball.AI = 15; anm.bunny.AI = 14; anm.larry.AI = 15; anm.konny.AI = 12; beavy.AI = 12; anm.shattered.AI = 13; anm.endo.AI = 12
	else
		anm.snowball.AI = cnlevels[1]; anm.bunny.AI = cnlevels[2]; beavy.AI = cnlevels[3]; anm.larry.AI = cnlevels[4]; anm.konny.AI = cnlevels[5]; anm.shattered.AI = cnlevels[6]; anm.endo.AI = cnlevels[7]
	end
	
	for _, a in pairs(anm) do
		a:enter()
	end
	beavy:enter()
	
	for i=1, 5 do
		for j=1, 14 do
			clownsData[i].vis[j] = false
		end
	end

	clownsCanvas = lg.newCanvas(wWidth/lowgraphics, wHeight/lowgraphics)
	updateClowns()
	
	-- ANCHOR Miniclowns voices
	if dbg.load_voices then
		timer.every(5, function()
			if cameraUp and not controlPanel then
				
				for _, voice in pairs(res.voices.miniclowns) do
					if voice:isPlaying() then
						return
					end
				end

				for i, clown in ipairs(clownsData) do
					if clown.vis[camera] and random(1,3) == 1 then
						local v = random(1, 4)
						
						if random(1, 3) == 1 then
							res.voices.miniclowns["l"..v]:play()
						else
							res.voices.miniclowns["r"..v]:play()
						end
						break
					end
				end
			end
		end)
	end
	
	--Subtitles
	subtitle.size = 25
	subtitle.back = true

	if res.voices and res.voices.phone then
		timer.after(1, function()
			res.voices.phone:play()

			if lang["phone"..night] then
				subtitle.parse(lang["phone"..night])
			end
		end)
	end
	
	--Perspective
	chain.clearAppended()
	chain.resize(1000, 675)
	chain.append(perspective)

	local vfx = dbg.vis_effects
	if vfx == "Default" then
		chain.setActive(lowgraphics - boolto(isMobile) < 3)
	else
		chain.setActive(vfx == "Aways")
	end
end

function office:draw()
	-- SECTION Monitor down
	if not cameraUp then
		chain.start()
		-- ANCHOR Front
		if not isBack and turnBackTimer == 0 then
			if energy > 0 then
				if not jumpscaring then
					--Snowball in the door
					if anm.snowball.camera == -1 then
						lg.setColor(1, 1, 1, anm.snowball.door_fade)
						lg.draw(res.room.snowball_office, -tracker, 0, 0, lowgraphics)
					end
					
					--Bunny in the door
					if anm.bunny.camera == -2 then
						lg.setColor(1, 1, 1, anm.bunny.door_fade)
						lg.draw(res.room.bunny_office, -tracker, 0, 0, lowgraphics)
					end
					--Bunny in the vent
					if anm.bunny.camera == -3 then
						lg.setColor(1, 1, 1, anm.bunny.door_fade)
						lg.draw(res.room.bunny_vent, -tracker, 0, 0, lowgraphics)
					end
				end
				lg.setColor(1,1,1,1)

				-- ANCHOR Doors
				--Left door
				lg.draw(res.door_left[floor(ldoorAnim)],-tracker,0,0,lowgraphics)
				--Right door
				lg.draw(res.door_right[floor(rdoorAnim)],-tracker,0,0,lowgraphics)
				--Duct
				lg.draw(res.duct[floor(ductAnim)],-tracker,0,0,lowgraphics)
				
				lg.draw(res.room.frontroom, -tracker, 0, 0 , lowgraphics)
				lg.draw(res.misc.plushies, -tracker, 0, 0, lowgraphics)
				
				if anm.shattered.step == 6 and not jumpscaring then
					lg.draw(res.room.shattered_office, -tracker, 0, 0, lowgraphics)
				end
			else
				lg.draw(res.room.frontroom_pd, -tracker, 0, 0, lowgraphics)
			end
		elseif turnBackTimer == 5 then
			-- ANCHOR Back
			lg.setColor(1,1,1,1)
			lg.draw(res.room.backroom, -tracker, 0, 0, lowgraphics)
			
			if beavy.AI > 0 then 
				beavy.draw()
			end
		else
			lg.draw(res.turnback[floor(turnBackTimer)+1],0,0,0,lowgraphics)
		end
		
		lg.setColor(0,0,0,roomlight)
		lg.rectangle("fill", 0, 0, wWidth, wHeight)
		lg.setColor(1,1,1,1)

		chain.stop()

		if isBack then
			if isMobile then
				lg.draw(res.misc.shock, wWidth/2-75, wHeight-150)

			elseif night == 3 and hour < 3 then
				lg.setColor(.5,.5,.5,1)
				setFont("alienleague", 20)

				lg.printf(lang.shock_hint, 0, 0, 1000, "center")
				lg.setColor(1,1,1,1)
			end
		end
		
		--Turning arrows
		if tracker >= 366 and not isBack and energy > 0 then
			lg.draw(res.misc.pullcam, (wWidth - 4) - 34, wHeight/2 - 201, pi/2, 1, -1.2)
		end

		if tracker <= 30 and isBack then
			lg.draw(res.misc.pullcam, 38, wHeight/2 - 201, pi/2, 1, 1.2)
		end
		-- !SECTION
	else
		-- SECTION Monitor up
		if controlPanel then
			-- ANCHOR Control panel
			controlPanelScreen.draw()
		
			--Corrupted signal
			local alpha = boolto(corrsig or camErr[4].error,0.5,1)
			if (anm.shattered.camera == camera and anm.shattered.AI > 0) or (anm.endo.camera == camera and anm.endo.AI > 0) then
				lg.setColor(.5,1,.5,alpha)
			else
				lg.setColor(1,1,1,alpha)
			end

			lg.rectangle("line", 400, 500, 200, 85)
			setFont("OCRAEXT", 18)
			lg.printf(lang.corrsig..camera, 400, 522, 200, "center")
			lg.setColor(1,1,1,1)
		else
			-- ANCHOR Cameras
			if not camErr[1].error then
				chain.start()

				--Rooms
				local imageId = 0
				if anm.shattered.step < 6 then
					imageId = camera * alucin + floor(camAnim) * 0.1
				else
					imageId = camera
				end
				
				lg.draw(res.cam[imageId], -tracker, 0, 0, lowgraphics)
			
				--Drawings
				if drawingVis and camera == select(night,6,11,13,14) then
					lg.draw(res.misc.drawing, -tracker, 0, 0, lowgraphics)
				end

				--Room details
				if res.cam_details[camera] then
					lg.draw(res.cam_details[camera], -tracker * .9, 0, 0, lowgraphics)
				end

				-- ANCHOR Draw animatronics
				for i, a in pairs(anm) do
					if a.draw and a.camera == camera and a.AI > 0 then
						a:draw()
					end
				end
				chain.stop()

				--Miniclowns
				lg.draw(clownsCanvas, 0, 0, 0, lowgraphics)
				
				--Static
				if dbg.show_static then
					lg.setColor(1, 1, 1, staticInt + 0.3)
					
					local anim = Ftimer * 30
					lg.draw(static, 500, 337, 0, boolto(floor(anim % 2) == 1, -1, 1), boolto(anim % 4 < 2, 1, -1), 500, 337)
				end
			else
				--No signal
				setFont("OCRAEXT", 100)
				lg.setColor(1,0,0, sin((Ftimer * pi/2) % pi))
				lg.printf(lang.nosig, 0, wHeight/2 - 50, 1000, "center")
			end
			if dbg.show_game_ui then
				lg.setColor(1,1,1,1)
				lg.draw(res.misc.map, wWidth - res.misc.map:getWidth() * 0.8 - 10, wHeight - res.misc.map:getHeight() * 0.8 - 40, 0, 0.8, 0.8)

				-- ANCHOR Camera buttons
				lg.setLineWidth(2)
				for i, button in ipairs(camButtons) do
					
					if anm.konny.cameraWarn and i == 8 then
						local red = boolto(Ftimer % 1 < 0.5, 1, 0.5)
						lg.setColor(1, red, red)
					else
						lg.setColor(1,1,1,1)
					end
					lg.rectangle("line", button.x, button.y, 50, 30)
					
					if camera == i then
						lg.setColor(0.78,0.78,0)
					else
						lg.setColor(0.39,0.39,0.39)
					end
					
					lg.rectangle("fill", button.x + 1, button.y + 1, 48, 28)
					lg.setColor(1,1,1)
					setFont("small_font", 13)
					lg.print("cam "..i, button.x + 1, button.y+4)

					-- ANCHOR Animatronic position warning
					if locpoint == 2 then
						lg.setColor(1,1,1, boolto(Ftimer%0.2 < 0.1))
						
						for j=1, 4 do
							local char = select(j, anm.shattered, anm.larry, anm.konny, anm.endo)
							
							if char.camera > 0 then
								if i == char.camera and char.AI > 0 then
									lg.draw(res.misc.warning, button.x+6, button.y)
								end
							else
								if char.camera == -1 then
									lg.draw(res.misc.warning, 642, 550)
								end
								
								if char.camera == -2 then
									lg.draw(res.misc.warning, 737, 550)
								end
							end
						end
						
						lg.setColor(1,1,1)
					end
				end
				lg.setLineWidth(1)

				-- ANCHOR Location point
				lg.rectangle("line", 780, 150, 200, 85)
				setFont("OCRAEXT", 25)
				lg.printf(boolto(locpoint, lang.searching, lang.locpoint), 780, boolto(locpoint, 175, 163), 200, "center")
			
				setFont("OCRAEXT", 49)
				lg.print(lang["cam"..camera], 10, 30, 0)

				-- ANCHOR Oxygen display
				if camera == 8 then
					setFont("OCRAEXT", 20)
					lg.printf(floor(oxygenPercent).."%", 30, 477, 200, "center")
					lg.setCanvas(oxdisplay)
					
					lg.clear()
					lg.push()
					lg.origin()
					lg.setScissor()
					
					lg.rectangle("fill", 0, 0, boolto(camErr[1].error, 200, oxygenPercent * 2), 20)
					
					setFont("OCRAEXT", 20)
					lg.setBlendMode("subtract")
					lg.printf(boolto(camErr[1].error, "--", floor(oxygenPercent)).."%", 0, 0, 200, "center")
					
					lg.setBlendMode("alpha")
					lg.pop()
					lg.setCanvas()
					
					lg.draw(oxdisplay, 30, 477)
					lg.rectangle("line", 30, 500, 200,85)
					
					setFont("OCRAEXT", 22)
					lg.printf(lang.oxg..boolto(oxygen,"ON","OFF"), 35, 530, 195, "center")
				end

				local str = ""
				for i, err in ipairs(camErr) do
					if err.error then
						str = str..lang["err"..err.n].."\n"
					end
				end
				setFont("small_font", 15)
				lg.setColor(1,0,0,boolto(Ftimer % 1 < 0.5))
				lg.print(str, 30, 345)


				lg.push()
				lg.translate(30, 590)
				lg.setLineWidth(2)
			
				lg.setColor(1,1,1,1)
				lg.rectangle("line", 0, 0, 180, 40, 3)
				lg.rectangle("line", 180, 7, 15, 25, 3)

				-- ANCHOR Energy display
				for i=0, 4 do
					local r = (4-i)/4
					local g = i/4
					local a = energy * 0.05

					lg.setColor(r*0.5,g*0.5,0, a - i)
					lg.rectangle("fill", i * 36, 0, 36, 40, 3)
					lg.setColor(1,1,1,1)
					lg.rectangle("line", i * 36, 0, 36, 40, 3)
				end
			
				setFont("OCRAEXT", 15)
				lg.printf(floor(energy).."%", 20, 40, 140, "center")
				lg.rectangle("line", 20, 40, 140, 15, 3)
			
				lg.pop()
			end
		end

		if dbg.show_game_ui then
			-- ANCHOR Tabs
			lg.setLineWidth(2)
			setFont("OCRAEXT", 40)

			local color = boolto(controlPanel)
			local alpha = boolto(controlPanelScreen.anyFixing, 0.5, 1)
			
			--Camera tab
			lg.setColor(color, color, 1, alpha)
			lg.rectangle("line", 30, 150, 200, 85)
			lg.printf(lang.camera, 30, 170, 200, "center")

			--Control panep tab
			lg.setColor(1-color, 1-color, 1, alpha)
			lg.rectangle("line", 30, 240, 200, 85)
			setFont("OCRAEXT", 30)
			lg.printf(lang.cp, 30, 250, 200, "center")
		end
		
		lg.setColor(1,1,1,1)
		lg.setLineWidth(1)
	end
	-- !SECTION
	
	-- ANCHOR Animations
	--Jumpscare
	if jumpscaring and turnBackTimer % 5 == 0 then
		jumpsAnim:draw(0,0,0,lowgraphics + 1)
	end
	--Tablet
	if floor(tabletAnimTime) > 0 and floor(tabletAnimTime) < 7 then
		lg.draw(res.tablet[floor(tabletAnimTime)],0,0,0,lowgraphics)
	end
	
	-- ANCHOR Interface
	if energy > 0 and dbg.show_game_ui then
		--Pull cam button
		if not pullcamOver and not jumpscaring and not isBack and not controlPanelScreen.anyFixing then
			lg.draw(res.misc.pullcam, 298, 631)
		end

		--Night and hour
		setFont("OCRAEXT", 25)
		lg.printf(boolto(night<8,lang.night..night,glang.customnight["c"..(currChallenge or 0)]), 480, 5, 500, "right")
		setFont("OCRAEXT", 45)
		lg.printf(boolto(hour > 1, floor(hour), 12).."AM", wWidth - 150, 30, 130, "right")
	end
	
	if res.voices and res.voices.phone and res.voices.phone:isPlaying() then
		lg.setColor(0,1,0,.5)
		lg.rectangle("fill", 10, 10, 120, 30, 10, 5)
		lg.setColor(1,1,1,1)
		lg.rectangle("line", 10, 10, 120, 30, 10, 5)
		setFont("OCRAEXT", 15)
		lg.printf(lang.mute_call, 15, 17, 110, "center")
	end
	setFont()
end

function office:update()
	-- ANCHOR Animatronic update
	local danger = false
	if energy > 0 and (night ~= 1 or hour > 2) then
		for i, a in pairs(anm) do
			if a.AI > 0 then
				a:update()
			end
			
			if a.danger then
				danger = true
			end
		end
		
		if beavy.AI > 0 then
			beavy:update()
		end
	end

	-- ANCHOR Ambiance music
	if not powerout then
		if hour < 3 then
			changeMusic("amb1")
		elseif not res.musics.amb1:isPlaying() then
			changeMusic("amb2")
		end
	end

	--Jumpscare update
	if jumpscaring then
		tabletAnim = false
		
		if turnBackTimer % 5 == 0 then
			jumpsAnim:update(dt)

			if not jumpsAnim:isPlaying() then
				return
			end
		end
	end

	-- ANCHOR Counters
	--Static intensity
	staticInt = max(staticInt - 0.7 * dt, 0)
	--Office lighting
	roomlight = max(roomlight - 0.7 * dt, 0)
	--Turn back animation
	turnBackTimer = clamp(turnBackTimer + boolto(isBack, 20, -20) * dt, 0, 5)
	--Tablet animation
	tabletAnimTime = clamp(tabletAnimTime + boolto(tabletAnim, 25, -25) * dt, 0, 7)
	--Left door animation
	ldoorAnim = clamp(ldoorAnim + boolto(leftDoor, 27, -27) * dt, 1, 9)
	--Right door animation
	rdoorAnim = clamp(rdoorAnim + boolto(rightDoor, 27, -27) * dt, 1, 9)
	--Duct animation
	ductAnim = clamp(ductAnim + boolto(duct, 30, -30) * dt, 1, 9)
	--Camera animation
	camAnim = (camAnim + camAnimSpeed[camera] * dt) % camAnimation[camera]
	--Hour
	hour = Ftimer / 50
	--Oxygen
	oxygenPercent = clamp(oxygenPercent + boolto(oxygen, 3, -3) * dt, 0, 100)

	-- ANCHOR Random sound effects
	rsfxtimer = rsfxtimer - dt
	if rsfxtimer <= 0 then
		rsfxtimer = random(15, 40)
		
		while true do
			local r = random(1,6)
			
			if not lume.find(rsfxplayed, r) then
				res.sounds["rs"..r]:play()
				toLast(rsfxplayed, r)
				
				break
			end
		end
		
		if #rsfxplayed >= 5 then
			table.remove(rsfxplayed, 1)
		end
	end

	-- ANCHOR View movement
	if cameraUp then
		--Camera movement
		tracker = clamp(tracker + camMove * dt, 0, 366)
		camMoveDir = camMoveDir + dt
		
		if camMoveDir > 5 then
			camMoveDir = 0
			camMove = -camMove
		end
		
		-- ANCHOR Camera error
		if not controlPanel and not camErr[1].error then
			camErr[1].count = camErr[1].count + (0.1 + staticInt * 1.8) * dt
		end
	else
		--Office movement
		if #dialogList == 0 and (not isMobile or lm.isDown(1)) then
    		tracker = clamp(tracker + (floor(RXmouse/200) - 2) * 200 * dt, 0, 366)
  		end
	end
	
	--Corrupted signal static
	if corrsig == camera and staticInt < 0.4 then
		staticInt = 0.4
	end
	
	controlPanelScreen.update()

	-- ANCHOR Power system error
	if not camErr[2].error then
		camErr[2].count = camErr[2].count + (boolto(cameraUp, 0.15) + boolto(leftDoor, 0.7) + boolto(rightDoor, 0.7) + boolto(duct, 0.4)) * dt
	end

	--ANCHOR Power consumption
	energy = max(energy - (boolto(cameraUp, 0.1) + boolto(leftDoor, 0.25) + boolto(rightDoor, 0.25) + boolto(duct, 0.2) + boolto(camErr[2].error, 0.35)) * dt, 0)

	-- ANCHOR Pull monitor
	if (mouseOver(298, 631, 404, 34) and not isBack) and energy > 0 and not controlPanelScreen.anyFixing and (not isMobile or lm.isDown(1)) then
		if not pullcamOver then
			tabletAnim = not tabletAnim
			pullcamOver = true
			
			if tabletAnim then
				res.sounds.cameraup:setPitch(lume.random(0.7,1))
				res.sounds.cameraup:play()
			else
				res.sounds.cameradown:setPitch(lume.random(0.7,1))
				res.sounds.cameradown:play()
			end
		end
	elseif tabletAnimTime % 7 == 0 then
		pullcamOver = false
	end

	if isBack then
		tabletAnim = false
	end
 
	-- ANCHOR Turn on monitor
	if tabletAnim and tabletAnimTime >= 7 then
		if not cameraUp then 
			staticInt = 0.7
			
			if res.cam[-camera] and random(night, 30) == 30 then
				alucin = -1
			else
				alucin = 1
			end
		end
		
		cameraUp = true
	else
		cameraUp = false
	end

	-- ANCHOR Power down
	if energy <= 0 then
		tabletAnim = false
		
		if not (jumpscaring and curJumps == "beavy") then
			isBack = false
		end
		
		--Powerdown jumpscare
		if not powerout then
			res.musics[currMusic]:stop()
			timer.script(function(wait)
				wait(random(5, 15))
				res.sounds.footsteps:play()
				
				wait(random(8, 16))
				jumpscare("powerdown")
			end)

			for _, sound in pairs(res.sounds) do
				sound:stop()
			end
			
			if dbg.load_voices then
				for _, voice in pairs(res.voices.endo) do
					voice:stop()
				end
				
				for _, voice in pairs(res.voices.miniclowns) do
					voice:stop()
				end
				
				if res.voices.phone then
					res.voices.phone:stop()
				end
			end
			res.sounds.powerdown:play()
			roomlight = 1

			powerout = true
		end
	end
	
	if hour >= 6 then
		fade(true, 1.5, "sixam")
	end
end

function office:exit() 
	res.musics[currMusic]:stop()
	
	for _, sound in pairs(res.sounds) do
		sound:stop()
	end
	
	if dbg.load_voices then
		for _, voice in pairs(res.voices.endo) do
			voice:stop()
		end

		for _, voice in pairs(res.voices.miniclowns) do
			voice:stop()
		end
		
		if res.voices.phone then
			res.voices.phone:stop()
		end
	end
end

function office:mousepressed(x,y)
	-- ANCHOR Mute call
	if res.voices and res.voices.phone and res.voices.phone:isPlaying() and mouseOver(10, 10, 120, 30) then
		res.voices.phone:stop()
		res.sounds.endcall:play()
		subtitle.clear()
	end
	
	if cameraUp then
		-- SECTION Monitor up
		if not controlPanel then
			-- ANCHOR Camera button click
			for i, button in ipairs(camButtons) do
				if mouseOver(button.x, button.y, 50, 30) and camera ~= i then
					camera = i
					staticInt = 0.7
					
					res.sounds.camerachange:stop()
					res.sounds.camerachange:setPitch(lume.random(0.9,1))
					res.sounds.camerachange:play()
					clownsData = lume.shuffle(clownsData)
					
					updateClowns()
					
					if dbg.load_voices then
						la.stop(res.voices.miniclowns)
					end

					if res.cam[-camera] and random(night, 30) == 30 then
						alucin = -1
					else
						alucin = 1
					end
				end
			end

			-- ANCHOR Location point
			if mouseOver(780, 150, 200, 85) and not locpoint and not camErr[3].error then
				locpoint = 1
				
				timer.script(function(wait)
					wait(2)
					locpoint = 2
					camErr[3].count = camErr[3].count + 10
					wait(1)
					locpoint = false
				end)
			end

			-- ANCHOR Toggle oxygen
			if camera == 8 and mouseOver(30, 500, 200, 85) then
				oxygen = not oxygen
			end
			 
			-- ANCHOR Remove miniclowns
			for i, clown in ipairs(clownsData) do
				local data = res.miniclowns.data[clown.anim]
				
				if clown.vis[camera] and x < data:getWidth() and y < data:getHeight() then
					local _,_,_,a = data:getPixel(x,y)
				
					if a > 0 then
						clown.vis[camera] = false
						staticInt = 0.7
						
						updateClowns()
						break
					end
				end
			end

			-- ANCHOR Pick drawings
			local drawingCam = select(night,6,11,13,14)
			if drawingVis and camera == drawingCam then
				local _,_,_,a = res.misc.drawing_data:getPixel(x+tracker, y)
				
				if a > 0 then
					local drawings = savedata.drawings
					drawings[night] = true

					local all = drawings[1] and
					            drawings[2] and
					            drawings[3] and
					            drawings[4]
					if all then
						trophies:achieve("Little artist")
					end

					savedata.drawings = drawings

					drawingVis = false
					staticInt = 0.7
				end
			end
		else
			-- ANCHOR Corrupted signal
			if mouseOver(400, 500, 200, 85) and not corrsig and not camErr[4].error then
				corrsig = camera
				camErr[4].count = camErr[4].count + 20

				timer.after(5, function()
					corrsig = false
				end)
				
				if camera == anm.shattered.camera then
					anm.shattered:enter()
				end

				if camera == anm.endo.camera then
					anm.endo:enter()
				end
			end
		end
        
		if not controlPanelScreen.anyFixing then
			-- ANCHOR Switch to cameras
			if mouseOver(30, 150, 200, 85) and controlPanel then
				staticInt = 0.7
				controlPanel = false
				res.sounds.camerachange:stop()
				res.sounds.camerachange:setPitch(lume.random(0.7,1))
				res.sounds.camerachange:play()
			end

			-- ANCHOR Switch to control panel
			if mouseOver(30, 240, 200, 85) and not controlPanel then
				controlPanel = true
				res.sounds.camerachange:stop()
				res.sounds.camerachange:setPitch(lume.random(0.7,1))
				res.sounds.camerachange:play()

				controlPanelScreen.enter()
			end
		end
		-- !SECTION
	else
		-- SECTION Monitor down
		if energy > 0 then
			if isBack then
				-- ANCHOR Turn to front
				if tracker <= 30 and mouseOver(0, 337 - res.misc.pullcam:getWidth()/2, res.misc.pullcam:getHeight() * 1.2, res.misc.pullcam:getWidth()) then
					isBack = false
				end
				
				-- ANCHOR Shock (touch)
				if mouseOver(425, 525, 150, 150) and isMobile then
					self:keypressed("q")
				end
			else
				-- ANCHOR Turn to back
				if tracker >= 366 and mouseOver(1000 - res.misc.pullcam:getHeight(), 337 - res.misc.pullcam:getWidth()/2, res.misc.pullcam:getHeight() * 1.2, res.misc.pullcam:getWidth()) then
					isBack = true
				end
				
				-- ANCHOR Touch controls
				--Left door
				if mouseOver(390 - tracker, 175, 190, 340) then
					self:keypressed("a")
				end
				--Right door
				if mouseOver(736 - tracker, 175, 190, 340) then
					self:keypressed("d")
				end
				--Duct
				if mouseOver(1076 - tracker, 397, 140, 218) then
					self:keypressed("f")
				end
			end
		end
		--!SECTION
	end
end

function office:keypressed(k)
	if not isBack and energy > 0 then
		if not cameraUp then
			if k == "a" and ldoorAnim % 8 == 1 then
				if anm.endo.camera == -1 then
					res.sounds.error:play()
				else
					leftDoor = not leftDoor

					res.sounds.door:stop()
					res.sounds.door:setPitch(lume.random(0.9,1))
					res.sounds.door:play()
				end
			end

			if k == "d" and rdoorAnim % 8 == 1 then
				rightDoor = not rightDoor

				res.sounds.door:stop()
				res.sounds.door:setPitch(lume.random(0.9,1))
				res.sounds.door:play()
			end

			if k == "f" and ductAnim % 8 == 1 then
				duct = not duct

				res.sounds.door:stop()
				res.sounds.door:setPitch(lume.random(0.9,1))
				res.sounds.door:play()
			end
		end
		
		if k == "w" and not controlPanelScreen.anyFixing and tabletAnimTime % 7 == 0 then
			tabletAnim = not tabletAnim
			
			if tabletAnim then
				res.sounds.cameraup:setPitch(lume.random(0.7,1))
				res.sounds.cameraup:play()
			else
				res.sounds.cameradown:setPitch(lume.random(0.7,1))
				res.sounds.cameradown:play()
			end
		end
	end

	if cameraUp then
		if not controlPanelScreen.anyFixing then
			if k == "tab" then
				if controlPanel then
					staticInt = 0.7
				end
				controlPanel = not controlPanel
				
				res.sounds.camerachange:stop()
				res.sounds.camerachange:setPitch(lume.random(0.9,1))
				res.sounds.camerachange:play()

				if controlPanel then
					controlPanelScreen.enter()
				end
			end
		end
	end

	if k == "q" and isBack and not controlShock then
		controlShock = true
		
		res.sounds.shock:stop()
		res.sounds.shock:play()
		
		timer.script(function(wait)
			roomlight = 1
			energy = energy - 0.8
			
			wait(0.3)
			
			roomlight = 1
			energy = energy - 0.8
			
			wait(0.3)
			
			roomlight = 1
			energy = energy - 0.8
			beavy.step = max(beavy.step - 1, 1)
			
			wait(0.3)
			
			beavy:enter()
			
			roomlight = 1
			energy = energy - 0.8
			controlShock = false
			camErr[2].count = camErr[2].count + 7
		end)
	end
end

return office
local minigame = {}

local bump = require "libs.bump.bump"

local crt = lg.newShader("shaders/crt.glsl")
local walls = lg.newCanvas(2480, 2016)
local scanlines = lg.newCanvas(1000, 675)
local ground = nil
local crtscreen = nil
local directions = nil
local sprites = nil
local sounds = nil
local world = nil
local map = nil
local scrollers = nil

local playables = {
	snowball = {n = "snowball", x = 2040, y = 800, dir = "down", anim = 2},
	bunny = {n = "bunny", x = 1850, y = 800, dir = "down", anim = 2},
	larry = {n = "larry", x = 455, y = 1700, dir = "down", anim = 2},
	konny = {n = "konny", x = -400, y = 0, dir = "down", anim = 2},
	beavy = {n = "beavy", x = -500, y = 0, dir = "down", anim = 2},
	soul = {n = "soul", x = 1985, y = 1245, dir = "down", anim = 1}
}
local player = playables.snowball

local level = 1

local function ysort(k1, k2)
	local _, y1 = world:getRect(k1)
	local _, y2 = world:getRect(k2)
	return y1 < y2
end

local function playerCol(x2, y2, w2, h2)
	local mx, my = player.x, player.y
	return  mx < x2+w2 and
	        x2 < mx    and
	        my < y2+h2 and
	        y2 < my
end

local cols = {}
local vel = 150

local endminigame = false

function minigame:enter(arg)
	cols = emptyTable()
	sprites = emptyTable()
	map = emptyTable()
	scrollers = emptyTable()
	
	endminigame = false
	level = arg or 1
	world = bump.newWorld(32)
	
	-- ANCHOR Setting playables
	if level == 1 then
		playables = {
			snowball = {n = "snowball", x = 2040, y = 820, dir = "down", anim = 2},
			bunny = {n = "bunny", x = 1850, y = 800, dir = "down", anim = 2},
			larry = {n = "larry", x = 455, y = 1700, dir = "down", anim = 2},
			konny = {n = "konny", x = 4500, y = 1000, dir = "down", anim = 2},
			beavy = {n = "beavy", x = 2300, y = 3800, dir = "down", anim = 2},
			soul = {n = "soul", x = 1985, y = 1245, dir = "down", anim = 1}
		}
		
		player = playables.soul
	end

	if level == 2 then
		playables = {
			snowball = {n = "snowball", x = 2040, y = 800, dir = "down", anim = 2},
			bunny = {n = "bunny", x = 1850, y = 800, dir = "down", anim = 2},
			larry = {n = "larry", x = 455, y = 1700, dir = "down", anim = 2},
			konny = {n = "konny", x = 4500, y = 1000, dir = "down", anim = 2},
			beavy = {n = "beavy", x = 2300, y = 3800, dir = "down", anim = 2},
			soul = {n = "soul", x = -600, y = 0, dir = "down", anim = 1}
		}
		player = playables.larry
		
		sprites.jean = {
			lg.newImage("assets/minigames/jean/1.png"),
			lg.newImage("assets/minigames/jean/2.png")
		}
		local jean = {n = "jean", x = 4444, y = 2462}
		toLast(map, jean)
		world:add(jean, 4444, 2462, sprites.jean[1]:getWidth()/2+12, 40)
	end

	if level == 3 then
		playables = {
			snowball = {n = "snowball", x = 2040, y = 800, dir = "down", anim = 2},
			bunny = {n = "bunny", x = 1850, y = 800, dir = "down", anim = 2},
			larry = {n = "larry", x = 455, y = 1700, dir = "down", anim = 2},
			konny = {n = "konny", x = 4500, y = 1000, dir = "down", anim = 2},
			beavy = {n = "beavy", x = 2300, y = 3800, dir = "down", anim = 2},
			soul = {n = "soul", x = -600, y = 0, dir = "down", anim = 1}
		}
		player = playables.snowball

		sprites.shattered = {
			lg.newImage("assets/minigames/shattered/1.png"),
			lg.newImage("assets/minigames/shattered/2.png")
		}
		local shattered = {n = "shattered", fading = false, fade = 0, x = 4370, y = 2370}

		toLast(map, shattered)
		world:add(shattered, 4370, 2370, 1, 1)
		world:add({n = "blocker"}, 4060, 2260, 32, 200)
	end

	if level == 0 then
		playables = {
			snowball = {n = "snowball", x = 2040, y = 820, dir = "down", anim = 2},
			bunny = {n = "bunny", x = 1850, y = 800, dir = "down", anim = 2},
			larry = {n = "larry", x = 455, y = 1700, dir = "down", anim = 2},
			konny = {n = "konny", x = 4400, y = 1100, dir = "down", anim = 2},
			beavy = {n = "beavy", x = 1900, y = 3800, dir = "down", anim = 2},
			soul = {n = "soul", x = 1985, y = 1245, dir = "down", anim = 1}
		}
		player = playables.snowball
	end
	
	-- ANCHOR Sprites
	for names, obj in pairs(playables) do
		if obj ~= playables.soul then
			sprites[names] = {
				down = {
					lg.newImage("assets/minigames/"..names.."/3.png"),
					lg.newImage("assets/minigames/"..names.."/2.png"),
					lg.newImage("assets/minigames/"..names.."/1.png")
				},
				up = {
					lg.newImage("assets/minigames/"..names.."/6.png"),
					lg.newImage("assets/minigames/"..names.."/5.png"),
					lg.newImage("assets/minigames/"..names.."/4.png")
				},
				right = {
					lg.newImage("assets/minigames/"..names.."/9.png"),
					lg.newImage("assets/minigames/"..names.."/8.png"),
					lg.newImage("assets/minigames/"..names.."/7.png")
				},
				left = {
					lg.newImage("assets/minigames/"..names.."/12.png"),
					lg.newImage("assets/minigames/"..names.."/11.png"),
					lg.newImage("assets/minigames/"..names.."/10.png")
				}
			}
		else
			sprites[names] = {
				down = {
					lg.newImage("assets/minigames/"..names.."/1.png"),
					lg.newImage("assets/minigames/"..names.."/2.png")
				},
				up = {
					lg.newImage("assets/minigames/"..names.."/3.png"),
					lg.newImage("assets/minigames/"..names.."/4.png")
				}
			}
		end		
		world:add(obj, obj.x, obj.y, sprites[names].up[1]:getWidth()/2+12, 40)
	end

	sprites.objects = {}
	for i=1, 15 do
		sprites.objects[i] = lg.newImage("assets/minigames/objects/"..i..".png")
		sprites.objects[i]:setWrap("repeat", "repeat")
	end

	ground = lg.newImage("assets/minigames/ground.png")
	crtscreen = lg.newImage("assets/minigames/screen.png")
	directions = lg.newImage("assets/minigames/directions.png")
	
	-- ANCHOR Sounds
	sounds = emptyTable()

	sounds.laugh = la.newSource("sounds/minigames/laugh.ogg", "static")
	sounds.step = la.newSource("sounds/minigames/step.ogg", "static")
	sounds.ambiance = la.newSource("sounds/minigames/ambiance.ogg", "stream")
	sounds.ambiance2 = la.newSource("sounds/minigames/ambiance2.ogg", "stream")
	
	sounds.ambiance:setVolume(.8)
	sounds.ambiance2:setVolume(.07)
	sounds.step:setVolume(.5)
	sounds.ambiance:setLooping(true)
	sounds.ambiance2:setLooping(true)
	la.stop()
	
	lg.push()
	lg.origin()
	lg.setCanvas(walls)
	lg.clear()

	for x=0, 4 do
		for y=0, 5 do
			lg.draw(ground, x * 496, y * 336)
		end
	end

	for i, obj in ipairs(lume.deserialize(lfs.read("minigamemap"))) do
		local spn = obj.sp
		
		if type(spn) ~= "number" then
			toLast(scrollers, {t = boolto(spn=="sx", "x", "y"), x = obj.x-496, y = obj.y-336, w = 992, h = 672})
		else
			local sp = sprites.objects[spn]
			local quad = lg.newQuad(0, 0, obj.w, obj.h, sp:getWidth(), sp:getHeight())
			
			if (spn >= 7 and spn <= 10) or spn == 14 or spn == 15 then
				if spn == 8 or spn == 9 or spn == 14 or spn == 15 then
					world:add(obj, obj.x, obj.y, obj.w, obj.h)
				end
				
				lg.draw(sp, quad, obj.x/2, obj.y/2, 0, .5)
			else
				world:add(obj, obj.x, obj.y+obj.h/2, obj.w, obj.h/2)
				toLast(map, obj)
				
				obj.sp = sp
				obj.quad = quad
			end
		end
	end
	for i, char in pairs(playables) do
		char.player = true
		toLast(map, char)
	end

	lg.setCanvas(scanlines)
	lg.setColor(0,0,0,1)

	for i=1, 135 do
		lg.line(0, i * 5, 1000, i * 5)
	end

	lg.setCanvas()
	lg.pop()
	
	sounds.ambiance:play()
	sounds.ambiance2:play()
	
	block_dt = true
	
	chain.clearAppended()
	chain.resize(1000, 675)
	chain.append(crt)
end

function minigame:draw()
	if not endminigame then
		chain.start()
		lg.push()

		-- ANCHOR Canera scrolling
		local camx, camy = floor(player.x/992)*992, floor(player.y/672)*672
		for i, scroll in ipairs(scrollers) do
			if playerCol(scroll.x, scroll.y, scroll.w, scroll.h) then
				if scroll.t == "x" then
					camx = player.x - 496
				else
					camy = player.y - 336
				end
			end
		end
		lg.translate(-camx, -camy)
		lg.draw(walls,0,0,0,2)
		table.sort(map, ysort)

		-- ANCHOR Draw characters
		for i, obj in ipairs(map) do
			if obj.player then
				local cframe = sprites[obj.n][obj.dir][floor(obj.anim)+1]
				lg.draw(cframe, obj.x - cframe:getWidth()/4+6, obj.y - cframe:getHeight() + 40)
			
			elseif obj.n == "jean" then
				local cframe = sprites.jean[floor(Ftimer*1.2%2)+1]
				lg.draw(cframe, obj.x - cframe:getWidth()/4+6, obj.y - cframe:getHeight() + 40)
			
			elseif obj.n == "shattered" then
				lg.draw(sprites.shattered[1], obj.x, obj.y)
				lg.setColor(1,1,1,obj.fade)
				lg.draw(sprites.shattered[2], obj.x, obj.y)
				lg.setColor(1,1,1,1)
			else
				obj.quad:setViewport(0, 0, obj.w, obj.h)
				lg.draw(obj.sp, obj.quad, obj.x, obj.y)
			end
		end


		lg.pop()

		-- ANCHOR UI

		--Door locked
		for i=1, #cols do
			if cols[i].other.sp == 15 then
				setFont("emulogic", 40)
				lg.printf(lang.locked, 500,610, 450, "right")
				break
			end
		end

		--Scanlines
		lg.setColor(0,0,0,1)
		lg.rectangle("fill", 992, 0, 8, 675)
		lg.rectangle("fill", 0, 672, 1000, 3)
		lg.draw(scanlines)

		chain.stop()
		lg.setColor(0,0,0,.3)
		lg.rectangle("fill", 0, 0, 1000, 675)
	
		--CRT screen
		lg.setColor(1,1,1,1)
		lg.draw(crtscreen)

		--Android Controls
		if isMobile then
			lg.setColor(1,1,1,.5)
			lg.draw(directions, 0, 475)
		end
	else
		chain.start()
		
		--Static
		lg.setColor(1, .4, .4, clamp(2.5-Ftimer/2, .5, 1))
		Ftimer = Ftimer * 30
		lg.draw(static, 500, 337, 0, boolto(floor(Ftimer%2)==1,-1,1), boolto(Ftimer%4<2,1,-1), 500, 337)
		Ftimer = Ftimer / 30

		--Quote
		lg.setColor(1, 0, 0, min(Ftimer/2-2.5, 1))
		setFont("alienleague", 50)
		lg.printf(lang["quote"..level], 0, 320, 1000, "center")
		
		--Scanlines
		lg.setColor(1,1,1,1)
		lg.draw(scanlines)
		
		chain.stop()
	end
end

function minigame:update()
	if not endminigame then

		-- ANCHOR Android touch commands
		local touchDir = ""
		if isMobile and lm.isDown(1) then
			if mouseOver(100, 475, 100, 100) then
				touchDir = "up"
			elseif mouseOver(100, 575, 100, 100) then
				touchDir = "down"
			elseif mouseOver(0, 575, 100, 100) then
				touchDir = "left"
			elseif mouseOver(200, 575, 100, 100) then
				touchDir = "right"
			end
		end

		-- ANCHOR Walk
		if not player.block_move then
			if love.keyboard.isDown("w", "up") or touchDir == "up" then
				player.x, player.y, cols = world:move(player, player.x, player.y - vel * dt, colfilter)
				player.dir = "up"
			end
			if love.keyboard.isDown("s", "down") or touchDir == "down" then
				player.x, player.y, cols = world:move(player, player.x, player.y + vel * dt, colfilter)
				player.dir = "down"
			end
			if love.keyboard.isDown("a", "left") or touchDir == "left" then
				player.x, player.y, cols = world:move(player, player.x - vel * dt, player.y, colfilter)
				if player ~= playables.soul then player.dir = "left" end
			end
			if love.keyboard.isDown("d", "right") or touchDir == "right" then
				player.x, player.y, cols = world:move(player, player.x + vel * dt, player.y, colfilter)
				if player ~= playables.soul then player.dir = "right" end
			end

			-- ANCHOR Walk animation and sound
			if love.keyboard.isDown("w", "a", "s", "d", "up", "down", "left", "right") or touchDir ~= "" then
				local cAnim = floor(player.anim)
				player.anim = (player.anim + 4 * dt) % 2
				if cAnim ~= floor(player.anim) then
					sounds.step:play()
				end
			else
				if player ~= playables.soul then
					player.anim = 2
				else
					player.anim = (player.anim + 4 * dt) % 2
				end
			end
		end
		-- ANCHOR Events
		if level == 1 then
			for i=1, #cols do
				if cols[i].other.n == "larry" then
					endminigame = true
					Ftimer = 0
					return
				end
			end
		end

		if level == 2 then
			for i=1, #cols do
				if cols[i].other.n == "jean" then
					endminigame = true
					Ftimer = 0
					return
				end
			end
		end

		if level == 3 then
			local shattered = nil

			for i, obj in ipairs(map) do
				if obj.n == "shattered" then
					shattered = obj
				end
			end
			
			if shattered.fading then
				shattered.fade = min(shattered.fade + 2 * dt, 1)
			end
			
			for i=1, #cols do
				if cols[i].other.n == "blocker" then
					if not player.block_move then
						timer.script(function(wait)
							wait(3)
							sounds.laugh:play()
							shattered.fading = true
							wait(3)
							fade(true, 2, "whichnight")
						end)

						player.block_move = true
						player.anim = 2
					end
				end
			end
		end
	else
		sounds.ambiance:stop()
		sounds.ambiance2:stop()
		
		if Ftimer >= 8 then
			fade(true, 2, "whichnight")
		end
	end
end

function minigame:keypressed(k)
	
end

function minigame:exit()
	la.stop()
	sprites = recicleTable(sprites)
	cols = recicleTable(cols)
	sounds = recicleTable(sounds)
	map = recicleTable(map)
	scrollers = recicleTable(scrollers)
	world = nil
	ground = nil
	crtscreen = nil
end

return minigame
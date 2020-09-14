local cut = {}

local max, min, floor, random, sin, cos, pi = math.max, math.min, math.floor, math.random, math.sin, math.cos, math.pi

local current = 2
local cutEnd = false
local path = ""
local res = {}

local tapePlay = false
local animTimer = 0
local dust
local fogQuad = love.graphics.newQuad(0 ,0 ,1000, 675, 1900, 675)

local function emit()
	local r = lume.random(0,pi*2)
	local x, y = sin(r) * 500, cos(r) * 337
	dust:setPosition(x+500,y+337)
	dust:setDirection(lume.angle(x,y,500,337))
	dust:emit(random(1,3))
	timer.after(1,emit)
end

function cut:enter(arg)
	current = arg or 1
	path = "assets/Cutscenes/"..current.."/"
	love.audio.stop()
	
	if current == 1 then
		res = {
			dark = {"newImage", path.."escuro.png"},
			fog = {"newImage", path.."neblina.png"},
			post = {"newImage", path.."poste"..langNumber..".png"},
			back = {"newImage", path.."background.png"}
		}
	end
	if current == 2 then
		res = {
			p1 = {"newImage", path.."part1.png"},
			p2 = {"newImage", path.."part2.png"},
			play = {"newSource", "sounds/tape_play.wav", "static"},
			stop = {"newSource", "sounds/tape_stop.wav", "static"},
			tape = {"newSource", "sounds/voices/tape_1.mp3", "stream"},
		}
		
		for i=1, 10 do
			res["a"..i] = {"newImage", path.."rodar000"..i..".jpg"}
		end
		--dust = love.graphics.newParticleSystem(love.graphics.newImage(path.."dust.png"))
		--dust:setLinearAcceleration(-20, -20, 20, 20)
		--dust:setParticleLifetime(1,10)
		--dust:setSpeed(60)
		--emit()
	end
	if current == 3 then
		local items = lfs.getDirectoryItems(path)
		for i, n in ipairs(items) do
			local ext = n:sub(-3)
			if ext == "png" then
				res["a"..tonumber(n:sub(-6, -4))] = {"newImage", path..n}
			end
		end
	end
	pushgamestate("quickload", res)
end

function cut:resume(arg)
	res = arg
	
	if current == 1 then
		res.fog:setWrap("mirroredrepeat")
	end
	if current == 3 then
		timer.after(5, function() fade(true, 2.5, "menu") end)
	end
	
	tapePlay = false
	cutEnd = false
	fade(false, 1.5)
end

function cut:draw()
	if current == 1 then
		local scroll = max(900-Ftimer*45, 0)
		
		love.graphics.draw(res.back, -460-scroll*.4)
		love.graphics.setColor(1,1,1,.5)
		fogQuad:setViewport(scroll - Ftimer * 20, 0, 1000, 675)
		love.graphics.draw(res.fog, fogQuad)
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(res.post, -scroll)
		love.graphics.draw(res.dark)
	end
	if current == 2 then
		love.graphics.draw(res["p"..boolto(res.tape:isPlaying(),2,1)])
		love.graphics.draw(res["a"..floor(animTimer)+1], 420, 310)
		--love.graphics.draw(dust)
	end
	if current == 3 then
		love.graphics.draw(res["a"..(floor(Ftimer * 30) % 21)], 500, 337, 0, Ftimer/10 + .5, Ftimer/10 + .5, 500, 337)
	end
end

function cut:update()
	if current == 1 then
		if Ftimer >= 23 then
			fade(true, 2.5, "menu")
		end
	end
	if current == 2 then
		if res.tape:tell() >= res.tape:getDuration()-.1 then
			res.tape:stop()
			res.stop:play()
			tapePlay = false
			cutEnd = true
			fade(true, 2.5, "menu")
		end
		animTimer = (animTimer + boolto(tapePlay,30) * dt) % 10
		--dust:update(dt)
	end
end

function cut:mousepressed(x,y,button,isTouch)
	if not cutEnd then
		if current == 2 then
			if mouseOver(345, 360, 30, 70) then
				if tapePlay then
					res.tape:pause()
					res.stop:play()
					tapePlay = false
				else
					res.tape:play()
					res.play:play()
					tapePlay = true
				end
			end
		end
	end
end

function cut:exit()
	for _, r in pairs(res) do
		r:release()
	end
	res = {}
	la.stop()
end

return cut
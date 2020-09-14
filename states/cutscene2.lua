local cut = {}

local cutEnd = false
local res = nil
local path = "assets/cutscenes/2/"

local tapePlay = false
local animTimer = 0
local dust = nil

local function emit()
	local r = lume.random(0,pi*2)
	local x, y = sin(r) * 500, cos(r) * 337
	dust:setPosition(x+500,y+337)
	dust:setDirection(lume.angle(x,y,500,337))
	dust:emit(random(1,2))
	timer.after(.3,emit)
end

function cut:enter(arg)
	la.stop()
	
	res = {
		p1 = {"newImage", path.."part1.png"},
		p2 = {"newImage", path.."part2.png"},
		play = {"newSource", "sounds/tape_play.ogg", "static"},
		stop = {"newSource", "sounds/tape_stop.ogg", "static"},
		tape = {"newSource", "sounds/game/voices/"..glang.code.."/tape1.ogg", "stream"},
	}
	for i=1, 10 do
		res["a"..i] = {"newImage", path.."anim"..i..".jpg"}
	end
	dust = lg.newImage(path.."dust.png")
	
	dust = lg.newParticleSystem(dust)
	dust:setLinearAcceleration(-20, -20, 20, 20)
	dust:setParticleLifetime(1,10)
	dust:setSpeed(60)
	
	pushgamestate("quickload", res)
end

function cut:resume(arg)
	res = arg
	
	tapePlay = false
	cutEnd = false
	if lang.subtitle then
		subtitle.parse(lang.subtitle)
		subtitle.back = true
		subtitle.size = 23
	end
	fade(false, 1.5)

	emit()
end

function cut:draw()
	lg.draw(res["p"..boolto(res.tape:isPlaying(),2,1)])
	lg.draw(res["a"..floor(animTimer)+1], 420, 310)
	
	lg.setColor(1,1,1,.3)
	lg.draw(dust)
end

function cut:update()
	if res.tape:tell() >= res.tape:getDuration()-0.1 then
		res.tape:stop()
		res.stop:play()
		tapePlay = false
		cutEnd = true
		fade(true, 2.5, "menu")
	end
	
	animTimer = (animTimer + boolto(tapePlay,30) * dt) % 10
	subtitle.pause = not tapePlay
	dust:update(dt)
end

function cut:mousepressed(x,y)
	if mouseOver(345, 360, 30, 70) and not cutEnd then
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

function cut:exit()
	res = nil
	la.stop()
end

return cut
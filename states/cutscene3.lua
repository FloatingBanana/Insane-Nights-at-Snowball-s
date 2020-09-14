local cut = {}

local animTimer = 1
local res = nil
local path = "assets/cutscenes/3/"

function cut:enter(arg)
	la.stop()

	res = {}
	for i=1, 21 do
		res[i] = {"newImage", path..i..".png"}
	end

	res.music = {"newSource", "sounds/cutscenes/3/background.ogg", "stream"}
	pushgamestate("quickload", res)
end

function cut:resume(arg)
	res = arg
	animTimer = 1

	timer.after(5, function() fade(true, 2.5, "menu") end)
	res.music:play()
	fade(false, 1.5)
end

function cut:draw()
	lg.draw(res[(floor(Ftimer * 30) % 21)+1], 500, 337, 0, Ftimer/10 + .5, Ftimer/10 + .5, 500, 337)
end

function cut:exit()
	res = nil
	la.stop()
end

return cut
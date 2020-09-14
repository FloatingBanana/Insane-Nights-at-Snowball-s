local cut = {}

local res = nil
local fogQuad = lg.newQuad(0 ,0 ,1000, 675, 1900, 675)
local back_to_menu = false
local path = "assets/cutscenes/1/"

function cut:enter(arg)
	la.stop()

	res = {
		dark = {"newImage", path.."dark.png"},
		fog = {"newImage", path.."fog.png"},
		post = {"newImage", path.."post"..langNumber..".png"},
		back = {"newImage", path.."background.png"},
		music = {"newSource", "sounds/cutscenes/1/background.ogg", "stream"}
	}
	
	back_to_menu = arg ~= nil
	pushgamestate("quickload", res)
end

function cut:resume(arg)
	res = arg
	res.fog:setWrap("mirroredrepeat")
	res.music:play()
	res.music:setVolume(.6)
	
	fade(false, 1.5)

	timer.after(23, function()
		fade(true, 2.5, "whichnight")
	end)
end

function cut:draw()
	local scroll = max(900-Ftimer*45, 0)
	
	lg.draw(res.back, -460-scroll*.4)
	lg.setColor(1,1,1,.5)
	fogQuad:setViewport(scroll - Ftimer * 20, 0, 1000, 675)
	lg.draw(res.fog, fogQuad)
	lg.setColor(1,1,1,1)
	lg.draw(res.post, -scroll)
	lg.draw(res.dark)
end

function cut:exit()
	res = nil
	la.stop()
end

return cut
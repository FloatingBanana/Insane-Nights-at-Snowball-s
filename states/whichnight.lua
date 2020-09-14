local whichnight = {}

local sound = la.newSource("sounds/wichnight.ogg", "static")
local text = ""
local lineSpeed = 0

function whichnight:enter()
	if random(1, 50) == 1 then
		loadgamestate("darkfaces", "whichnight")
		
		return
	end
	
	menuMusic:stop()
	sound:play()
	fade(false, 2)
	
	if night <= 6 then
		text = glang.office.night.." "..night
	end
	if night == 7 then
		text = glang.menu["op1_4"]
	end
	if night == 8 then
		text = glang.customnight["c"..(currChallenge or 0)]
	end
	if night == 9 then
		text = glang.menu.secretnight
	end

	setFont("alienleague", 70)
	lineSpeed = fontWidth(text) / 12
    
	timer.after(4, function() fade(true, 2, "loading") end)
end

function whichnight:draw()
	setFont("alienleague", 70)
	lg.push()
	
	local mult = Ftimer/15
	lg.translate(-wWidth * mult/2, -wHeight * mult/2)
	lg.scale(1 + mult)

	lg.printf(text.."\n12:00 AM", 0, 250, 1000, "center")
	lg.line(500 - Ftimer * lineSpeed, 320, 500, 320, 500 + Ftimer * lineSpeed, 320)
	
	lg.pop()
end

function whichnight:exit()
	sound:stop()
end

return whichnight
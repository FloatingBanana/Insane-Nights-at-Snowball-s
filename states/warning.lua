local warning = {}

local glow = nil
local logo = nil

function warning:enter()
	blur.gaussianblur.sigma = 5

	glow = lg.newCanvas(wWidth, wHeight)
	logo = lg.newImage("assets/icons/inas_productions.jpg")

	lg.setCanvas(glow)
	blur(function()
  		setFont("alienleague", 50)
		lg.printf(lang.title, 250, 250, 500, "center")
		setFont("alienleague", 40)
		lg.printf(lang.txt, 150, 330, 700, "center")
	end)
	setFont("alienleague", 50)
	lg.printf(lang.title, 250, 250, 500, "center")
	setFont("alienleague", 40)
	lg.printf(lang.txt, 150, 330, 700, "center")
	lg.setCanvas()
end

function warning:draw()
	lg.setColor(1,1,1,sin((Ftimer/2)%(pi+.5))*1.5)
	if Ftimer < 6.5 then
		lg.draw(logo, 500, 337, 0, 1+Ftimer/35, 1+Ftimer/35, 500, 337)
	else
		lg.draw(glow)
	end
end

function warning:update()
	if dt > 0.2 then
		dt = 0
		Ftimer = 0
	end

	if Ftimer >= 14.5 then
		loadgamestate("menu")
	end
end

function warning:exit()
	glow = nil
	logo = nil
end

return warning
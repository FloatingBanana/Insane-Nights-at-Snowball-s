dialog = {}

local function new(_, text, ...)
	setFont("alienleague", 20)
	local _, wrap = fonts[currFont]:getWrap(text, 800)
	wrap = #wrap * fonts[currFont]:getHeight()
	toLast(dialogList, {t = text, h = wrap + 50, buttons = {...}})
	dialAlpha = 0
	dclosing = false
end
setmetatable(dialog, {__call = new})

dialAlpha = 0
dclosing = false
dialogList = {}
local stack = 0
local nbuttons = 0
local dial = nil

--Dialog background image
local dialBackground = love.image.newImageData(1,2)
dialBackground:setPixel(0,0,0,0,0,0)
dialBackground:setPixel(0,1,0,0,0,1)
dialBackground = lg.newImage(dialBackground)
dialBackground:setFilter("linear", "linear")

function dialog.draw()
	if #dialogList > 0 then
		--Draw dialog background
		lg.setColor(0,0,0,dialAlpha)
		lg.rectangle("fill", 0, (wHeight - dial.h) / 2, wWidth, dial.h)
		lg.draw(dialBackground, 0,(wHeight - dial.h) / 2 - 80, 0, wWidth, 40)
		lg.draw(dialBackground, wWidth, (wHeight - dial.h) / 2 + 80 + dial.h, pi, wWidth, 40)

		--Draw text
		lg.setColor(1,1,1,dialAlpha)
		setFont("alienleague", 20)
		lg.printf(dial.t, 100, (wHeight - dial.h) / 2, 800, "center")

		--Draw buttons
		for i, btn in ipairs(dial.buttons) do
			local x, y = (wWidth / 2 - nbuttons * 42) + 84 * (i - 1), (wHeight - dial.h) / 2 + dial.h - 30
			lg.setColor(1,1,1,dialAlpha)
			lg.rectangle("fill", x, y, 80, 20)
			lg.setColor(0,0,0,dialAlpha)
			lg.printf(btn[1], x, y, 80, "center")
		end
	end
end

function dialog.update()
	stack = #dialogList
	dial = dialogList[stack]
	
	dialAlpha = clamp(dialAlpha + boolto(dclosing, -3, 3) * dt, 0, 1)
	if dial then
		nbuttons = #dial.buttons
	end
	
	if stack > 0 and dclosing and dialAlpha <= 0 then
		table.remove(dialogList, stack)
		dclosing = false
	end
end

function dialog.mousepressed()
	if dial then
		local id
		local x, y = RXmouse, RYmouse
		local by = (wHeight - dial.h) / 2 + dial.h - 30
		for i = 1, nbuttons do
			local bx = (wWidth / 2 - nbuttons * 42) + 84 * (i - 1)
	
			if  x < bx+80 and
				bx < x    and
				y < by+20 and
				by < y    then
				id = i
			end
		end
	
		if id then
			if dial.buttons[id][2] then
				dial.buttons[id][2]()
			end
			dclosing = true
		end
	end
end

function dialog.queque(text, ...)
	setFont("alienleague", 20)
	local wrap = fontHeight(text, 800)
	table.insert(dialogList, 1, {t = text, h = wrap + 50, buttons = {...}})
end
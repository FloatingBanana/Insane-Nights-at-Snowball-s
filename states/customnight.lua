local customnight = {}

--local imgui = require "imgui"

local chroll = 0
local chmenu = false
local star = lg.newMesh({{6,6},{8,0},{10,6},{16,6},{11,10},{13,16},{8,12},{3,16},{5,10},{0,6}})

local back, go = nil, nil

local challenges = {
	{name = "1970 Challenge", 10,10,5,0,6,0,0},
	{name = "Midnight Time", 15,0,0,0,0,17,10},
	{name = "Metalic Revenge", 0,0,0,0,12,10,16},
	{name = "Triple Nightmare", 0,20,20,20,0,0,0},
	{name = "White and Gray", 13,0,0,0,20,0,13},
	{name = "Try to Focus", 0,0,10,15,15,20,0},
	{name = "Trick or Death", 0,18,15,10,10,0,0},
	{name = "7/20 Mode", 20,20,20,20,20,20,20}
}

local quad = lg.newQuad(200, 200, 150, 200, 1366, 675)

currChallenge = nil
cnlevels = {0,0,0,0,0,0,0}

local images = {}
local frames = {}

function customnight:enter()
	for i=1, 7 do
		local image = lg.newImage("assets/icons/cn/"..i..".png")

		images[i] = image
		frames[i] = createFrame(30 + boolto(i > 4, 75) + 160 * ((i - 1) % 4), boolto(i > 4, 337, 127), lang.names[i], image, cnlevels[i], 1 - i * 0.5)
	end

	if not menuMusic:isPlaying() then
		menuMusic:play()
	end
	
	for i=1, #challenges do
		challenges[i].name = lang["c"..i]
	end
	
	chroll = 0
end

local bg = lg.newImage("assets/menu/cnbg.jpg")
function customnight:draw()
	lg.draw(bg)

	--Draw animatronic frames
	for i, frame in ipairs(frames) do
		frame:draw()
	end

	--Draw GUI
	lg.setColor(1,1,1,Ftimer*4)
	imgui.draw()
	
	--Selected challenge
	lg.setColor(0,0,.2,1)
	lg.rectangle("fill", 967, 100, 32, 320)

	lg.setColor(1,1,1,1)
	lg.rectangle("line", 967, 100, 32, 320)
	
	setFont("OCRAEXT", 25)
	lg.printf(boolto(currChallenge, challenges[currChallenge or 1].name, lang.challenges), 970, 420, 320, "center", pi*1.5)
	
	for line, list in ipairs(challenges) do
		if currChallenge == line then
			--Green if selected
			lg.setColor(0, .3, 0, 1)

		elseif mouseOver(wWidth - 320, 60 + 40 * line, 320, 40) then
			--Blue if hovered
			lg.setColor(0, 0, .3, 1)
		else
			--Defaults to dark blue
			lg.setColor(0, 0, .1, 1)
		end
		
		--Draw rectangles
		lg.rectangle("fill", wWidth - chroll, 60 + 40 * line, 320, 40)
		lg.setColor(1,1,1,1)
		lg.rectangle("line", wWidth - chroll, 60 + 40 * line, 320, 40)
		
		--Star completed challenges
		if savedata.cnchallenge and savedata.cnchallenge[line] then
			lg.draw(star, 1280 - chroll, 64 + 40 * line, 0, 2 )
		end
		
		--Set color to red on 7/20 mode
		if line == #list+1 then
			lg.setColor(1,0,0,1)
		end
		
		--Draw challenge name
		lg.print(list.name, wWidth - chroll, 67 + 40 * line)
	end
end

function customnight:update()
	for i, frame in ipairs(frames) do
		frame:update()
		cnlevels[i] = frame.level
	end
	
	local brk = false
	for i=1, #challenges do
		if brk then
			break
		end

		local levels = challenges[i]

		for j=1, #levels do
			if levels[j] ~= cnlevels[j] then
				currChallenge = nil
				brk = false

				break
			end

			currChallenge = i
			brk = true
		end
	end

	if mouseOver(wWidth-320, 100, 320, 320) then
		chroll = min(chroll + dt * 10 * (319-chroll), 319)
	else
		chroll = max(chroll - dt * 10 * chroll, 0)
	end
	
	imgui.update()
	setFont("OCRAEXT", 45)

	if imgui.textbutton("bk", glang.menu.op2_6, "left", 30, 610) then
		loadgamestate("menu")
	end

	if imgui.textbutton("st", glang.menu.op2_7, "right", 0, 610) then
		fade(true, 3, "whichnight")
		
		night = 8
	end

	imgui.current.x = 1000 - imgui.current.w - 30
end

function customnight:mousepressed(x,y)
	for line, list in ipairs(challenges) do
		if mouseOver(wWidth - 320, 60 + 40 * line, 320, 40) then
			for i=1, #list do
				frames[i].level = list[i]
				frames[i].levelScroll = clamp(frames[i].levelScroll, list[i] - 1, list[i] + 1)
			end
		end
	end

	for i, frame in ipairs(frames) do
		frame:mousepressed(x,y)
	end
end

function customnight:mousereleased()
	for i, frame in ipairs(frames) do
		frame:mousereleased(x,y)
	end
end

local numberDisplay = lg.newCanvas(58, 40)
createFrame = class {
	init = function(self, x, y, name, image, level, alpha)
		self.x = x
		self.y = y
		self.name = name
		self.image = image
		self.level = level
		self.alpha = alpha

		self.arrowAnim = 0
		self.levelScroll = level
		self.holdtimer = 0.4
	end,
	draw = function(self)
		lg.push()
		lg.translate(self.x, self.y)

		lg.setLineWidth(2)
		lg.setColor(1, 1, 1, self.alpha)
		lg.draw(self.image, 0, 0)

		if dbg.show_static then
			lg.setColor(1, 1, 1, 0.2 * self.alpha)

			if self.level > 0 or self.hovered then
				local anim = Ftimer * 25

				lg.draw(static, quad, 75, 100, 0, boolto(floor(anim % 2 ) == 1, -1, 1), boolto(floor(anim % 4) < 2, 1, -1), 75, 100)
			else
				lg.draw(static, quad, 0, 0)
			end
		end

		lg.setColor(1, 1, 1, self.alpha)
		lg.rectangle("line", 0, 0, 150, 200)

		local y = self.arrowAnim * 10

		setFont("OCRAEXT", 40)
		lg.push()
		lg.setCanvas(numberDisplay)
		lg.clear()
		lg.origin()
		lg.translate(-self.levelScroll * 58, 0)
		
		for i=0, dbg.cn_ai_limit do
			if i > self.level - 2 and i < self.level + 2 then
				lg.printf(i, i * 58, 0, 58, "center")
			end
		end
		
		lg.setCanvas()
		lg.pop()
		lg.draw(numberDisplay, 45, 155 - y)

		lg.setColor(1, 1, 1, self.arrowAnim * self.alpha)
		lg.polygon("line", 25, 175-y, 45, 160-y, 45, 190-y)
		lg.polygon("line", 125, 175-y, 105, 160-y, 105, 190-y)

		setFont("OCRAEXT", 20)
		lg.printf(self.name, 5, 5, 140, "center")

		local highlight = self.level > 0 or self.hovered
		lg.setColor(0, 0, 0, boolto(highlight, 0, .5) * self.alpha)
		lg.rectangle("fill", 0, 0, 150, 200)

		lg.pop()
	end,
	update = function(self)
		self.hovered = mouseOver(self.x, self.y, 150, 200)
		local target = boolto(self.hovered)
		
		self.arrowAnim = ease(self.arrowAnim, target, 8)

		self.hoverDirection = nil
		if mouseOver(self.x, self.y + 150, 45, 30) then
			self.hoverDirection = "left"
		end

		if mouseOver(self.x + 105, self.y + 150, 45, 30) then
			self.hoverDirection = "right"
		end

		self.levelScroll = ease(self.levelScroll, self.level, 13 * boolto(self.holdtimer <= 0, 10, 1))

		if self.holdtimer > 0 then
			self.holdtimer = self.holdtimer - boolto(self.hoverDirection and lm.isDown(1)) * dt
		else
			self.holdtimer = 0.15
			self:mousepressed()
		end

		self.alpha = min(self.alpha + 3 * dt, 1)
	end,

	mousepressed = function(self, x, y)
		if self.hoverDirection == "left" and self.level > 0 then
			self.level = self.level - 1
		end

		if self.hoverDirection == "right" and self.level < dbg.cn_ai_limit then
			self.level = self.level + 1
		end
	end,

	mousereleased = function (self, x, y)
		self.holdtimer = 0.4
	end
}


return customnight
local cr = {}

local blocks, titles = nil, nil
local res = nil

local fontH = 0
local angle, mag = 0, 0
local spotX, spotY = 0, 0
local lastAngle, lastMag = 0, 0

function cr:enter()
	res = {
		music = {"newSource", "sounds/musics/credits.ogg", "stream"},
		title = {"newImage", "assets/icons/title.png"},
	}

	for i=1, 4 do
		res[i] = {"newImage", "assets/icons/credits_images/"..i..".jpg"}
	end

	pushgamestate("quickload", res)
	la.stop()
	chromaticAberration:send("distortion", 0.1)
end

function cr:resume(r)
	res = r
	res.music:setVolume(.6)
	res.music:play()

	setFont("alienleague", 25)
	fontH = fonts[currFont]:getHeight()
	blocks, titles = {}, {}
	
	for t=1, 4 do
		local sec = lang["section"..t]:explode("\n!\n")

		for _, block in ipairs(sec) do
			toLast(blocks, textBlock(block, 8, t%2==0))
		end

		local _, lb = fonts[currFont]:getWrap(sec[1], 500)
		local lb = string.rep("\n", #lb + 4)

		toLast(titles, textBlock(lang["title"..t]..lb, #sec * 8, t%2==0, res[t]))
	end

	timer.after(85, function()
		fade(true, 4, "menu")
	end)
end

function cr:draw()
	if Ftimer < 7 then
		lg.setColor(1,1,1,7 - Ftimer)
		lg.draw(res.title, 500 - res.title:getWidth()/2, 337 - res.title:getHeight()/2)
	end

	setFont("alienleague", 25)
	if titles[1] then
		lg.push()
		lg.translate(lume.vector(angle, mag/2))
		lg.setColor(1,1,1,.2)

		blocks[1]:draw()
		titles[1]:draw()

		lg.pop()
		lg.push()
		lg.translate(lume.vector(angle + math.pi, mag))

		lg.setColor(1,1,1,1)
		blocks[1]:draw()
		titles[1]:draw()

		lg.pop()
	end

	if Ftimer > 82 then
		lg.setColor(1,1,1,Ftimer-82)
		setFont("alienleague", 40)
		lg.printf(lang.final, 0, 317, 1000, "center")
	end
end

function cr:update()
	if titles[1] and Ftimer > 8 then
		blocks[1]:update(dt)
		titles[1]:update(dt)
	end
	
	if lm.isDown(1) then
		angle = lume.angle(spotX, spotY, RXmouse, RYmouse) + lastAngle
		mag = math.min(lume.distance(spotX, spotY, RXmouse, RYmouse)/30 + lastMag, 60)
	else
		mag = math.max(mag - mag * 6 * dt, 0)
	end

	chromaticAberration:send("aberration", 0.1 * mag)
end

function cr:mousepressed(x, y)
	spotX, spotY = x, y
end

function cr:exit()
	res = nil
	la.stop()
end

textBlock = class {
	init = function(self, text, time, left, img)
		self.step = 0
		self.time = time
		self.img = img
		self.left = left
		self.write = true
		_, self.text = fonts[currFont]:getWrap(text, 450)
		self.x = boolto(left, 50, 550)
		self.y = 337 - #self.text * fontH / 2
		self.max = 0
		
		for i, t in ipairs(self.text) do
			local offset = utf8.offset(t, -1)
			
			if offset then
				if self.max < offset then
					self.max = offset
					greater = t
				end
			end
		end
	end,

	update = function(self, dt)
		self.step = clamp(self.step + boolto(self.write, 30, -30) * dt, 0, self.max)
		self.time = self.time - dt
		
		local waitTime = self.max/30
		if self.time <= waitTime then
			self.write = false
		end

		if self.time <= 0 then
			if blocks[1] == self then
				table.remove(blocks, 1)
			else
				table.remove(titles, 1)
			end
		end
	end,

	draw = function(self)
		for i, t in ipairs(self.text) do
			local ok = pcall(lg.printf, string.sub(t, 1, self.step), self.x, self.y + (i-1) * fontH, 450, "left")
			
			if not ok then
				lg.printf(string.sub(t, 1, self.step-1), self.x, self.y + (i-1) * fontH, 450, "left")
			end
		end

		if self.img then
			local imgx = boolto(self.left, 550, 50)
			local _,_,_,a = lg.getColor()
			local alpha = self.step/self.max * a
			
			lg.setShader(chromaticAberration)
			lg.setColor(1,1,1, alpha)
			lg.draw(self.img, imgx, 177, 0, .4)
			lg.setShader()

			lg.setLineWidth(3)
			lg.setColor(0,0,0, alpha)
			lg.rectangle("line", imgx, 177, 400, 256, 4)

			lg.setLineWidth(1)
			lg.setColor(1,1,1,1)
		end
	end
}

return cr
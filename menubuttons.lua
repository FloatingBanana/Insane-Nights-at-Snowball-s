local selQuad = lg.newQuad(0, 0, 500, 55, 400, 350)
gbuttons = class {
	init = function(self, x, y, menu, id, width, func, mode, height)
		self.selX = 0
		self.x = x
		self.y = y
		self.menu = menu
		self.id = id
		self.func = func
		self.width = width
		self.height = height or 45
		self.pressed = false
		self.selected = false
		self.mode = mode or "right"
	end,
	draw = function(self, alpha)
		lg.push()
		lg.setColor(1,1-self.selX/30, 1-self.selX/30, alpha)
		selQuad:setViewport(0, self.id, 500, self.height + 10, self.menu:getWidth(), self.menu:getHeight())
		if self.mode == "right" then
			lg.draw(self.menu, selQuad, self.x + self.selX, self.y - 5)
		elseif self.mode == "left" then
			lg.draw(self.menu, selQuad, self.x + 30 - self.selX, self.y - 5)
		elseif self.mode == "fade" then
			lg.draw(self.menu, selQuad, self.x + 15, self.y - 5)
		else
			error(self.menu.." is not a mode")
		end
		lg.pop()
	end,
	update = function(self, dt)
		if mouseOver(self.x, self.y, self.width + 30, self.height) and (not isMobile or lm.isDown(1)) then
			self.selX = min(self.selX + 150 * dt, 30)
			if not self.selected then
				menuselect:setPitch(lume.random(.8, 1))
				menuselect:stop()
				menuselect:play()
				self.selected = true
			end
		else
			self.selX = max(self.selX - 150 * dt, 0)
			self.selected = false
		end
	end,
	mousepressed = function(self, x, y)
		if mouseOver(self.x, self.y, self.width + 30, self.height) then
			if isMobile then
				self.pressed = true
			else
				self.func()
			end
		end
	end,
	mousereleased = function(self, x, y)
		if isMobile and self.pressed and mouseOver(self.x, self.y, self.width + 30, self.height) then
			self.func()
			self.pressed = false
		end
	end
}
local anm = {}
local funcs = {}
local sefuncs = {}
local shfuncs = {}

local floor = math.floor

local function copy_to_table(from, to)
	for k, v in pairs(from) do
		to[k] = v
	end
end

function anm.newSequence(images, speed, range)
	local new = {
		images = images,
		speed = speed or 30,
		frame = 1,
		time = 0,
		playing = false,
		rewind = false,
		loop = false,
		range = range or #images
	}
	copy_to_table(funcs, new)
	copy_to_table(sefuncs, new)
	
	return new
end

function anm.newSheet(sheet, width, height, speed, range)
	local new = {
		sheet = sheet,
		quad = love.graphics.newQuad(0, 0, width, height, sheet:getDimensions()),
		speed = speed or 30,
		frame = 1,
		time = 0,
		playing = false,
		rewind = false,
		loop = false,
		width = width,
		height = height,
		maxColums = sheet:getWidth()/width,
		maxLines = sheet:getHeight()/height,
		range = range or (sheet:getWidth()/width * sheet:getHeight()/height)
	}
	copy_to_table(funcs, new)
	copy_to_table(shfuncs, new)
	
	return new
end

function funcs:update(dt)
	if self.playing then
		local dir = self.rewind and 1 or -1
		
		self.time = self.time + self.speed * dt
		if self.time >= 1 then
			self.frame = self.frame +- dir
			self.time = self.time - 1
		end
		if self.loop then
			if self.frame < 1 then
				self.frame = self.range
				if self.onFinish then
					self:onFinish()
				end
			elseif self.frame > self.range then
				self.frame = 1
				if self.onFinish then
					self:onFinish()
				end
			end
		else
			if self.frame < 1 then
				self.frame = 1
				self.playing = false
				if self.onFinish then
					self:onFinish()
				end
			elseif self.frame > self.range then
				self.frame = self.range
				self.playing = false
				if self.onFinish then
					self:onFinish()
				end
			end
		end
	end
	
	return self
end

function funcs:stop()
	self.playing = false
	self.time = 0
	
	if self.rewind then
		self.frame = self.range
	else
		self.frame = 1
	end
	
	return self
end

function funcs:pause()
	self.playing = false
	
	return self
end

function funcs:play()
	self.playing = true
	
	if self.rewind then
		if self.frame == 1 then
			self.frame = self.range
		end
	else
		if self.frame == self.range then
			self.frame = 1
		end
	end
	
	return self
end

function sefuncs:draw(...)
	love.graphics.draw(self.images[self.frame], ...)
	
	return self
end

function shfuncs:draw(...)
	local spriteX = (self.frame-1) % self.maxColums 
	local spriteY = floor((self.frame-1) / self.height)
	
	self.quad:setViewport(spriteX * self.width, spriteY * self.height, self.width, self.height)
	love.graphics.draw(self.sheet, self.quad, ...)
	
	return self
end

function funcs:getFrame()
	return self.frame
end

function funcs:getSpeed()
	return self.speed
end

function funcs:getRange()
	return self.range
end

function sefuncs:getImage(frame)
	return self.images[frame or self.frame]
end

function sefuncs:getAllImages()
	return self.frames
end

function shfuncs:getSheet()
	return self.sheet
end

function funcs:isLooping()
	return self.loop
end

function funcs:isRewinding()
	return self.rewind
end


function funcs:isPlaying()
	return self.playing
end

function funcs:setFrame(frame)
	self.frame = frame
	self.time = 0
	
	return self
end

function funcs:setSpeed(speed)
	self.speed = speed
	
	return self
end

function funcs:setRange(range)
	self.range = range
	
	return self
end

function sefuncs:setImage(image, frame)
	self.images[frame or self.frame] = image
	
	return self
end

function sefuncs:setAllImages(images)
	self.images = images
	self.range = #images
	
	return self
end

function shfuncs:setSheet(sheet)
	self.sheet = sheet
	
	return self
end

function shfuncs:setSize(width, height)
	self.width = width or self.width
	self.height = height or self.height
end

function funcs:setLoop(loop)
	self.loop = loop
	
	return self
end

function funcs:setRewind(rewind)
	self.rewind = rewind
	
	return self
end

return anm
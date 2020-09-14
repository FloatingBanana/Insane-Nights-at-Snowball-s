local res = {mouse = {}, touch = {}}

local min, max, floor = math.min, math.max, math.floor

local getWidth = love.graphics.getWidth
local getHeight = love.graphics.getHeight
local mousegetX = love.mouse.getX
local mousegetY = love.mouse.getY
local mousegetPosition = love.mouse.getPosition
local touchgetPosition = love.touch.getPosition

local NULL = function(_) return _ end
local clamp = nil
local resized = false
local olddraw
local oldmousepressed
local oldmousereleased
local oldmousemoved
local oldtouchpressed
local oldtouchreleased
local oldtouchmoved

local conf = {
	centered = false,
	aspectRatio = true,
	clampMouse = false,
	clip = true,
	width = getWidth(),
	height = getHeight()
}
local replaced = {}
local scalerW, scalerH = 1, 1
local centerXoffset, centerYoffset = 0, 0

local function f_clamp(n, low, high)
	if conf.clampMouse then
		return min(max(n, low), high)
	end
	return n
end

local function check_type(obj, check)
	local objtype = type(obj)
	if objtype == "userdata" then
		if obj.type then
			objtype = obj:type()
		end
	end
	assert(objtype == check, check.." expected, got "..objtype)
end

function res.init(c)
	check_type(c, "table")
	
	if c.replace then
		check_type(c.replace, "table")
		res.replace(c.replace)
	end
	c.width = c.width or getWidth()
	c.height = c.height or getHeight()
	conf = c
end

function res.start()
	assert(not resized, "Missing \"stop\" function")
	
	love.graphics.push()
	scalerW = getWidth()/conf.width
	scalerH = getHeight()/conf.height
	if conf.aspectRatio then
		scalerW = min(scalerW, scalerH)
		scalerH = scalerW
	end
	
	if conf.centered then
		centerXoffset = (getWidth() - conf.width * scalerW)/2
		centerYoffset = (getHeight() - conf.height * scalerH)/2
		love.graphics.translate(centerXoffset, centerYoffset)
	else
		centerXoffset = 0
		centerYoffset = 0
	end
	love.graphics.scale(scalerW, scalerH)
	if conf.clip then
		love.graphics.setScissor(centerXoffset, centerYoffset, conf.width * scalerW + 1, conf.height * scalerH)
	end
	resized = true
end

function res.stop()
	assert(resized, "Missing \"start\" function")
	love.graphics.scale(1/scalerW, 1/scalerH)
	love.graphics.setScissor()
	love.graphics.pop()
	
	resized = false
end

function res.toResized(x,y)
	x = floor(x / scalerW) - centerXoffset / scalerW
	y = floor(y / scalerH) - centerYoffset / scalerH
	return x, y
end

function res.toScreen(x,y)
	x = floor(x * scalerW) + centerXoffset * scalerW
	y = floor(y * scalerH) + centerYoffset * scalerH
	return x, y
end

function res.mouse.getX()
	return f_clamp(floor(mousegetX() / scalerW - centerXoffset / scalerW), 0, conf.width)
end

function res.mouse.getY()
	return f_clamp(floor(mousegetY() / scalerH - centerYoffset / scalerH), 0, conf.height)
end

function res.mouse.getPosition()
	return res.toResized(mousegetPosition())
end

function res.touch.getPosition(id)
	return res.toResized(touchgetPosition(id))
end


function res.replace(modules)
	if #modules == 0 then
		modules = {"graphics","mouse","touch"}
	end

	for i, event in ipairs(modules) do
		if event == "graphics" and not replaced.graphics then
			--draw
			olddraw = love.draw or NULL
			love.draw = function()
				res.start()
				olddraw()
				res.stop()
			end
		end
	
		if event == "mouse" and not replaced.mouse then
			love.mouse.getX = res.mouse.getX
			love.mouse.getY = res.mouse.getY
			love.mouse.getPosition = res.mouse.getPosition
			
			--mousepressed
			oldmousepressed = love.mousepressed or NULL
			love.mousepressed = function(x, y, button, isTouch, presses)
				x, y = res.toResized(x, y)
				oldmousepressed(x, y, button, isTouch, presses)
			end
			
			--mousereleased
			oldmousereleased = love.mousereleased or NULL
			love.mousereleased = function(x, y, button, isTouch, presses)
				x, y = res.toResized(x, y)
				oldmousereleased(x, y, button, isTouch, presses)
			end
			
			--mousemoved
			oldmousemoved = love.mousemoved or NULL
			love.mousemoved = function(x, y, dx, dy, isTouch)
				x, y = res.toResized(x, y)
				dx, dy = res.toResized(dx, dy)
				oldmousemoved(x, y, dx, dy,  isTouch)
			end
		end
	
		if event == "touch" and not replaced.touch then
			love.touch.getPosition = res.touchPosition
			
			--touchpressed
			oldtouchpressed = love.touchpressed or NULL
			love.touchpressed = function(id, x, y, dx, dy, pressure)
				x, y = res.toResized(x, y)
				dx, dy = res.toResized(dx, dy)
				oldtouchpressed(id, x, y, dx, dy, pressure)
			end
			
			--touchreleased
			oldtouchreleased = love.touchreleased or NULL
			love.touchreleased = function(id, x, y, dx, dy, pressure)
				x, y = res.toResized(x, y)
				dx, dy = res.toResized(dx, dy)
				oldtouchreleased(id, x, y, dx, dy, pressure)
			end
			
			--touchmoved
			oldtouchmoved = love.touchmoved or NULL
			love.touchmoved = function(id, x, y, dx, dy, pressure)
				x, y = res.toResized(x, y)
				dx, dy = res.toResized(dx, dy)
				oldtouchmoved(id, x, y, dx, dy, pressure)
			end
		end
		replaced[event] = true
	end
end

return res
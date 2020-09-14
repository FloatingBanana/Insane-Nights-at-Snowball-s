local mgeditor = {}

local item = 1
local cx, cy = 0, 0
local camx, camy = 0, 0

local zoom = 1

local map = {}
local sprites = {}

local function newItem(n, x, y)
	local sp = sprites[n]
	local obj = {
		x = x,
		y = y,
		sp = sp,
		spn = n,
		w = sp:getWidth(),
		h = sp:getHeight(),
		quad = lg.newQuad(0, 0, sp:getWidth(), sp:getHeight(), sp:getWidth(), sp:getHeight()),

		sel = false,
	}
	toLast(map, obj)
end

function mgeditor:enter()
	for i=1, 15 do
		sprites[i] = lg.newImage("assets/minigames/objects/"..i..".png")
		sprites[i]:setWrap("repeat", "repeat")
	end
	sprites.sx = lg.newImage("assets/minigames/objects/sx.png")
	sprites.sy = lg.newImage("assets/minigames/objects/sy.png")
end

function mgeditor:draw()
	lg.push()
	lg.translate(-camx, -camy)

	for i, obj in ipairs(map) do
		obj.quad:setViewport(0, 0, obj.w, obj.h)
		lg.draw(obj.sp, obj.quad, obj.x, obj.y)
		
		if not lk.isDown("lctrl") then
			if obj.hover or obj.rw or obj.rh then
				if obj.rw or obj.rh then
					lg.setColor(0,1,1)
				else
					lg.setColor(0,0,1)
				end
				lg.rectangle("line", obj.x, obj.y, obj.w, obj.h)
				lg.setColor(0,0,0)
				lg.rectangle("fill", obj.x+obj.w/2-3, obj.y+obj.h-5, 5, 5)
				lg.setColor(1,1,1)
				lg.rectangle("line", obj.x+obj.w/2-3, obj.y+obj.h-5, 5, 5)
				lg.setColor(0,0,0)
				lg.rectangle("fill", obj.x+obj.w-5, obj.y+obj.h/2-3, 5, 5)
				lg.setColor(1,1,1)
				lg.rectangle("line", obj.x+obj.w-5, obj.y+obj.h/2-3, 5, 5)
			end
		end
	end
	if lk.isDown("lctrl", "x", "y") then
		lg.draw(sprites[item], cx, cy)
	end

	lg.pop()
	lg.push()
	lg.translate(-(camx%992), -(camy%672))
	lg.rectangle("line", 0, 0, 992, 672)
	lg.rectangle("line", 992, 0, 992, 672)
	lg.rectangle("line", 992, 672, 992, 672)
	lg.rectangle("line", 0, 672, 992, 672)
	lg.pop()

	setFont(20)
	lg.print("Objects: "..#map)

	setFont(15)
	lg.print([[
	Left click: select/resize objects
	Right click: delete object
	Middle click: drag view

	Alt + left click: resize object without snapping
	Ctrl + left click: Create object
	Scroll: change object
	
	X + left click: place a horizontal scroller
	Y + left click: place a vertical scroller 

	S: save map in the save directory
	L: load map in the save directory (or the default one)
	]], 0, 30)
end

function mgeditor:update()
	RXmouse, RYmouse = RXmouse + camx, RYmouse + camy

	for i, obj in ipairs(map) do
		obj.hover = false
	end

	if lk.isDown("x") then
		cx, cy = floor(RXmouse/992)*992, floor(RYmouse/672)*672+336
		item = "sx"
	elseif lk.isDown("y") then
		cx, cy = floor(RXmouse/992)*992+496, floor(RYmouse/672)*672
		item = "sy"
	else
		if item == "sx" or item == "sy" then
			item = 1
		end

		for i, obj in lume.ripairs(map) do
			if not lk.isDown("lctrl") and mouseOver(obj.x, obj.y, obj.w, obj.h) then
				obj.hover = true
				break
			end
		end

		cx, cy = floor(RXmouse/32)*32, floor(RYmouse/32)*32
		if lk.isDown("lalt") then
			cx, cy = RXmouse, RYmouse
		end
		local ores = nil
		if lk.isDown("lshift") and ores then
			tx, ty = floor(RXmouse/ores:getWidth()) * ores:getWidth(), floor(RYmouse/ores:getHeight()) * ores:getHeight()
		end
	
		for i, obj in ipairs(map) do
			if obj.rw then
				obj.w = max(obj.sp:getWidth(), cx-obj.x)
				ores = obj
			elseif obj.rh then
				obj.h = max(obj.sp:getHeight(), cy-obj.y)
				ores = obj
			else
				ores = nil
			end
		end
	end
end

function mgeditor:mousepressed(x, y, button)
	RXmouse, RYmouse = RXmouse + camx, RYmouse + camy
	
	if button == 1 and lk.isDown("lctrl", "x", "y") then
		newItem(item, cx, cy)
	end
	
	for i, obj in ipairs(map) do
		obj.rh = mouseOver(obj.x+obj.w/2-3, obj.y+obj.h-5, 5, 5)
		obj.rw = mouseOver(obj.x+obj.w-5, obj.y+obj.h/2-3, 5, 5)
		if obj.hover and button == 2 then
			table.remove(map, lume.find(map, obj))
		end
	end
end

function mgeditor:mousereleased(x, y)
	for i, obj in ipairs(map) do
		obj.rw, obj.rh = false, false
	end
end

function mgeditor:wheelmoved(x, y)
	if type(item) == "number" and lk.isDown("lctrl") then
		item = (item % 15) + y
		item = item <= 0 and 15 or item
	end

end

function mgeditor:mousemoved(x, y, dx, dy)
	if lm.isDown(3) then
		camx = max(camx-dx, 0)
		camy = max(camy-dy, 0)
	end
end


function mgeditor:keypressed(k)
	if k == "p" then
		local l = lume.deserialize(lfs.read("mgmap"))
		for x, _ in pairs(l) do
			for y, o in pairs(_) do
				newItem(o, x, y)
			end
		end
	end
	if k == "-" then
		zoom = max(zoom - .25, .25)
	end
	if k == "+" then
		zoom = min(zoom + .25, 2)
	end

	if k == "s" then
		local save = {}
		for i, obj in ipairs(map) do
			save[i] = {
				x = obj.x,
				y = obj.y,
				w = obj.w,
				h = obj.h,
				sp = obj.spn
			}
		end
		lfs.write("minigamemap", lume.serialize(save))
		dialog("saved", {"ok"})
	end
	if k == "l" then
		local save = lume.deserialize(lfs.read("minigamemap"))
		map = {}
		for i, obj in ipairs(save) do
			if obj then
				newItem(obj.sp, obj.x, obj.y)
				map[i].w = obj.w
				map[i].h = obj.h
			end
		end
		dialog("loaded", {"ok"})
	end
end

return mgeditor
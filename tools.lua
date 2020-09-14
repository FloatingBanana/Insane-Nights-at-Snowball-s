function boolto(bool, rt, rf)
	local rt = rt or 1
	local rf = rf or 0
	return bool and rt or rf
end

--Mouse over check
function mouseOver(x2,y2,w2,h2)
	local mx, my = RXmouse, RYmouse
	return  mx < x2+w2 and
			x2 < mx    and
			my < y2+h2 and
			y2 < my    and
			fdalpha <= 0 and
			#dialogList == 0 and
			not debugmenu.focus
end

--Clamp number
function clamp(n, low, high)
	return min(max(n, low), high)
end

function ease(value, target, speed)
    return value - (value - target) * speed * dt
end

--Change and cache font
fonts = {}
currFont = "default13"
function setFont(n, s)
	local name, size = n, s
	if not s then
		name, size = "default", n or 13
	end
	local fname = name..size

	if not fonts[fname] then
		if name == "default" then
			fonts[fname] = lg.newFont(size)
		else
			fonts[fname] = lg.newFont("fonts/"..name..".ttf", size)
		end
	end

	lg.setFont(fonts[fname])
	currFont = fname
end

function fontWidth(s)
	return fonts[currFont]:getWidth(s)
end

local __fontHeight = lume.memoize(function(s, limit, font)
	local _, wrap = fonts[font]:getWrap(s, limit)
	return #wrap * fonts[font]:getHeight()
end)

function fontHeight(s, limit)
	return __fontHeight(s, limit, currFont)
end

function deepcopy(obj)
    if type(obj) ~= 'table' then return obj end
	
	local res = {}
    for k, v in pairs(obj) do res[deepcopy(k)] = deepcopy(v) end
    return res
end



currMusic = ""
function changeMusic(music, volume)
	if music ~= currMusic or not res.musics[music]:isPlaying() then
		if currMusic ~= "" then
			res.musics[currMusic]:stop()
		end
		currMusic = music
		res.musics[music]:play()
	end
end

function toLast(t, value)
	t[#t+1] = value
end


--Table reciclation
table_pool = {}
function emptyTable()
	local t = table_pool[1]

	if not t then
		return {}
	else
		table.remove(table_pool, 1)
		return t
	end
end

function recicleTable(t)
	if t then
		for i in pairs(t) do
			t[i] = nil
		end

		toLast(table_pool, t)
	end
end
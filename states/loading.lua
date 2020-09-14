local loading = {}

local pointer = 270
local count, percent = 0,0,0
local P = nil

local curr_lowgraphics = 1

local function resizeImage(image, base)
	local iw, ih = image:getDimensions()
	local div = lowgraphics + (base or 0)
	local resized = lg.newCanvas(iw/div, ih/div)

	lg.setCanvas(resized)
	lg.clear()
	lg.origin()
	lg.draw(image,0,0,0,1/div)
	lg.setCanvas()
	image:release()

	return resized
end

local finfo = {
	places = {},
	names = {},
	low = {}
}

ffunc = function(id, l)
	local place = finfo.places[id]
	local name = finfo.names[id]
	local low = finfo.low[id]

	if low then
		place[name] = resizeImage(l, low)
	else
		place[name] = l
	end

	finfo.places[id] = nil
	finfo.names[id] = nil
	finfo.low[id] = nil
end

local function loadFolder(path, low, baselow)
	local place = emptyTable()
	local base = lfs.getDirectoryItems(path)

	for i, file in ipairs(base) do
		local filepath = path.."/"..file

		if lfs.getInfo(filepath).type == "file" then
			local name = file:sub(1, -5)
			name = tonumber(name) or name

			P[filepath] = lily.newImage(filepath):onComplete(ffunc):setUserData(filepath)

			finfo.places[filepath] = place
			finfo.names[filepath] = name
			finfo.low[filepath] = low and (baselow or 0)
		end
	end

	return place
end

local function loadSourceFolder(path, stream)
	local place = emptyTable()
	local base = lfs.getDirectoryItems(path)

	for i, file in ipairs(base) do
		local filepath = path.."/"..file

		if lfs.getInfo(filepath).type == "file" then
			local name = file:sub(1, -5)
			name = tonumber(name) or name

			P[filepath] = lily.newSource(filepath, boolto(stream, "stream", "static")):onComplete(ffunc):setUserData(filepath)

			finfo.places[filepath] = place
			finfo.names[filepath] = name
		end
	end
	return place
end

local function loadSingle(path, func, place, key, ...)
	P[path] = lily[func](path, ...):onComplete(ffunc)
	:setUserData(path)

	finfo.places[path] = place
	finfo.names[path] = key

	return P[path]
end

function loading:enter(arg)
	P = emptyTable()
	count, percent = 0,0,0
	pointer = 270
	loadc = 0
	fade(false, .5)
	

	if night ~= 9 then
		-- SECTION Night 1-8

		if resourcecleared then

			-- ANCHOR Animations
			res.cam = loadFolder("assets/office/cam", true)
			res.cam_details = loadFolder("assets/office/cam_details", true)
			res.door_left = loadFolder("assets/office/doors/left", true)
			res.door_right = loadFolder("assets/office/doors/right", true)
			res.duct = loadFolder("assets/office/doors/duct", true)
			res.tablet = loadFolder("assets/office/tablet", true)
			res.turnback = loadFolder("assets/office/turnback", true)

			-- ANCHOR Others
			res.miniclowns = loadFolder("assets/office/miniclowns", true)
			res.room = loadFolder("assets/office/room", true)
			res.misc = loadFolder("assets/office/misc")

			-- ANCHOR Movements
			res.moves = {
				snowball = loadFolder("assets/office/moves/snowball", true),
				bunny = loadFolder("assets/office/moves/bunny", true),
				larry = loadFolder("assets/office/moves/larry", true),
				konny =  loadFolder("assets/office/moves/konny", true),
				shattered = loadFolder("assets/office/moves/shattered", true),
				beavy = loadFolder("assets/office/moves/beavy", true),
				endo = loadFolder("assets/office/moves/endo", true),
			}

			-- ANCHOR Jumpscares
			if dbg.load_jumpscares then
				res.jumpscares = {
					snowball = loadFolder("assets/office/jumpscares/snowball", true, 1),
					bunny = loadFolder("assets/office/jumpscares/bunny", true, 1),
					larry = loadFolder("assets/office/jumpscares/larry", true, 1),
					konny = loadFolder("assets/office/jumpscares/konny", true, 1),
					shattered = loadFolder("assets/office/jumpscares/shattered", true, 1),
					beavy = loadFolder("assets/office/jumpscares/beavy", true, 1),
					powerdown = loadFolder("assets/office/jumpscares/powerdown", true, 1),
				}
			end

			-- ANCHOR Plushies
			res.misc.plushies = lg.newCanvas(1000/lowgraphics, 675/lowgraphics)
			for i = 1, 8 do
				if savedata.cnchallenge[i] then
					P["plush"..i] = lily.newImage("assets/office/plushies/"..i..".png"):onComplete(function(_, l)
						lg.setCanvas(res.misc.plushies)
						lg.origin()
						lg.draw(resizeImage(l), 0, 0, 0, lowgraphics)
						lg.setCanvas()
					end)
				end
			end

			-- ANCHOR Miniclowns
			res.miniclowns = emptyTable()
			res.miniclowns.data = emptyTable()
			for i=1, 5 do
				P["clown"..i] = lily.newImageData("assets/office/miniclowns/"..i..".png"):onComplete(function(_, l)
					res.miniclowns[i] = resizeImage(lg.newImage(l))
					res.miniclowns.data[i] = l
				end)
			end

			-- ANCHOR Sounds
			res.sounds = loadSourceFolder("sounds/game/sounds")
			res.musics = loadSourceFolder("sounds/game/musics", true)
		end

		-- ANCHOR Drawings
		if night >= 1 and night <= 4 and not savedata.drawings[night] then
			P.drawing = lily.newImageData("assets/office/drawings/"..night..".png"):onComplete(function(_, l)
				res.misc.drawing = resizeImage(lg.newImage(l))
				res.misc.drawing_data = l
			end)
		end

		res.voices = nil
		-- SECTION Voices
		if dbg.load_voices then
			
			-- ANCHOR Miniclowns
			res.voices = {
				miniclowns = loadSourceFolder("sounds/game/voices/"..glang.code.."/miniclowns")
			}

			-- ANCHOR Endo
			res.voices.endo = loadSourceFolder("sounds/game/voices/"..glang.code.."/endo")

			-- ANCHOR Phone girl
			local path = string.format("sounds/game/voices/%s/phone_girl/%d.ogg", glang.code, night)
			if lfs.getInfo(path) then
				loadSingle(path, "newSource", res.voices, "phone", "stream")
			end
			
			-- ANCHOR Game over
			local g_o = gamestates.gameover.chars
			local vcount = {
				snowball = 5, 
				bunny = 6,
				beavy = 4,
				larry = 6,
				konny = 6,
				shattered = 6
			}

			for char, count in pairs(vcount) do
				local exclude = savedata.jumpscared[char]
				local available = emptyTable()

				for i=1, count do
					if not exclude[i] then
						toLast(available, i)
					end
				end

				if #available > 0 then
					g_o[char] = lume.randomchoice(available)
				else
					g_o[char] = random(1, count)
				end

				recicleTable(available)
			end
			
			for name, line in pairs(g_o) do
				local path = string.format("sounds/game/voices/%s/%s/%d.ogg", glang.code, name, line)
				
				if lfs.getInfo(path) then
					loadSingle(path, "newSource", res.voices, name, "static")
				end
			end
		end
		-- !SECTION
		-- !SECTION 
	else
		-- SECTION Secret night
		clearResources()

		-- ANCHOR Animations
		res.shock = loadFolder("assets/secret night/shock", true)
		res.tablet = loadFolder("assets/secret night/tablet", true)
		res.door_left = loadFolder("assets/secret night/doors/left", true)
		res.door_right = loadFolder("assets/secret night/doors/right", true)
		res.leaksm = loadFolder("assets/secret night/leaksmonitor", true)
		
		if dbg.load_jumpscares then
			res.jumpscare = loadFolder("assets/secret night/jumpscare", true)
		end
		

		-- ANCHOR Others
		res.cam = loadFolder("assets/secret night/cams", true)
		res.move = loadFolder("assets/secret night/move", true)
		res.room = loadFolder("assets/secret night/room", true)
		res.misc = loadFolder("assets/secret night/misc")
		

		-- ANCHOR Sounds
		res.sounds = loadSourceFolder("sounds/game/sounds")
		res.musics = loadSourceFolder("sounds/game/musics", true)
		
		-- !SECTION
	end

	for i, c in pairs(P) do
		count = count + 1
	end

	timer.every(2, function()
		collectgarbage()
	end)
end

function loading:draw()
	lg.setLineWidth(2)
	lg.arc("fill", wWidth-24, wHeight-24, 15, pi*1.5, pi*1.5 + percent * pi*2 % (pi*2), 100)
	lg.circle("line", wWidth-24, wHeight-24, 15, 100)
	
	if (Ftimer * 3) % (pi*2) < percent * pi*2 then
		lg.setColor(0,0,0)
	end

	lg.line(wWidth-24, wHeight-24, wWidth-24 + cos(pi*1.5 + Ftimer * 3) * 15, wHeight-24 + sin(pi*1.5 + Ftimer * 3) * 15)
	lg.setColor(1,1,1)
end

function loading:update()
	if percent >= 1 then
		if night ~= 9 then
			fade(true, .5, "office")
		else
			fade(true, .5, "snight")
		end
		resourcecleared = false
		curr_lowgraphics = lowgraphics
	end

	local loaded = 0
	for i, c in pairs(P) do
		loaded = loaded + boolto(c:isComplete())
	end

	if count == 0 then
		percent = 1
	else
		percent = loaded / count
	end
end

function loading:exit()
	P = recicleTable(P)
	collectgarbage()
	collectgarbage()
end

return loading
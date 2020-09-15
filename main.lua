wWidth, wHeight = 1000, 675
rWidth, rHeight = love.graphics.getDimensions()
currGamestate = "menu"
scalerW, scalerH, centered = 0,0,0
Ftimer = 0
OS = love.system.getOS()
isMobile = OS == "Android"
inasversion = "1.5"

lg = love.graphics
la = love.audio
lm = love.mouse
lk = love.keyboard
lfs = love.filesystem


-- ANCHOR Libs
utf8 = require "utf8"
lily = require "libs.lily.lily"
timer = require "libs.hump.timer"
class = require "libs.hump.class"
lume = require "libs.lume.lume"
gamejolt = require "libs.gamejolt"
chain = require "libs.grove.chainshaders"
animation = require "libs.grove.animation"
moonshine = require "libs.moonshine"
kuey = require "libs.kuey"
local fpsgraph = require "libs.fpsgraph.FPSGraph"
local resolution = require "libs.grove.resolution"
lume.extend(_G, math)

-- ANCHOR Shaders
perspective = lg.newShader("shaders/perspective.glsl")
chromaticAberration = lg.newShader("shaders/chromatic_aberration.glsl")

perspective:send("depth", 3.5)

--Moonshine effects
blur = moonshine(moonshine.effects.gaussianblur)
blur.gaussianblur.sigma = 5

--Debug graphs
local graphs = {
	fpsgraph.createGraph(0, 0, 50, 30, 0.5),
	fpsgraph.createGraph(0, 35, 50, 30, 0.5)
}
-----------------
--Resource tables
-----------------

res = {}

menuMusic = la.newSource("sounds/musics/menu.ogg", "stream")
menuMusic:setLooping(true)
menuMusic:setVolume(.65)

-- ANCHOR Languages
langNumber = 1
languages = {}

local mt = {__index = function(self, k)
	self[k] = {}

	return self[k]
end}

for i, file in pairs(lfs.getDirectoryItems("lang")) do
	lang = setmetatable({}, mt)

	require("lang."..string.sub(file, 1, -5))

	languages[i] = lume.clone(lang)
end

glang = languages[1]
lang = glang.menu

-- ANCHOR Extra files
require "tools"
require "devmenu"
require "dialf"
require "subtitles"
require "love_run"
trophies = require "achievements"
imgui = require "imgui"

-- ANCHOR Gamestate files
gamestates = {}
for _, file in ipairs(lfs.getDirectoryItems("states")) do
	local name = file:sub(1, -5)

	gamestates[name] = require("states."..name)
end

gamestates.cp = require "controlpanel"

-----------------
--ANCHOR Settings
-----------------

unlocks = {
	beatgame = true,
	sixnight = true,
	insnight = true
}

resConf = {
	replace = {},
	width = wWidth,
	height = wHeight,
	centered = true,
	aspectRatio = false,
	clip = true,
	clampMouse = true
}

subtitles = true
widescreen = false
showdebugmenu = false

fddur = 0 --Fade duration
fdalpha = 0 --Fade alpha


if OS == "Windows" then
	rpc = require "libs.discordRPC.discordRPC"
end

-- ANCHOR Discord RPC
local presence = {
	state = "In game",
	details = "Night 1",
	largeImageKey = "icon",
	largeImageText = "INaS"
}

local function updatePresence()
	if not rpc or not dbg.discord_rpc then
		return
	end

	if currGamestate == "office" or currGamestate == "snight" then
		presence.details = "In game"

		if night <= 6 then
			presence.state = languages[1].office.night.." "..night
		end
		if night == 7 then
			presence.state = languages[1].menu["op1_4"]
		end
		if night == 8 then
			presence.state = languages[1].customnight["c"..(currChallenge or 0)]
		end
		if night == 9 then
			presence.state = languages[1].menu.secretnight
		end
	else
		presence.details = "Idle"
		presence.state = nil
	end

	rpc.updatePresence(presence)
end

-- TODO Substituir pelo hump.gamestate
gsStack = {""}

--Load a gamestate
function loadgamestate(stt, arg)
	Ftimer = 0
	fdin = false
	fddur = 0
	fdalpha = 0
	
	--For better randomness
	randomseed(os.time())

	--Reset subtitles
	subtitle.clear()
	subtitle.pause = false
	subtitle.opacity = 0

	if currGamestate and gamestates[currGamestate].exit then
		--Cancel exit
		if gamestates[currGamestate]:exit() then
			return
		end
	end
	
	timer.clear()
	collectgarbage()

	currGamestate = stt
	gsStack[#gsStack] = stt
	
	if glang[currGamestate] then
		lang = glang[currGamestate]
	end

	if gamestates[stt].enter then
		gamestates[stt]:enter(arg)
	end

	timer.every(5, updatePresence)

	block_dt = true
end

--Push a gamestate to the top of stack
function pushgamestate(stt, arg)
	Ftimer = 0
	fdin = false
	fddur = 0
	fdalpha = 0
	
	--For better randomness
	randomseed(os.time())

	--Reset subtitles
	subtitle.clear()
	subtitle.pause = false
	subtitle.opacity = 0
	
	timer.clear()
	collectgarbage()

	currGamestate = stt
	toLast(gsStack, stt)
	
	if glang[currGamestate] then
		lang = glang[currGamestate]
	end
	
	if gamestates[stt].enter then
		gamestates[stt]:enter(arg)
	end

	timer.every(5, updatePresence)

	block_dt = true
end

--Pop current gamestate from stack
function popgamestate(arg)
	Ftimer = 0
	fdin = false
	fddur = 0
	fdalpha = 0
	
	--For better randomness
	randomseed(os.time())
	
	--Reset subtitles
	subtitle.clear()
	subtitle.pause = false
	subtitle.opacity = 0
	
	if gamestates[currGamestate].exit then
		--Cancel exit
		if gamestates[currGamestate]:exit() then
			return
		end
	end
	
	timer.clear()
	collectgarbage()
	
	assert(#gsStack > 1, "No more states to pop")
	
	table.remove(gsStack, #gsStack)
	currGamestate = gsStack[#gsStack]
	
	if glang[currGamestate] then
		lang = glang[currGamestate]
	end

	if gamestates[currGamestate].resume then
		gamestates[currGamestate]:resume(arg)
	end

	timer.every(5, updatePresence)

	block_dt = true
end

function fade(out, dur, stt, arg)
	if fdalpha <= 0 then
		fdin = out
		fddur = dur
		fdalpha = 1

		if out then
			timer.after(dur, function()
				if stt then
					loadgamestate(stt, arg)
				else
					popgamestate(arg)
				end
			end)
		end
	end
end

------------------------
-- ANCHOR LÖVE Callbacks
------------------------
function love.load(args)
	-- ANCHOR Load settings
	loadgame()
	
	night = savedata.level
	unlocks = savedata.unlocks
	langNumber = savedata.lang
	subtitles =  savedata.sub
	lowgraphics = savedata.lowgpcs
	resConf.aspectRatio = savedata.wide
	trophies:loadAchieved()

	glang = languages[langNumber]
	
	-- ANCHOR Gamejolt stuff (please don't steal)
	local keys = require("apikeys")
	gamejolt.init(keys.gj_id, keys.gj_key, args)

	--Discord Rich Presence
	if rpc then
		rpc.initialize(keys.rpc_id, true)
	end

	if not gamejolt.isLoggedIn and savedata.username then
		pcall(gamejolt.authUser, savedata.username, savedata.token)
	end
	trophies:achieve()

	resolution.init(resConf)

	-- ANCHOR Initial state
	loadgamestate("systemcheck")

	debugmenu.init(args)
end

function love.draw()
	gamestates[currGamestate]:draw()
	lg.setColor(1, 1, 1, 1)
	subtitle:draw()
	
	if fdalpha > 0 then
		if fdin then
			lg.setColor(0, 0, 0, 1 - fdalpha)
		else
			lg.setColor(0, 0, 0, fdalpha)
		end

		lg.rectangle("fill", 0, 0, wWidth, wHeight)
		lg.setColor(1, 1, 1, 1)
	end

	dialog.draw()
	trophies:draw()

	-- ANCHOR Draw debug menu
	if showdebugmenu then
		if debugmenu.focus then
			lg.setColor(0, 0, 0, 0.2)
			lg.rectangle("fill", 0, 0, 1000, 675)
			lg.setColor(1, 1, 1, 1)
		end

		lg.push()
		lg.origin()
		lg.setLineWidth(1)

		debugmenu.draw()

		lg.pop()

		lg.setLineWidth(1)
		lg.setColor(1, 1, 1, 1)
		setFont()

		fpsgraph.drawGraphs(graphs)
		
		local stats = "Graphic stats:"
		local sinfo = lg.getStats()
		sinfo.texturememory = lume.round(sinfo.texturememory / 1024 / 1024, 0.01).." MB"
		
		for k, v in pairs(sinfo) do
			stats = stats.."\n"..k..": "..v
		end
		
		setFont(14)
		lg.print(string.format("Debug:\nState: %s\nState stack: %d\nTime: %02d:%02d\nOS: %s\nEmpty tables pool: %s\n\n%s\n\n%s", currGamestate, #gsStack, Ftimer/60, Ftimer % 60, OS, #table_pool, stats, imgui._info), 0, 70)
		lg.print(string.format("mouse X: %d\nmouse Y: %d", RXmouse, RYmouse), 0, 600)
	end
end

block_dt = false
function love.update(delta)
	if showdebugmenu then
		debugmenu.update(dt)
	end

	if dbg.block_update then
		return
	end

	if dbg.frameskip then
		if dbg.prevent_big_delta then
			dt = min(delta, 1)
		else
			dt = delta
		end
	else
		dt = 1/60
	end

	if block_dt then
		dt = 0
		block_dt = false
	end

	Ftimer = Ftimer + dt

	--Fade
	if fdalpha > 0 then
		fdalpha = fdalpha - (1/fddur) * dt
	end

	RXmouse, RYmouse = lm.getX(), lm.getY()
	
	-- ANCHOR Updates
	if gamestates[currGamestate].update then
		gamestates[currGamestate]:update()
	end

	timer.update(dt)
	subtitle:update()
	trophies:update()
	dialog.update()

	fpsgraph.updateFPS(graphs[1], delta)
	fpsgraph.updateMem(graphs[2], delta)

	if rpc then
		rpc.runCallbacks()
	end
end

----------------------------
-- ANCHOR Some helpful tools
----------------------------

--Clear all loaded resources
resourcecleared = true
function clearResources()
	for i, t in pairs(res) do
		if type(t) == "table" then
			recicleTable(t)
		end
	end

	lume.clear(res)
	
	resourcecleared = true
	collectgarbage()
	collectgarbage()
end

function simulplay(data, x, vol, pitch)
	local sound = la.newSource(data, "static")
	
	if x and x ~= 0 then
		sound:setRelative(true)
		sound:setPosition(x,0,0)
	end

	sound:setVolume(vol or .3)
	sound:setPitch(pitch or 1)
	sound:play()
end

function string.explode(str, div, plain)
	assert(type(str) == "string" and type(div) == "string", "invalid arguments")
	
	local o = emptyTable()
	while true do
		local pos1,pos2 = str:find(div, 1, plain)

		if not pos1 then
			o[#o+1] = str
			break
		end

		o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
	end

	return o
end

-------------------
-- ANCHOR Save data
-------------------
realsavedata = {}
savedata = setmetatable({}, {
	__newindex = function(_, k, v)
		realsavedata[k] = v

		savegame({[k] = v})
	end,

	__index = function(_, k)
		return realsavedata[k]
	end
})

local emptysave = {
	level = 0,
	lang = boolto(os.setlocale() == "pt_BR", 2, 1),
	sub = true,
	lowgpcs = 1,
	wide = false,
	fullscreen = true,
	startip = false,
	trophies = {},
	cnchallenge = {},
	drawings = {},
	jumpscared = {
		snowball = {},
		bunny = {},
		konny = {},
		beavy = {},
		larry = {},
		shattered = {},
		powerdown = {},	
		sn = {}
	},
	unlocks = {
		beatgame = false,
		sixnight = false,
		insnight = false
	}
}

function log_err(message, text)
	local vlbutton = {glang.view, function()
		os.execute("explorer "..lfs.getSaveDirectory():gsub("/", "\\").."\\error.txt")
	end}
	
	dialog(message, {"OK"}, {glang.quit, love.event.quit}, boolto(OS == "Windows", nil, vlbutton))
	
	local date = os.date("\r\n\r\n%x %X - ")
	local file = ""
	
	if lfs.getInfo("error.txt") then
		local loaded = lfs.read("error.txt")
		
		if loaded then
			file = loaded
		else
			lfs.remove("error.txt")
		end
	end
	local output = file..date..message..": "..text
	
	lfs.write("error.txt", output)
end

--function love.errorhandler(msg)
--	log_err("error: ", msg)
--end

--Save game
function savegame(t)
	t = lume.merge(loadgame(), t)

	local ser = lume.serialize(t)
	local data = kuey.encode(ser, "inaskey")
	local ok, err = lfs.write("inas.sav", data)
	
	if ok then
		realsavedata = t
	else
		log_err(glang.saveErr, err)
	end
end

--Load game
function loadgame()
	if lfs.getInfo("inas.sav") then
		local file, err = lfs.read("inas.sav")
		
		if file then
			local ok, loaded = pcall(kuey.decode, file, "inaskey")
			
			if ok then
				ok, loaded = pcall(lume.deserialize, loaded)
			end
			
			if ok then
				realsavedata = loaded
			else
				log_err(glang.loadErr, loaded)
				lfs.write("inas.sav.bak", file)
				lfs.remove("inas.sav")
				
				realsavedata = deepcopy(emptysave)
			end
		else
			if lfs.getInfo("inas.sav") then
				log_err(glang.loadErr, err)
			end
			
			realsavedata = deepcopy(emptysave)
		end
	else
		realsavedata = deepcopy(emptysave)
	end

	return realsavedata
end

--Empty function
function fnull(...)
	return ...
end

function love.keypressed(k, unicode)
	if k == "f3" then
		showdebugmenu = not showdebugmenu
		debugmenu.focus = false
		
		if not showdebugmenu then
			lm.setCursor()
		end
	end

	if showdebugmenu and debugmenu.focus then
		return
	end

	if gamestates[currGamestate].keypressed and (#dialogList == 0 or currGamestate == "menu") then
		gamestates[currGamestate]:keypressed(k)
	end

	if k == "escape" then
		dialog(glang.exit, {glang.mmenu, function()loadgamestate("menu")end},{glang.desktop, love.event.quit}, {glang.cancel})
	end

	if k == "f2" then	
		dialog(glang.restart, {glang.yes, function()love.event.quit("restart")end}, {glang.no})
	end
end

function love.mousepressed(x, y, button)
	RXmouse, RYmouse = x, y

	if showdebugmenu and debugmenu.focus then
		return
	end

	if gamestates[currGamestate].mousepressed and #dialogList == 0 then
		gamestates[currGamestate]:mousepressed(x, y, button)
	end

	if #dialogList > 0 and not dclosing then
		dialog.mousepressed()
	end
end

function love.mousereleased(x, y, button)
	RXmouse, RYmouse = x, y

	if showdebugmenu and debugmenu.focus then
		return
	end

	if gamestates[currGamestate].mousereleased then
		gamestates[currGamestate]:mousereleased(x, y, button)
	end
end

function love.textinput(text)
	if gamestates[currGamestate].textinput then
		gamestates[currGamestate]:textinput(text)
	end
end
function love.wheelmoved(x, y)
	if gamestates[currGamestate].wheelmoved then
		gamestates[currGamestate]:wheelmoved(x, y)
	end
end

function love.mousemoved(x, y, dx, dy)
	if gamestates[currGamestate].mousemoved then
		gamestates[currGamestate]:mousemoved(x, y, dx, dy)
	end
end

function love.lowmemory()
	res.jumpscares = nil
	dbg.load_jumpscares = false
	collectgarbage()
	collectgarbage()
end

function love.quit()
	lily.quit()

	if rpc then
		rpc.shutdown()
	end
end
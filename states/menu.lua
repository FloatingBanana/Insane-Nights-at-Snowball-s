local menu = {}

local mndraw = "main"
local opalpha = 0
local snowanim = 0
local staticInt = .3
local staticAlpha = 0
local settings = false
local smenu = {}
local menuOptions = {}
local titlecanvas = lg.newImage("assets/icons/title.png")
local gjcredent = {"Gamejolt login\n\n",{1,1,1},"Username: ", {.6,.6,.6}, "ovo", {1,1,1}, "\nToken: ", {.6,.6,.6}, "batata"}
local username, token = "", ""
local logging, userEntry = false, true
local starJoke = 1

for i = 1, 4 do
	smenu[i-1] = lg.newImage("assets/menu/snowball/"..i..".png")
end
static = lg.newImage("assets/menu/static.jpg")

local function deldata()
	if lfs.getInfo("inas.sav") then
		lfs.remove("inas.sav")
	end
	
	loadgame()
	savedata.wide = resConf.aspectRatio
	savedata.lang = langNumber
	savedata.lowgpcs = lowgraphics
	savedata.sub = subtitles
	gamejolt.username = nil
	gamejolt.userToken = nil
	gamejolt.isLoggedIn = false
	
	unlocks = savedata.unlocks
	night = 0
	username = ""
	token = ""
end

local function snowglitch(wait)
	wait(random(1,3))
	local times = random(1,3)
	for i = 1, times do
		snowanim = random(1,3)
		if snowanim == 3 and random(1,3) ~= 1 then
			snowanim = random(1,2)
		end
		wait(0.1)
	end

	snowanim = 0
	timer.script(snowglitch)
end

function menu:enter()
	loadgame()
	setFont("OCRAEXT", 45)

	night = savedata.level
	unlocks = savedata.unlocks

	snowanim = 0
	opalpha = 0
	timer.script(snowglitch)
	
	if not menuMusic:isPlaying() then
		menuMusic:play()
	end
	clearResources()

	if savedata.username then
		username = savedata.username
		token = savedata.token
	end
	
	if not savedata.startip and unlocks.beatgame then
		dialog.queque(lang.startip, {"OK"})
		savedata.startip = true
	end

	if starJoke < 5 then
		starJoke = 1
	end
end

function menu:resume()
	snowanim = 0
	timer.script(snowglitch)
end

function menu:draw()
	lg.setColor(1,1,1,.7)
	lg.draw(smenu[snowanim])
	
	if dbg.show_static then
		local anim = Ftimer * 30

		lg.setColor(0.6, 0.6, 1, sin(staticAlpha) * staticInt + 0.3)
		lg.draw(static, 500, 337, 0, boolto(floor(anim % 2) == 1, -1, 1), boolto(anim % 4 < 2, 1, -1), 500, 337)
	end
	
	lg.setColor(1,1,1,1)
	
	lg.setBlendMode("screen")
	lg.draw(titlecanvas, 15)
	setFont("OCRAEXT", 45)

	lg.setBlendMode("alpha")
	lg.setColor(1,1,1,abs(opalpha))
	imgui.draw()

	local obj = nil
	for _, o in ipairs(imgui.list) do
		if o.hovered then
			obj = o
		end
		if o.id == "op1_2" and night > 0 then
			setFont("OCRAEXT", 20)
			lg.setColor(1,1,1,-opalpha)
			lg.print(night, o.x + o.w - o.scroll * 30 + 35, o.y + o.h - 30)
		end
	end
	
	if obj and obj.id:find("star") then
		setFont(15)
		local tWidth, txt = fonts[currFont]:getWrap(lang[obj.id], 300)
		local tHeight = fonts[currFont]:getHeight()
		
		lg.setColor(.1,.1,.1,1)
		lg.rectangle("fill", 880 - tWidth, obj.y - (#txt * tHeight - 93)/2, 10 + tWidth, #txt * tHeight + 10, 5)
		lg.setColor(1,1,1,1)
		lg.printf(lang[obj.id], 885 - tWidth, 5 + obj.y - (#txt * tHeight - 93)/2, tWidth, "center")
	end

	if logging then
		setFont(13)
		lg.printf(lang.holdlshift, 0, 660, 1000, "center")
	end

	lg.setColor(1,1,1,opalpha)
	setFont("OCRAEXT", 15)
	lg.printf(lang.version..inasversion, 500, 657, 490, "right")
end

function menu:update()
	opalpha = clamp(opalpha + boolto(settings, 3, -3) * dt, -1, 1)
	
	staticAlpha = max(staticAlpha - 4 * dt, 0)
	if staticAlpha == 0 and random(1,50) == 1 then
		staticInt = lume.random(.1,.3)
		staticAlpha = pi
	end
	
	gjcredent[2][4] = boolto(userEntry, 1, .5)
	gjcredent[4][4] = boolto(userEntry, 1, .5)
	gjcredent[6][4] = boolto(userEntry, .5, 1)
	gjcredent[8][4] = boolto(userEntry, .5, 1)
	gjcredent[5] = username
	
	if lk.isDown("lshift") then
		gjcredent[9] = token
	else
		gjcredent[9] = string.rep("-", #token)
	end

	imgui.update()

	-- ANCHOR Menu options
	setFont("OCRAEXT", 45)
	local y = 325

	if opalpha < 0 then
		--New game
		if imgui.textbutton("op1_1", lang.op1_1, "left", 30, y) then
			if night > 0 then
				dialog(lang.resetprog, {glang.yes,
					function()
						fade(true, 2, "newgame")
					end
				}, {glang.no})
					
			else
				fade(true, 2, "newgame")
			end
		end
		y = y + 55

		--Continue
		if imgui.textbutton("op1_2", lang.op1_2, "left", 30, y) then
			night = clamp(night, 1, 5)

			loadgamestate("whichnight")
		end
		y = y + 55

		--6th night
		if unlocks.beatgame then
			if imgui.textbutton("op1_3", lang.op1_3, "left", 30, y) then
				night = 6

				loadgamestate("whichnight") 
			end

			y = y + 55
		end

		--Insane night
		if unlocks.sixnight then
			if imgui.textbutton("op1_4", lang.op1_4, "left", 30, y) then
				night = 7

				loadgamestate("whichnight")
			end

			y = y + 55
		end

		--Custom night
		if unlocks.insnight then
			if imgui.textbutton("op1_5", lang.op1_5, "left", 30, y) then
				loadgamestate("customnight")

				return
			end

			y = y + 55
		end

		--Settings
		if imgui.textbutton("op1_6", lang.op1_6, "left", 30, y) then
			settings = true
		end
	else
		--Language
		if imgui.textbutton("op2_1", lang.op2_1..glang.name, "left", 30, y) then
			langNumber = (langNumber % #languages) + 1
			
			glang = languages[langNumber]
			lang = glang.menu
			savedata.lang = langNumber
			
			opalpha = 0
		end

		y = y + 55

		--Subtitles
		if imgui.textbutton("op2_2", lang.op2_2..boolto(subtitles, lang.on, lang.off), "left", 30, y) then
			subtitles = not subtitles
			savedata.sub = subtitles
		end

		y = y + 55
		
		--Graphics
		if imgui.textbutton("op2_3", lang.op2_3..(lang["gpc"..lowgraphics] or "1/"..lowgraphics), "left", 30, y) then
			lowgraphics = (lowgraphics % 3) + 1

			savedata.lowgpcs = lowgraphics
		end

		y = y + 55
		
		--Resolution
		if imgui.textbutton("op2_4", lang.op2_4..boolto(resConf.aspectRatio, lang.aspect, lang.wide), "left", 30, y) then
			resConf.aspectRatio = not resConf.aspectRatio
			savedata.wide = resConf.aspectRatio
		end

		y = y + 55
		
		--Delete data
		if isMobile then
			if imgui.textbutton("op2_5", lang.op2_5, "left", 30, y) then
				dialog(lang.deldata, {glang.yes, deldata}, {glang.no})
			end

			y = y + 55
		end
		
		--Back
		if imgui.textbutton("op2_6", lang.op2_6, "left", 30, y) then
			settings = false
		end
	end

	-- ANCHOR Stars
	y = 5

	if opalpha < 0 then
		--5 nights completed
		if unlocks.beatgame then
			if imgui.button("star1", "star.png", 902, y) then
				pushgamestate("extras", "night")
			end

			y = y + 93
		end

		--6th night completed
		if unlocks.sixnight then
			if imgui.button("star2", "star.png", 902, y) then
				pushgamestate("extras", "minigame")
			end

			y = y + 93
		end

		--Insane night completed
		if unlocks.insnight then
			if imgui.button("star3", "star.png", 902, y) then
				pushgamestate("extras", "cutscene")
			end

			y = y + 93
		end

		--7/20 mode completed
		if savedata.cnchallenge and savedata.cnchallenge[8] then
			if imgui.button("star4", "star.png", 902, y) then
				night = 9
				loadgamestate("whichnight")
			end

			y = y + 93
		end

		--Secret night completed
		if savedata.snight then
			if imgui.button("star5", "star.png", 902, y) then
				if starJoke < 5 then
					dialog(lang["joke"..starJoke], {"Ok"})

					starJoke = starJoke + 1
				else
					trophies:achieve("Curious annoying")
					dialog(lang.joke5, {"Ok"})
				end
			end

			y = y + 93
		end

		--All drawings completed
		if savedata.drawings and savedata.drawings[1] and savedata.drawings[2] and savedata.drawings[3] and savedata.drawings[4] then
			if imgui.button("star6", "star.png", 902, y) then
				pushgamestate("extras", "drawings")
			end
		end

		-- ANCHOR Gamejolt icon (It's a mess, I know...)
		if imgui.button("gjbtn", "gjicon.png", 902, 577) then
			if gamejolt.isLoggedIn then
				local info = lang.userinfo:format(gamejolt.username, trophies:getAchievedCount(), #trophies.list)
				
				dialog(info, {lang.logout, function()
						gamejolt.isLoggedIn = false
						gamejolt.username = nil
						gamejolt.userToken = nil
						savedata.username = ""
						savedata.token = ""
					end}, {glang.cancel})
			else
				dialog(gjcredent, {"Login", function()
					local ok, success = pcall(gamejolt.authUser, username, token)

					dialog.queque(boolto(success and ok , lang.lsuccess, lang.lfailed), {"OK"})
					lk.setTextInput(not isMobile)
					
					logging = false
					block_dt = true
					
					if success and ok then
						savedata.username = username
						savedata.token = token

						trophies:achieve()
					end
				end},
				
				{glang.cancel, function()
					logging = false

					lk.setTextInput(not isMobile)
				end})

				lk.setTextInput(true,0,220,1000,200)
				
				userEntry = true
				logging = true
			end
		end
	end
end

function menu:keypressed(k)
	if k == "delete" then
		if delHandler then
			timer.cancel(delHandler)
			
			delHandler = nil
		end

		delHandler = timer.after(1, function()
			if lk.isDown("delete") then
				dialog(lang.deldata, {glang.yes, deldata}, {glang.no})
			end
		end)
	end
	
	-- ANCHOR Backspacing
	lk.setKeyRepeat(k == "backspace" and logging)
	
	if logging then
		if k == "backspace" then
			if userEntry then
				local offset = utf8.offset(username, -1)
				
				if offset then
					username = string.sub(username, 1, offset - 1)
				end
			else
				local offset = utf8.offset(token, -1)
				
				if offset then
					token = string.sub(token, 1, offset - 1)
				end
			end
		end
		if k == "return" or k == "up" or k == "down" or k == "tab" then
			userEntry = not userEntry
		end
	end
end

function menu:textinput(text)
	-- ANCHOR GJ credentials typing
	if logging then
		if userEntry then
			username = username..text
		else
			token = token..text
		end
	end
end

return menu
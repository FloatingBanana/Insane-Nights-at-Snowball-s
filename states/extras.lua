local extras = {}

local sel = 0
local tab = "cutscene"
local drawView = false
local drawId = 1

local tabs = {
	cutscene = {
		"cutscene1",
		"cutscene2",
		"cutscene3",
		"payment",
		"credits",

		func = function(name, sel)
			local state = gamestates[name]
			local oldexit = state.exit

			state.exit = function(self)
				if oldexit then
					oldexit(self)
				end
				state.exit = oldexit
				loadgamestate("menu")

				return true
			end

			popgamestate()
			loadgamestate(name)
		end
	},
	minigame = {
		"minigame",
		"minigame",
		"minigame",

		func = function(name, sel)
			local state = gamestates[name]
			local oldexit = state.exit

			state.exit = function(self)
				if oldexit then
					oldexit(self)
				end
				state.exit = oldexit
				loadgamestate("menu")

				return true
			end

			popgamestate()
			loadgamestate(name, sel)
		end
	},
	drawings = {
		"laughs",
		"Follow me",
		"Killer",
		"The truth",

		func = function(name, sel)
			drawId = sel
			drawView = true
		end
	},
	night = {
		"whichnight",
		"whichnight",
		"whichnight",
		"whichnight",
		"whichnight",

		func = function(name, sel)
			night = sel
			loadgamestate(name)
		end
	}
}
local icons = {
	cutscene = {},
	minigame = {},
	drawings = {},
	night = {}
}
for name, t in pairs(icons) do
	for i=1, #tabs[name] do
		t[i] = lg.newImage("assets/icons/extras/"..name..i..".png")
	end
end

local drawings = {}
for i=1, 4 do
	drawings[i] = lg.newImage("assets/icons/drawings/"..i..".jpg")
end

function extras:enter(arg)
	tab = arg
end

function extras:draw()
	gamestates.menu:draw()
	lg.setColor(.15,.15,.15)
	lg.rectangle("fill", 200, 112, 600, 450, 5)
	
	if mouseOver(200, 187, 600, 75 * #tabs[tab]) then
		lg.setColor(.3,.3,.3)
		lg.rectangle("fill", 200, 187 + 75 * (sel-1), 600, 75)
	end
	
	setFont("OCRAEXT", 25)
	for i=1, #tabs[tab] do
		lg.setColor(.3,.3,.3)
		lg.rectangle("line", 200, 187 + 75 * (i-1), 600, 75)
		lg.setColor(1,1,1)
		lg.print(lang[tab..i], 300, 187 + 75 * (i-1) + 22)
		
		if icons[tab] and icons[tab][i] then
			lg.draw(icons[tab][i], 215, 187 + 75 * (i-1) + 7)
		end
		
		lg.rectangle("line", 215, 187 + 75 * (i-1) + 7, 60, 60, 5)
	end
	
	lg.printf(lang["goto"..tab], 200, 134, 600, "center")
	lg.rectangle("line", 200, 112, 600, 450, 5)
	
	if drawView then
		lg.setColor(0,0,0,.5)
		lg.rectangle("fill", 0, 0, 1000, 675)
		lg.setColor(1,1,1,1)
		lg.draw(drawings[drawId], 300, 95)
	end
end

function extras:update()
	if not drawView then
		sel = floor((RYmouse - 187) / 75) + 1
	end
end

function extras:mousepressed(x, y)
	sel = floor((RYmouse - 187) / 75) + 1
	
	if not drawView then
		if mouseOver(200, 112, 600, 450) then
			if tabs[tab][sel] then
				--if tab == "drawings" then
				--	drawView = true
				--	drawId = sel
				--else
				--	if tab == "night" then
				--		night = sel
				--	end
				--	
				--	popgamestate()
				--	loadgamestate(tabs[tab][sel], sel)
				--	menuMusic:stop()
				--end
				tabs[tab].func(tabs[tab][sel], sel)
			end
		else
			popgamestate()
		end
	else
		drawView = false
	end
end

return extras
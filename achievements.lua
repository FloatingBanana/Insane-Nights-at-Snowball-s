local tph = {}

local tlang = nil
local wait = false
local trophyPopups = {}

-- ANCHOR Thread code
local threadUpdate = love.thread.newThread("gj_threadcode.lua")

-- ANCHOR Icons
local icons = {}
for i=1, 11 do
	local filename = string.format("assets/icons/trophies/%d.png", i)

	icons[i] = lg.newImage(filename)
end

-- ANCHOR List
tph.list = {
	{name = "The insanity begins",      id = 114149, get = false},
	{name = "We are just starting",     id = 114150, get = false},
	{name = "Things are getting worse", id = 114151, get = false},
	{name = "Dive into insanity",       id = 114152, get = false},
	{name = "Meeting all of them",      id = 114155, get = false},
	{name = "Weird chatting",           id = 114154, get = false},
	{name = "Challenge accepted",       id = 114255, get = false},
	{name = "The hidden nightmare",     id = 117626, get = false},
	{name = "Little artist",            id = 117543, get = false},
	{name = "Curious annoying",         id = 125677, get = false},
	{name = "INaS King",                id = 114153, get = false},
}

function tph:popup(trophy)
	toLast(trophyPopups, tpopup(trophy.name, lume.find(self.list, trophy)))
end

local function saveTrophies()
	local tlist = emptyTable()

	for i, trophy in ipairs(tph.list) do
		tlist[i] = trophy.get
	end

	savedata.trophies = tlist
end

function tph:achieve(name)
	for i, trophy in ipairs(self.list) do
		if not trophy.get and trophy.name == name then
			trophy.get = true
			
			self:popup(trophy)
			break
		end
	end
	saveTrophies()
	
	if not wait and gamejolt.isLoggedIn then
		if threadUpdate:isRunning() then
			wait = true
		else
			threadUpdate:start(self.list, gamejolt.username, gamejolt.userToken, gamejolt.gameID, gamejolt.gameKey)
		end
	end
	
	for i=1, 10 do
		if not self.list[i].get or self.list[10].get then
			return
		end
	end

	self:achieve("INaS King")
end

function tph:loadAchieved()
	for i, achieved in pairs(savedata.trophies) do
		if achieved then
			self.list[i].get = true
		end
	end
end

function tph:getAchievedCount()
	local count = 0
	
	for i, t in ipairs(self.list) do
		if t.get then
			count = count + 1
		end
	end

	return count
end

function tph:draw()
	for i, pop in ipairs(trophyPopups) do
		pop:draw()
	end

	lg.setColor(1,1,1,1)
end

function tph:update()
	tlang = glang.trophies
	
	for i, pop in ipairs(trophyPopups) do
		pop:update()
	end
	
	if gamejolt.isLoggedIn then
		local info = love.thread.getChannel("info"):pop()

		if info then
			for i, trophy in ipairs(self.list) do
				if not trophy.get and info[i] then
					trophy.get = true
					
					self:popup(trophy)
				end
			end
			saveTrophies()
			
			if wait then
				threadUpdate:start(self.list, gamejolt.username, gamejolt.userToken, gamejolt.gameID, gamejolt.gameKey)
				wait = false
			end
		end
	end
end

-- ANCHOR Popup object
tpopup = class {
	init = function(self, name, id)
		self.name = name
		self.id = id
		self.showdesc = false
		self.txtalpha = 1
		self.x = 1000
		self.y = 0
		self.width = 280
		self.count = tph:getAchievedCount() + 1
		
		setFont(15)
		
		local height = fontHeight(tlang["t"..id], 270)
		self.height = max(120, height + 40)
		
		local last = lume.last(trophyPopups)
		if last then
			self.y = last.y + last.height
		end
		
		timer.script(function(wait)
			timer.tween(.3, self, {x = 720}, "out-quad")
			wait(1.5)
			self.showdesc = true
			wait(3)
			timer.tween(.3, self, {x = 1000}, "out-quad")
			wait(.35)
			table.remove(trophyPopups, lume.find(trophyPopups, self))
		end)
	end,
	
	draw = function(self)
		lg.push()
		lg.translate(self.x, self.y)

		lg.setColor(.1,.1,.1,1)
		lg.rectangle("fill", 0, 0, self.width, self.height, 5)

		lg.setColor(.4,.4,.4,1)
		lg.rectangle("line", 0, 0, self.width, self.height, 5)
		
		lg.setColor(1,1,1,1)
		lg.draw(icons[self.id], 10, 35, 0, .7)
		lg.rectangle("line", 10, 35, 70, 70, 4)

		setFont(22)
		lg.setColor(1,1,1, self.txtalpha)
		lg.print(tlang.new, 5, 5)

		setFont(15)
		lg.printf(self.count.." out of "..#tph.list.." trophies", 85, 35, 180, "left")

		setFont(22)
		lg.setColor(1,1,1, -self.txtalpha)
		lg.print(self.name, 5, 5)

		setFont(15)
		lg.printf(tlang["t"..self.id], 85, 35, 180, "left")

		lg.pop()
	end,
	update = function(self)
		if self.showdesc then
			self.txtalpha = max(self.txtalpha - 3 * dt, -1)
		end
	end
}

return tph
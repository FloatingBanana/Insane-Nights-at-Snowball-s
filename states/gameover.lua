local gameover = {
	chars = {
		snowball = 1,
		bunny = 1,
		konny = 1,
		beavy = 1,
		larry = 1,
		shattered = 1,
		powerdown = 1,
		sn = 1
	}
}

--FIXME A música da noite continua

local char = ""
local voice = nil

local text = {
	{1,0,0,1},"G",
	{1,0,0,1},"A",
	{1,0,0,1},"M",
	{1,0,0,1},"E",
	{0,0,0,0}," ",
	{1,0,0,1},"O",
	{1,0,0,1},"V",
	{1,0,0,1},"E",
	{1,0,0,1},"R",
}

local function count(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

local letters = {}
local current = 1

local function changeColor()
	while lume.find(letters, current) do
		current = random(1, 9) * 2 - 1
	end

	local toValue = (text[current][4] + lume.random(0, 0.5)) % 1
	timer.tween(0.2, text[current], {1,0,0,0.1 + toValue})
	
	toLast(letters, current)

	if #letters > 5 then
		table.remove(letters, 1)
	end
	timer.after(.2, changeColor)
end

--Blur
local go = lg.newCanvas(360, 90)
lg.setCanvas(go)
lg.clear()
lg.setBlendMode("alpha", "premultiplied")

setFont("alienleague", 80)
blur(lg.print, "GAME OVER", 5, 5)

lg.setBlendMode("alpha", "alphamultiply")
lg.setCanvas()

function gameover:enter(c)
	c = c or "snowball"
	char = c

	la.stop()
	if dbg.load_jumpscares then
		res.sounds.jumps_reverb:play()
	end

	--Reset text transparency
	for i=1, 17, 2 do
		text[i][4] = 1
	end
	
	subtitle.size = 25
	subtitle.back = false

	voice = nil
	if res.voices then
		voice = res.voices[char]
	end

	timer.after(1.5,function()
		changeColor()
		local line = lang[char..self.chars[char]]

		if voice then
			voice:play()

			if line then
				subtitle(line, voice:getDuration())
			end
		end
	end)
	
	--Check trophies
	local jumps = savedata.jumpscared
	
	jumps[c][self.chars[c]] = true
	
	-- TROPHY Meeting all of them 
	local get = true
	for i, jump in pairs(jumps) do
		if count(jump) == 0 then
			get = false
			break
		end
	end

	if get then
		trophies:achieve("Meeting all of them")
	end

	-- TROPHY Weird chatting
	if count(jumps.snowball) == 5 and
	   count(jumps.bunny) == 6 and
	   count(jumps.larry) == 6 and
	   count(jumps.konny) == 6 and
	   count(jumps.shattered) == 6 and
	   count(jumps.beavy) == 4 then
	   	trophies:achieve("Weird chatting")
	end

	savedata.jumpscared = jumps
end

function gameover:draw()
	--Blur pulse
	lg.setColor(1,0,0,.3 + sin(Ftimer % pi) * .7)
	lg.draw(go, 320, 292)

	--Print "GAME OVER"
	lg.setColor(1,1,1,1)
	setFont("alienleague", 80)
	lg.printf(text, 0, 297, 1000, "center")
	
	--Red fade in
	lg.setColor(1, 0, 0, 1 - Ftimer)
	lg.rectangle("fill", 0, 0, wWidth, wHeight) 
	
	lg.setColor(.5,.5,.5,.5)
	setFont("alienleague", 20)
	if isMobile then
		lg.printf(lang.see_tips_mobile, 0, 50, 1000, "center")
	else
		lg.printf(lang.see_tips, 0, 50, 1000, "center")
	end
	
	lg.setColor(1,1,1,1)
end

function gameover:keypressed(k)
	if k == "t" then
		dialog(lang.names[char].."\n\n"..lang["tip_"..char], {"Ok"})
	end
end

function gameover:mousepressed(x, y)
	if isMobile and y < 85 then
		dialog(lang.names[char].."\n\n"..lang["tip_"..char], {"Ok"})
	else
		if Ftimer > 2 and not(voice and voice:isPlaying()) then
			if random(1, 50) == 1 then
				fade(true, 1.5, "darkfaces", "menu")
			else
				fade(true, 1.5, "menu")
			end
		end
	end
end

return gameover
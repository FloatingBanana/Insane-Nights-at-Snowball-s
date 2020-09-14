subtitle = setmetatable({
	text = {},
	size = 25,
	back = false,
	pause = false
},
{__call = function(self, text, time)
	if subtitles then
		toLast(self.text, {text, time})
	end
end})

local function seconds(str)
	local time = str:explode(":")
	return time[1] * 60 + time[2] + time[3] * 0.1
end

function subtitle.parse(sub)
	for i=2, #sub-1, 2 do
		local t1 = seconds(sub[i-1])
		local t2 = seconds(sub[i+1])
		subtitle(sub[i], t2 - t1)
	end
end

function subtitle.clear()
	lume.clear(subtitle.text)
end

function subtitle:draw()
	if #self.text == 0 or not subtitles then
		return
	end
	
	setFont(dbg.sub_font, self.size)

	local _, lines = fonts[currFont]:getWrap(self.text[1][1], 750)
	if self.back then
		for i=0, #lines-1 do
			local wtxt = fonts[currFont]:getWidth(lines[i+1])
			lg.setColor(.2,.2,.2,self.opacity)
			lg.rectangle("fill", (wWidth - wtxt)/2 - 2,(663 - self.size * #lines) + (self.size+4) * i, wtxt + 4, (self.size+4))
		end
	end
	
	lg.setColor(1,1,1,self.opacity)
	lg.printf(self.text[1][1], 125, 665 - self.size * #lines, 750, "center")
	lg.setColor(1,1,1,1)
end

function subtitle:update()
	if #self.text == 0 or not subtitles or self.pause then
		return
	end
	
	if self.text[1][2] > 0.4 then
		self.text[1][2] = self.text[1][2] - dt
		if self.opacity < 0.8 then
			self.opacity =self. opacity + 2 * dt
		end
	else
		if self.opacity > 0 then
			self.opacity = self.opacity - 2 * dt
		else
			table.remove(self.text, 1)
		end
	end
end

return sub
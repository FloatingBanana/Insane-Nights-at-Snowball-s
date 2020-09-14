local ql = {}

local P = nil
local res = nil
local count = 0
local loadc = 0

function ql:enter(arg)
	P = arg
	res = emptyTable()
	count = 0
	loadc = 0
	
	for i, item in pairs(P) do
		item = lily[item[1]](item[2], item[3])
		item:onComplete(function(_, l)
			res[i] = l

			item = recicleTable(item)
			
			loadc = loadc + 1
		end)
		count = count + 1
	end
end

function ql:draw()
	local percent = 0
	if loadc > 0 then
		percent = loadc/count
	end
	
	lg.arc("fill", wWidth-24, wHeight-24, 15, pi*1.5, pi*1.5 + percent * pi*2 % (pi*2), 100)
	lg.circle("line", wWidth-24, wHeight-24, 15, 100)
	lg.setLineWidth(2)
	
	if (Ftimer * 3) % (pi*2) < percent * pi*2 then
		lg.setColor(0,0,0)
	end

	lg.line(wWidth-24, wHeight-24, wWidth-24 + cos(pi*1.5 + Ftimer * 3) * 15, wHeight-24 + sin(pi*1.5 + Ftimer * 3) * 15)
	lg.setColor(1,1,1)
end

function ql:update()
	if count == loadc then
		popgamestate(res)
		P = nil
		res = nil
		collectgarbage()
		collectgarbage()
	end
end

return ql
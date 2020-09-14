local order = {}

local unpack = unpack or table.unpack
local m_huge = math.huge

local list = {}
local stack = 0

local function defaultSort(a, b)
	if a.order < b.order then
		return a
	elseif a.order == b.order then
		if a.stack < b.stack then
			return a
		end
	end
	return b
end

function order.clearCache()
	list = {}
	stack = 0
end

function order.queque(order, func, ...)
	stack = stack + 1

	if not list[stack] then
		list[stack] = {...}
	else
		for i=1, select("#", ...) do
			list[stack][i] = select(i, ...)
		end
	end
	list[stack].order = order
	list[stack].func = func
	list[stack].stack = stack
end

function order.present(f)
	if stack > 1 then
		table.sort(list, f or defaultSort)
	end
	
	for i=1, stack do
		local item = list[i]
		local func = item.func
		
		if type(func) == "function" then
			func(unpack(item))
		else
			love.graphics[func](unpack(item))
		end
		
		for j=1, #item do
			item[j] = nil
		end
	end
	stack = 0
end

function order.clearQueque()
	for i=1, #list do
		if #list[i] > 0 then
			for j=1, #list[i] do
				list[i][j] = nil
			end
		end
	end
	stack = 0
end

return order
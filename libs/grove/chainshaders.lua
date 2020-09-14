local chain = {}

local function check_type(obj, check, index)
	local objtype = type(obj)
	if objtype == "userdata" then
		if obj.type then
			objtype = obj:type()
		end
	end
	assert(objtype == check, "Bad argument #"..index..": "..check.." expected, got "..objtype)
end

--To avoid creating new tables
local function clear_array(arr)
	for i=1, #arr do
		arr[i] = nil
	end
end

local function copy_to_array(from, to)
 for i = 1, #from do
		to[#to+1] = from[i]
	end
end

function chain:start(...)
	if self.isActive then
		self.currCanvas = lg.getCanvas()
		--Set the front buffer
		lg.push()
		lg.origin()
		lg.setCanvas(self.front)
		lg.clear()
		self.active = true
	
		--Hold additional shaders
		for i=1, select("#", ...) do
			check_type(select(i, ...), "Shader", i)
			self.holding[i] = select(i, ...)
		end
	end
	return self
end

local shader_list = {}
function chain:stop()
	if self.isActive then
		--Check if chain:start was called
		assert(self.active, "You need to call chain:start() first")
		--Reset any graphics changes
		lg.reset()
		lg.setBlendMode("alpha", "premultiplied")
		copy_to_array(self.shaders, shader_list)
		copy_to_array(self.holding, shader_list)
	
		for i=1, #shader_list do
			--Apply shaders on the back buffer
			lg.setCanvas(self.back)
			lg.clear()
			lg.setShader(shader_list[i])
			lg.draw(self.front)
		
			--Send the results to the front buffer
			lg.setCanvas(self.front)
			lg.clear()
			lg.draw(self.back)
		end
		--Restore previous changes
		lg.setShader()
		lg.setBlendMode("alpha", "alphamultiply")
		lg.setCanvas(self.currCanvas)
		self.currCanvas = nil
		self.active = false
		--Draw the results
		lg.pop()
		lg.draw(self.front)
		clear_array(shader_list)
		clear_array(self.holding)
	end
	return self
end

function chain:append(...)
	local list = {...}
	
	for i=1, #list do
		check_type(list[i], "Shader", i)
	end
	copy_to_array(list, self.shaders)
	list = nil
	
	return self
end

function chain:removeAppended(...)
	for i=1, select("#", ...) do
		local sh = select(i, ...)
		check_type(sh, "Shader", i)
		
		local find = false
		for j=1, #self.shaders do
			if sh == self.shaders[j] then
				table.remove(self.shaders, j)
				find = true
			end
		end
		assert(find, "Item #"..i.." is not appended")
	end
	
	return self
end

function chain:clearAppended()
	clear_array(self.shaders)
	
	return self
end

function chain:resize(width, height)
	check_type(width, "number", 1)
	check_type(height, "number", 2)
	
	self.front = lg.newCanvas(width, height)
	self.back = lg.newCanvas(width, height)
	
	return self
end

function chain:isAppended(sh)
	check_type(sh, "Shader", 1)

	for i=1, #self.shaders do
		if sh == self.shaders[i] then
			return true
		end
	end
	return false
end

function chain:setActive(bool)
	if bool == nil then
		return self.isActive
	else
		self.isActive = bool
		return self
	end
end

function chain:new(width, height)
	width = width or lg.getWidth()
	height = height or lg.getHeight()
	
	local object =  {
		front = nil,
		back = nil,
		currCanvas = nil,
		isActive = true,
		shaders = {},
		holding = {},
	}
	for k, func in pairs(chain) do
		object[k] = func
	end
	object:resize(width, height)
	
	return object
end

--Default instance
local default = chain:new() 
for i, func in pairs(chain) do
	default[i] = function(...) return func(default, ...) end
end

return setmetatable(default, {__call = chain.new})
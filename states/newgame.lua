local newgame = {}

local journal = nil

function newgame:enter()
	night = 1
	savedata.level = 1
	
	journal = emptyTable()
	for i=1, 50 do
		journal[i] = emptyTable()

		journal[i][1] = "newImage"
		journal[i][2] = "assets/animations/journal/"..glang.code.."/"..i..".jpg"
	end
	pushgamestate("quickload", journal)
end

function newgame:resume(arg)
	journal = animation.newSequence(arg, 25):play()
	
	fade(false, 1)
	timer.after(5, function()fade(true, 3, "whichnight")end)
end

function newgame:draw()
	journal:draw()
end

function newgame:update()
	journal:update(dt)
end

function newgame:exit()
	recicleTable(journal)
end

return newgame
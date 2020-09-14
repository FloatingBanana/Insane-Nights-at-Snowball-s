local sixam = {}

local animTimer = 1
local animation = {}

function sixam:enter(arg)
	animTimer = 1
	
	for i=0, 35 do
		animation[i] = {"newImage", "assets/animations/6am/s"..i..".png"}
	end
	animation.sound = {"newSource", "sounds/sixam_eerie.ogg", "static"}

	pushgamestate("quickload", animation)
end

function sixam:resume(arg)
	animation = arg
	local to = nil
	local toArg = nil

	
	timer.after(3, function()
		animTimer = 1.1
		animation.sound:play()
	end)
	
	fade(false, 2.5)
	if night < 5 then
		if night == 1 then
			trophies:achieve("The insanity begins")

			to = "cutscene1"
		else
			to = "minigame"
			toArg = night - 1
		end

		night = night + 1
		savedata.level = night
	else
		if night == 5 then
			unlocks.beatgame = true
			trophies:achieve("We are just starting")
			to = "cutscene3"
		end
		
		if night == 6 then
			unlocks.sixnight = true
			trophies:achieve("Things are getting worse")
			to = "cutscene2"
		end

		if night == 7 then
			unlocks.insnight = true
			trophies:achieve("Dive into insanity")
			to = "payment"
		end

		if night == 8 then
			if currChallenge then
				local ch = savedata.cnchallenge
				
				ch[currChallenge] = true
				savedata.cnchallenge = ch
				
				local get = true
				for i = 1, 8 do
					if not ch[i] then
						get = false
						break
					end
				end
				if get then
					trophies:achieve("Challenge accepted")
				end
			end

			if currChallenge == 8 then
				to = "whichnight"
				night = 9
			else
				to = "customnight"
			end
		elseif night == 9 then
			to = "menu"
			savedata.snight = true
			trophies:achieve("The hidden nightmare")
		else
			savedata.unlocks = unlocks
		end

		clearResources()
	end

	timer.after(7, function()
		fade(true, 3, to, toArg)
	end)
end

function sixam:draw()
	lg.draw(animation[0])
	lg.draw(animation[floor(animTimer)])
end

function sixam:update()
	if animTimer > 1 then
		animTimer = min(animTimer+25*dt, 35)
	end
end

function sixam:exit()
	animation.sound:stop()
	animation = {}
end

return sixam
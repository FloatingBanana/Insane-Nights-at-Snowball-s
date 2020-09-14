gamejolt = require "libs.gamejolt"

local gtrophies, username, token, gameId, gameKey = ...
local updated = {}

local logged = false

gamejolt.init(gameId, gameKey)

if not gamejolt.isLoggedIn then
	logged = pcall(gamejolt.authUser, username, token)
end

if logged then
	local tlist = gamejolt.fetchAllTrophies(true)
	
	for i, trophy in ipairs(gtrophies) do
		for j, fetch in ipairs(tlist) do
			if trophy.id == tonumber(fetch.id) then
				if fetch.achieved ~= "false" and not trophy.get then
					updated[i] = true
				end
			
	            if fetch.achieved == "false" and trophy.get then
					gamejolt.giveTrophy(trophy.id)
				end
			end
		end
	end
end

love.thread.getChannel("info"):push(updated)
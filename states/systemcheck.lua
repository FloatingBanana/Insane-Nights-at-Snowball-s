local syscheck = {}

local cannot_run = false
function syscheck:enter()
    local gf = lg.getSupported()
    local gl = lg.getSystemLimits()

    if not gf.fullnpot or gl.texturesize < 1900 then
        cannot_run = true

        love.mousepressed = fnull
        love.mousereleased = fnull
        love.keypressed = fnull
        love.keyreleased = fnull
    else
        local ok, response = pcall(gamejolt.fetchData, "inas_version", true)
        
        --error(response)
        if ok then
            local new = response:explode(".", true)
            local cur = inasversion:explode(".", true)
            local new1, new2 = tonumber(new[1]), tostring(new[2])
            local cur1, cur2 = tonumber(cur[1]), tostring(cur[2])
    
            if new1 and new2 and (new1 > cur1 or new2 > cur2) then
                newversion = true
            end
        end
        
        if newversion then
            dialog(glang.newversion, {"OK", function()
                loadgamestate("warning")
            end})
        else
            loadgamestate("warning")
        end
    end
end

function syscheck:draw()
    if cannot_run then
        setFont(13)
        lg.printf(lang.message, 0, 320, 1000, "center")

        lg.printf(boolto(isMobile, lang.mobileexit, lang.exit), 0, 350, 1000, "center")
    end
end

function syscheck:update()
    if cannot_run and lk.isDown("escape") then
        love.event.quit()
    end
end

return syscheck
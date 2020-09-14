local df = {}

local sound = nil
local image = nil

function df:enter(next_state)
    sound = la.newSource("sounds/darkface.ogg", "static")
    image = lg.newImage("assets/darkfaces/"..random(1, 5)..".png")

    chromaticAberration:send("distortion", 0.1)
    chromaticAberration:send("aberration", 1.0)

    block_dt = true
    
    la.stop()
    sound:play()

    timer.after(random(4, 8), function()
        loadgamestate(next_state)
    end)
end

function df:draw()
    lg.setShader(chromaticAberration)
    lg.draw(image)
    lg.setShader()
end

function df:exit()
    sound:stop()
    sound = nil
    image = nil
end

return df
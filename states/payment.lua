local pay = {}

local image = nil
local music = nil
function pay:enter()
    fade(false, 3)
    la.stop()

    timer.after(8, function()
        fade(true, 3, "credits")
    end)

    image  = lg.newImage("assets/icons/great "..glang.code..".png")
    music = la.newSource("sounds/musics/payment.ogg", "stream")

    music:setVolume(.7)
    music:play()

end

function pay:draw()
    lg.draw(image, 500, 337, -Ftimer * .001, 1 + Ftimer * .005, 1 + Ftimer * .005, 500, 337)
end

function pay:exit()
    la.stop()
    music = nil
    image = nil
end

return pay
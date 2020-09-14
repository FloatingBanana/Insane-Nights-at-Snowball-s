local cp = {
    errors = nil,
    anyError = false,
}

local enterFade = 0
local sely = 125
local totalErrors = 0
local anyFixing = false
local maxBoxWidth = 0
local hoverItems = false
local boxAlpha = 0

function cp.enter()
    lang = glang.office

    enterFade = 0
    maxBoxWidth = 0
    for i, err in ipairs(cp.errors) do
        setFont("OCRAEXT", 30)
        local w = fontWidth(lang["fx"..err.n]) + 70
        if w > maxBoxWidth then
            maxBoxWidth = w
        end
    end
end

function cp.draw()
    for i, err in ipairs(cp.errors) do
        local percent = boolto(err.error, err.fixtime, 100)

        lg.setColor(.5,.5,.5, err.counterfade)
        lg.arc("fill", 300 + 60, 85 + i * 80, 25, 0,  percent/100*pi*2, 100)
        lg.setColor(.2,.2,.2, err.counterfade)
        lg.setBlendMode("replace")
        lg.circle("fill", 300 + 60, 85 + i * 80, 22, 100)
        lg.setBlendMode("alpha")
        
        lg.setColor(1,1,1, err.counterfade)
        setFont("OCRAEXT", 15)
        lg.printf(floor(percent).."%", 280 + 60, 78 + i * 80, 42, "center")

        if err.error then
            local r = sin(Ftimer * 4 % pi)
            lg.setColor(1,r,r,enterFade-i)
        else
            lg.setColor(1,1,1,enterFade-i)
        end
        setFont("OCRAEXT", 30)
        
        local pos = min(enterFade-i, 1) * 15
        lg.print(lang["fx"..err.n], 335 + pos + err.counterfade * 50, 70 + i * 80, 0)
    end

    --Selection box
    lg.setColor(1,1,1,boxAlpha)
    lg.setLineWidth(2)
    lg.rectangle("line", 330, sely + 10, maxBoxWidth, 60)
end

function cp.update()
    totalErrors = 0
    anyFixing = false
    
    for i, err in ipairs(cp.errors) do
        if err.count >= 50 then
            err.count = 0
            err.fixtime = 0
            err.error = true
        end
        
        if err.fixtime >= 100 then
            err.fixtime = 0
            err.count = 0
            err.error = false
        end
        
        err.fixing = err.fixtime > 0
        err.counterfade = clamp(ease(err.counterfade, boolto(err.fixing), 6), 0, 1)

        if err.error then
            totalErrors = totalErrors + 1
        end
        
        if err.fixing then
            anyFixing = true
        end
    end

    cp.anyError = totalErrors > 0
    cp.anyFixing = anyFixing

    for i, err in ipairs(cp.errors) do
        local holding = mouseOver(300, 55 + i * 80, maxBoxWidth, 60) and lm.isDown(1)

        if err.error and (err.fixing or not anyFixing) then
            err.fixtime = clamp(err.fixtime + boolto(holding, dt, -2 * dt) * 16, 0, 100)
        end
    end

    enterFade = min(enterFade + 7 * dt, 5)
    
    local sel = clamp(floor((RYmouse - 45)/80), 1, 4)
    local targetPos = 45 + sel * 80
    
    sely = ease(sely, targetPos, 9)

    hoverItems = mouseOver(330, 125, maxBoxWidth, 320)
    boxAlpha = clamp(boxAlpha + boolto(hoverItems, 5, -5) * dt, 0, 1)
end

return cp
local imgui = {
    mouse_clicked = false,
    mouse_released = false,
    mouse_down = false,
    current = nil,

    list = {} --List of objects
}

menuselect = la.newSource("sounds/bing1.ogg", "static")
menuselect:setVolume(.8)

local list = imgui.list
local pool = {} --Empty tables

local function getTable(id)
    for i, obj in ipairs(list) do
        if obj.id == id then
            imgui.current = obj
            
            return obj
        end
    end
    local obj = nil

    if pool[1] then
        obj = pool[1]
        table.remove(pool, 1)
    else
        obj = {}
    end
    obj.id = id
    imgui.current = obj
    toLast(list, obj)
    
    return obj
end


local function deleteTable(index)
    local obj = list[index]

    lume.clear(obj)
    table.remove(list, index)
    toLast(pool, obj)
end

function imgui.update()
    local old_mouse_down = imgui.mouse_down
    
    imgui.current = nil
    imgui.mouse_clicked = false
    imgui.mouse_released = false
    imgui.mouse_down = false

    if lm.isDown(1) then
        imgui.mouse_down = true

        if not old_mouse_down then
            imgui.mouse_clicked = true
        end
    elseif old_mouse_down then
        imgui.mouse_released = true
    end
    
    for i, obj in ipairs(list) do
        local old_hovered = obj.hovered

        obj.hovered = false
        obj.mouse_enter = false
        obj.mouse_exit = false

        assert(obj.x, #list)

        if mouseOver(obj.x, obj.y, obj.w, obj.h) then
            if (not isMobile or lm.isDown(1)) then
                obj.hovered = true
                
                if not old_hovered then
                    obj.mouse_enter = true
                end
            end
        elseif old_mouse_down then
            obj.mouse_exit = true
        end

        if obj.not_rendering then
            deleteTable(i)
        else
            obj.not_rendering = true
        end
    end

    imgui._info = string.format("Imgui:\npool: %d\nobjects: %d", #pool, #list)
end

function imgui.draw()
    local r, g, b, a = lg.getColor()

    for i, obj in ipairs(list) do

        if not obj.not_rendering then
            if obj.type == "scrollbutton" then
                local scroll = obj.scroll
                lg.setColor(r, scroll*g, scroll*b, a)

                local addPos = 30 - scroll * 30
                lg.draw(obj.img, obj.x + addPos * boolto(obj.dir == "left", 1, -1), obj.y)
            end
            if obj.type == "button" then
                local scroll = obj.scroll
                lg.setColor(r, scroll*g, scroll*b, a)

                lg.draw(obj.img, obj.x, obj.y)
            end
        end
    end
    lg.setColor(1,1,1,1)
    setFont(20)
end

local imagecache = {}
function imgui.button(id, img, x, y, w, h)
    obj = getTable(id)

    obj.type = "button"
    obj.x = x
    obj.y = y
    obj.img = img
    
    if type(img) == "string" then
        if imagecache[img] then
            obj.img = imagecache[img]
        else
            obj.img = lg.newImage("assets/icons/"..img)
            imagecache[img] = obj.img
        end
    end

    obj.w = w or obj.img:getWidth()
    obj.h = h or obj.img:getHeight()

    obj.scroll = obj.scroll or 1

    if obj.hovered then
        obj.scroll = max(obj.scroll - 5 * dt, 0)
    else
        obj.scroll = min(obj.scroll + 5 * dt, 1)
    end

    obj.not_rendering = false

    if obj.mouse_enter then
        menuselect:setPitch(lume.random(.8, 1))
		menuselect:stop()
		menuselect:play()
    end
    
    if isMobile then
        if obj.hovered and imgui.mouse_clicked then
            obj.pressed = true
        end
        if obj.mouse_exit then
            obj.pressed = false
        end
        return imgui.mouse_released and obj.pressed
    else
        return obj.hovered and imgui.mouse_clicked
    end
end

function imgui.scrollbutton(id, img, dir, x, y, w, h)
    local rt = imgui.button(id, img, x, y, w, h)
    
    imgui.current.type = "scrollbutton"
    imgui.current.dir = dir

    return rt
end

function imgui.textbutton(id, text, dir, x, y, w, h)
    local obj = getTable(id)
    local img = obj.img

    local cachepointer = string.format("%s_%s_%s", lang.code, currFont, text)
    
    if imagecache[cachepointer] then
        img = imagecache[cachepointer]
    else
        local w, h = fontWidth(text) + 2.5, fonts[currFont]:getHeight() + 5
        img = lg.newCanvas(w, h)
        
        lg.clear()
        lg.setCanvas(img)
        lg.push()
        lg.origin()
        
        lg.setBlendMode("alpha", "premultiplied")
        lg.setColor(1,0,1,1)
        blur(lg.print, text, 2.5)
        
        lg.setBlendMode("alpha")
        lg.setColor(1,1,1,1)
        lg.print(text, 2.5)
        
        lg.pop()
        lg.setCanvas()
        
        imagecache[cachepointer] = img
        block_dt = true
    end

    return imgui.scrollbutton(id, img, dir, x, y, w, h)
end

function imgui.clearcachedimages()
    imagecache = {}
end

return imgui
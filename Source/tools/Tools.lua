local pd <const> = playdate
local gfx <const> = pd.graphics

function getRandomDistinctPair(min, max)
    -- Get the first random number
    local first = math.random(min, max)
    
    -- Keep generating a second number until it's different from the first
    local second
    repeat
        second = math.random(min, max)
    until second ~= first
    
    return first, second
end

function drawDottedCircle(centerX, centerY, radius, dotCount, dotRadius, rotationAngle)
    -- Iterate through the number of dots you want to place on the circle
    for i = 1, dotCount do
        -- Calculate the angle for each dot (evenly spaced)
        local angle = (i / dotCount) * (2 * math.pi)
        
        -- Apply the rotation offset to create the spinning effect
        local rotatedAngle = angle + rotationAngle
        
        -- Calculate the x and y positions for each dot using the rotated angle
        local x = centerX + radius * math.cos(rotatedAngle)
        local y = centerY + radius * math.sin(rotatedAngle)
        
        -- Draw a small circle (dot) at the calculated position
        playdate.graphics.fillCircleAtPoint(x, y, dotRadius)
    end
end

function drawDottedEllipse(centerX, centerY, a, b, dotCount, dotRadius, rotationAngle)
    -- Iterate through the number of dots you want to place on the ellipse
    for i = 1, dotCount do
        -- Calculate the angle for each dot (evenly spaced)
        local angle = (i / dotCount) * (2 * math.pi)
        
        -- Calculate the x and y positions for each dot using ellipse parametric equations
        local rotatedAngle = angle + rotationAngle

        local x = centerX + a * math.cos(rotatedAngle)
        local y = centerY + b * math.sin(rotatedAngle)
        
        -- Draw a small circle (dot) at the calculated position
        playdate.graphics.fillCircleAtPoint(x, y, dotRadius)
    end
end

function drawDottedLine(x1, y1, x2, y2, dotSpacing, dotRadius)
    -- Calculate the total length of the line
    local dx = x2 - x1
    local dy = y2 - y1
    local lineLength = math.sqrt(dx * dx + dy * dy)
    
    -- Calculate the unit direction vector of the line
    local unitX = dx / lineLength
    local unitY = dy / lineLength
    
    -- Calculate the number of dots that will fit along the line
    local dotCount = math.floor(lineLength / dotSpacing)
    
    -- Draw dots along the line
    for i = 0, dotCount do
        -- Calculate the position of each dot with animation offset
        local dotPosition = (i * dotSpacing) % lineLength
        
        -- Calculate the x and y coordinates of the dot
        local x = x1 + dotPosition * unitX
        local y = y1 + dotPosition * unitY
        
        -- Draw a small circle (dot) at the calculated position
        playdate.graphics.fillCircleAtPoint(x, y, dotRadius)
    end
end

function clamp(v, l, m)

    if v > m then
        return m
    end

    if v < l then
        return l
    end

    return v

end

function rotatePoint(x, y, cx, cy, angle)
    -- Step 1: Translate the point to be relative to the center
    local px = x - cx
    local py = y - cy

    -- Step 2: Convert the angle to radians
    local angle_in_radians = math.rad(angle)

    -- Step 3: Apply the rotation matrix
    local new_px = px * math.cos(angle_in_radians) - py * math.sin(angle_in_radians)
    local new_py = px * math.sin(angle_in_radians) + py * math.cos(angle_in_radians)

    -- Step 4: Translate the point back to global coordinates
    local new_x = new_px + cx
    local new_y = new_py + cy

    return new_x, new_y
end

function stringToSeed(str)
    local hash = 0
    for i = 1, #str do
        local char = string.byte(str, i)
        hash = (hash * 31 + char) % 2147483647  -- Keep it within 32-bit range
    end
    return hash
end

function printTable(table)
    for k,v in pairs(table) do
        print(k,v)
    end
end

function getShadowSprite(spr)

    local img = gfx.image.new(spr:getSize())

    inContext(img, function ()
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRoundRect(0,0, img.width,img.height, 4)
    end)

    local _spr = gfx.sprite.new(img)
    _spr:setZIndex(spr:getZIndex()-1)

    return _spr
end

function getSignContractCallback(contract)
    local _func = function ()
        contract:generate()
        g_SceneManager:pushScene(ImageViewer({image=contract:getContractImage(), a_callback=function (_image_viewer)

            g_SceneManager:pushScene(Popup({text='Sign Contract?', options={
                {
                    name='Yes',
                    callback= function ()
                        if g_SystemManager:getPlayer():chargeMoney(contract:getSignPrice()) then
                            
                            local _timer = pd.timer.new(1000, _image_viewer.image_sprite.y,_image_viewer.image_sprite.height/2 - 240, pd.easingFunctions.outCubic)
                            _timer.updateCallback = function (timer)
                                _image_viewer.image_sprite:moveTo(200, timer.value)
                                _image_viewer.image_sprite:markDirty()
                            end
                            _timer.timerEndedCallback = function ()

                                inContext(_image_viewer.image_sprite:getImage(), function ()
                                    gfx.image.new('assets/contracts/contract_stamp'):drawAnchored(_image_viewer.image_sprite.width*0.8, _image_viewer.image_sprite.height*0.9, 0.5, 0.5)
                                end)
                                
                                _image_viewer.image_sprite:markDirty()

                                local _timer2 = pd.timer.new(250)
                                _timer2.updateCallback = function (timer)
                                    pd.display.setOffset(math.random(-2,2), math.random(-2,2))
                                end
                                _timer2.timerEndedCallback = function ()

                                    g_NotificationManager:notify('Contract Signed')
                                    contract:onSign()
                                    g_SystemManager:getPlayer():addContract(contract)
                                    
                                end
                            end
                        end
                    end
                },
                {
                    name='No'
                }
            }}), 'stack')
            
        end}), 'between menus')
    end

    return _func
end

function createPopup(data)
    print('Here')
    g_SceneManager:pushScene(Popup(data), 'stack')
end

function goTo(x, y, z, direction)

    if not direction then
        direction = 'down'
    end

    
    local _label = string.format("%i.%i.%i", x, y, z)

    if g_SystemManager:getPlayer().current_position then
        g_SystemManager:getPlayer().last_position.x = g_SystemManager:getPlayer().current_position.x
        g_SystemManager:getPlayer().last_position.y = g_SystemManager:getPlayer().current_position.y
        g_SystemManager:getPlayer().last_position.z = g_SystemManager:getPlayer().current_position.z
    end

    g_SystemManager:getPlayer().current_position.x = x
    g_SystemManager:getPlayer().current_position.y = y
    g_SystemManager:getPlayer().current_position.z = z

    local _s = g_SystemManager:getSystems()[_label]

    local _system = nil

    if _s then
        _system = _G[_s.class](_s)
        g_SystemManager:getPlayer().map[_label] = _s
        g_SceneManager:switchScene(_system, string.format('wipe %s', direction))
        g_SystemManager:getPlayer():setCurrentSystem(_system)
    else
        local _empty = g_SystemManager:getSystems()['empty']
        _empty.x = x
        _empty.y = y
        _empty.z = z

        _system = EmptySystem(_empty)
        g_SystemManager:getPlayer().map[_label] = {x = x, y = y, z = z, empty = true}
        g_SceneManager:switchScene(_system, string.format('wipe %s', direction))
        g_SystemManager:getPlayer():setCurrentSystem(_system)
    end

    g_SystemManager:save()

end

function getRandomMineral()

    local _minerals = {'Neodymium', 'Scandium', 'Yttrium'}
    return _G[_minerals[math.random(1, #_minerals)]]()
    
end

function tableUpdate(t1, t2)
    for k2,v2 in pairs (t2) do
        t1[k2] = v2
    end

    return t1
end

function tableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function drawPauseMenu()

    local img =  gfx.image.new("assets/pause_bg")
    gfx.pushContext(img)
        gfx.setFont(g_font_18)
        gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
        gfx.setColor(gfx.kColorWhite)
        if g_SystemManager:getPlayer().current_position.x then
            local _label = "System"
            local _data = g_SystemManager:getPlayer():getCurrentSystem().data.name
            
            --gfx.drawTextAligned(_label, img.width*0.05, img.height*0.3, kTextAlignment.left)
            gfx.drawTextAligned(_data, img.width*0.45, img.height*0.3, kTextAlignment.right)
        end

        if g_SystemManager:getPlayer().cycle then
            local _label = "Cycle"
            local _data = string.format("Cycle %i", g_SystemManager:getPlayer().cycle)
            
            --gfx.drawTextAligned(_label, img.width*0.05, img.height*0.4, kTextAlignment.left)
            gfx.drawTextAligned(_data, img.width*0.45, img.height*0.4, kTextAlignment.right)

        
        end

        if g_SystemManager:getPlayer().money then
            local _label = ""
            local _data = string.format("%iC", g_SystemManager:getPlayer().money)
            
            
            --gfx.drawTextAligned(_label, img.width*0.05, img.height*0.5, kTextAlignment.left)
            gfx.drawTextAligned(_data, img.width*0.45, img.height*0.5, kTextAlignment.right)
        end

        gfx.drawTextAligned("Fuel", img.width/4, img.height*0.78, kTextAlignment.center)
        gfx.setImageDrawMode(playdate.graphics.kDrawModeCopy)
        gfx.imagetable.new('assets/fuel'):getImage(clamp(math.floor(10*(g_SystemManager:getPlayer().ship.fuel_current/g_SystemManager:getPlayer().ship.fuel_capacity))+2, 1, 11)):drawAnchored(img.width/4, img.height*.9 , 0.5, 0.5)
        gfx.setFont()
    gfx.popContext()

    return img
    
end

function getRelativePoint(x, y, offsetX, offsetY, angle)
    -- Convert the angle from degrees to radians
    local radians = math.rad(angle)
    
    -- Rotate the offset vector by the given angle
    local rotatedOffsetX = offsetX * math.cos(radians) - offsetY * math.sin(radians)
    local rotatedOffsetY = offsetX * math.sin(radians) + offsetY * math.cos(radians)
    
    -- Calculate the new coordinates
    local newX = x + rotatedOffsetX
    local newY = y + rotatedOffsetY
    
    return newX, newY
end

function scaleAndCenterImage(image, canvas)
    -- Get the original image dimensions
    local imageWidth, imageHeight = image:getSize()
    
    -- Calculate the scaling factor to fit the image within the canvas
    local scaleX = canvas.width / imageWidth
    local scaleY = canvas.height / imageHeight
    local scale = math.max(scaleX, scaleY)

    -- Calculate the new image dimensions
    local newWidth = imageWidth * scale
    local newHeight = imageHeight * scale

    -- Calculate the top-left position to center the image on the canvas
    local x = (canvas.width  - newWidth) / 2
    local y = (canvas.height - newHeight) / 2

    -- Draw the scaled image at the calculated position
    gfx.pushContext(canvas)
        image:drawScaled(x, y, scale)
    gfx.popContext()
end

function round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function table_length(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end

  function table_remove(t, e)
    local count = 1
    for k,v in pairs(t) do 
        if v == e then
            table.remove(t, count)
            break
        end
        count = count + 1 
    end
  end


  function inContext(img, func)
    gfx.pushContext(img)
        func()
    gfx.popContext()
  end
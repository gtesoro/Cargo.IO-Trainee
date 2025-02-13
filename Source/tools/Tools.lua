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
        gfx.setColor(gfx.kColorWhite)
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

-- function --printTable(table)
--     for k,v in pairs(table) do
--         --print(k,v)
--     end
-- end


function getImageWithDitherMask(img, blurred)
    local _flip = nil
    if math.random(0, 1) > 0 then
        --_flip = gfx.kImageFlippedX
    end

    local _base = gfx.image.new(img)

    if blurred then
        _base = _base:blurredImage(1, 2, gfx.image.kDitherTypeScreen)
    end

    local _scale = 1
    local _x = _base.width/2
    local _y = _base.height/2
    local _flip = nil

    local _right_side = _base:scaledImage(_scale)
    
    local dither_image = gfx.image.new(_base:getSize())
    gfx.pushContext(dither_image)
        _right_side:drawAnchored(_x, _y, 0.5, 0.5, _flip)
    gfx.popContext()

    dither_image:setMaskImage(gfx.image.new('assets/dither_mask'))

    local _outline = gfx.image.new(string.format("%s_outline", img))
    if _outline then
        inContext(dither_image, function ()
            _outline:scaledImage(_scale):drawAnchored(_x, _y, 0.5, 0.5, _flip)
        end)
    end

    return dither_image
    
end

function applyFlicker(sprite)
    local _spr_img_orig = sprite:getImage():copy()
    local _timer = pd.timer.new(math.random(5000, 8000))
    sprite.flicker_timer = _timer
    _timer.flicker_duration = math.random(100, 300)
    _timer.repeats = true
    _timer.updateCallback = function (timer)
        if timer.timeLeft < timer.flicker_duration then
            if g_SystemManager:isTick(2) then
                sprite:setImage(_spr_img_orig:vcrPauseFilterImage())
            else
                sprite:setImage(_spr_img_orig)
            end
            sprite:markDirty()
        end
        sprite:markDirty()
        
    end
    _timer.timerEndedCallback = function (timer)
        sprite:setImage(_spr_img_orig)
        sprite:markDirty()
        timer.duration = math.random(5000, 8000)
        timer.flicker_duration = math.random(150, 300)
    end

    return _timer
end

function tableHasElement(table, element)
    for k,v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
end

function rumbleSprite(spr, duration, tick, distance, delay)

    if spr.rumbling then
        return
    end

    local _tick = tick or 1
    
    local _duration = duration or 999999999999
    local _distance = distance or 1
    local _delay = delay or 0

    local _t = pd.timer.new(_duration)
    local _x, _y = spr.x, spr.y
    _t.delay = _delay
    spr.rumbling = true
    _t.updateCallback = function (timer)
        if g_SystemManager:isTick(_tick) then
            spr:moveTo(_x + math.random(-_distance, _distance), _y + math.random(-_distance, _distance))
        end
    end
    _t.timerEndedCallback = function (timer)
        spr.rumbling = false
        spr:moveTo(_x, _y)
    end

    return _t
    
end

function getShadowSprite(spr, hover)

    local img = gfx.image.new(spr:getSize())

    inContext(img, function ()
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRoundRect(0,0, img.width,img.height, 4)
    end)

    local _spr = gfx.sprite.new(img)
    _spr:setZIndex(spr:getZIndex())
    _spr:setCenter(spr:getCenter())
    _spr:moveTo(spr.x + (hover or 5), spr.y + (hover or 5))

    return _spr
end

function collectGarbage()
    for i=0,5 do
        local _b = collectgarbage("count")
        collectgarbage("collect")
        local _a = collectgarbage("count")
    end
end


function arcInRect(arc, rect, samples)
     samples = samples or 3

     if (arc.x + arc.radius < rect.x) or (arc.x - arc.radius > rect.x + rect.width) then
        return false
     end

     if (arc.y + arc.radius < rect.y) or (arc.y - arc.radius > rect.y + rect.height) then
        return false
     end

    for d=0,samples-1  do
        local _p = arc:pointOnArc(d*arc:length()/(samples-1))
        if rect:containsPoint(_p) then
            return true
        end
    end
    return false
end

function systemNameFromCoords(x, y, z)

    local z_name = 'N/A'

    if z == 0 then
        z_name = 'GEN'
    end

    local x_name = 'N/A'
    if x >= 0 then
        x_name = string.format('+%03d', x)
    else
        x_name = string.format('-%03d', math.abs(x))
    end

    local y_name = 'N/A'
    if y >= 0 then
        y_name = string.format('+%03d', y)
    else
        y_name = string.format('-%03d', math.abs(y))
    end

    return string.format('%s%s%s', z_name, x_name, y_name)

end

function signContractMenu(contract, a_callback, b_callback, notify)

    g_SceneManager:pushScene(ImageViewer({image=gfx.sprite.new(contract:getContractImage()), a_callback=function (_image_viewer)

        if contract.state.signed then
            return
        end
        g_SceneManager:pushScene(Popup({text='Sign Contract?', options={
            {
                name='Yes',
                callback= function ()
                    if contract:canSign() then
                        
                        local _timer = pd.timer.new(1000, _image_viewer.image_sprite.y, (-_image_viewer.image_sprite.height) + 90 + 120, pd.easingFunctions.outCubic)
                        _timer.updateCallback = function (timer)
                            _image_viewer.image_sprite:moveTo(_image_viewer.image_sprite.x, timer.value)
                            _image_viewer.image_sprite:markDirty()
                        end
                        _timer.timerEndedCallback = function ()

                            inContext(_image_viewer.image_sprite:getImage(), function ()
                                g_SystemManager:getPlayer():getSiegelImage():drawAnchored(_image_viewer.image_sprite.width - 25, _image_viewer.image_sprite.height - 15, 1, 1)
                            end)

                            g_SoundManager:playStamp()
                            
                            _image_viewer.image_sprite:markDirty()

                            local _timer2 = pd.timer.new(250)
                            _timer2.updateCallback = function (timer)
                                pd.display.setOffset(math.random(-2,2), math.random(-2,2))
                            end
                            _timer2.timerEndedCallback = function ()

                                if notify then
                                    g_NotificationManager:notify('Contract Signed')
                                end
                                contract:onSign()
                                g_SystemManager:getPlayer():addContract(contract)
                                
                                if a_callback then
                                    a_callback()
                                end
                            end
                        end
                    end
                end
            },
            {
                name='No',
                callback= function ()
                    if b_callback then
                        b_callback()
                    end
                end
            }
        }}))
        
    end}), 'between menus')
end

function createPopup(data)
    g_SceneManager:pushScene(Popup(data))
end

function goTo(x, y, z, direction, no_last_position_update)

    local _player = g_SystemManager:getPlayer()

    if not direction then
        direction = 'down'
    end

    if not no_last_position_update then
        if _player.current_position then
            _player.last_position.x = _player.current_position.x
            _player.last_position.y = _player.current_position.y
            _player.last_position.z = _player.current_position.z
        end
    end

    _player.current_position.x = x
    _player.current_position.y = y
    _player.current_position.z = z

    local _s = g_SystemManager:getSystem(x, y, z)

    local _system = nil

    _player.map[string.format("%i.%i.%i", x, y, z)] = {x,y,z}

    if _s then
        _system = _G[_s.class](_s)
        --_player.map[_label] = _s
        g_SceneManager:switchScene(_system, table.concat({'wipe ', direction}))
        _player:setCurrentSystem(_system)
    else

        _system = EmptySystem({
            x = x,
            y = y,
            z = z
        })
        --_player.map[_label] = {x = x, y = y, z = z, empty = true}
        g_SceneManager:switchScene(_system, table.concat({'wipe ', direction}))
        _player:setCurrentSystem(_system)
    end

    g_SystemManager:save()

end

function isometricProjection(x, y, z, scale)

    -- Angles to rotate around the X and Z axes
    local angleX = math.rad(-35.264)  -- Convert to radians
    local angleZ = math.rad(45)

    -- Rotate around X-axis
    local cosX = math.cos(angleX)
    local sinX = math.sin(angleX)
    local x1 = x
    local y1 = y * cosX - z * sinX
    local z1 = y * sinX + z * cosX

    -- Rotate around Z-axis
    local cosZ = math.cos(angleZ)
    local sinZ = math.sin(angleZ)
    local x2 = x1 * cosZ - y1 * sinZ
    local y2 = x1 * sinZ + y1 * cosZ

    -- Apply scaling
    x2 = x2 * scale
    y2 = y2 * scale

    -- Return the isometrically projected and scaled x and y coordinates
    return x2, y2

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

function getStatusImg()
    
    local img = gfx.image.new(180, 150)

    gfx.setFont(g_font_text)

    inContext(img, function ()
        gfx.setFontFamily(g_font_text_family)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRoundRect(0,0,img.width, img.height, 2)

        gfx.setColor(gfx.kColorWhite)
        gfx.drawRoundRect(0,0,img.width, img.height, 2)

        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

        local _system = g_SystemManager:getPlayer():getCurrentSystem()
        local _system_data = _system.data

        local _data = "*System*"
        gfx.drawTextAligned(_data, img.width*0.05, img.height*0.05, kTextAlignment.left)

        _data = string.format("%s", _system:getName()) 
        gfx.drawTextAligned(_data, img.width*0.95, img.height*0.05, kTextAlignment.right)

        _data = "*Loc*"
        gfx.drawTextAligned(_data, img.width*0.05, img.height*0.2, kTextAlignment.left)

        _data = systemNameFromCoords(_system_data.x, _system_data.y, _system_data.z)
        gfx.drawTextAligned(_data, img.width*0.95, img.height*0.2, kTextAlignment.right)

        _data = "*Cycle*"
        gfx.drawTextAligned(_data, img.width*0.05, img.height*0.35, kTextAlignment.left)

        _data = string.format("%i.%02i", g_SystemManager:getCycle())
        gfx.drawTextAligned(_data, img.width*0.95, img.height*0.35, kTextAlignment.right)

        _data = "*Credits*"
        gfx.drawTextAligned(_data, img.width*0.05, img.height*0.5, kTextAlignment.left)

        _data = string.format("%iC", g_SystemManager:getPlayer().money)
        gfx.drawTextAligned(_data, img.width*0.95, img.height*0.5, kTextAlignment.right)

        gfx.drawTextAligned("*Hull*", img.width*0.05, img.height*0.65, kTextAlignment.left)

        _data = string.format("%i%%", 100)
        gfx.drawTextAligned(_data, img.width*0.95, img.height*0.65, kTextAlignment.right)


        gfx.drawTextAligned("*Fuel*", img.width*0.05, img.height*0.80, kTextAlignment.left)
        
        _data = string.format("%i%%", math.floor(g_SystemManager:getPlayer().ship.fuel_current/g_SystemManager:getPlayer().ship.fuel_capacity*100 + 0.5))
        gfx.drawTextAligned(_data, img.width*0.95, img.height*0.80, kTextAlignment.right)


        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end)
    return img
end

function drawPauseMenu()

    local img =  gfx.image.new("assets/pause_bg")
    gfx.pushContext(img)
        gfx.setFont(g_font_18)
        gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
        gfx.setColor(gfx.kColorWhite)
        if g_SystemManager:getPlayer().current_position.x then
            local _label = "System"
            local _data = g_SystemManager:getPlayer():getCurrentSystem():getName()
            
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

function getRelativePoint(cx, cy, offsetX, offsetY, angle)

    local rad = angle * math.pi / 180
    
    -- Apply the rotation matrix to the offset
    local rotatedX = offsetX * math.cos(rad) - offsetY * math.sin(rad)
    local rotatedY = offsetX * math.sin(rad) + offsetY * math.cos(rad)
    
    -- Translate back to world coordinates by adding the center coordinates
    local worldX = rotatedX + cx
    local worldY = rotatedY + cy
    
    return worldX, worldY
end

function scaleAndCenterImage(image, canvas, rand)
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
        local _img = image
        
        if scale ~= 1 then
            _img = image:scaledImage(scale)
        end

        local _flip = gfx.kImageUnflipped

        if rand then
            local _rand = math.random(0,3)

            if _rand == 1 then
                _flip = gfx.kImageFlippedX
            end
            if _rand == 2 then
                _flip = gfx.kImageFlippedY
            end
            if _rand == 3 then
                _flip = gfx.kImageFlippedY
            end

        end

        _img:draw(x, x, _flip)


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
    assert(img)
    gfx.pushContext(img)
        func()
    gfx.popContext()
  end
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Map').extends('Scene')

function Map:startScene()

    self.player_pos = g_SystemManager:getPlayer().current_position
    self.current_z = self.player_pos.z

    self:initInputs()

    local img = gfx.image.new(400, 240, gfx.kColorBlack)
    gfx.pushContext(img)
        local _i = gfx.image.new('assets/backgrounds/grid')
        _i:drawAnchored(pd.display.getWidth()/2, pd.display.getHeight()/2, 0.5, 0.5)
    gfx.popContext()

    self.bg_image = img:blurredImage(1, 2, gfx.image.kDitherTypeScreen)
    self.bg_sprite = gfx.sprite.new(self.bg_image)
    self.bg_sprite:setIgnoresDrawOffset(true)
    self.bg_sprite:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.bg_sprite:setZIndex(0)
    self.bg_sprite:add()
    table.insert(self.sprites, self.bg_sprite)

    self.pointer_system = nil
    self.pointer_size = 80
    self.pointer = gfx.sprite.new(gfx.image.new(self.pointer_size, self.pointer_size))
    inContext(self.pointer:getImage(), function ()
        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(8)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.drawRoundRect(0,0, self.pointer_size, self.pointer_size, 2)

        -- gfx.drawLine(0, 120, 200 - self.pointer_size/2, 120)
        -- gfx.drawLine(200 + self.pointer_size/2, 120, 400, 120)

        -- gfx.drawLine(200, 0, 200, 120 - self.pointer_size/2)
        -- gfx.drawLine(200, 120 + self.pointer_size/2, 200, 240)

    end)
    self.pointer:setIgnoresDrawOffset(true)
    self.pointer:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.pointer:setZIndex(4)
    self.pointer:add()

    table.insert(self.sprites, self.pointer)

    self.infolay = gfx.sprite.new(gfx.image.new(400, 240))
    self.infolay:setIgnoresDrawOffset(true)
    self.infolay:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.infolay:setZIndex(4)
    self.infolay:add()

    table.insert(self.sprites, self.infolay)

    self.ui_overlay = gfx.sprite.new(gfx.image.new('assets/backgrounds/ui_overlay'))
    self.ui_overlay:setIgnoresDrawOffset(true)
    self.ui_overlay:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.ui_overlay:setZIndex(4)
    self.ui_overlay:add()

    table.insert(self.sprites, self.ui_overlay)

    self.separation = 100

    local map_img = gfx.image.new(self:getMapSize())

    self.map_sprite = gfx.sprite.new(map_img)

    self.map_sprite:setImage(map_img)
    self.map_sprite:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.map_sprite:setZIndex(1)
    self.map_sprite:add()

    self.map_sprite:setVisible(false)

    self.x_offset = 0
    self.y_offset = 0
    self:drawMap()

    table.insert(self.sprites, self.map_sprite)

end

function Map:getMapSize()

    local _w, _h = 400, 240

    for k,v in pairs(g_SystemManager:getPlayer().map) do

        local _x, _y = math.abs(v[1]), math.abs(v[2])

        _w = math.max((_x*self.separation+64)*2, _w)
        _h = math.max((_y*self.separation+64)*2, _h)

    end
    return _w, _h

end

function Map:areAdjacent(x1, y1, x2, y2)
    -- Check if the points are horizontally adjacent
    local horizontalAdjacency = (x1 == x2) and (math.abs(y1 - y2) == 1)
    -- Check if the points are vertically adjacent
    local verticalAdjacency = (y1 == y2) and (math.abs(x1 - x2) == 1)

    -- Return true if either condition is met, false otherwise
    return horizontalAdjacency or verticalAdjacency
end

function Map:drawMap()

    local _separation = self.separation
    local _img = self.map_sprite:getImage()

    inContext(_img, function ()

        gfx.clear()

        for k,c in pairs(g_SystemManager:getPlayer().map) do
            for k,o in pairs(g_SystemManager:getPlayer().map) do
                if self:areAdjacent(c[1], c[2], o[1], o[2]) then
                    gfx.setColor(gfx.kColorWhite)
                    gfx.setLineWidth(3)
                    local _x1, _y1 = c[1]*_separation + _img.width/2, c[2]*_separation + _img.height/2
                    local _x2, _y2 = o[1]*_separation + _img.width/2, o[2]*_separation + _img.height/2
                    gfx.drawLine(_x1, _y1, _x2, _y2)
                end
            end
        end

        for k,v in pairs(g_SystemManager:getPlayer().map) do
            local _x, _y = v[1]*_separation + _img.width/2, v[2]*_separation + _img.height/2
            local _system = g_SystemManager:getSystem(v[1], v[2], v[3])
            if _system and _system.thumbnail then
                local _s = _system.thumbnail()

                gfx.setColor(gfx.kColorBlack)
                gfx.fillCircleAtPoint(_x, _y, math.max(_s.width, _s.height)/2+8)
                if self.player_pos.x == v[1] and self.player_pos.y == v[2] and self.player_pos.z == v[3] then
                    gfx.setColor(gfx.kColorWhite)
                    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeScreen)
                    gfx.fillCircleAtPoint(_x, _y, math.max(_s.width, _s.height)/2+8)
                end

                gfx.setColor(gfx.kColorWhite)
                gfx.drawCircleAtPoint(_x, _y, math.max(_s.width, _s.height)/2+8)

                _s:moveTo(_x+(200-_img.width/2), _y+(120-_img.height/2))
                _s:setZIndex(2)
                _s:add()
                table.insert(self.sprites, _s)
            elseif _system then
                gfx.setColor(gfx.kColorWhite)
                gfx.fillCircleAtPoint(_x, _y, 16)
                if self.player_pos.x == v[1] and self.player_pos.y == v[2] and self.player_pos.z == v[3] then
                    gfx.setColor(gfx.kColorBlack)
                    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeScreen)
                    gfx.fillCircleAtPoint(_x, _y, 16)
                end
            else
                gfx.setColor(gfx.kColorBlack)
                gfx.fillCircleAtPoint(_x, _y, 16)

                if self.player_pos.x == v[1] and self.player_pos.y == v[2] and self.player_pos.z == v[3] then
                    gfx.setColor(gfx.kColorWhite)
                    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeScreen)
                    gfx.fillCircleAtPoint(_x, _y, 16)
                end

                gfx.setColor(gfx.kColorWhite)
                gfx.drawCircleAtPoint(_x, _y, 16)
            end

            -- if self.player_pos.x == v[1] and self.player_pos.y == v[2] and self.player_pos.z == v[3] then

            --     local _s = AnimatedSprite('assets/ui/map_selector')

            --     _s:moveTo(_x+(200-_img.width/2), _y+(120-_img.height/2))
            --     _s:setZIndex(2)
            --     _s:add()
            --     table.insert(self.sprites, _s)
            -- end

        end
    end)

    self.x_offset = self.player_pos.x * self.separation
    self.y_offset = self.player_pos.y * self.separation

    self.map_sprite:markDirty()
end


function Map:doVCR()

    self.bg_sprite:setImage(self.bg_image:vcrPauseFilterImage())
    
end

function Map:initInputs()

    local _cam_speed = 6

    self.input_handlers = {

        -- cranked = function (change, acceleratedChange)
        --     -- self.separation += 5*(change/360)
        --     -- self:doVCR()
        --     -- self:drawMap()
        -- end,

        -- AButtonUp = function ()

        -- end,

        BButtonUp = function ()
            self.map_sprite:remove()
            g_SceneManager:popScene('between menus')
        end,

        -- upButtonDown = function ()
        --     self.y_offset -= _cam_speed
        --     self:doVCR()
        --     gfx.setDrawOffset(-self.x_offset, -self.y_offset)
        -- end,

        -- downButtonDown = function ()
        --     self.y_offset += _cam_speed
        --     self:doVCR()
        --     gfx.setDrawOffset(-self.x_offset, -self.y_offset)
        -- end,

        -- leftButtonDown = function ()
        --     self.x_offset -= _cam_speed
        --     self:doVCR()
        --     gfx.setDrawOffset(-self.x_offset, -self.y_offset)
        -- end,

        -- rightButtonDown = function ()
        --     self.x_offset += _cam_speed
        --     self:doVCR()
        --     gfx.setDrawOffset(-self.x_offset, -self.y_offset)
        -- end

    }
    
end

function Map:getSystemFromOffset(x_offset, y_offset)
    
    local _x, _y, _z = 0, 0, self.current_z

    _x = math.floor((x_offset / self.separation) + 0.5)
    _y = math.floor((y_offset / self.separation) + 0.5)

    local _s = string.format('%d.%d.%d', _x, _y, _z)

    if g_SystemManager:getPlayer().map[_s] then
        local _s = g_SystemManager:getSystem(_x, _y, _z)

        if _s then
            return _s
        else
            return {
                name = 'Unknown',
                x = _x,
                y = _y,
                z = _z
            }
        end
    end

    return nil
end

function Map:doUpdate()

    local _cam_speed = 4

    self.bg_sprite:setImage(self.bg_image)

    gfx.setDrawOffset(-self.x_offset, -self.y_offset)
    self.map_sprite:setVisible(true)

    if pd.buttonIsPressed(pd.kButtonUp) then
        self.y_offset -= _cam_speed
        self:doVCR()
        gfx.setDrawOffset(-self.x_offset, -self.y_offset)
    end

    if pd.buttonIsPressed(pd.kButtonDown) then
        self.y_offset += _cam_speed
        self:doVCR()
        gfx.setDrawOffset(-self.x_offset, -self.y_offset)
    end

    if pd.buttonIsPressed(pd.kButtonLeft) then
        self.x_offset -= _cam_speed
        self:doVCR()
        gfx.setDrawOffset(-self.x_offset, -self.y_offset)
    end

    if pd.buttonIsPressed(pd.kButtonRight) then
        self.x_offset += _cam_speed
        self:doVCR()
        gfx.setDrawOffset(-self.x_offset, -self.y_offset)
    end

    local _s = self:getSystemFromOffset(self.x_offset, self.y_offset)
    
    if self.pointer_system ~= _s then
        self.pointer_system = _s
        if self.pointer_system then
            inContext(self.infolay:getImage(), function ()
                gfx.clear()
                gfx.setColor(gfx.kColorWhite)
                gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
                gfx.fillRect(0, 20, 400,45)
                gfx.setFont(g_font_text)
                --gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                gfx.drawTextAligned(self.pointer_system.name, 200, 25, kTextAlignment.center)
                gfx.drawTextAligned(systemNameFromCoords(self.pointer_system.x, self.pointer_system.y, self.pointer_system.z) , 200, 45, kTextAlignment.center)
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
            end)
            self.infolay:markDirty()
        else
            self.infolay:getImage():clear(gfx.kColorClear)
        end
    end

end
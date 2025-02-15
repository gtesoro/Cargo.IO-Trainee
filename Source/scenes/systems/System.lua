local pd <const> = playdate
local gfx <const> = pd.graphics

class('System').extends(Scene)

function System:startScene()

    self.locations = {}

    if self.data.name then
        g_NotificationManager:notify(self.data.name)
    else
        g_NotificationManager:notify(systemNameFromCoords(self.data.x, self.data.y, self.data.z))
    end

    self.x_offset = 0
    self.y_offset = 0
    self.x_cam_loose = 50
    self.y_cam_loose = 30
    self.wrap = false

    self.playfield_width = self.data.playfield_width
    self.playfield_height = self.data.playfield_height

    self.zoom = 1

    self.selection_spr = gfx.sprite.new()
    self.selection_spr:add()
    table.insert(self.sprites, self.selection_spr)
    self.selection_focus = nil

    self:initBg()
    
    self:initPlayer()
    self:initInputs()
    self:moveCamera()
    self:initUI()
    self:initLocations()
end

function System:add()
    System.super.add(self)
    g_SystemManager:unpause()
    g_SoundManager:playSpaceBg()
    gfx.setDrawOffset(-self.x_offset, -self.y_offset)
end

function System:remove()
    System.super.remove(self)
    g_SystemManager:pause()
    g_SoundManager:stopSpaceBg()
end

function System:setSelectionSprite(spr)

    local _offset = 30
    local _c_s = 2

    self.selection_focus = spr

    local _w, _h = spr:getSize()
    local img = gfx.image.new(_w + _offset + _c_s, _h + _offset + _c_s)
    local _dots = math.floor(math.max(_w, _h)/5)

    gfx.pushContext(img)
        gfx.clear()
        gfx.setColor(pd.graphics.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.setLineWidth(_c_s)
        gfx.drawCircleAtPoint(img.width/2, img.height/2, (math.max(img.width, img.height)/2) - _c_s)
    gfx.popContext()

    self.selection_spr:setImage(img)
    
    self.selection_spr:setZIndex(self.playfield_height*2)
    self.selection_spr:moveTo(self.selection_focus:getPosition())

    self.selection_spr:setVisible(true)

end

function System:getName()

    if self.data.name then
        return self.data.name
    else
        return "Unknown"
    end
end

function System:initLocations()

    if not self.data.locations then
        return 
    end
    
    for k,loc in pairs(self.data.locations) do
        local _loc = AnimatedSprite(loc.img, loc.img_delay or 100)
        _loc:moveTo(loc.x, loc.y)
        _loc:setZIndex(loc.z_index or 1)
        _loc:add()
        _loc.collisionResponse = gfx.sprite.kCollisionTypeOverlap
        _loc:setCollideRect( 0, 0, _loc:getSize() )
        _loc.interactuable = true
        function _loc:interact()
            g_SceneManager:pushScene(LocationMenu(loc), 'to menu')
        end
        table.insert(self.locations, _loc)
        table.insert(self.sprites, _loc)
    end
    
end

function System:updateSelectionSprite()

    if self.selection_focus  then
        self.selection_spr:moveTo(self.selection_focus:getPosition())
    end

end

function System:initPlayer()

    self.margin = 40

    self.player = Player(self)
    self.player:setZIndex(self.playfield_height*2+1)
    self.player:moveTo(self.playfield_width/2-100, self.playfield_height/2)
    if g_SystemManager:getPlayerData().last_position.x then
        self.spawn_point = pd.geometry.point.new(self.playfield_width/2-100, self.playfield_height/2)
        local dx, dy, dz = self.data.x - g_SystemManager:getPlayerData().last_position.x, self.data.y - g_SystemManager:getPlayerData().last_position.y, self.data.z - g_SystemManager:getPlayerData().last_position.z
        if math.abs(dx) + math.abs(dy) + math.abs(dz) == 1 then
            if dx > 0 then
                self.spawn_point = pd.geometry.point.new(self.margin, self.playfield_height/2)
                self.player.angle = 90
            end

            if dx < 0 then
                self.spawn_point = pd.geometry.point.new(self.playfield_width - self.margin, self.playfield_height/2)
                self.player.angle = 270
            end

            if dy > 0 then
                self.spawn_point = pd.geometry.point.new(self.playfield_width/2, self.margin)
                self.player.angle = 180
            end

            if dy < 0 then
                self.player:moveTo(self.playfield_width/2, self.playfield_height - 50)
                self.spawn_point = pd.geometry.point.new(self.playfield_width/2, self.playfield_height - self.margin)
            end
        end

        self.player:moveTo(self.spawn_point.x, self.spawn_point.y)
        self.player:updateImg()
    end
    local _x, _y = self.player:getPosition()
    self.x_offset = _x - pd.display.getWidth()/2
    self.y_offset = _y - pd.display.getHeight()/2

    --self.player:moveTo(30, self.playfield_height/2)

    table.insert(self.sprites, self.player)
end

function System:initBg()

    local img = gfx.image.new(self.playfield_width, self.playfield_height)
    local bg = nil
    if not self.data.background then
        bg = gfx.image.new(self.playfield_width, self.playfield_height, gfx.kColorBlack)
    else
        bg = gfx.image.new(self.data.background)
    end

    if self.data.blur_bg then
        bg = bg:blurredImage(5, 2, gfx.image.kDitherTypeBayer8x8) 
    end
    
    scaleAndCenterImage(bg, img, self.data.bg_random_flip)

    self.bg_sprite = gfx.sprite.new(img)
    self.bg_sprite:moveTo(self.playfield_width/2, self.playfield_height/2)
    self.bg_sprite:setZIndex(0)

    table.insert(self.sprites, self.bg_sprite)

end

-- function System:initBorders()

--     local speed = 50
--     self.arrow_y = 0

--     local spr = AnimatedSprite("assets/border",speed)
--     spr:moveTo(pd.display.getWidth()/2, spr.height/2)
--     spr:setIgnoresDrawOffset(true)
--     spr:setZIndex(2)
--     spr:setCollideRect( 0, 0, spr:getSize() )
--     table.insert(self.sprites, spr)
--     self.up = spr

--     spr = AnimatedSprite("assets/border",speed)
--     spr:moveTo(pd.display.getWidth()/2, pd.display.getHeight() - spr.height/2)
--     spr:setRotation(180)
--     spr:setIgnoresDrawOffset(true)
--     spr:setZIndex(2)
--     spr:setCollideRect( 0, 0, spr:getSize() )
--     table.insert(self.sprites, spr)
--     self.down = spr

--     spr = AnimatedSprite("assets/border",speed)
--     spr:moveTo(spr.height/2, pd.display.getHeight()/2)
--     spr:setRotation(270)
--     spr:setIgnoresDrawOffset(true)
--     spr:setZIndex(2)
--     spr:setCollideRect( 0, 0, spr:getSize() )
--     table.insert(self.sprites, spr)
--     self.left = spr

--     spr = AnimatedSprite("assets/border",speed)
--     spr:moveTo(pd.display.getWidth() - spr.height/2, pd.display.getHeight()/2)
--     spr:setRotation(90)
--     spr:setIgnoresDrawOffset(true)
--     spr:setZIndex(2)
--     spr:setCollideRect( 0, 0, spr:getSize() )
--     table.insert(self.sprites, spr)
--     self.right = spr

--     self.up:setVisible(false)
--     self.down:setVisible(false)
--     self.left:setVisible(false)
--     self.right:setVisible(false)

-- end

function System:handleBorders()

    local margin = 64

    self.blackout_overlay:setVisible(true)
    local margin = 64
    if self.player.x < 0 then
        self.blackout_overlay:setVisible(true)
        inContext(self.blackout_overlay:getImage(), function ()
            gfx.clear(gfx.kColorWhite)
            gfx.setColor(gfx.kColorClear)
            gfx.fillCircleAtPoint(clamp(self.player.x - self.x_offset, 0, 400), clamp(self.player.y - self.y_offset, 0, 240), (1 - math.abs(self.player.x/margin))*466.48)
            gfx.setColor(gfx.kColorWhite)
            self.player:getImage():fadedImage(0.5, gfx.image.kDitherTypeBayer8x8):drawAnchored(clamp(self.player.x - self.x_offset, 0, 400), clamp(self.player.y - self.y_offset, 0, 240), 0.5 , 0.5 )

        end)
        self.blackout_overlay:markDirty()
    elseif self.player.x > self.playfield_width then
        self.blackout_overlay:setVisible(true)
        inContext(self.blackout_overlay:getImage(), function ()
            gfx.clear(gfx.kColorWhite)
            gfx.setColor(gfx.kColorClear)
            gfx.fillCircleAtPoint(clamp(self.player.x - self.x_offset, 0, 400), clamp(self.player.y - self.y_offset, 0, 240), (1 - math.abs(self.player.x - self.playfield_width)/margin)*466.48)
            gfx.setColor(gfx.kColorWhite)
            self.player:getImage():fadedImage(0.5, gfx.image.kDitherTypeBayer8x8):drawAnchored(clamp(self.player.x - self.x_offset, 0, 400), clamp(self.player.y - self.y_offset, 0, 240), 0.5 , 0.5)
        end)
        self.blackout_overlay:markDirty()
    elseif self.player.y < 0 then
        self.blackout_overlay:setVisible(true)
        inContext(self.blackout_overlay:getImage(), function ()
            gfx.clear(gfx.kColorWhite)
            gfx.setColor(gfx.kColorClear)
            gfx.fillCircleAtPoint(clamp(self.player.x - self.x_offset, 0, 400), clamp(self.player.y - self.y_offset, 0, 240), (1 - math.abs(self.player.y/margin))*466.48)
            gfx.setColor(gfx.kColorWhite)
            self.player:getImage():fadedImage(0.5, gfx.image.kDitherTypeBayer8x8):drawAnchored(clamp(self.player.x - self.x_offset, 0, 400), clamp(self.player.y - self.y_offset, 0, 240), 0.5 , 0.5)
        end)
        self.blackout_overlay:markDirty()
    elseif self.player.y > self.playfield_height then
        self.blackout_overlay:setVisible(true)
        inContext(self.blackout_overlay:getImage(), function ()
            gfx.clear(gfx.kColorWhite)
            gfx.setColor(gfx.kColorClear)
            gfx.fillCircleAtPoint(clamp(self.player.x - self.x_offset, 0, 400), clamp(self.player.y - self.y_offset, 0, 240), (1 - math.abs(self.player.y - self.playfield_height)/margin)*466.48)
            gfx.setColor(gfx.kColorWhite)
            self.player:getImage():fadedImage(0.5, gfx.image.kDitherTypeBayer8x8):drawAnchored(clamp(self.player.x - self.x_offset, 0, 400), clamp(self.player.y - self.y_offset, 0, 240), 0.5 , 0.5)
        end)
        self.blackout_overlay:markDirty()
    else
        self.blackout_overlay:setVisible(false)
    end

    if self.player.x < -margin then
        inContext(self.blackout_overlay:getImage(), function ()
            gfx.clear(gfx.kColorWhite)
        end)
        self.blackout_overlay:markDirty()
        goTo(self.data.x-1, self.data.y , self.data.z, 'left')
    end

    if self.player.x > self.playfield_width + margin then
        inContext(self.blackout_overlay:getImage(), function ()
            gfx.clear(gfx.kColorWhite)
        end)
        self.blackout_overlay:markDirty()
        goTo(self.data.x+1, self.data.y , self.data.z, 'right')
    end

    if self.player.y < -margin then
        inContext(self.blackout_overlay:getImage(), function ()
            gfx.clear(gfx.kColorWhite)
        end)
        self.blackout_overlay:markDirty()
        goTo(self.data.x, self.data.y -1, self.data.z, 'up')
    end

    if self.player.y > self.playfield_height + margin then
        inContext(self.blackout_overlay:getImage(), function ()
            gfx.clear(gfx.kColorWhite)
        end)
        self.blackout_overlay:markDirty()
        goTo(self.data.x, self.data.y + 1, self.data.z, 'down')
    end

end

function System:initUI()

    self.blackout_overlay = gfx.sprite.new(gfx.image.new(400,240))
    self.blackout_overlay:moveTo(200, 120)
    self.blackout_overlay.no_zoom = true
    self.blackout_overlay:setIgnoresDrawOffset(true)
    self.blackout_overlay:setZIndex(self.player:getZIndex()+1)
    self.blackout_overlay:add()

    table.insert(self.sprites, self.blackout_overlay)

    --table.insert(self.sprites, FuelUI(self.player))
    
end

function System:moveCamera()

    local _cx = self.x_offset + playdate.display.getWidth()/2
    local _cy = self.y_offset + playdate.display.getHeight()/2

    local _nx = self.x_offset
    local _ny = self.y_offset

    if math.abs(_cx - self.player.x) > self.x_cam_loose  then
        _nx = self.player.x - playdate.display.getWidth()/2 + (self.x_cam_loose * (_cx - self.player.x)/math.abs(_cx - self.player.x))
    end
    if math.abs(_cy - self.player.y) > self.y_cam_loose  then
        _ny = self.player.y - playdate.display.getHeight()/2 + (self.y_cam_loose * (_cy - self.player.y)/math.abs(_cy - self.player.y))
    end
    
    _nx = playdate.math.lerp(self.x_offset, _nx, 0.5)
    _ny = playdate.math.lerp(self.y_offset, _ny, 0.5)

    self.x_offset = round(clamp(_nx , 0, self.playfield_width - playdate.display.getWidth()))
    self.y_offset = round(clamp(_ny , 0, self.playfield_height - playdate.display.getHeight()))

    if math.fmod(self.x_offset, 2) == 1 then
        self.x_offset += 1
    end

    if math.fmod(self.y_offset, 2) == 1 then
        self.y_offset += 1
    end

    gfx.setDrawOffset(-self.x_offset, -self.y_offset)

end

function System:getCameraRect()

    return pd.geometry.rect.new(self.x_offset, self.y_offset, 400, 240)

end

function System:getCurrentBg()

    local img = gfx.image.new(pd.display.getWidth(), pd.display.getHeight(), gfx.kColorBlack)
    local _offset_x, _offset_y = gfx.getDrawOffset()
    gfx.pushContext(img)
        self.bg_sprite:getImage():draw(_offset_x, _offset_y)
    gfx.popContext()

    return img

end

function System:initInputs()
    self.input_handlers = {

        cranked = function (change, acceleratedChange)
            if not g_SystemManager:canControl() then
                return
            end

            local ship_angle = self.player.angle
            ship_angle += change * self.player.rotation_modifier
		    self.player:setAngle(ship_angle)
        end,

        BButtonDown = function ()
            if not g_SystemManager:canControl() then
                return
            end
            self.player.move_ship = true
            g_SoundManager:playEngine()
        end,

        BButtonUp = function ()
            if not g_SystemManager:canControl() then
                return
            end
            self.player.move_ship = false
            g_SoundManager:stopEngine()
        end,

        upButtonUp = function ()
            --self:zoomIn()
        end,

        downButtonUp = function ()
            --self.player.move_ship = not self.player.move_ship 
            --g_SoundManager:playNotification()
            --self:zoomOut()
        end,

        leftButtonUp = function ()
            if not g_SystemManager:canControl() then
                return
            end
            g_SceneManager:pushScene(PlayerMenu(), 'to menu')
        end

    }
end

function System:zoomIn()

    self.zoom *= 2
    self.x_offset *= 2
    self.y_offset *= 2

    self.playfield_width *= 2
    self.playfield_height *= 2

    self.player.speed_vector *= 2

    for k, spr in pairs(self.sprites) do
        if not spr.no_zoom then
            spr:moveTo(spr.x*2, spr.y*2)
            spr:setScale(self.zoom)
            spr.zoom = self.zoom
            local _rect = spr:getCollideRect()
            spr:setCollideRect( _rect.x*2, _rect.y*2, _rect.width*2, _rect.height*2 )
            spr:markDirty()
        end
    end

    self:moveCamera()
    
end

function System:zoomOut()

    if self.playfield_width * 0.5 < 400 or self.playfield_height * 0.5 < 240 then
        return
    end

    self.zoom *= 0.5
    self.x_offset *= 0.5
    self.y_offset *= 0.5

    self.playfield_width *= 0.5
    self.playfield_height *= 0.5

    self.player.speed_vector *= 0.5

    for k, spr in pairs(self.sprites) do
        if not spr.no_zoom then
            spr:moveTo(spr.x*0.5, spr.y*0.5)
            spr:setScale(self.zoom)
            spr.zoom = self.zoom
            local _rect = spr:getCollideRect()
            spr:setCollideRect( _rect.x*0.5, _rect.y*0.5, _rect.width*0.5, _rect.height*0.5)
            spr:markDirty()
        end        
    end

    self:moveCamera()
    
end


function System:doUpdate()

    self.player:doUpdate()
    self:moveCamera()

    self:handleBorders()

    self:updateSelectionSprite()

    local collisions = self.player:overlappingSprites()

    if #collisions == 0 then
        self.selection_spr:setVisible(false)
        self.selection_focus = nil
    end

	for i = 1, #collisions do
        if collisions[i].interactuable then
            if not self.selection_focus then
                self:setSelectionSprite(collisions[i])
            end
            if pd.buttonJustReleased(pd.kButtonA) then
                self.selection_spr:setVisible(false)
                self.selection_focus = nil
                self.player:stop()
                collisions[i]:interact()
                break
            end
        end
	end
end

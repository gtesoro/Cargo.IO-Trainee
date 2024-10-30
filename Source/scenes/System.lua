local pd <const> = playdate
local gfx <const> = pd.graphics

class('System').extends(Scene)

function System:startScene()

    self.x_offset = 0
    self.y_offset = 0
    self.x_cam_loose = 50
    self.y_cam_loose = 30
    self.wrap = false

    self.selection_spr = gfx.sprite.new()
    self.selection_focus = nil
    
    self:initBg()
    self:initPlanets()
    self:initOrbits()
    self:initIU()
    self:initBorders()
    self:initAsteroids()
    self:initShip()

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
    
    self.selection_spr:setZIndex(self.data.playfield_height*2)
    self.selection_spr:moveTo(self.selection_focus:getPosition())

    self.selection_spr:add()

end

function System:updateSelectionSprite()

    if self.selection_focus  then
        self.selection_spr:moveTo(self.selection_focus:getPosition())
    end

end

function System:initShip()
    self.ship = Ship(self)
    self.ship:setZIndex(self.data.playfield_height*2+1)

    self.ship:moveTo(self.data.playfield_width/2-100, self.data.playfield_height/2)
    if g_player.last_position.x then
        local dx, dy, dz = self.data.x - g_player.last_position.x, self.data.y - g_player.last_position.y, self.data.z - g_player.last_position.z
        if math.abs(dx) + math.abs(dy) + math.abs(dz) == 1 then
            if dx > 0 then
                self.ship:moveTo(50, self.data.playfield_height/2)
                self.ship:setRotation(90)
            end

            if dx < 0 then
                self.ship:moveTo(self.data.playfield_width - 50, self.data.playfield_height/2)
                self.ship:setRotation(270)
            end

            if dy > 0 then
                self.ship:moveTo(self.data.playfield_width/2, 50)
                self.ship:setRotation(180)
            end

            if dy < 0 then
                self.ship:moveTo(self.data.playfield_width/2, self.data.playfield_height - 50)
            end
        end
    end

    self.sprites[#self.sprites+1] = self.ship
end

function System:initBg()

    local img = gfx.image.new(self.data.playfield_width, self.data.playfield_height)
    local bg = gfx.image.new(self.data.background) -- :blurredImage(0.5, 2, gfx.image.kDitherTypeScreen)

    scaleAndCenterImage(bg, img)

    self.bg_sprite = gfx.sprite.new(img)
    self.bg_sprite:moveTo(self.data.playfield_width/2, self.data.playfield_height/2)
    self.bg_sprite:setZIndex(0)

    self.sprites[#self.sprites+1] = self.bg_sprite

end

function System:initPlanets() 
    self.planets = {}

    if self.data.planets then
        for k,v in pairs(self.data.planets) do
            local p = Planet(v.img, v.orbit_size, self.data.angle, v.speed, math.random(0, 360), self.data.playfield_width, self.data.playfield_height, v.outline)
            self.planets[#self.planets+1] = p
            self.sprites[#self.sprites+1] = p
            v.sprite = p
        end
    end

    if self.data.sun then
        self.sun = AnimatedSprite(self.data.sun)
        self.sun:moveTo(self.data.playfield_width/2, self.data.playfield_height/2)

        self.sprites[#self.sprites+1] = self.sun
    end

end

function System:initBorders()

    local speed = 50
    self.arrow_y = 0

    local spr = AnimatedSprite("assets/border",speed)
    spr:moveTo(pd.display.getWidth()/2, spr.height/2)
    spr:setIgnoresDrawOffset(true)
    spr:setZIndex(2)
    spr:setCollideRect( 0, 0, spr:getSize() )
    self.sprites[#self.sprites+1] = spr
    self.up = spr

    spr = AnimatedSprite("assets/border",speed)
    spr:moveTo(pd.display.getWidth()/2, pd.display.getHeight() - spr.height/2)
    spr:setRotation(180)
    spr:setIgnoresDrawOffset(true)
    spr:setZIndex(2)
    spr:setCollideRect( 0, 0, spr:getSize() )
    self.sprites[#self.sprites+1] = spr
    self.down = spr

    spr = AnimatedSprite("assets/border",speed)
    spr:moveTo(spr.height/2, pd.display.getHeight()/2)
    spr:setRotation(270)
    spr:setIgnoresDrawOffset(true)
    spr:setZIndex(2)
    spr:setCollideRect( 0, 0, spr:getSize() )
    self.sprites[#self.sprites+1] = spr
    self.left = spr

    spr = AnimatedSprite("assets/border",speed)
    spr:moveTo(pd.display.getWidth() - spr.height/2, pd.display.getHeight()/2)
    spr:setRotation(90)
    spr:setIgnoresDrawOffset(true)
    spr:setZIndex(2)
    spr:setCollideRect( 0, 0, spr:getSize() )
    self.sprites[#self.sprites+1] = spr
    self.right = spr

    self.up:setVisible(false)
    self.down:setVisible(false)
    self.left:setVisible(false)
    self.right:setVisible(false)

end

function System:handleBorders()

    local margin = 40

    self.up:setVisible(false)
    self.down:setVisible(false)
    self.left:setVisible(false)
    self.right:setVisible(false)

    if self.ship.x < margin then
        self.left:setVisible(true)
        if pd.buttonJustPressed(pd.kButtonA) then
            goTo(self.data.x-1, self.data.y , self.data.z)
        end
    end

    if self.ship.x > self.data.playfield_width - margin then
        self.right:setVisible(true)
        if pd.buttonJustPressed(pd.kButtonA) then
            goTo(self.data.x+1, self.data.y , self.data.z)
        end
    end

    if self.ship.y < margin then
        self.up:setVisible(true)
        if pd.buttonJustPressed(pd.kButtonA) then
            goTo(self.data.x, self.data.y -1, self.data.z)
        end
    end

    if self.ship.y > self.data.playfield_height - margin then
        self.down:setVisible(true)
        if pd.buttonJustPressed(pd.kButtonA) then
            goTo(self.data.x, self.data.y + 1, self.data.z)
        end
    end

end

function System:moveArrows()
    self.arrow_y += 0.5
    if self.arrow_y > self.arrow_img.height then
        self.arrow_y = 0
    end
    gfx.pushContext(self.arrow_canvas)
        gfx.clear()
        gfx.setColor(playdate.graphics.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRect(0,0, self.arrow_canvas:getSize())
        self.arrow_img:drawAnchored(self.arrow_canvas.width/2, self.arrow_canvas.height/2 - self.arrow_y, 0.5, 0.5)
        self.arrow_img:drawAnchored(self.arrow_canvas.width/2, self.arrow_canvas.height + self.arrow_canvas.height/2 - self.arrow_y, 0.5, 0.5)
    gfx.popContext()
end

function System:initOrbits() 
    self.orbits_sprite = gfx.sprite.new(gfx.image.new(self.data.playfield_width, self.data.playfield_height))
    local img = self.orbits_sprite:getImage()
    gfx.pushContext(img)

        gfx.setColor(playdate.graphics.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.setLineWidth(2)
        for k, p in pairs(self.planets) do
            
            gfx.drawEllipseInRect(p.cx - p.h_radius, p.cy - p.v_radius, 2 * p.h_radius, 2 * p.v_radius)
            --drawDottedEllipse(p.cx , p.cy, p.h_radius, p.v_radius, math.floor(p.h_radius/self.data.playfield_width * 1000), 3, 0)
        end
    gfx.popContext()
    self.orbits_sprite:moveTo(self.data.playfield_width/2, self.data.playfield_height/2)
    self.orbits_sprite:setZIndex(1)

    self.sprites[#self.sprites+1] = self.orbits_sprite
end

function System:initAsteroids()

    local scale_factor = 0.15

    if self.data.asteroids then     
        for k,v in pairs(self.data.asteroids) do
            local spr = gfx.sprite.new(gfx.image.new(v.img))
            local _x, _y = math.random(math.floor(self.data.playfield_width*0.3), math.floor(self.data.playfield_width*0.7)),
                           math.random(math.floor(self.data.playfield_height*0.3), math.floor(self.data.playfield_height*0.7))
                   
            spr:moveTo(_x, _y)
            spr:setZIndex(1900)
            
            spr:setRotation(math.random(0, 359))
            spr:setCollideRect( 0, 0, spr:getSize() )
            
            v.sprite = spr
            v.linear_speed = math.random(20,100)/250
            v.angular_speed = math.random(0,100)/1000
            v.rotation = math.random(0,359)
            spr:setRotation(v.rotation)
            self.sprites[#self.sprites+1] = spr
        end
    end
end

function System:moveAsteroids()
    if self.data.asteroids then
        for k,v in pairs(self.data.asteroids) do
            local spr = v.sprite

            if spr.y < 0 or spr.y > self.data.playfield_height then
                v.rotation = 180 - v.rotation
            end
    
            if spr.x < 0 or spr.x > self.data.playfield_width then
                v.rotation = 360 - v.rotation
            end

            v.rotation += v.angular_speed
            v.rotation = math.fmod(v.rotation, 360)
            v.move_vector = pd.geometry.vector2D.newPolar(v.linear_speed, v.rotation)
            spr:moveBy(v.move_vector.x, v.move_vector.y)
        end
    end
end

function System:initIU()


    
end

function System:moveCamera()

    local _cx = self.x_offset + playdate.display.getWidth()/2
    local _cy = self.y_offset + playdate.display.getHeight()/2

    local _nx = self.x_offset
    local _ny = self.y_offset

    if math.abs(_cx - self.ship.x) > self.x_cam_loose  then
        _nx = self.ship.x - playdate.display.getWidth()/2 + (self.x_cam_loose * (_cx - self.ship.x)/math.abs(_cx - self.ship.x))
    end
    if math.abs(_cy - self.ship.y) > self.y_cam_loose  then
        _ny = self.ship.y - playdate.display.getHeight()/2 + (self.y_cam_loose * (_cy - self.ship.y)/math.abs(_cy - self.ship.y))
    end
    
    _nx = playdate.math.lerp(self.x_offset, _nx, 0.5)
    _ny = playdate.math.lerp(self.y_offset, _ny, 0.5)

    self.x_offset = round(clamp(_nx , 0, self.data.playfield_width - playdate.display.getWidth()))
    self.y_offset = round(clamp(_ny , 0, self.data.playfield_height - playdate.display.getHeight()))

    if math.fmod(self.x_offset, 2) == 1 then
        self.x_offset += 1
    end

    if math.fmod(self.y_offset, 2) == 1 then
        self.y_offset += 1
    end

    gfx.setDrawOffset(-self.x_offset, -self.y_offset)

end

function System:getCurrentBg()

    local img = gfx.image.new(pd.display.getWidth(), pd.display.getHeight())
    local _offset_x, _offset_y = gfx.getDrawOffset()
    gfx.pushContext(img)
        self.bg_sprite:getImage():draw(_offset_x, _offset_y)
    gfx.popContext()

    return img

end

function System:checkBoundaries(spr, wrap)

    local _s_x = spr.x
    local _s_y = spr.y

    if wrap then
		if _s_x < 0 then
			_s_x = self.data.playfield_width
		end
		if _s_x > self.data.playfield_width then
			_s_x  = 0
		end
	
		if _s_y < 0 then
			_s_y = self.data.playfield_height 
		end
		if _s_y > self.data.playfield_height then
			_s_y = 0
		end
        spr:moveTo(_s_x, _s_y)
	else
        if _s_y < 0 or _s_y > self.data.playfield_height then
            spr.speed_vector.y *= -1
            spr.speed_vector /= 2
        end

        if _s_x < 0 or _s_x > self.data.playfield_width then
            spr.speed_vector.x *= -1
            spr.speed_vector /= 2
        end

        if _s_x < 0 then
			_s_x = 0
		end
		if _s_x > self.data.playfield_width then
			_s_x  = self.data.playfield_width
		end
	
		if _s_y < 0 then
			_s_y = 0
		end
		if _s_y > self.data.playfield_height then
			_s_y = self.data.playfield_height 
		end
        spr:moveTo(_s_x, _s_y)

    end

end

function System:update()

    self:moveCamera()

    if g_SceneManager.transitioning then
        return
    end     

    self:moveAsteroids()
    self:handleBorders()
    self:checkBoundaries(self.ship, self.wrap)

    checkAndOpenInventory()

    self:updateSelectionSprite()

    local collisions = self.ship:overlappingSprites()

    if #collisions == 0 then
        self.selection_spr:remove()
        self.selection_focus = nil
    end

	for i = 1, #collisions do
        self:setSelectionSprite(collisions[i])
        if pd.buttonJustReleased(playdate.kButtonA) then   
            if self.data.planets then
                for k,v in pairs(self.data.planets) do
                    if v.sprite == collisions[i] then
                        g_SceneManager:pushScene(PlanetCard(v), 'hwipe')
                        break
                    end
                end
            end
            if self.data.asteroids then
                for k,v in pairs(self.data.asteroids) do
                    if v.sprite == collisions[i] then
                        v.bg_img = self:getCurrentBg()
                        g_SceneManager:pushScene(MiningLaser(v), 'hwipe')
                        break
                    end
                end
            end
        end
	end   

    self.ship:doUpdate()

    for k,v in pairs(self.planets) do
        v:doUpdate()
    end
end

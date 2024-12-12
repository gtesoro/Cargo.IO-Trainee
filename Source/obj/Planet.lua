local gfx <const> = playdate.graphics

class('Planet').extends(playdate.graphics.sprite)

function Planet:init(image_table, orbit_size, tilt, speed, angle, playfield_width, playfield_height, outline)

    self.MAX_DOTS = 10
    self.countdown = 3

    self.size = size
    self.outline = outline
    self.orbit_size = orbit_size
    self.h_radius = orbit_size
    self.v_radius = orbit_size*tilt
    self.cx = playfield_width/2
    self.cy = playfield_height/2
    self.speed = speed
    self.angle = angle

    self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

    self.playfield_width = playfield_width
    self.playfield_height = playfield_height

    self.imageTable =  gfx.imagetable.new(image_table)
    self.animation = gfx.animation.loop.new(100, self.imageTable, true)

    self.image = gfx.image.new(self.imageTable:getImage(1):getSize())

    gfx.pushContext(self.image)
        gfx.clear()
        self.animation:draw(0,0)
        if self.outline then
            gfx.setColor(playdate.graphics.kColorWhite)
            gfx.setLineWidth(1)
            gfx.drawCircleAtPoint(self.image.width/2, self.image.height/2, self.image.width/2 )
        end
    gfx.popContext()

    local x = self.cx  + self.h_radius * math.cos(self.angle)
    local y = self.cy + self.v_radius * math.sin(self.angle)

    self:moveTo(x, y)

    self:setImage(self.image)   

	self:setZIndex(y + 1000)
    self:setCollideRect( 0, 0, self:getSize() )

end

function Planet:add()
    self.animation.paused = false
    Planet.super.add(self)
end

function Planet:remove()
    self.animation.paused = true
    Planet.super.remove(self)
end

function Planet:doUpdate()

    self:setZIndex(self.y + 1000)

    self.angle = (self.angle + self.speed * (2 * math.pi/50)/60)

    self.angle = math.fmod(self.angle, 2 * math.pi)

    local x = self.cx  + self.h_radius * math.cos(self.angle)
    local y = self.cy + self.v_radius * math.sin(self.angle)

    x = playdate.math.lerp(self.x, x, 0.5)
    y = playdate.math.lerp(self.y, y, 0.5)

    self:moveTo(math.floor(x), math.floor(y))

    gfx.pushContext(self.image)
        gfx.clear()
        self.animation:draw(0,0)
        if self.outline then
            gfx.setColor(playdate.graphics.kColorWhite)
            gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
            gfx.setLineWidth(2)
            gfx.drawCircleAtPoint(self.width/2, self.height/2, self.width/2 - 1)
        end
        
    gfx.popContext()

    --self:setImage(self.animation:image())

end
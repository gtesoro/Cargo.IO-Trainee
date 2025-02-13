local gfx <const> = playdate.graphics

class('Planet').extends(AnimatedSprite)

function Planet:init(planet_data, image_table, orbit_size, tilt, speed, angle, outline, playfield_width, playfield_height)

    Planet.super.init(self, image_table, 100)

    self.location_data = planet_data

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

    self.zoom = 1

    self.interactuable = true

    self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

    self.playfield_width = playfield_width
    self.playfield_height = playfield_height

    self.imageTable =  gfx.imagetable.new(image_table)
    self.animation = gfx.animation.loop.new(100, self.imageTable, true)

    local x = self.cx  + self.h_radius * math.cos(self.angle)
    local y = self.cy + self.v_radius * math.sin(self.angle)

    self:moveTo(x, y)

	self:setZIndex(y + 1000)
    self:setCollideRect( 0, 0, self:getSize() )

end

function Planet:interact()
    g_SceneManager:pushScene(LocationMenu(self.location_data), 'to menu')
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

    self.angle = (self.angle + self.speed * self:getScale() * (2 * math.pi/50)/60)

    self.angle = math.fmod(self.angle, 2 * math.pi)

    local x = (self.cx + self.h_radius * math.cos(self.angle)) * self:getScale()
    local y = (self.cy + self.v_radius * math.sin(self.angle)) * self:getScale()

    x = playdate.math.lerp(self.x, x, 0.5)
    y = playdate.math.lerp(self.y, y, 0.5)

    self:moveTo(math.floor(x), math.floor(y))

end
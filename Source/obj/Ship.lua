local gfx <const> = playdate.graphics

class('Ship').extends(playdate.graphics.sprite)

function Ship:init()

    self.image = playdate.graphics.image.new("assets/ship2")
    self:setImage(self.image)

	self.max_speed = 8
    self.acceleration = 0.1
    self.rotation_modifier = 1
	self.friction = 0.01

	self.collisionResponse = gfx.sprite.kCollisionTypeOverlap    
	self.speed_vector = playdate.geometry.vector2D.new(0,0)
	self:setCollideRect( 0, 0, self:getSize() )

end


function Ship:doUpdate()
    

    local shipX, shipY = self:getPosition()

	local crankChange = playdate.getCrankChange()
	local shipAngle = self:getRotation()

	self.speed_vector = self.speed_vector - (self.speed_vector * self.friction)

	shipX += self.speed_vector.x 
	shipY += self.speed_vector.y 

	x = playdate.math.lerp(self.x, shipX, 0.5)
    y = playdate.math.lerp(self.y, shipY, 0.5)

	self:moveTo(x, y)

end




local gfx <const> = playdate.graphics

class('Ship').extends(playdate.graphics.sprite)

function Ship:init()

    self.image = playdate.graphics.image.new("assets/ship2")
    self:setImage(self.image)

	self.max_speed = 100
    self.acceleration = 0.1
    self.rotation_modifier = 0.3
	self.friction = 0.01

	self.collisionResponse = gfx.sprite.kCollisionTypeOverlap    
	self.speed_vector = playdate.geometry.vector2D.new(0,0)
	self.max_fuel = 100
	self.fuel = self.max_fuel
	self.fuel_per_frame = 1
	self.fuel_recovery = 1

	self.loaded = false
	self:setCollideRect( 0, 0, self:getSize() )

end


function Ship:doUpdate()
    

    local shipX, shipY = self:getPosition()

	local crankChange = playdate.getCrankChange()
	local shipAngle = self:getRotation()

	self.speed_vector = self.speed_vector - (self.speed_vector * self.friction)

	if not playdate.isCrankDocked() then
		shipAngle += crankChange * self.rotation_modifier
		self:setRotation(shipAngle)
	end

	if playdate.buttonIsPressed(playdate.kButtonB) and self.speed_vector:magnitude() < self.max_speed then
		self.speed_vector += playdate.geometry.vector2D.newPolar(self.acceleration , shipAngle)
		self.fuel -= self.fuel_per_frame
	end

	if not playdate.buttonIsPressed(playdate.kButtonB) then
		self.fuel += self.fuel_recovery
	end

	shipX += self.speed_vector.x 
	shipY += self.speed_vector.y 

	x = playdate.math.lerp(self.x, shipX, 0.5)
    y = playdate.math.lerp(self.y, shipY, 0.5)

	self:moveTo(x, y)

end




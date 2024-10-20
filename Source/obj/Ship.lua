import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"


local gfx <const> = playdate.graphics

class('Ship').extends(playdate.graphics.sprite)

function Ship:init(stage)
	self.stage = stage
    self.image = playdate.graphics.image.new("sprites/ship2")
    self:setImage(self.image)

	self.wrap = false

	self.collisionResponse = gfx.sprite.kCollisionTypeBounce
    
	self:setCollideRect( 0, 0, self:getSize() )
	self.shipVector = playdate.geometry.vector2D.new(0,0)
	self.max_fuel = 100
	self.fuel = self.max_fuel
	self.fuel_per_frame = 1
	self.fuel_recovery = 1

	self:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)

	self.loaded = false
	self:setCollideRect( 0, 0, self:getSize() )

end

function Ship:scale()

	local SCALE_FACTOR <const> = 1.2

	local ratio = self.y / playdate.display.getHeight() * SCALE_FACTOR + 0.3
	self:setScale(ratio)
	self:setCollideRect( 0, 0, self:getSize() )

end

function Ship:doUpdate()

	
	-- local _x, _y  = self.x, self.y
	-- local _was_x, _was_y = _x, _y

	-- if playdate.buttonIsPressed(playdate.kButtonUp) then
	-- 	_y -= 1
	-- end

	-- if playdate.buttonIsPressed(playdate.kButtonDown) then
	-- 	_y += 1
	-- end

	-- if playdate.buttonIsPressed(playdate.kButtonLeft) then
	-- 	_x -= 1
	-- end

	-- if playdate.buttonIsPressed(playdate.kButtonRight) then
	-- 	_x += 1
	-- end

	-- local _a_x, _a_y, col, col_len = self:moveWithCollisions(_x, _y)

	-- if col_len > 0 then
	-- 	for k, v in pairs(col) do
	-- 		print("P", _was_x, _was_y, 'T', _x, _y, "R", _a_x, _a_y, "Diff", _a_x -_x, _a_y - _y, "Planet", v.other.x, v.other.y, v.other.angle, "Overlap", v.overlaps, "Type", v.type)
	-- 		print("Touch", v.touch, v.spriteRect, v.otherRect )
	-- 		self.last_col_rect = v.spriteRect
	-- 		self.last_col_rect_othert = v.otherRect
	-- 		break
	-- 	end
	-- end

    MAX_SPEED = 100
    ACCELERATION = 0.1
    ROTATION_MODIFIER = 0.3
	FRICTION = 0.01

    local shipX, shipY = self:getPosition()

	local crankChange = playdate.getCrankChange()
	local shipAngle = self:getRotation()

	self.shipVector = self.shipVector - (self.shipVector * FRICTION)

	if not playdate.isCrankDocked() then
		shipAngle += crankChange * ROTATION_MODIFIER
		self:setRotation(shipAngle)
	end

	if playdate.buttonIsPressed(playdate.kButtonB) and self.shipVector:magnitude() < MAX_SPEED then
		self.shipVector += playdate.geometry.vector2D.newPolar(ACCELERATION, shipAngle)
		self.fuel -= self.fuel_per_frame
	end

	if not playdate.buttonIsPressed(playdate.kButtonB) then
		self.fuel += self.fuel_recovery
	end

	shipX += self.shipVector.x 
	shipY += self.shipVector.y 

	x = playdate.math.lerp(self.x, shipX, 0.5)
    y = playdate.math.lerp(self.y, shipY, 0.5)

	self:moveWitTo(x, y)

    -- local _a_x, _a_y, col, col_len = self:moveWithCollisions(shipX, shipY)

	-- if col_len > 0 then
	-- 	for k, v in pairs(col) do
	-- 		self.shipVector = v.normal * self.shipVector:magnitude()
	-- 		break
	-- 	end
	-- end

end

function Ship:load()
	self.image = playdate.graphics.image.new("sprites/ship_loaded2")
	self:setImage(self.image)
	self.loaded = true
end

function Ship:unload()
	self.image = playdate.graphics.image.new("sprites/ship2")
	self:setImage(self.image)
	self.loaded = false
end


local pd <const> = playdate
local gfx <const> = pd.graphics

class('Ship').extends(gfx.sprite)

function Ship:init()

	self.sheet = gfx.imagetable.new('assets/ship')
	assert(self.sheet)
    self:setImage(self.sheet:getImage(1))

	self.max_speed = 12
    self.acceleration = 0.075
    self.rotation_modifier = 1
	self.friction = 0.01

	self.fuel_enabled =  true
	self.fuel_usage = g_SystemManager:getPlayer().ship.fuel_usage

	self.angle = 0
	self.move_ship = false
	self.booster_table = gfx.imagetable.new('assets/booster')
	self.bosster_offset_x = 0
	self.bosster_offset_y = 12
	self.particle_tick = 2
	function self:collisionResponse(other)
		print('Colliding with solid response', self.className, other.className)
		if other.solid then
			return gfx.sprite.kCollisionTypeBounce
		else
			return gfx.sprite.kCollisionTypeOverlap
		end
	end
	self.speed_vector = playdate.geometry.vector2D.new(0,0)
	self:setCollideRect( self.width*0.35, self.height*0.35, self.width*0.25, self.height*0.25 )

end

function Ship:add()
	Ship.super.add(self)
end

function Ship:remove()
	Ship.super.remove(self)
	
end

function Ship:setZIndex(z)
	Ship.super.setZIndex(self, z)	
end

function Ship:stop()
	self.speed_vector = playdate.geometry.vector2D.new(0,0)
end

function Ship:updateImg()
	self:setImage(self.sheet:getImage(math.floor(self.angle) + 1))
end


function Ship:setAngle(angle)
	
	local _new_angle =  math.fmod(angle, 359)
	if _new_angle < 0 then
		_new_angle += 359
	end
	if _new_angle ~= self.angle then
		self.angle = _new_angle
		self:updateImg()
	end
	
end

function Ship:doUpdate()

	if g_SceneManager.transitioning then
		return
	end

	if self.move_ship and g_SystemManager:getPlayer().ship.fuel_current > 0 then
		if self.speed_vector:magnitude() < self.max_speed then
        	self.speed_vector += pd.geometry.vector2D.newPolar(self.acceleration  , self.angle)
		end
		for _, breakpoint in  pairs({25, 50, 75}) do
			if g_SystemManager:getPlayer().ship.fuel_current - self.fuel_usage < breakpoint and g_SystemManager:getPlayer().ship.fuel_current > breakpoint then 
				g_NotificationManager:notify(string.format('Fuel <%i%%', breakpoint))
			end
		end
		g_SystemManager:getPlayer().ship.fuel_current -= self.fuel_usage
    end

	local shipX, shipY = self:getPosition()

	--self.speed_vector = self.speed_vector - (self.speed_vector * self.friction)
	self.speed_vector *= (1 - self.friction)


	shipX += self.speed_vector.x
	shipY += self.speed_vector.y

	x = playdate.math.lerp(self.x, shipX, 0.5)
    y = playdate.math.lerp(self.y, shipY, 0.5)

	local _a_x, _a_y, _collisions, _len = self:moveWithCollisions(x, y)
	if _len > 0 then
		for k,col in pairs(_collisions) do
			print('Colliding with solid', col.other.solid)
			if col.other.solid then
				self.speed_vector = (self.speed_vector - (col.normal * (2*(self.speed_vector*col.normal)))) * 0.5
				break
			end
		end
	end

	if self.move_ship then
		local _x, _y = getRelativePoint(self.x, self.y, self.bosster_offset_x, self.bosster_offset_y, self.angle)
		if g_SystemManager:isTick(self.particle_tick) then
			Particle(self.booster_table, _x, _y, 100)
		end
	end

end




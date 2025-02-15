local pd <const> = playdate
local gfx <const> = pd.graphics

class('Player').extends(gfx.sprite)

function Player:init()

	self.fuel_enabled =  true
	self.fuel_usage = g_SystemManager:getPlayerData().ship.fuel_usage

	self.angle = 0
	self.move_ship = false
	
	self.particle_tick = 2
	function self:collisionResponse(other)
		if other.solid then
			return gfx.sprite.kCollisionTypeBounce
		else
			return gfx.sprite.kCollisionTypeOverlap
		end
	end

	self:setShip()

end

function Player:setShip()

	self.ship = SHIP_BASE
	self.sheet = gfx.imagetable.new('assets/ship')

	self.booster_table = gfx.imagetable.new('assets/booster')
	self.bosster_offset_x = 0
	self.bosster_offset_y = 16

	self.max_speed = 12
    self.acceleration = 0.075
    self.rotation_modifier = 1
	self.friction = 0.01

	local _collide_percentage = 0.7

	self:updateImg()
	local _w, _h = self:getSize()
	self:setCollideRect( _w*(1-_collide_percentage)/2, _h*(1-_collide_percentage)/2, _w*_collide_percentage, _h*_collide_percentage)

	self.speed_vector = playdate.geometry.vector2D.new(0,0)
	
end

function Player:setEVA()

	self.ship = SHIP_EVA

	self.bosster_offset_x = 0
	self.bosster_offset_y = 4

	self.booster_table = gfx.imagetable.new('assets/booster_eva')

	self.eva_sheets = {
		gfx.imagetable.new('assets/eva_left'),
		gfx.imagetable.new('assets/eva'),
		gfx.imagetable.new('assets/eva_right')
	}

	self.eva_sheet = 2
	self.sheet = self.eva_sheets[self.eva_sheet]

	self.max_speed = 4
    self.acceleration = 0.01
    self.rotation_modifier = 1
	self.friction = 0.00

	local _collide_percentage = 0.5

	self:updateImg()
	local _w, _h = self:getSize()
	self:setCollideRect( _w*(1-_collide_percentage)/2, _h*(1-_collide_percentage)/2, _w*_collide_percentage, _h*_collide_percentage)

	self.speed_vector = playdate.geometry.vector2D.new(0,0)
	
end

function Player:add()
	Player.super.add(self)
end

function Player:remove()
	Player.super.remove(self)
	
end

function Player:setZIndex(z)
	Player.super.setZIndex(self, z)	
end

function Player:stop()
	self.speed_vector = playdate.geometry.vector2D.new(0,0)
end

function Player:updateImg()
	self:setImage(self.sheet:getImage(self.angle + 1))
end


function Player:setAngle(angle)

	_new_angle = math.floor(angle)

	if self.ship == SHIP_EVA then
		if _new_angle - self.angle > 3 then
			self.sheet = self.eva_sheets[3]	
		elseif _new_angle - self.angle < -3 then
			self.sheet = self.eva_sheets[1]
		else 
			self.sheet = self.eva_sheets[2]
		end
	end

	local _new_angle =  math.fmod(_new_angle, 359)
	if _new_angle < 0 then
		_new_angle += 359
	end	

	self.angle = _new_angle
		
	self:updateImg()
end

function Player:doUpdate()

	if g_SceneManager.transitioning then
		return
	end

	if self.move_ship and g_SystemManager:getPlayerData().ship.fuel_current > 0 then
		
        self.speed_vector += pd.geometry.vector2D.newPolar(self.acceleration * self:getScale(), self.angle)
		for _, breakpoint in  pairs({25, 50, 75}) do
			if g_SystemManager:getPlayerData().ship.fuel_current - self.fuel_usage < breakpoint and g_SystemManager:getPlayerData().ship.fuel_current > breakpoint then 
				g_NotificationManager:notify(string.format('Fuel <%i%%', breakpoint))
			end
		end
		g_SystemManager:getPlayerData().ship.fuel_current -= self.fuel_usage

		if self.speed_vector:magnitude() > self.max_speed then
			self.speed_vector:normalize()
			self.speed_vector *= self.max_speed
		end
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
			if col.other.solid then
				self.speed_vector = (self.speed_vector - (col.normal * (2*(self.speed_vector*col.normal)))) * 0.5
				break
			end
		end
	end

	if self.move_ship then
		local _x, _y = getRelativePoint(self.x, self.y, self.bosster_offset_x, self.bosster_offset_y, self.angle)
		if g_SystemManager:isTick(self.particle_tick) then
			local _p = Particle(self.booster_table, _x, _y, 100)
			_p:setZIndex(self:getZIndex())
		end
	end

end




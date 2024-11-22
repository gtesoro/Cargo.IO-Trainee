local pd <const> = playdate
local gfx <const> = pd.graphics

class('Enemy').extends(Ship)

function Enemy:init(player)

	Enemy.super.init(self)

	self.sheet = gfx.imagetable.new('assets/enemy')
	assert(self.sheet)
    self:setImage(self.sheet:getImage(1))
	self:setCollideRect( 0, 0, self:getSize() )

	self.max_speed = 10
    self.acceleration = 0.1
    self.rotation_modifier = 1
	self.friction = 0.01
	
	self.boost_power = 100
	self.current_boost = self.boost_power
	self.boost_usage_rate = 0.5
	self.boost_regen = 2

	self.activation_radius = 150

	self.move_ship = false

	self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
	self.speed_vector = playdate.geometry.vector2D.new(0,0)

	self.player = player

	self.hunting_timer = nil
	

end

function Enemy:hunting()

	self.max_speed = 10
	self.acceleration = 0.1
	

	self.hunting_timer = pd.timer.new(5000)

	self.hunting_timer.timerEndedCallback = function (timer)
		self.hunting_timer = nil
	end

	if g_SystemManager:isTick(2) then
		local _target_x, target_y = getRelativePoint(self.player.x, self.player.y, 0, 30, self.player.angle)
		local _target_vector = pd.geometry.vector2D.new(self.player.x + self.player.speed_vector.x - self.x, self.player.y + self.player.speed_vector.y - self.y)
		self:setAngle(-_target_vector:angleBetween(pd.geometry.vector2D.new(0,-1)))
	end

	if self.current_boost < self.boost_power/2 then
		self.move_ship = false
	else
		self.move_ship = true
	end
end

function Enemy:wandering()

	self.max_speed = 1
	self.acceleration = 0.025

	if g_SystemManager:isTick(50) then
		self:setAngle(self.angle + math.random(-5, 5))
	end

	if self.current_boost < self.boost_power * .8 then
		self.move_ship = false
	else
		self.move_ship = true
	end
end

function Enemy:applyAI()

	local _p = pd.geometry.point.new(self.player.x, self.player.y)
	
	if _p:distanceToPoint(pd.geometry.point.new(self:getPosition())) > self.activation_radius and self.hunting_timer == nil then
		self:wandering()
	else
		self:hunting()
	end

end

function Enemy:update()

	self:applyAI()
	Enemy.super.update(self)

end




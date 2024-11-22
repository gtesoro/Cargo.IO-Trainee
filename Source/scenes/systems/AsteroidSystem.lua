local pd <const> = playdate
local gfx <const> = pd.graphics

class('AsteroidSystem').extends(System)

function AsteroidSystem:startScene()

    AsteroidSystem.super.startScene(self)

    self:initAsteroids()

end

function AsteroidSystem:initAsteroids()

    local scale_factor = 0.15

    if self.data.asteroid_count then     
        self.asteroids = {}
        for i=0,self.data.asteroid_count do
            local v = {}
            local spr = gfx.sprite.new(gfx.image.new("assets/asteroids/a_map_1"))
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

            self.asteroids[#self.asteroids+1] = v
            self.sprites:append(spr)
        end
    end
end

function AsteroidSystem:moveAsteroids()
    if self.asteroids then
        for k,v in pairs(self.asteroids) do
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

function AsteroidSystem:doUpdate()

    AsteroidSystem.super.doUpdate(self)
    
    self:moveAsteroids()

    local collisions = self.ship:overlappingSprites()

    if #collisions == 0 then
        self.selection_spr:remove()
        self.selection_focus = nil
    end

	for i = 1, #collisions do
        self:setSelectionSprite(collisions[i])
        if pd.buttonJustReleased(playdate.kButtonA) then
            self.selection_spr:remove()
            self.selection_focus = nil
            if self.asteroids then
                for k,v in pairs(self.asteroids) do
                    if v.sprite == collisions[i] then
                        g_SceneManager:pushScene(MiningLaser({bg_img = self:getCurrentBg()}), 'hwipe')
                        
                        self.sprites:remove(v.sprite)

                        v.sprite:remove()
                        self.asteroids[k] = nil

                        break
                    end
                end
            end
        end
	end   
end

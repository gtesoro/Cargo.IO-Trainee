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
            
            spr.linear_speed = math.random(20,100)/250
            spr.angular_speed = math.random(0,100)/1000
            spr.rotation = math.random(0,359)
            spr:setRotation(spr.rotation)

            spr.interactuable = true
            local _self = self
            function spr:interact()
                g_SceneManager:pushScene(MiningLaser({bg_img = _self:getCurrentBg()}), 'wipe down')
                        
                table_remove(_self.sprites, spr)
                table_remove(_self.asteroids, spr)
                spr:remove()

            end
            table.insert(self.asteroids, spr)
            table.insert(self.sprites, spr)
        end
    end
end

function AsteroidSystem:moveAsteroids()
    if self.asteroids then
        for k,asteroid in pairs(self.asteroids) do

            if asteroid.y < 0 or asteroid.y > self.data.playfield_height then
                asteroid.rotation = 180 - asteroid.rotation
            end
    
            if asteroid.x < 0 or asteroid.x > self.data.playfield_width then
                asteroid.rotation = 360 - asteroid.rotation
            end

            asteroid.rotation += asteroid.angular_speed
            asteroid.rotation = math.fmod(asteroid.rotation, 360)
            asteroid.move_vector = pd.geometry.vector2D.newPolar(asteroid.linear_speed, asteroid.rotation)
            asteroid:moveBy(asteroid.move_vector.x, asteroid.move_vector.y)
        end
    end
end

function AsteroidSystem:doUpdate()
    
    self:moveAsteroids()

    AsteroidSystem.super.doUpdate(self)
    

    -- local collisions = self.ship:overlappingSprites()

    -- if #collisions == 0 then
    --     self.selection_spr:remove()
    --     self.selection_focus = nil
    -- end
    -- local _collided = false
	-- for i = 1, #collisions do
    --     if _collided then
    --         break
    --     end
    --     self:setSelectionSprite(collisions[i])
    --     if pd.buttonJustReleased(playdate.kButtonA) then
    --         self.selection_spr:remove()
    --         self.selection_focus = nil
    --         if self.asteroids then
    --             for k,v in pairs(self.asteroids) do
    --                 if v.sprite == collisions[i] then
                        
    --                     g_SceneManager:pushScene(MiningLaser({bg_img = self:getCurrentBg()}), 'wipe down')
                        
    --                     table_remove(self.sprites, v.sprite)

    --                     v.sprite:remove()
    --                     self.asteroids[k] = nil
    --                     _collided = true
    --                     break
    --                 end
    --             end
    --         end
    --     end
	-- end   
end

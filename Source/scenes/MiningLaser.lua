import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "CoreLibs/animator"
import "CoreLibs/sprites"
import "CoreLibs/math"

import "scenes/scene"
import "tools/tools"

import "CoreLibs/crank"

import "obj/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('MiningLaser').extends(Scene)

function MiningLaser:startScene()

    self:initBg()
    self:initAsteroid()
    self:initLaser()
    self:initMinerals()

end

function MiningLaser:initBg() 

    self.bg_sprite = gfx.sprite.new(gfx.image.new("sprites/asteroid_bg") )
    self.bg_sprite:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.bg_sprite:setIgnoresDrawOffset(true)
    self.bg_sprite:setZIndex(0)

    self.sprites[#self.sprites+1] = self.bg_sprite

end

function MiningLaser:initMinerals()

    self.data = { {120, 33, 10}, {65, 70, 12}, {95, 140, 8}, {145, 120, 6} }
    self.minerals = {}

    for k,v in pairs(self.data) do
        local img = gfx.image.new("sprites/asteroids/m1")
        local sprt = gfx.sprite.new(img)
        sprt:moveTo(v[1] + pd.display.getWidth()/2 - self.asteroid_img.width/2, v[2] + pd.display.getHeight()/2 - self.asteroid_img.height/2)
        sprt:setZIndex(2)
        self.minerals[#self.minerals+1] = {sprt, sprt.x, sprt.y}
        self.sprites[#self.sprites+1] = sprt
    end
    
end

function MiningLaser:rotateMinerals()
    for k,v in pairs(self.minerals) do
        local _x, _y = rotatePoint(v[2], v[3], pd.display.getWidth()/2, pd.display.getHeight()/2, math.floor(self.asteroid_rotation)-1)
        v[1]:moveTo(_x, _y)
    end
end

function MiningLaser:checkFreeMinerals()
    local img = self.asteroid_canvas:getImage()
    for k,v in pairs(self.minerals) do
        local _arc = pd.geometry.arc.new(v[1].x, v[1].y, v[1]:getImage().width, 0, 360)
        local _free = math.floor(_arc:length()/10)
        for d=0,_arc:length() do
            local _p = _arc:pointOnArc(d)
            if img:sample(_p.x, _p.y) ~= gfx.kColorClear then
                _free -= 1
                if _free < 0 then
                    break
                end
            end
        end
        if _free > 0 then
            v[1]:moveTo(380, 180 - #self.minerals * 20)
            table.remove(self.minerals, k)
        end
    end
end

function MiningLaser:initAsteroid() 

    self.asteroid_cache = {}

    self.asteroid_img_quantum = 2

    self.asteroid_rotation = 1
    self.asteroid_angular_speed = 0

    self.asteroid_img = gfx.image.new("sprites/asteroids/a1", gfx.kColorClear)
    assert(self.asteroid_img)

    self.asteroid_canvas = gfx.sprite.new()
    self.asteroid_canvas:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.asteroid_canvas:setZIndex(1)

    for a=0,360,self.asteroid_img_quantum do
        local img = gfx.image.new(pd.display.getWidth(), pd.display.getHeight(), gfx.kColorClear)
        gfx.pushContext(img)
            self.asteroid_img:drawRotated(pd.display.getWidth()/2, pd.display.getHeight()/2, a)
        gfx.popContext()
        self.asteroid_cache[#self.asteroid_cache+1] = img
        self.asteroid_cache[#self.asteroid_cache+1] = img
    end

    self.sprites[#self.sprites+1] = self.asteroid_canvas

end

function MiningLaser:initLaser()

    self.beam_size = 10
    self.remaining_beam = self.beam_size
    self.beam_rate = 0.05

    self.laser_counter = 0
    self.laser_update = 8

    self.laser_origin_x = 70
    self.laser_origin_y = 120
    self.laser_target_x = 330
    self.laser_target_y = 120

    img = gfx.image.new(pd.display.getWidth(), pd.display.getHeight(), gfx.kColorClear)
    self.laser_sprite = gfx.sprite.new(img)
    self.laser_sprite:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.laser_sprite:setZIndex(3)

    self.sprites[#self.sprites+1] = self.laser_sprite

end

function MiningLaser:castRay(img, _laser_line)
    for d=0, _laser_line:length() do 
        local _p = _laser_line:pointOnLine(d)
        local _p_x, _p_y = _p.x, _p.y -- math.floor(_p.x), math.floor(_p.y)
        for b=0,self.remaining_beam/2 do
            if img:sample(_p_x, _p_y + b) ~= gfx.kColorClear then
                return true, _p_x, _p_y
            end
        end
        for b=0,self.remaining_beam/2 do
            if img:sample(_p_x, _p_y - b) ~= gfx.kColorClear then
                return true, _p_x, _p_y
            end
        end
    end
    return false, nil, nil
end

function MiningLaser:applyLaser()

    
    self.remaining_beam -= self.beam_rate

    if self.laser_counter == self.laser_update then

        self.laser_target_x = 330
        self.laser_target_y = 120

        local _laser_line = pd.geometry.lineSegment.new(self.laser_origin_x, self.laser_origin_y, self.laser_target_x, self.laser_target_y)
        local _hit, _t_x, _t_y = self:castRay(self.asteroid_canvas:getImage(), _laser_line)

        if _hit then
            self.laser_target_x, self.laser_target_y = _t_x, _t_y
            if true then
                for k,v in pairs(self.asteroid_cache) do
                    gfx.pushContext(v)
                        gfx.setColor(gfx.kColorClear)
                        local _x, _y = rotatePoint(self.laser_target_x, self.laser_target_y, pd.display.getWidth()/2, pd.display.getHeight()/2, 360 - self.asteroid_rotation + k)
                        gfx.fillCircleAtPoint(_x, _y, self.remaining_beam)
                    gfx.popContext()
                end
            end
            self:checkFreeMinerals()
        end
    end

    gfx.pushContext(self.laser_sprite:getImage())

        local _rumble_x , _rumble_y = math.random(-1,1), math.random(-1,1)/2
        gfx.clear(gfx.kColorClear)
        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(self.remaining_beam)
        gfx.drawLine(self.laser_origin_x + _rumble_x , self.laser_origin_y + _rumble_y, self.laser_target_x + _rumble_x,self.laser_target_y + _rumble_y)
        
        gfx.fillCircleAtPoint(self.laser_target_x + _rumble_x, self.laser_target_y + _rumble_y, self.remaining_beam/2)

        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillCircleAtPoint(self.laser_target_x + math.random(-1,1), self.laser_target_y + math.random(-1,1), self.remaining_beam*2)
    gfx.popContext()

    return hit

end

function MiningLaser:update()

    pd.display.setOffset(0,0)

    if self.asteroid_angular_speed > 0 then
        self.asteroid_angular_speed -= 0.01
    end

    if self.asteroid_angular_speed < 0 then
        self.asteroid_angular_speed += 0.01
    end

    local ticks = pd.getCrankTicks(360)

    if math.abs(self.asteroid_angular_speed) < 2 then
        self.asteroid_angular_speed += ticks/1000
        if math.abs(self.asteroid_angular_speed) > 2 then
            self.asteroid_angular_speed = 2 * self.asteroid_angular_speed/math.abs(self.asteroid_angular_speed)
        end
    end

    self.asteroid_rotation += self.asteroid_angular_speed

    if self.asteroid_rotation > 360 then
        self.asteroid_rotation = 1
    end

    if self.asteroid_rotation < 1 then
        self.asteroid_rotation = 361
    end

    if self.asteroid_cache[math.floor(self.asteroid_rotation)] then
        self.asteroid_canvas:setImage(self.asteroid_cache[math.floor(self.asteroid_rotation)])
    end

    self:rotateMinerals()

    self.laser_counter += 1

    if pd.buttonIsPressed(pd.kButtonB) and self.remaining_beam > 0 then
        pd.display.setOffset(math.random(-2,2), math.random(-2,2))
        self:applyLaser()
    else
        if self.remaining_beam < self.beam_size then
            self.remaining_beam += (self.beam_size/pd.getFPS())
        end
        gfx.pushContext(self.laser_sprite:getImage())
            gfx.clear(gfx.kColorClear)
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
            gfx.fillCircleAtPoint(self.laser_origin_x + math.random(-1,1), self.laser_origin_y + math.random(-1,1), self.remaining_beam*2)
        gfx.popContext()
    end

    if self.laser_counter > self.laser_update then
        self.laser_counter = 0
    end


end
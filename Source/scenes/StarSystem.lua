import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "CoreLibs/animator"
import "CoreLibs/sprites"
import "CoreLibs/math"

import "obj/ship"
import "obj/planet"

import "ui/fuel"
import "ui/objective"
import "tools/tools"
import "obj/AnimatedSprite"

import "scenes/scene"

import "scenes/PlanetCard"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('StarSystem').extends(Scene)


function StarSystem:startScene()

    self.ship = Ship(self)
    self.ship:setZIndex(2000)
    self.ship:moveTo(self.data.playfield_width/2-100, self.data.playfield_height/2)

    self.sprites[#self.sprites+1] = self.ship

    self.x_offset = 0
    self.y_offset = 0
    self.x_cam_loose = 50
    self.y_cam_loose = 30
    self.wrap = false
    
    self:initBg()
    self:initPlanets()
    self:initOrbits()
    self:initIU()
    self:initArrows()

end

function StarSystem:initBg()

    self.bg_sprite = gfx.sprite.new(gfx.image.new(self.data.background))
    self.bg_sprite:moveTo(self.data.playfield_width/2, self.data.playfield_height/2)
    self.bg_sprite:setZIndex(0)

    self.sprites[#self.sprites+1] = self.bg_sprite

end

function StarSystem:initPlanets() 
    self.planets = {}

    if self.data.planets then
        for k,v in pairs(self.data.planets) do
            local p = Planet(v.img, v.orbit_size, self.data.angle, v.speed, math.random(0, 360), self.data.playfield_width, self.data.playfield_height, v.outline)
            self.planets[#self.planets+1] = p
            self.sprites[#self.sprites+1] = p
        end
    end

    if self.data.sun then
        self.sun = AnimatedSprite(self.data.sun)
        self.sun:moveTo(self.data.playfield_width/2, self.data.playfield_height/2)

        self.sprites[#self.sprites+1] = self.sun
    end

end

function StarSystem:initArrows()

    local offset = 20
    self.arrow_y = 0

    self.arrow_img = gfx.image.new("sprites/arrow")
    self.arrow_canvas = gfx.image.new(self.arrow_img.width, self.arrow_img.height)

    local _up = gfx.sprite.new(self.arrow_canvas)
    _up:moveTo(self.data.playfield_width/2, _up.height/2 + offset)
    _up:setZIndex(2)
    self.sprites[#self.sprites+1] = _up

    local _down = gfx.sprite.new(self.arrow_canvas)
    _down:moveTo(self.data.playfield_width/2, self.data.playfield_height - _down.height/2 - offset)
    _down:setZIndex(2)
    _down:setRotation(180)
    self.sprites[#self.sprites+1] = _down

    local _left = gfx.sprite.new(self.arrow_canvas)
    _left:moveTo(_left.height/2 + offset, self.data.playfield_height/2)
    _left:setRotation(270)
    _left:setZIndex(2)
    self.sprites[#self.sprites+1] = _left

    local _right = gfx.sprite.new(self.arrow_canvas)
    _right:moveTo(self.data.playfield_width - _right.height/2 - offset, self.data.playfield_height/2)
    _right:setZIndex(2)
    _right:setRotation(90)
    self.sprites[#self.sprites+1] = _right

end

function StarSystem:moveArrows()
    self.arrow_y += 0.5
    if self.arrow_y > self.arrow_img.height then
        self.arrow_y = 0
    end
    gfx.pushContext(self.arrow_canvas)
        gfx.clear()
        gfx.setColor(playdate.graphics.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRect(0,0, self.arrow_canvas:getSize())
        self.arrow_img:drawAnchored(self.arrow_canvas.width/2, self.arrow_canvas.height/2 - self.arrow_y, 0.5, 0.5)
        self.arrow_img:drawAnchored(self.arrow_canvas.width/2, self.arrow_canvas.height + self.arrow_canvas.height/2 - self.arrow_y, 0.5, 0.5)
    gfx.popContext()
end

function StarSystem:initOrbits() 
    self.orbits_sprite = gfx.sprite.new(gfx.image.new(self.data.playfield_width, self.data.playfield_height))
    local img = self.orbits_sprite:getImage()
    gfx.pushContext(img)

        gfx.setColor(playdate.graphics.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.setLineWidth(2)
        for k, p in pairs(self.planets) do
            
            gfx.drawEllipseInRect(p.cx - p.h_radius, p.cy - p.v_radius, 2 * p.h_radius, 2 * p.v_radius)
            --drawDottedEllipse(p.cx , p.cy, p.h_radius, p.v_radius, math.floor(p.h_radius/self.data.playfield_width * 1000), 3, 0)
        end
    gfx.popContext()
    self.orbits_sprite:moveTo(self.data.playfield_width/2, self.data.playfield_height/2)
    self.orbits_sprite:setZIndex(1)

    self.sprites[#self.sprites+1] = self.orbits_sprite
end

function StarSystem:initIU()


    
end

function StarSystem:moveCamera()

    local _cx = self.x_offset + playdate.display.getWidth()/2
    local _cy = self.y_offset + playdate.display.getHeight()/2

    local _nx = self.x_offset
    local _ny = self.y_offset

    if math.floor(math.abs(_cx - self.ship.x)) > self.x_cam_loose  then
        _nx = self.ship.x - playdate.display.getWidth()/2 + (self.x_cam_loose * (_cx - self.ship.x)/math.abs(_cx - self.ship.x))
    end
    if math.floor(math.abs(_cy - self.ship.y)) > self.y_cam_loose  then
        _ny = self.ship.y - playdate.display.getHeight()/2 + (self.y_cam_loose * (_cy - self.ship.y)/math.abs(_cy - self.ship.y))
    end
    
    _nx = playdate.math.lerp(self.x_offset, _nx, 0.5)
    _ny = playdate.math.lerp(self.y_offset, _ny, 0.5)
    self.x_offset = clamp(_nx , 0, self.data.playfield_width - playdate.display.getWidth())
    self.y_offset = clamp(_ny , 0, self.data.playfield_height - playdate.display.getHeight())

    gfx.setDrawOffset(-math.floor(self.x_offset), -math.floor(self.y_offset))

end

function StarSystem:update()

    self:moveCamera()

    if g_SceneManager.transitioning then
        return
    end     

    self:moveArrows()

    local _s_x = self.ship.x
    local _s_y = self.ship.y

    if self.wrap then
		if _s_x < 0 then
			_s_x = self.data.playfield_width
		end
		if _s_x > self.data.playfield_width then
			_s_x  = 0
		end
	
		if _s_y < 0 then
			_s_y = self.data.playfield_height 
		end
		if _s_y > self.data.playfield_height then
			_s_y = 0
		end
        self.ship:moveTo(_s_x, _s_y)
	else
        if _s_y < 0 or _s_y > self.data.playfield_height then
            self.ship.shipVector.y *= -1
            self.ship.shipVector /= 2
        end

        if _s_x < 0 or _s_x > self.data.playfield_width then
            self.ship.shipVector.x *= -1
            self.ship.shipVector /= 2
        end

        if _s_x < 0 then
			_s_x = 0
		end
		if _s_x > self.data.playfield_width then
			_s_x  = self.data.playfield_width
		end
	
		if _s_y < 0 then
			_s_y = 0
		end
		if _s_y > self.data.playfield_height then
			_s_y = self.data.playfield_height 
		end
        self.ship:moveTo(_s_x, _s_y)

    end

    local collisions = self.ship:overlappingSprites()

	for i = 1, #collisions do
		if collisions[i].className == "Planet" and pd.buttonJustReleased(playdate.kButtonA) then
            gfx.setDrawOffset(0, 0)
            g_SceneManager:pushScene(PlanetCard(), 'hwipe')
		end
	end   

    self.ship:doUpdate()

    for k,v in pairs(self.planets) do
        v:doUpdate()
    end
end

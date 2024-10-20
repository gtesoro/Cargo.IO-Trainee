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

import "scenes/PlanetCard"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('StarSystem').extends(gfx.sprite)

function StarSystem:init()
    self.sprites = {}
    self.name = "Star System"
end

function StarSystem:load()

    self:startScene()
    
end

function StarSystem:add()

    for k,v in pairs(self.sprites) do
        print(v.className, v:getPosition(), v:getZIndex())
        v:add()
    end
    StarSystem.super.add(self)

end

function StarSystem:remove()
    for k,v in pairs(self.sprites) do
        v:remove()
    end
    StarSystem.super.remove(self)
end

function StarSystem:startScene()

    self.playfield_width = 1600
    self.playfield_height = 960

    self.ship = Ship(self)
    self.ship:setZIndex(2000)
    self.ship:moveTo(self.playfield_width/2-100, self.playfield_height/2)

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

end

function StarSystem:initBg() 
    self.bg_sprite = gfx.sprite.new(gfx.image.new("sprites/bg") )
    self.bg_sprite:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.bg_sprite:setIgnoresDrawOffset(true)
    self.bg_sprite:setZIndex(0)

    self.sprites[#self.sprites+1] = self.bg_sprite
end

function StarSystem:initPlanets() 
    local angle = 0.35
    self.planets = {}

    local p = Planet("sprites/planets/planet3", 200, angle, 1, math.random(0, 360), self.playfield_width, self.playfield_height, true)
    self.planets[#self.planets+1] = p
    self.sprites[#self.sprites+1] = p

    p = Planet("sprites/planets/planet2", 300, angle, 1, math.random(0, 360), self.playfield_width, self.playfield_height, true)
    self.planets[#self.planets+1] = p
    self.sprites[#self.sprites+1] = p

    p = Planet("sprites/planets/planet1", 400, angle, 1, math.random(0, 360), self.playfield_width, self.playfield_height, true)
    self.planets[#self.planets+1] = p
    self.sprites[#self.sprites+1] = p

    p = Planet("sprites/planets/planet4", 700, angle, 1, math.random(0, 360), self.playfield_width, self.playfield_height, false)
    self.planets[#self.planets+1] = p
    self.sprites[#self.sprites+1] = p

    local _o, _t = getRandomDistinctPair(1, #self.planets)
    self.current_origin = self.planets[_o]
    self.current_destination = self.planets[_t]
    self.current_target = self.planets[_o]

    self.sun = AnimatedSprite("sprites/planets/star")
    self.sun:moveTo(self.playfield_width/2, self.playfield_height/2)

    self.sprites[#self.sprites+1] = self.sun

end

function StarSystem:initOrbits() 
    self.orbits_sprite = gfx.sprite.new(gfx.image.new(self.playfield_width, self.playfield_height))
    gfx.pushContext(self.orbits_sprite:getImage())
        local center_x = self.playfield_width/2
        local center_y = self.playfield_height/2

        gfx.setColor(playdate.graphics.kColorWhite)
        for k, p in pairs(self.planets) do
            drawDottedEllipse(p.cx , p.cy, p.h_radius, p.v_radius, math.floor(p.h_radius/self.playfield_width * 1000), 1, 0)
        end
    gfx.popContext()
    self.orbits_sprite:moveTo(self.playfield_width/2, self.playfield_height/2)
    self.orbits_sprite:setZIndex(1)

    self.sprites[#self.sprites+1] = self.orbits_sprite
end

function StarSystem:initIU()

    self.objective_ui = ObjectiveUI(self)
    local objetive_ui_offset = 10
    self.objective_ui:moveTo(pd.display.getWidth() - self.objective_ui.width/2 - objetive_ui_offset, self.objective_ui.height/2 + objetive_ui_offset)

    self.sprites[#self.sprites+1] = self.objective_ui
    
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
    self.x_offset = clamp(_nx , 0, self.playfield_width - playdate.display.getWidth())
    self.y_offset = clamp(_ny , 0, self.playfield_height - playdate.display.getHeight())

    gfx.setDrawOffset(-math.floor(self.x_offset), -math.floor(self.y_offset))

end

function StarSystem:update()

    self:moveCamera()

    if g_SceneManager.transitioning then
        return
    end     

    local _s_x = self.ship.x
    local _s_y = self.ship.y

    if self.wrap then
		if _s_x < 0 then
			_s_x = self.playfield_width
		end
		if _s_x > self.playfield_width then
			_s_x  = 0
		end
	
		if _s_y < 0 then
			_s_y = self.playfield_height 
		end
		if _s_y > self.playfield_height then
			_s_y = 0
		end
        self.ship:moveTo(_s_x, _s_y)
	else
        if _s_y < 0 or _s_y > self.playfield_height then
            self.ship.shipVector.y *= -1
            self.ship.shipVector /= 2
        end

        if _s_x < 0 or _s_x > self.playfield_width then
            self.ship.shipVector.x *= -1
            self.ship.shipVector /= 2
        end

        if _s_x < 0 then
			_s_x = 0
		end
		if _s_x > self.playfield_width then
			_s_x  = self.playfield_width
		end
	
		if _s_y < 0 then
			_s_y = 0
		end
		if _s_y > self.playfield_height then
			_s_y = self.playfield_height 
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

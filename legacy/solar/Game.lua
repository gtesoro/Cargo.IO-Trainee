import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "CoreLibs/animator"
import "CoreLibs/sprites"

import "obj/GameOver"
import "obj/Intro"
import "obj/ship"
import "obj/planet"

import "ui/fuel"
import "tools/tools"
import "stages/solar/background"

local gfx <const> = playdate.graphics

class('Solar').extends(playdate.graphics.sprite)

function Solar:init()

    self.x_offset = 0
    self.y_offset = 0

    self:setSize(400, 240)

    self:moveTo(200,120)
    self:setZIndex(1)
    self:startStage()

end

function Solar:draw(x, y, width, height)
    if not self.stage_over  and self.current_origin == self.current_target then
            
        gfx.setColor(playdate.graphics.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
        gfx.setLineWidth(3)
        gfx.setColor(playdate.graphics.kColorBlack)
        drawDottedLine(
            self.current_origin.x,
            self.current_origin.y,
            self.current_destination.x,
            self.current_destination.y,
            10, 2
        )

    end

    gfx.setColor(playdate.graphics.kColorBlack)
    gfx.setLineWidth(3)
    
    gfx.drawArc(self.current_target.x, self.current_target.y, self.current_target.width/2 + 8 , 0, 359 * (self.countdown/self.current_countdown))
end

function Solar:startStage()

    self:add()

    local angle = 0.35

    self.planets = {}

    self.current_countdown = 30
    self.countdown = self.current_countdown

    self.score = 0
    self.stage_over = false


    self.planets[1] =  Planet("assets/planets/p1", 0.3, 55, angle, 0.001 * math.random(1, 8), math.random(0, 360), 2)

    self.planets[2] =  Planet("assets/planets/p1", 0.4, 100, angle, 0.001 * math.random(1, 8), math.random(0, 360), 2)

    self.planets[3] =  Planet("assets/planets/p1", 1, 100, angle, 0.001 * math.random(1, 8), math.random(0, 360), 2)

    self.planets[4] =  Planet("assets/planets/p1", 0.6, 150, angle, 0.001 * math.random(1, 8), math.random(0, 360), 2)

    self.planets[5] =  Planet("assets/planets/p1", 0.5, 200, angle, 0.001 * math.random(1, 8), math.random(0, 360), 2)


    local _o, _t = getRandomDistinctPair(1, #self.planets)

    self.current_origin = self.planets[_o]
    self.current_destination = self.planets[_t]
    self.current_target = self.planets[_o]

    self.ship = Ship(self)
    self.ship:moveTo(50, 30)
    self.ship:setRotation(135)
	self.bg = SolarBg(self)

    self.fuel_ui = FuelUI(self.ship)

end

function Solar:endStage()

    self.stage_over = true

    self.ship:remove()
    self.ship = nil
    self.bg:remove()
    self.bg = nil
    self.fuel_ui:remove()
    self.fuel_ui = nil

    for i=1,#self.planets do
        self.planets[i]:remove()
        self.planets[i] = nil
    end

    self:remove()
    GameOver(self)

end

function Solar:moveCamera()

    if playdate.buttonIsPressed(playdate.kButtonUp) then
        self.y_offset -= 1 
    end

    if playdate.buttonIsPressed(playdate.kButtonDown) then
        self.y_offset += 1 
    end

    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self.x_offset -= 1 
    end

    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self.x_offset += 1 
    end
    gfx.setDrawOffset(self.x_offset, self.y_offset)
end




function Solar:update()

    self:moveCamera()

    self.countdown -= (1/playdate.getFPS())

    if self.countdown < 0 then
        self:endStage()
        return
    end

    local collisions = self.ship:overlappingSprites()

	for i = 1, #collisions do
		if collisions[i].className == "Planet" and self.current_target == collisions[i] then
            if self.ship.loaded then
                self.ship:unload()
            else
                self.ship:load()
            end
            
            self:getNextTarget()
            self.countdown = self.current_countdown
		end
	end

end

function Solar:getNextTarget()

    -- Part of a trip
    if self.current_target == self.current_origin then
        self.current_target = self.current_destination
    else

        -- new trip!
        if self.current_countdown > 5 then
            self.current_countdown -= 1
        end 

        local _o, _t = getRandomDistinctPair(1, #self.planets)

        while self.planets[_o] == self.current_target do
            _o, _t = getRandomDistinctPair(1, #self.planets)
        end

        self.current_origin = self.planets[_o]
        self.current_destination = self.planets[_t]
        self.current_target = self.planets[_o]

        self.score += 1

    end

end
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

local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlanetCard').extends(gfx.sprite)

function PlanetCard:initBg() 

    local img = gfx.image.new(pd.display.getWidth(), pd.display.getHeight())
    gfx.pushContext(img)
        gfx.setColor(playdate.graphics.kColorBlack)
        --gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRect(0,0, img:getSize())
    gfx.popContext()
    self.bg_sprite = gfx.sprite.new(img)
    self.bg_sprite:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.bg_sprite:setZIndex(0)

    self.sprites[#self.sprites+1] = self.bg_sprite

end

function PlanetCard:initPlanet()
    self.planet = AnimatedSprite("sprites/planets/planet5",100)
    self.planet:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)

    local img = gfx.image.new(self.planet:getSize())
    gfx.pushContext(img)
        gfx.setColor(playdate.graphics.kColorWhite)
        gfx.setLineWidth(2)
        gfx.drawCircleAtPoint(self.planet.width/2, self.planet.width/2, self.planet.width/2 - 1)
    gfx.popContext()
    self.planet_outline = gfx.sprite.new(img)
    self.planet_outline:setZIndex(2)
    self.planet_outline:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)

    self.sprites[#self.sprites+1] = self.planet_outline
    self.sprites[#self.sprites+1] = self.planet
    
end

function PlanetCard:init()

    self.name = "Planet Card"
    self.sprites = {}
    
end

function PlanetCard:load()
    self:startScene()
end


function PlanetCard:add()

    for k,v in pairs(self.sprites) do
        v:add()
    end
    PlanetCard.super.add(self)

end

function PlanetCard:startScene()
    self:initBg()
    self:initPlanet()
end

function PlanetCard:remove()
    
    for k,v in pairs(self.sprites) do
        v:remove()
    end
    PlanetCard.super.remove(self)
end

function PlanetCard:update()
    gfx.setDrawOffset(0,0)

    if g_SceneManager.transitioning then
        return
    end

    if pd.buttonJustReleased(pd.kButtonB) then
        g_SceneManager:popScene('hwipe')
    end
end
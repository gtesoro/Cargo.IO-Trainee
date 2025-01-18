local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlanetSystem').extends(System)

function PlanetSystem:startScene()

    PlanetSystem.super.startScene(self)

    self:initOrbits()
    
end

function PlanetSystem:initLocations() 
    self.planets = {}

    if self.data.locations then
        for k,v in pairs(self.data.locations) do
            local p = Planet(v, v.img, v.orbit_size, self.data.angle, v.speed, math.random(0, 360), v.outline, self.data.playfield_width, self.data.playfield_height)
            self.planets[#self.planets+1] = p
            table.insert(self.locations, p)
            table.insert(self.sprites, p)
        end
    end

    if self.data.sun then
        self.sun = AnimatedSprite(self.data.sun)
        self.sun:moveTo(self.data.playfield_width/2, self.data.playfield_height/2)

        table.insert(self.sprites, self.sun)
    end

end

function PlanetSystem:initOrbits() 
    gfx.pushContext(self.bg_sprite:getImage())

        gfx.setColor(playdate.graphics.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.setLineWidth(1)
        for k, p in pairs(self.planets) do
            
            gfx.drawEllipseInRect(p.cx - p.h_radius, p.cy - p.v_radius, 2 * p.h_radius, 2 * p.v_radius)
            --drawDottedEllipse(p.cx , p.cy, p.h_radius, p.v_radius, math.floor(p.h_radius/self.data.playfield_width * 500), 2, 0)
        end
    gfx.popContext()
end


function PlanetSystem:doUpdate()

    PlanetSystem.super.doUpdate(self)  

    for k,v in pairs(self.planets) do
        v:doUpdate()
    end
    
end

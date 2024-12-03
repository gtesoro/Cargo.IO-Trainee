local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlanetSystem').extends(System)

function PlanetSystem:startScene()

    PlanetSystem.super.startScene(self)

    self:initPlanets()
    self:initOrbits()
    
end

function PlanetSystem:initPlanets() 
    self.planets = {}

    if self.data.planets then
        for k,v in pairs(self.data.planets) do
            local p = Planet(v.img, v.orbit_size, self.data.angle, v.speed, math.random(0, 360), self.data.playfield_width, self.data.playfield_height, v.outline)
            self.planets[#self.planets+1] = p
            self.sprites:append(p)
            v.sprite = p
        end
    end

    if self.data.sun then
        self.sun = AnimatedSprite(self.data.sun)
        self.sun:moveTo(self.data.playfield_width/2, self.data.playfield_height/2)

        self.sprites:append(self.sun)
    end

end

function PlanetSystem:initOrbits() 
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

    self.sprites:append(self.orbits_sprite)
end


function PlanetSystem:doUpdate()

    PlanetSystem.super.doUpdate(self)

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
            if self.data.planets then
                for k,v in pairs(self.data.planets) do
                    if v.sprite == collisions[i] then
                        self.ship:stop()
                        g_SceneManager:pushScene(PlanetMenu(v), 'to menu')
                        break
                    end
                end
            end
        end
	end   

    for k,v in pairs(self.planets) do
        v:doUpdate()
    end
end

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('PlanetDescription').extends(Scene)

function PlanetDescription:init(planet)

    PlanetDescription.super.init(self)

    local img = gfx.image.new(300, 424, gfx.kColorWhite)

    self.data = planet

    inContext(img, function ()
        
        gfx.setLineWidth(5)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawLine(img.width*0.1, img.height*0.20, img.width*0.9, img.height*0.20)

        gfx.setFont(gfx.font.new('font/Full Circle/font-full-circle'))
        gfx.drawTextInRect(self.data.description, img.width*0.1, img.height*0.25, img.width*0.8, img.height*0.45)

        local facilities = "Facilities:"
        for k,v in pairs(self.data.facilities) do
            facilities = string.format("%s\n  - %s", facilities, facility_v_options[v].name)
        end
        gfx.drawTextInRect(facilities, img.width*0.1, img.height*0.7, img.width*0.8, img.height*0.2)

    end)

    self:setImage(img)
    
    self:moveTo(self.width/2, self.height/2)
    self:setZIndex(0)

    self:initPlanet()

end


function PlanetDescription:initPlanet()

    self.planet_spr = AnimatedSprite(self.data.img, 100)
    self.planet_spr:moveTo(self.width*0.2, self.height*0.1)
    self.planet_spr:setZIndex(1)
    table.insert(self.sprites, self.planet_spr)

    gfx.setFont(g_font_24)
    local img = gfx.image.new(gfx.getTextSize(self.data.name))
    inContext(img, function ()
        gfx.drawText(self.data.name, 0,0)
    end)
    self.planet_label = gfx.sprite.new(img)

    self.planet_label:setZIndex(1)
    self.planet_label:setCenter(1, 0.5)
    self.planet_label:moveTo(self.width*0.8, self.height*0.1)

    table.insert(self.sprites, self.planet_label)

end

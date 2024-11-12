local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlanetCard').extends(Scene)

function PlanetCard:startScene()

    g_Notifications:notify(self.data.name, 1000)

    self:initPlanet()
    self:initBg()
    self:initGrid()
end

function PlanetCard:initGrid()

    self.list_box = ListBox(self.data.facilities, self.data_width, self.data_height)
    self.list_box:moveTo(self.data_x + self.data_width/2, self.data_y + self.data_height/2)
    self.list_box:setZIndex(2)

    self.list_box.b_callback = function ()
        self.list_box:unfocus()
        self:unfocus()
        g_SceneManager:popScene('hwipe')
    end

    self.sprites:append(self.list_box)
    
end

function PlanetCard:initBg()

    local offset_x = 10
    local offset_y = 20
    local float = 2
    local radius = 4

    local data_width = pd.display.getWidth()/2 - self.planet_offset*2

    self.data_x = offset_x
    self.data_y = offset_y
    self.data_width = data_width- offset_x*2
    self.data_height = pd.display.getHeight() - offset_y*2

    local img = gfx.image.new(pd.display.getWidth(), pd.display.getHeight(), gfx.kColorBlack)
    self.bg_sprite = gfx.sprite.new(img)
    self.bg_sprite:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.bg_sprite:setZIndex(0)

    self.sprites:append(self.bg_sprite)

end

function PlanetCard:initPlanet()
    self.planet_offset = 20
    self.planet = AnimatedSprite(self.data.img_hd,100)
    self.planet:moveTo(pd.display.getWidth() - pd.display.getWidth()/4 - self.planet_offset, pd.display.getHeight()/2)

    local img = gfx.image.new(self.planet:getSize())
    gfx.pushContext(img)
        gfx.setColor(playdate.graphics.kColorWhite)
        gfx.setLineWidth(2)
        gfx.drawCircleAtPoint(self.planet.width/2, self.planet.width/2, self.planet.width/2 - 1)
    gfx.popContext()
    self.planet_outline = gfx.sprite.new(img)
    self.planet_outline:setZIndex(2)
    self.planet_outline:moveTo(pd.display.getWidth() - self.planet.width/2 - self.planet_offset, pd.display.getHeight()/2)

    self.sprites:append(self.planet_outline)
    self.sprites:append(self.planet)
    
end

function PlanetCard:focus()
    if self.list_box then
        self.list_box:focus()
    end
end

function PlanetCard:unfocus()
    if self.list_box then
        self.list_box:unfocus()
    end
end
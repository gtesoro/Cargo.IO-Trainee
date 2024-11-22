local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlanetMenu').extends(GenericMenu)

function PlanetMenu:init(data)

    PlanetMenu.super.init(self)

    self.data = data

    self.data.options = self.data.facilities
    
end

function PlanetMenu:preload()

    self.data.right_side = AnimatedSprite(self.data.img_hd,100)
    
end
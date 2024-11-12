local pd <const> = playdate
local gfx <const> = pd.graphics

class('Yttrium').extends(Item)

function Yttrium:init()

    self:setImage(gfx.image.new("assets/items/yttrium"))

    self.type = "Metall"
    self.usage = "Industry"
    self.price_max = 100
    self.price_min = 50

    self.description = {
        {
            "Type",  self.type 
        },
        {
            "Usage", self.usage
        },
        {
            "Price", string.format("%s-%s", self.price_min, self.price_min)
        }
    }
    
end
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Scandium').extends(Item)

function Scandium:init()

    self:setImage(gfx.image.new("assets/items/scandium"))

    self.type = "Metall"
    self.usage = "Industry"
    self.price_max = 100
    self.price_min = 50

    self.name = self.className

    self.description = {
        {
            "Type",  self.type 
        },
        {
            "Usage", self.usage
        },
        {
            "Price", string.format("%s-%s", self.price_min, self.price_max)
        }
    }

end

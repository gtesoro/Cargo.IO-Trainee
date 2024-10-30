local pd <const> = playdate
local gfx <const> = pd.graphics

class('Yttrium').extends(Item)

function Yttrium:init()

    self:setImage(gfx.image.new("assets/items/yttrium"))
    
end
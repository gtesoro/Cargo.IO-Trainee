local pd <const> = playdate
local gfx <const> = pd.graphics

class('Scandium').extends(Item)

function Scandium:init()

    self:setImage(gfx.image.new("assets/items/scandium"))
    
end

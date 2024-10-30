local pd <const> = playdate
local gfx <const> = pd.graphics

class('Neodymium').extends(Item)

function Neodymium:init()

    self:setImage(gfx.image.new("assets/items/neodymium"))
    
end

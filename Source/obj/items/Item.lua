local pd <const> = playdate
local gfx <const> = pd.graphics

class('Item').extends(gfx.sprite)

function Item:init()

    self.price_min = 0 
    self.price_max = 0

end

function Item:getCurrentPrice()

    print(stringToSeed(self.className))
    math.randomseed(g_player.cycle + stringToSeed(self.className))
    return  math.random(self.price_min, self.price_max)
    
end

local pd <const> = playdate
local gfx <const> = pd.graphics

class('AnimatedSprite').extends(playdate.graphics.sprite)

function AnimatedSprite:init(image_table, delay)

    if not delay then
        self.delay = 100
    else
        self.delay = delay
    end

    self.imageTable =  gfx.imagetable.new(image_table)
    self.animation = gfx.animation.loop.new(self.delay, self.imageTable, true)
    self.image = gfx.image.new(self.imageTable:getImage(1):getSize())
    self:setImage(self.image)
	self:setZIndex(1)
 
end

function AnimatedSprite:update()
    gfx.pushContext(self.image)
        gfx.clear()
        self.animation:draw(0,0)
    gfx.popContext()
end

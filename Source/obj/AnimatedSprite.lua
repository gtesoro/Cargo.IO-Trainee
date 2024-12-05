local pd <const> = playdate
local gfx <const> = pd.graphics

class('AnimatedSprite').extends(playdate.graphics.sprite)

function AnimatedSprite:init(image_table, delay, scale)

    if not delay then
        self.delay = 100
    else
        self.delay = delay
    end

    self.scale = scale

    local _err = nil
    self.imageTable = gfx.imagetable.new(image_table)
    while not self.imageTable do
        collectgarbage()
        self.imageTable = gfx.imagetable.new(image_table)
    end
    self.animation = gfx.animation.loop.new(self.delay, self.imageTable, true)

    if self.scale then
        self:setImage(self.imageTable:getImage(1):scaledImage(scale))
    else
        self:setImage(self.imageTable:getImage(1))
    end
	self:setZIndex(1)
 
end

function AnimatedSprite:update()
    if self.scale then
        self:setImage(self.animation:image():scaledImage(self.scale))
    else
        self:setImage(self.animation:image())
    end
end

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

class('AnimatedSpriteLazy').extends(playdate.graphics.sprite)

function AnimatedSpriteLazy:init(image_name, delay, frames, scale)

    if not delay then
        self.delay = 100
    else
        self.delay = delay
    end

    self.image_name = image_name
    self.frame_counter = 1
    self.frames = frames
    self.img_map = {}

    self:setImage(gfx.image.new(string.format('%s-%i', self.image_name, self.frame_counter)))
	self:setZIndex(1)
 
end

function AnimatedSpriteLazy:update()
    if not self.timer then
        self.timer = pd.timer.new(self.delay*self.frames, 1, self.frames, pd.easingFunctions.inLinear)
        self.timer.updateCallback = function (timer)
            local img = nil
            if self.img_map[math.ceil(timer.value)] then
                img = self.img_map[math.ceil(timer.value)]
            else
                img = gfx.image.new(string.format('%s-%i', self.image_name, math.ceil(timer.value)))
                self.img_map[math.ceil(timer.value)] = img
            end
            self:setImage(img)
        end

        self.timer.timerEndedCallback = function ()
            self.timer = nil
        end
    end
end

function AnimatedSpriteLazy:remove()
    AnimatedSpriteLazy.super.remove(self)
    self.img_map = nil
    collectgarbage()
end

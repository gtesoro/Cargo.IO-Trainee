local pd <const> = playdate
local gfx <const> = pd.graphics

class('Particle').extends(gfx.sprite)

function Particle:init(x, y, duration, size)

    self.img = gfx.image.new(size, size)

    self.size = size

    gfx.pushContext(self.img)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(size/2, size/2, size/2)
    gfx.popContext()

    self.start_x = x
    self.start_y = y

    self.update_tick = 4
    self.update_counter = self.update_tick

    self.timer = pd.timer.new(duration, 1, 0, pd.easingFunctions.inLinear)

    self:setImage(gfx.image.new(self.img:getSize()))
    self:drawImg(1)
    self:moveTo(x, y)
    self:add()

    self.timer.updateCallback = function (timer)

        self.update_counter -= 1
        if self.update_counter == 0 then
            self.update_counter = self.update_tick
            self:drawImg(timer.value)
        end
    end

    self.timer.timerEndedCallback = function()
        self:remove()
    end
    
end

function Particle:drawImg(alpha)

    gfx.pushContext(self:getImage())
        gfx.clear()
        self.img:drawFaded(0,0, alpha, gfx.image.kDitherTypeScreen)
    gfx.popContext()
    
end
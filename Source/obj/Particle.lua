local pd <const> = playdate
local gfx <const> = pd.graphics

class('Particle').extends(gfx.sprite)

function Particle:init(imgtable, x, y, duration)

    self.sheet = imgtable

    self.start_x = x
    self.start_y = y

    self.timer = pd.timer.new(duration, 1, self.sheet:getLength() - 1, pd.easingFunctions.inLinear)

    self:setImage(self.sheet:getImage(1))
    self:moveTo(x, y)
    self:add()

    self.timer.updateCallback = function (timer)
        self:setImage(self.sheet:getImage(math.floor(timer.value) + 1))
    end

    self.timer.timerEndedCallback = function()
        self:remove()
    end
    
end
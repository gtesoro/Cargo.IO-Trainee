local pd <const> = playdate
local gfx <const> = pd.graphics

class('Unstack').extends(gfx.sprite)

function Unstack:init(duration)
    local img = gfx.getDisplayImage()
    self:setImage(img)
    self:setZIndex(TRANSITIONS_Z_INDEX)
    self:setIgnoresDrawOffset(true)
    self:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)

    self.timer = pd.timer.new(duration, 0, pd.display.getHeight(), pd.easingFunctions.linear)
    self.timer.updateCallback = function(timer)
        self:moveTo(self.x, pd.display.getHeight()/2 - timer.value)
    end

    self.timer.timerEndedCallback = function(timer)
        if self.endCallback then
            self.endCallback()
        end
        self:remove()
    end

end
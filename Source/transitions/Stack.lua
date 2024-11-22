local pd <const> = playdate
local gfx <const> = pd.graphics

class('Stack').extends(gfx.sprite)

function Stack:init(duration, blur)
    self.base_img = gfx.getDisplayImage()
    self:setImage(img)
    self:setZIndex(-TRANSITIONS_Z_INDEX)
    self:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self:setIgnoresDrawOffset(true)
    gfx.setDrawOffset(0, -pd.display.getHeight())

    self.timer = pd.timer.new(duration, 0, pd.display.getHeight(), pd.easingFunctions.inOutCubic)

    self.timer.updateCallback = function(timer)
        gfx.setDrawOffset(0, -pd.display.getHeight() + timer.value)
        
    end

    self.timer.timerEndedCallback = function(timer)
        if self.endCallback then
            self.endCallback()
        end
        self:remove()
    end

    if blur then
        self.blur_timer = pd.timer.new(duration, 0, 1, pd.easingFunctions.inLinear)

        self.blur_timer.updateCallback = function(timer)
            self:setImage(self.base_img:blurredImage(timer.value, 1, gfx.image.kDitherTypeScreen))        
        end
    end

end
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "CoreLibs/animator"
import "CoreLibs/sprites"
import "CoreLibs/math"


import "scenes/PlanetCard"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Stack').extends(gfx.sprite)

function Stack:init(duration, img)
    self:setImage(img)
    self:setZIndex(TRANSITIONS_Z_INDEX)
    self:setIgnoresDrawOffset(true)
    self:moveTo(pd.display.getWidth()/2, -pd.display.getHeight()/2)

    self.timer = pd.timer.new(duration, 0, pd.display.getHeight(), pd.easingFunctions.inOutCubic)

    self.timer.updateCallback = function(timer)
        self:moveTo(self.x, -pd.display.getHeight()/2 + timer.value)
    end

    self.timer.timerEndedCallback = function(timer)
        if self.endCallback then
            self.endCallback()
        end
        self:remove()
    end

end
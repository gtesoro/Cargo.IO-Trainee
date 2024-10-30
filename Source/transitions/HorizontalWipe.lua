import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "CoreLibs/animator"
import "CoreLibs/sprites"
import "CoreLibs/math"

import "scenes/PlanetCard"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('HorizontalWipe').extends(gfx.sprite)

function HorizontalWipe:init(duration, start_x, stop_x, inverted)
    local img = gfx.image.new("assets/loading") --pd.display.getWidth(), pd.display.getHeight(), gfx.kColorBlack)
    self:setImage(img)
    self:setZIndex(TRANSITIONS_Z_INDEX)
    self:setIgnoresDrawOffset(true)
    self:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    if inverted then
        self:setClipRect(0,0, pd.display.getWidth(), pd.display.getHeight())
    else
        self:setClipRect(0,0, 0, pd.display.getHeight())
    end

    
    self.timer = pd.timer.new(duration, start_x, stop_x, pd.easingFunctions.inOutCubic)
    self.timer.updateCallback = function(timer)
        if inverted then
            self:setClipRect(timer.value,0, pd.display.getWidth(), pd.display.getHeight())
        else
            self:setClipRect(0,0, timer.value, pd.display.getHeight())
        end
    end

    self.timer.timerEndedCallback = function(timer)
        if self.endCallback then
            self.endCallback()
        end
        self:remove()
    end

end
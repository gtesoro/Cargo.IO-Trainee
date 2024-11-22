local pd <const> = playdate
local gfx <const> = pd.graphics

class('BetweenMenusIn').extends(gfx.sprite)

function BetweenMenusIn:init(duration)

    duration = 500

    gfx.setDrawOffset(0, 0)

    self.grid_sheet = g_SystemManager.fading_grid

    self.grid = gfx.sprite.new(self.grid_sheet:getImage(100))
    self.grid:setZIndex(TRANSITIONS_Z_INDEX)
    self.grid:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.grid:add()
    self.overlay = gfx.sprite.new(gfx.image.new('assets/backgrounds/ui_overlay'))
    self.overlay:setZIndex(TRANSITIONS_Z_INDEX+1)
    self.overlay:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.overlay:add()

    self.timer = pd.timer.new(duration)
    self.fade_timer = pd.timer.new(duration, 1, 0, pd.easingFunctions.inCubic)

    self.fade_timer.updateCallback = function(timer)
        local value = clamp(math.ceil(timer.value*100), 1, 100)
        self.grid:setImage(self.grid_sheet:getImage(value))
        self.grid:markDirty()
    end

    self.fade_timer.timerEndedCallback = function ()
        self.grid:setImage(self.grid_sheet:getImage(1))
    end

    self.timer.timerEndedCallback = function(timer)
        if self.endCallback then
            self.endCallback()
        end
        self.grid:remove()
        self.overlay:remove()
        self:remove()
    end
end

class('BetweenMenusOut').extends(gfx.sprite)

function BetweenMenusOut:init(duration)

    duration = 500 

    gfx.setDrawOffset(0, 0)

    self.grid_sheet = g_SystemManager.fading_grid

    self.grid = gfx.sprite.new(self.grid_sheet:getImage(0))
    self.grid:setZIndex(TRANSITIONS_Z_INDEX)
    self.grid:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.grid:add()
    self.overlay = gfx.sprite.new(gfx.image.new('assets/backgrounds/ui_overlay'))
    self.overlay:setZIndex(TRANSITIONS_Z_INDEX+1)
    self.overlay:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.overlay:add()

    self.timer = pd.timer.new(duration)
    self.fade_timer = pd.timer.new(duration, 0, 1, pd.easingFunctions.outCubic)

    self.fade_timer.updateCallback = function(timer)
        local value = clamp(math.ceil(timer.value*100), 1, 100)
        self.grid:setImage(self.grid_sheet:getImage(value))
        self.grid:markDirty()
    end

    self.fade_timer.timerEndedCallback = function ()
        
        self.grid:setImage(self.grid_sheet:getImage(100))

    end

    self.timer.timerEndedCallback = function(timer)
        if self.endCallback then
            self.endCallback()
        end
        self.grid:remove()
        self.overlay:remove()
        self:remove()
    end

end
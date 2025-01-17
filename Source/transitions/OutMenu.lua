local pd <const> = playdate
local gfx <const> = pd.graphics

class('OutMenu').extends(gfx.sprite)

function OutMenu:init(duration)

    self.base_img = gfx.getDisplayImage()
    self:setImage(self.base_img)
    self:setZIndex(-TRANSITIONS_Z_INDEX)
    self:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self:setIgnoresDrawOffset(true)

    self.grid_sheet = g_SystemManager.fading_grid
    
    self.grid = gfx.sprite.new(self.grid_sheet:getImage(100))
    self.grid:setIgnoresDrawOffset(true)
    self.grid:setZIndex(TRANSITIONS_Z_INDEX)
    self.grid:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.grid:add()
    self.overlay = gfx.sprite.new(gfx.image.new('assets/backgrounds/ui_overlay'))
    self.overlay:setIgnoresDrawOffset(true)
    self.overlay:setZIndex(TRANSITIONS_Z_INDEX+1)
    self.overlay:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.overlay:add()

    self.timer = pd.timer.new(duration)
    self.fade_timer = pd.timer.new(duration/2, 1, 0, pd.easingFunctions.inCubic)
    
    self.move_overlay_timer = pd.timer.new(duration/2, 0, 400, pd.easingFunctions.outCubic)
    self.move_overlay_timer.delay = duration/2

    self.move_overlay_timer.updateCallback = function(timer)
        self.overlay:moveTo(pd.display.getWidth()/2 + timer.value, pd.display.getHeight()/2)
    end

    
    g_SoundManager:playDegauss()
    g_SoundManager:playMenuSwitch()
    g_SoundManager:stopComputerHum()
    g_SoundManager:getRadio():setVolume(g_SoundManager:getRadio():getVolume()*2)

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
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Unstack').extends(gfx.sprite)

function Unstack:init(duration)

    self.scene = g_SceneManager:getCurrentScene()

    self.timer = pd.timer.new(duration, 0, pd.display.getHeight(), pd.easingFunctions.inQuad)
    self.timer.updateCallback = function(timer)
        self.scene:moveTo(self.scene.x, pd.display.getHeight()/2 - timer.value)
        self:markDirty()
    end

    self:setImage(self.scene.previous_scene_img)
    self:setZIndex(-TRANSITIONS_Z_INDEX)
    self:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self:setIgnoresDrawOffset(true)
    gfx.setDrawOffset(0, 0)

    self.timer.timerEndedCallback = function(timer)
        if self.endCallback then
            self.endCallback()
        end
        self:remove()
    end

end
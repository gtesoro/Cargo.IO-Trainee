local pd <const> = playdate
local gfx <const> = pd.graphics

class('Stack').extends(gfx.sprite)

function Stack:init(duration, blur)
    print('Stacking')
    self.base_img = gfx.getDisplayImage()
    self.scene = g_SceneManager:getCurrentScene()

    self:setImage(self.base_img)
    self:setZIndex(-TRANSITIONS_Z_INDEX)
    self:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self:setIgnoresDrawOffset(true)
    gfx.setDrawOffset(0, 0)

    self.timer = pd.timer.new(duration, 0, pd.display.getHeight(), pd.easingFunctions.outQuint)

    self.timer.updateCallback = function(timer)
        self.scene:moveTo(self.scene.x, -pd.display.getHeight()/2 + timer.value)
    end

    self.timer.timerEndedCallback = function(timer)
        if self.endCallback then
            self.endCallback()
        end
        self.scene:moveTo(self.scene.x, pd.display.getHeight()/2)
        self:remove()
    end

    -- if true then
        -- self.blur_timer = pd.timer.new(duration, 0, 1, pd.easingFunctions.inLinear)

        -- self.blur_timer.updateCallback = function(timer)
        --     self:setImage(self.base_img:blurredImage(timer.value, 1, gfx.image.kDitherTypeScreen))        
        -- end
    -- end

end
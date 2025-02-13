local pd = playdate
local gfx <const> = pd.graphics
class('GameOver').extends(Scene)


function GameOver:init()
    GameOver.super.init(self)
    self.bg = gfx.getDisplayImage()
end

function GameOver:startScene()

    self:setCenter(0.5,0.5)
    self:moveTo(200,120)

    self.bg_sprite = gfx.sprite.new(gfx.image.new(400,240, gfx.kColorWhite))
    self.bg_sprite:moveTo(200,120)
    self.bg_sprite:setZIndex(0)

    table.insert(self.sprites, self.bg_sprite)

    self:initInputs()
    
    self:setImage(self.bg)
    self:setZIndex(1)
    self:add()

end

function GameOver:initInputs()

    self.input_handlers = {

        AButtonUp = function()
            if self.animation_finished then
                g_SceneManager:pushScene(Intro(), 'wipe down')
            end
        end
    }

end

function GameOver:doUpdate()

    if not self.blur_timer then
        self.blur_timer = pd.timer.new(1000, 1, 0, pd.easingFunctions.linear)
        self.blur_timer.updateCallback = function (timer)
            self:setImage(self.bg:fadedImage(timer.value,gfx.image.kDitherTypeBayer8x8))
            self:markDirty()
        end
        self.blur_timer.timerEndedCallback = function ()

            self.animation_finished = true
            self:setImage(gfx.image.new('assets/game_over'))
        end
    end
    
end
local gfx <const> = playdate.graphics
class('Intro').extends(Scene)


function Intro:startScene()

    self:initInputs()


    local bgImage = gfx.image.new("assets/intro")
    assert( bgImage )

    self:setImage(bgImage)
    self:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self:setZIndex(0)
    self:add()

end

function Intro:initInputs()

    self.input_handlers = {

        AButtonUp = function()
            goTo(g_player.current_position.x, g_player.current_position.y, g_player.current_position.z)
        end
    }

end


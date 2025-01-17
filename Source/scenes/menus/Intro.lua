local pd = playdate
local gfx <const> = pd.graphics
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
            g_SystemManager:load()
            goTo(g_SystemManager:getPlayer().current_position.x, g_SystemManager:getPlayer().current_position.y, g_SystemManager:getPlayer().current_position.z, nil, true)
        end
    }

end

function Intro:doUpdate()
    
end


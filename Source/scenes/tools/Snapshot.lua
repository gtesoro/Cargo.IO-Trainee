local pd = playdate
local gfx <const> = pd.graphics
class('Snapshot').extends(Scene)


function Snapshot:startScene()

    local bgImage = gfx.getDisplayImage()
    assert( bgImage )

    self:setImage(bgImage)
    self:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self:add()

end

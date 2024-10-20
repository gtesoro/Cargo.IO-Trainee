import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "scenes/StarSystem"
import "scenes/MiningLaser"

local gfx <const> = playdate.graphics
class('Intro').extends(playdate.graphics.sprite)

function Intro:init()

    self.name = "Intro"

    local bgImage = gfx.image.new("sprites/intro")
    assert( bgImage )

    self.test_sprite = gfx.sprite.new(gfx.image.new(400,240, gfx.kColorClear))
    gfx.pushContext(self.test_sprite:getImage())
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRect(0,0,400,240)
    gfx.popContext()
    self.test_sprite:setZIndex(30000)
    self.test_sprite:moveTo(200,120)

    self:setImage(bgImage)
    self:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self:setZIndex(0)
    self:add()

end

function Intro:load()
    
end

function Intro:update()

    if playdate.buttonJustReleased(playdate.kButtonA) then
        --self.test_sprite:add()
        g_SceneManager:pushScene(MiningLaser(), 'hwipe')
    end

end
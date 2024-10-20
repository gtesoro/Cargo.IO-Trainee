import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
class('GameOver').extends(playdate.graphics.sprite)

function GameOver:init(stage)

    self.stage = stage

    self:setIgnoresDrawOffset(true)
    self.image = gfx.image.new(playdate.display.getWidth(), playdate.display.getHeight())
    gfx.pushContext(self.image)
        gfx.setColor(playdate.graphics.kColorBlack)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
        gfx.fillRect(0, 0, self.image:getSize())
        gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
        local _scoreStr = string.format("*Game Over*\n*%i*", self.stage.score)
        gfx.drawTextAligned(_scoreStr,playdate.display.getWidth()/2, playdate.display.getHeight()*0.3, kTextAlignment.center)

        local _scoreStr = "*Press A to restart*"
        gfx.drawTextAligned(_scoreStr,playdate.display.getWidth()/2, playdate.display.getHeight()*0.8, kTextAlignment.center)
        gfx.setImageDrawMode(playdate.graphics.kDrawModeCopy)
    gfx.popContext()

    self:setImage(self.image)
    self:moveTo(200, 120)
	self:setZIndex(32766)
    self:add()

end

function GameOver:update()

    if playdate.buttonJustReleased(playdate.kButtonA) then
        self:remove()
        self.stage:startStage()
    end

end
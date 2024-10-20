import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
class('ObjectiveUI').extends(playdate.graphics.sprite)

function ObjectiveUI:updateImg()

    local _scale = (self.size - self.inner_offset) / self.stage.current_target.animation:image().width

    gfx.clear()

    gfx.setColor(playdate.graphics.kColorWhite)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)

    gfx.fillRect(self.float , self.float , self.inner_offset + self.size, self.inner_offset + self.size)

    gfx.setColor(playdate.graphics.kColorBlack)
    gfx.fillRect(0, 0, self.inner_offset + self.size, self.inner_offset + self.size)

    self.stage.current_target.animation:image():scaledImage(_scale):draw(self.inner_offset, self.inner_offset)

    gfx.setColor(playdate.graphics.kColorWhite)
    gfx.setLineWidth(1)
    
    if self.stage.current_target.outline then
        gfx.drawCircleAtPoint((self.size - self.inner_offset)/2+self.inner_offset, (self.size - self.inner_offset)/2 + self.inner_offset, (self.size - self.inner_offset)/2 )
    end

    gfx.drawRect(0, 0, self.inner_offset + self.size, self.inner_offset + self.size)
end

function ObjectiveUI:init(stage)

    self.stage = stage

    self.inner_offset = 5
    self.float = 2
    self.size = 50

    self.image = gfx.image.new(self.size + self.float + self.inner_offset, self.size + self.float + self.inner_offset, playdate.graphics.kColorClear)
    gfx.pushContext(self.image)
        self:updateImg()
    gfx.popContext()

    self:setImage(self.image)
	self:setZIndex(UI_Z_INDEX)
    self:setIgnoresDrawOffset(true)

end

function ObjectiveUI:update()
    gfx.pushContext(self.image)
        self:updateImg()
    gfx.popContext()
end
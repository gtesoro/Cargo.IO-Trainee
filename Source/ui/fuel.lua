import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
class('FuelUI').extends(playdate.graphics.sprite)

function FuelUI:updateImg()
    gfx.clear()
    gfx.setColor(playdate.graphics.kColorWhite)
    gfx.setLineWidth(3)
    gfx.drawLine(playdate.display.getWidth()/2 - self.ship.fuel, playdate.display.getHeight() * 0.95, playdate.display.getWidth()/2 + self.ship.fuel, playdate.display.getHeight() * 0.95)
end

function FuelUI:init(ship)

    self.ship = ship

    self.image = gfx.image.new(playdate.display.getWidth(), playdate.display.getHeight())
    gfx.pushContext(self.image)
        self:updateImg()
    gfx.popContext()

    self:setImage(self.image)
    self:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
	self:setZIndex(UI_Z_INDEX)
    self:setIgnoresDrawOffset(true)
    self:add()

end

function FuelUI:update()

    gfx.pushContext(self.image)
        self:updateImg()
    gfx.popContext()
end
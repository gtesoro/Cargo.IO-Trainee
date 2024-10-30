import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

class('SolarBg').extends(playdate.graphics.sprite)

function SolarBg:init(stage)
    
    self.stage = stage

    self.image = gfx.image.new(playdate.display.getWidth(), playdate.display.getHeight())

    self.bg_sprite = gfx.sprite.new(gfx.image.new("assets/solar_bg"))

    self.bg_sprite:add()
    self.bg_sprite:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.bg_sprite:setZIndex(-1)


    self:setImage(self.image)
    self:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self:setZIndex(0)
    self:add()

end

function SolarBg:remove()
    self.bg_sprite:remove()
    SolarBg.super.remove(self)
end

function SolarBg:update()
    local center_x = playdate.display.getWidth()/2
    local center_y = playdate.display.getHeight()/2

    gfx.pushContext(self.image)
        gfx.clear()
        gfx.setColor(playdate.graphics.kColorBlack)
        gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
        gfx.fillCircleAtPoint(center_x, center_y, 15+math.random(-1, 1))

        local _scoreStr = string.format("*%i*", self.stage.score)
        local _w, _h = gfx.getTextSize(_scoreStr)
        gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
        gfx.drawTextAligned(_scoreStr, center_x, center_y*0.93, kTextAlignment.center)

        for i=1,#self.stage.planets do
            local p = self.stage.planets[i]
            gfx.setColor(playdate.graphics.kColorWhite)
            --gfx.setDitherPattern(0.8, gfx.image.kDitherTypeBayer2x2)
            gfx.setLineWidth(2)
            gfx.drawEllipseInRect(p.cx - p.h_radius, p.cy - p.v_radius, 2 * p.h_radius, 2 * p.v_radius)
        end

    gfx.popContext()
end

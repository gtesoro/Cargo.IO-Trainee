import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = pd.graphics
class('FuelUI').extends(playdate.graphics.sprite)

function FuelUI:updateImg()
    gfx.clear()
    gfx.setColor(playdate.graphics.kColorWhite)
    gfx.setLineWidth(3)
    self.fuel_sheet:getImage(self.current_fuel_img):fadedImage(self.alpha, gfx.image.kDitherTypeDiagonalLine):drawAnchored(playdate.display.getWidth()/2, playdate.display.getHeight() * 0.95, 0.5, 0.5)
end

function FuelUI:init(ship)

    self.ship = ship

    self.fuel_sheet = gfx.imagetable.new('assets/fuel')

    self.current_fuel_img = -1
    self.show_timer = nil
    self.alpha = 1
    self.image = gfx.image.new(playdate.display.getWidth(), playdate.display.getHeight())

    self:setImage(self.image)
    self:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
	self:setZIndex(UI_Z_INDEX)
    self:setIgnoresDrawOffset(true)
    self:add()

end

function FuelUI:update()

    local new_fuel_img = clamp(math.floor(10*(g_player.ship.fuel_current/g_player.ship.fuel_capacity))+2, 1, 11)
    if new_fuel_img ~= self.current_fuel_img then

        self:setVisible(true)

        self.current_fuel_img = new_fuel_img
        local _fade_in_timer = pd.timer.new(500, 0, 1, pd.easingFunctions.inLinear)

        _fade_in_timer.updateCallback = function (timer)
            self.alpha = timer.value
            gfx.pushContext(self.image)
                self:updateImg()
            gfx.popContext()
        end

        _fade_in_timer.timerEndedCallback = function ()

            local _show_timer = pd.timer.new(3000)
            _show_timer.timerEndedCallback = function ()
                local _fade_out_timer = pd.timer.new(500, 1, 0, pd.easingFunctions.inLinear)
                _fade_out_timer.updateCallback = function (timer)
                    self.alpha = timer.value
                    gfx.pushContext(self.image)
                        self:updateImg()
                    gfx.popContext()
                end
                _fade_out_timer.timerEndedCallback = function ()
                    self.alpha = 1 
                    self:setVisible(false)
                end
            end

        end
        
    end

    
end
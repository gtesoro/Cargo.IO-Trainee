local pd <const> = playdate
local gfx <const> = pd.graphics

class('FuelStation').extends(GenericMenu)

function FuelStation:init()

    FuelStation.super.init(self)
    
    self.data.options = {
        {
            name = 'Refuel - 10C',
            callback = function ()
                if g_SystemManager:getPlayer():chargeMoney(10) then
                    g_SystemManager:getPlayer().ship.fuel_current = g_SystemManager:getPlayer().ship.fuel_capacity
                    g_NotificationManager:notify("Fuel Refilled")
                end
            end
        },
    }

    self.data.right_side = AnimatedSprite('assets/objects/fuel_station', 100)
    
end


local pd <const> = playdate
local gfx <const> = pd.graphics

class('FuelStation').extends(GenericMenu)

function FuelStation:init()

    FuelStation.super.init(self)
    
    self.data.options = {
        {
            name = 'Refuel',
            callback = function ()
                local pop_up_data = {
                    text = "Do you want to refuel for 100C?",
                    options = {
                        {
                            name = "Yes",
                            callback = function ()
                                g_player.ship.fuel_current = g_player.ship.fuel_capacity
                            end
                        },
                        {
                            name = "No",
                        }
                    }
                }
                g_SceneManager:pushScene(Popup(pop_up_data))
            end
        },
    }

    self.data.right_side = AnimatedSprite('assets/objects/fuel_station', 100)
    
end


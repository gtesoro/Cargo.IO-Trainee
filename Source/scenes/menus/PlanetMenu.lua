local pd <const> = playdate
local gfx <const> = pd.graphics

facility_v_options = {}

facility_v_options['Cloning Facility'] = {
    name = 'Namaste Cloning',
    callback = function ()
        g_SceneManager:pushScene(CloningFacility(), 'between menus')
    end
}

facility_v_options['Fuel Station'] = {
    name = 'Fuel Station',
    callback = function ()
        g_SceneManager:pushScene(FuelStation(), 'between menus')
    end
}

facility_v_options['Market'] = {
    name = 'Market',
    callback = function ()
        g_SceneManager:pushScene(Shop(
            {
                shop_items = {
                    FuelCell()
                }
            }
        ), 'between menus')
    end
}


class('PlanetMenu').extends(GenericMenu)

function PlanetMenu:init(data)

    PlanetMenu.super.init(self)

    self.data = data

    self.data.options = self:getOptions(self.data.facilities)
    
end

function PlanetMenu:getOptions(facilities)

    local _ret = {}

    for k,v in pairs(facilities) do
        _ret[#_ret+1] = facility_v_options[v]
    end

    return _ret

end

function PlanetMenu:preload()

    self.data.right_side = AnimatedSprite(self.data.img_hd, 100)
    
end
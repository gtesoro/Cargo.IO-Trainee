local pd <const> = playdate
local gfx <const> = pd.graphics

facility_v_options = {}

facility_v_options['CloningFacility'] = {
    name = 'Namaste Cloning',
    callback = function ()
        g_SceneManager:pushScene(CloningFacility(), 'between menus')
    end
}

facility_v_options['Starport'] = {
    name = 'Starport',
    callback = function ()
        g_SceneManager:pushScene(Starport(), 'between menus')
    end
}

facility_v_options['Market'] = {
    name = 'Market',
    callback = function ()
        g_SceneManager:pushScene(Market(
            {
                shop_items = {
                    Radar(),
                    Radio(),
                    FuelCell(),
                    YggdrasilAtlas()
                }
            }
        ), 'between menus')
    end
}

facility_v_options['CargoHub'] = {
    name = 'Quick Lock Hub',
    callback = function ()
        g_SceneManager:pushScene(CargoHub(), 'between menus')
    end
}


class('PlanetMenu').extends(GenericMenu)

function PlanetMenu:init(data)

    self.b_callback = function ()
        g_SystemManager:getPlayer():setCurrentPlanet(nil)
    end

    PlanetMenu.super.init(self)

    self.data = data

    self.data.options = function ()
        
        return self:getOptions(self.data.facilities)
    end

    
end

function PlanetMenu:startScene()

    PlanetMenu.super.startScene(self)

    local _delay = self.data.img_hd_delay or 100

    self:setRightSide( AnimatedSprite(self.data.img_hd, _delay))
    
    self.label = TextBox(self.data.name, self.list_box.width, 10)
    self.label:setCenter(0.5, 1)
    self.label:moveTo(self.right_side.x, 120 + 75)
    self.label:setZIndex(3)

    self.label_shadow = getShadowSprite(self.label)
    self.label_shadow:setZIndex(2)
    self.label_shadow:add()
    self.label:add()
    table.insert(self.sprites, self.label)
    table.insert(self.sprites, self.label_shadow)


end

function PlanetMenu:add()
    PlanetMenu.super.add(self)
    g_SystemManager:getPlayer():setCurrentPlanet(self.data)
end

function PlanetMenu:getOptions(facilities)

    local _ret = {}

    for k,v in pairs(facilities) do
        _ret[#_ret+1] = facility_v_options[v]
    end

    return _ret

end

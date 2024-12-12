local pd <const> = playdate
local gfx <const> = pd.graphics

facility_v_options = {}

facility_v_options['CloningFacility'] = {
    name = 'Namaste Cloning',
    callback = function ()
        g_SceneManager:pushScene(CloningFacility(), 'between menus')
    end
}

facility_v_options['FuelStation'] = {
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
    
    self.label = TextBox(self.data.name, self.list_box.width, 10)
    self.label:setCenter(0.5, 1)
    self.label:moveTo(self.right_side.x, 120 + 75)
    self.label:setZIndex(3)

    self.label_shadow = getShadowSprite(self.label)
    self.label_shadow:setZIndex(2)
    self.label_shadow:add()
    self.label:add()
    self.sprites:append(self.label)
    self.sprites:append(self.label_shadow)

end

function PlanetMenu:add()

    PlanetMenu.super.add(self)
    g_SystemManager:getPlayer():setCurrentPlanet(self.data)
    
end

function PlanetMenu:remove()
    PlanetMenu.super.remove(self)
    collectgarbage('collect')
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
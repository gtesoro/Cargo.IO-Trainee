local pd <const> = playdate
local gfx <const> = pd.graphics

facility_v_options = {}

facility_v_options[FACILITY_CLONING] = {
    name = 'Namaste Cloning',
    callback = function ()
        g_SceneManager:pushScene(CloningFacility(), 'between menus')
    end
}

facility_v_options[FACILITY_STARPORT] = {
    name = 'Starport',
    callback = function ()
        g_SceneManager:pushScene(Starport(), 'between menus')
    end
}

facility_v_options[FACILITY_MARKET] = {
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

facility_v_options[FACILITY_CARGO] = {
    name = 'Quick Lock Hub',
    callback = function ()
        g_SceneManager:pushScene(CargoHub(), 'between menus')
    end
}


class('LocationMenu').extends(GenericMenuList)

function LocationMenu:init(data)

    self.b_callback = function ()
        g_SystemManager:getPlayerData():setCurrentLocation(nil)
    end

    LocationMenu.super.init(self)

    self.data = data

    self.data.options = function ()
        
        return self:getOptions(self.data.facilities)
    end

    
end

function LocationMenu:startScene()

    LocationMenu.super.startScene(self)

    local _delay = self.data.img_delay or 100

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

function LocationMenu:add()
    LocationMenu.super.add(self)
    g_SystemManager:getPlayerData():setCurrentLocation(self.data)
end

function LocationMenu:getOptions(facilities)

    local _ret = {}

    for k,v in pairs(facilities) do
        _ret[#_ret+1] = facility_v_options[v]
    end

    return _ret

end

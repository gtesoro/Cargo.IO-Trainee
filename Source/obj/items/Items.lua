local pd <const> = playdate
local gfx <const> = pd.graphics

class('Item').extends(Stateful)

function Item:init()
    print('Item Init', Item.super.className)
    Item.super.init(self)

    self.price_min = 0
    self.price_max = 0

    self.options = {
        {
            name="Description",
            callback = function (_self)
                _self:remove()
                g_SceneManager:pushScene(Popup({text=self.description}), 'stack')
            end
        }
    }
end

function Item:getCurrentPrice()
    math.randomseed(g_SystemManager:getPlayer().cycle + stringToSeed(self.className))
    return  math.random(self.price_min, self.price_max)
end

function Item:getOptions()
    return self.options
end

function Item:onGain()
    g_NotificationManager:notify(string.format("Item Gained: %s", self.name))
end

function Item:onLose()
    g_NotificationManager:notify(string.format("Item Lost: %s", self.name))
end

function Item:getOptions()
    return self.options
end

function Item:getImage()
    return self.image
end


class('FuelCell').extends(Item)

function FuelCell:init()

    FuelCell.super.init(self)

    self.image = gfx.image.new("assets/items/fuel_cell")

    self.type = "Utility"
    self.usage = "Space Travel"
    self.price_max = 500
    self.price_min = 250

    self.name = "Fuel Cell"

    self.attrs = {
        {
            "Type",  self.type 
        },
        {
            "Usage", self.usage
        },
        {
            "Price", string.format("%s-%s", self.price_min, self.price_max)
        }
    }

    self.description = "Fully replenishes the fuel on your ship.\nContains a whole ecosystem that produces carbon fuel at a steady pace. Nifty."

    local _options = {
        {
            name="Use",
            blacklist={
                ShopInventory=true
            },
            callback = function (_self)
                
                g_SystemManager:getPlayer().ship.fuel_current = g_SystemManager:getPlayer().ship.fuel_capacity
                g_NotificationManager:notify("Fuel Refilled")
                _self:remove()
                _self.data.parent:focus()
            end
        }
    }

    self.options = tableConcat(_options, self.options)

end

class('Radar').extends(Item)

function Radar:init()

    Radar.super.init(self)

    self.image = gfx.image.new("assets/items/sonar")

    self.type = "Utility"
    self.usage = "Location"
    self.price_max = 1000
    self.price_min = 800

    self.name = "Sonar"

    self.attrs = {
        {
            "Type",  self.type 
        },
        {
            "Usage", self.usage
        },
        {
            "Price", string.format("%s-%s", self.price_min, self.price_max)
        }
    }

    self.description = "Locates objects in the current system.\nAn example of pre-leap technology that is still widely used."

    local _options = {
        {
            name="Use",
            blacklist={
                ShopInventory=true
            },
            callback = function (_self)
                _self:remove()
                g_SceneManager:popToSystem()
                
                local _sprs = g_SceneManager:getCurrentScene().sprites:getLength()
                g_NotificationManager:notify(string.format("Detected %i objects", _sprs), 3000)
            end
        }
    }

    self.options = tableConcat(_options, self.options)

end

class('Radio').extends(Item)

function Radio:init()

    Radar.super.init(self)

    self.image = gfx.image.new("assets/items/radio")

    self.player = pd.sound.fileplayer.new("assets/music/Im_Gonna_Get_Me_A_Man_Thats_All", 10)

    self.type = "Utility"
    self.usage = "Entertaiment"
    self.price_max = 1000
    self.price_min = 800

    self.name = "Sonar"

    self.attrs = {
        {
            "Type",  self.type 
        },
        {
            "Usage", self.usage
        },
        {
            "Price", string.format("%s-%s", self.price_min, self.price_max)
        }
    }

    self.description = "Plays music.\nThe universe is full of waves, this pre-leap device turns them into sound."

    local _options = {
        {
            name="Use",
            blacklist={
                ShopInventory=true
            },
            callback = function (_self)
                
                if self.player:isPlaying() then
                    self.player:stop()
                else
                    self.player:play(0)
                end
                _self:remove()
                _self.data.parent:focus()
            end
        }
    }

    self.options = tableConcat(_options, self.options)

end

class('Neodymium').extends(Item)

function Neodymium:init()

    Neodymium.super.init(self)

    self.image = gfx.image.new("assets/items/neodymium")

    self.type = "Metall"
    self.usage = "Industry"
    self.price_max = 100
    self.price_min = 50

    self.name = self.className

    self.attrs = {
        {
            "Type",  self.type 
        },
        {
            "Usage", self.usage
        },
        {
            "Price", string.format("%s-%s", self.price_min, self.price_max)
        }
    }

    self.description = "TBD"

end

class('Yttrium').extends(Item)

function Yttrium:init()

    Yttrium.super.init(self)

    self.image = gfx.image.new("assets/items/yttrium")

    self.type = "Metall"
    self.usage = "Industry"
    self.price_max = 100
    self.price_min = 50

    self.name = self.className

    self.attrs = {
        {
            "Type",  self.type 
        },
        {
            "Usage", self.usage
        },
        {
            "Price", string.format("%s-%s", self.price_min, self.price_max)
        }
    }

    self.description = "TBD"

end

class('Scandium').extends(Item)

function Scandium:init()

    Scandium.super.init(self)

    self.image = gfx.image.new("assets/items/scandium")

    self.type = "Metall"
    self.usage = "Industry"
    self.price_max = 100
    self.price_min = 50

    self.name = self.className

    self.attrs = {
        {
            "Type",  self.type 
        },
        {
            "Usage", self.usage
        },
        {
            "Price", string.format("%s-%s", self.price_min, self.price_max)
        }
    }

    self.description = "TBD"

end
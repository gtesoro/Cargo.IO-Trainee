local pd <const> = playdate
local gfx <const> = pd.graphics

class('Item').extends(Stateful)

function Item:init()
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

function Item:getAttrs()
    return {
        {
            "Type",  self.type 
        },
        {
            "Usage", self.usage
        },
        {
            "Price", table.concat({self.price_min,'-',self.price_max})
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
    
end

function Item:onLose()

end

function Item:getOptions()
    return self.options
end

function Item:getImage()
    return self.image
end

class('Cross').extends(Item)

function Cross:init()
    Cross.super.init(self)

    self.image = gfx.image.new("assets/cross")
    self.name = "Remove"

end

function Cross:getAttrs()
    return {
    }
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

    self.type = "Utility"
    self.usage = "Entertaiment"
    self.price_max = 1000
    self.price_min = 800

    self.name = "Radio"

    self.description = "Plays music.\nThe universe is full of waves, this pre-leap device turns them into sound."

    local _options = {
        {
            name="Use",
            blacklist={
                ShopInventory=true
            },
            callback = function (_self)
                g_SoundManager:switchRadio()
                _self:remove()
                _self.data.parent:focus()
            end
        }
    }

    self.options = tableConcat(_options, self.options)

end

class('Laser').extends(Item)

function Laser:init()

    Laser.super.init(self)

    self.image = gfx.image.new("assets/items/Laser")

    self.type = "Equipment"
    self.usage = "Mining"
    self.price_max = 100
    self.price_min = 50

    self.name = self.className

    self.description = "TBD"

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

    self.description = "TBD"

end

class('QlCargo').extends(Item)

function QlCargo:init(destination)

    QlCargo.super.init(self)

    self.image = gfx.image.new("assets/items/ql_cargo")

    self.type = "Logistics"
    self.usage = "Transport"
    self.price_max = 1
    self.price_min = 1

    self.destination = destination

    self.name = "Quick Lock Cargo"

    self.description = "TBD"

end

function QlCargo:load(state)
    QlCargo.super.load(self, state)
    self.destination = self.state.destination
end

function QlCargo:save()
    self.state.destination = self.destination
    return QlCargo.super.save(self)
end

function QlCargo:getAttrs()
    return {
        {
            "Type",  self.type 
        },
        {
            "Usage", self.usage
        },
        {
            "Price", string.format("%s-%s", self.price_min, self.price_max)
        },
        {
            "Destination", self.destination.name
        }
    }
end

class('YggdrasilAtlas').extends(Item)

function YggdrasilAtlas:init()

    YggdrasilAtlas.super.init(self)

    self.image = gfx.image.new("assets/items/atlas")

    self.type = "Data"
    self.usage = "Codex"
    self.price_max = 100
    self.price_min = 50

    self.name = "Yggdrasil Atlas"

    self.description = "An atlas containing information about the Yggdrasil system. Very useful if one needs to get around and know what's where."

    local _options = {
        {
            name="Use",
            blacklist={
                ShopInventory=true
            },
            callback = function (_self)
                g_SystemManager:getPlayer().codex.systems[#g_SystemManager:getPlayer().codex.systems+1] = "Yggdrasil"
                for k, v in pairs(g_SystemManager:getSystemByName("Yggdrasil").planets) do
                    g_SystemManager:getPlayer().codex.planets[#g_SystemManager:getPlayer().codex.planets+1] = v.name
                end
                g_NotificationManager:notify('Codex Updated')
                g_SystemManager:getPlayer():removeFromInventory(_self.data.parent.item_grid:getSelection())
                _self.data.parent.item_grid:drawGrid()
                _self.data.parent:focus()
                _self:remove()
            end
        }
    }

    self.options = tableConcat(_options, self.options)

end
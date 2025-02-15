local pd <const> = playdate
local gfx <const> = pd.graphics

class('ItemContainer').extends(AnimatedSprite)

function ItemContainer:init(item)

    ItemContainer.super.init(self, 'assets/items/container')
    self:setCollideRect(0,0, self:getSize())
    self.interactuable = true
    
    self.item = item

end

function ItemContainer:interact(data)
    if g_SystemManager:getPlayerData():addToInventory(self.item) then
        self:remove()
    end
end

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
                g_SceneManager:pushScene(Popup({text=self.description}))
            end
        }
    }
end

function Item:getAttrs()
    local _self = self
    return {
        {
            "Type",  self.type 
        },
        {
            "Usage", self.usage
        },
        {
            "Price Range", table.concat({self.price_min,'-',self.price_max})
        },
        {
            "Price", function ()
                return string.format("%i", _self:getCurrentPrice()) 
            end
        }
    }
end

function Item:getCurrentPrice()
    math.randomseed(g_SystemManager:getPlayerData().cycle + stringToSeed(self.className))
    return  math.random(self.price_min, self.price_max)
end

function Item:getOptions()
    return self.options
end

function Item:onGain()
    
end

function Item:onEquip()
    
end

function Item:onUnequip()
    
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
                
                g_SystemManager:getPlayerData().ship.fuel_current = g_SystemManager:getPlayerData().ship.fuel_capacity
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

    self.name = "Radar"

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

class('LeapEngine').extends(Item)

function LeapEngine:init()

    Laser.super.init(self)

    self.name = "Leap Engine"

    self.image = gfx.image.new("assets/items/leap_engine")

    self.type = "Equipment"
    self.usage = "Leap"
    self.price_max = 10000
    self.price_min = 9000

    self.description = "It allows to performed leaps through space. A Friedenmarke is required for its operation."

end

function LeapEngine:onEquip()
    g_NotificationManager:notify('New Function: Leap')
end

function LeapEngine:onUnequip()
    g_NotificationManager:notify('Function Lost: Leap')
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
    local _attrs = QlCargo.super.getAttrs(self)
    table.insert(_attrs, {
        "Destination", self.destination.name
    })
    return _attrs
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
                table.insert(g_SystemManager:getPlayerData().codex.systems, "Yggdrasil")
                for k, v in pairs(g_SystemManager:getSystemByName("Yggdrasil").locations) do
                    table.insert(g_SystemManager:getPlayerData().codex.locations, v.name)
                end
                g_NotificationManager:notify('Codex Updated')
                g_SystemManager:getPlayerData():removeFromInventory(_self.data.parent.item_grid:getSelection())
                _self.data.parent.item_grid:drawGrid()
                _self.data.parent:focus()
                _self:remove()
            end
        }
    }

    self.options = tableConcat(_options, self.options)

end
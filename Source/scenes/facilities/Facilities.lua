local pd <const> = playdate
local gfx <const> = pd.graphics

class('CargoHub').extends(GenericMenu)

function CargoHub:init()

    CargoHub.super.init(self)
    
    self.data.options = {
        {
            name = 'Delivery Contract',
            callback = function ()
                local _todays_contract = false

                local _cycle = g_SystemManager:getPlayer().cycle
                for k,v in pairs(g_SystemManager:getPlayer():getContractByType('DeliveryContract')) do
                    print(k, v)
                    printTable(v)
                    if v.state.sign_date == _cycle then
                        _todays_contract = true
                    end
                end
                if _todays_contract then
                    createPopup({text='You already have the current delivery contract for this cycle.\n\nCome back later!'})
                else
                    getSignContractCallback(DeliveryContract())()
                end

                print('Done!')
            end
        },
    }

    self.data.right_side = gfx.sprite.new(gfx.image.new('assets/facilities/cargo_hub'))
    
end

class('CloningFacility').extends(GenericMenu)

function CloningFacility:init()

    CloningFacility.super.init(self)

    
    self.data.options = {
        {
            name = 'Sign Contract',
            callback = getSignContractCallback(CloningContract())
        },
        {
            name = 'Update Memory',
            callback = function ()
                local _contract = g_SystemManager:getPlayer():getContractByType('CloningContract')[1]
                if _contract then 
                    _contract:updateMemory()
                else
                    createPopup({text='You dont have a contract with Namaste Cloning.\nWe welcome you to sign one.'})
                end
            end
        }
    } 
end

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

class('Shop').extends(GenericMenu)

function Shop:init(data)

    Shop.super.init(self, data)

    self.data.options = {
        {
            name = 'Buy',
            callback = function ()
                g_SceneManager:pushScene(ShopInventory(self.data), 'between menus')
            end
        },
        {
            name = 'Sell',
            callback = function ()
                g_SceneManager:pushScene(ShopPlayerInventory(self.data), 'between menus')
            end
        }
    }

    self.data.right_side = gfx.sprite.new(gfx.image.new('assets/backgrounds/facilities/shop'))
    
end

class('ShopInventory').extends(GenericInventory)

function ShopInventory:init(data)

    ShopInventory.super.init(self, data)

    self.data.items = self.data.shop_items

    self.data.item_panel = ItemPanelShop(180, 150)

    self.data.context_options = {
        {
            name="Buy",
            callback = function (_self)
                local item = _self.data.parent.item_grid:getSelection()

                if g_SystemManager:getPlayer():chargeMoney(item:getCurrentPrice()) then
                    g_SystemManager:getPlayer():addToInventory(item)

                    table.remove(self.data.items, _self.data.parent.item_grid:getSelectionIndex())
                    _self.data.parent.item_grid:drawGrid()
                    _self.data.parent.item_grid:focus()
                    _self:remove()
                end
            end
        }
    }
    
end

class('ShopPlayerInventory').extends(GenericInventory)

function ShopPlayerInventory:init(data)

    ShopPlayerInventory.super.init(self, data)

    self.data.items = g_SystemManager:getPlayer().inventory.items
    self.data.item_panel = ItemPanelShop(180, 150)

    self.data.context_options = {
        {
            name="Sell",
            callback = function (_self)
                local item = _self.data.parent.item_grid:getSelection()
                local price = item:getCurrentPrice()
                g_SystemManager:getPlayer():gainMoney(price)
                g_SystemManager:getPlayer():removeFromInventory(item)
                _self.data.parent.item_grid:drawGrid()
                _self.data.parent:focus()
                _self:remove()
            end
        }
    }
    
end



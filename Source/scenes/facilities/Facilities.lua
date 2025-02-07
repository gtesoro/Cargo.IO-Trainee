local pd <const> = playdate
local gfx <const> = pd.graphics

class('CargoHub').extends(GenericMenu)

function CargoHub:init()

    CargoHub.super.init(self)

    self.data.options = {
        {
            name= "Deliver",
            callback = function ()

                local _items = {}
                for k,v in pairs(g_SystemManager:getPlayer().inventory.items) do
                    if v:isa(QlCargo) then
                        table.insert(_items, v)
                    end
                end

                if #_items == 0 then
                    createPopup({text="No cargo avaialble in inventory."})
                else

                    g_SceneManager:pushScene(GenericInventory({
                        items=_items,
                        rows=1,
                        columns=#_items,
                        a_callback= function (_self)
                            local _item = _self:getSelection()
                            if _item.destination.name ~= g_SystemManager:getPlayer():getCurrentLocation().name then
                                createPopup({text='Wrong destination'})
                            else
                                g_SystemManager:getPlayer():removeFromInventory(_item)
                                for k,v in pairs(g_SystemManager:getPlayer():getContractByType("DeliveryContract")) do
                                    g_SystemManager:getPlayer():removeContract(v)
                                    v:onComplete()
                                end
                            end
                            g_SceneManager:popScene('between menus')
                        end
                    }),'between menus')
                end

            end
        },
        {
            name = 'System Delivery Contract',
            callback = function ()
                if #g_SystemManager:getPlayer():getContractByType('DeliveryContract') > 0 then
                    createPopup({text='You can only have one Quick Lock delivery contract at the same time.'})
                else
                    local _contract = DeliveryContract()
                    _contract:generateSystemContract()
                    getSignContractCallback(_contract)()
                end
                
            end
        }
    }
    local _locations = g_SystemManager:getPlayer():getCurrentSystem().locations
    if _locations and #_locations > 1 then
        table.insert(self.data.options, {
            name = 'Local Delivery Contract',
            callback = function ()
                if #g_SystemManager:getPlayer():getContractByType('DeliveryContract') > 0 then
                    createPopup({text='You can only have one Quick Lock delivery contract at the same time.'})
                else
                    local _contract = DeliveryContract()
                    _contract:generateLocalContract()
                    getSignContractCallback(_contract)()
                end
                
            end
        })
    end

    self.data.right_side = gfx.sprite.new(getImageWithDitherMask('assets/facilities/cargo_hub'))

end

class('CargoHubDelivery').extends(GenericInventory)

function CargoHubDelivery:init(data)

    CargoHubDelivery.super.init(self, data)

    self.data.items = g_SystemManager:getPlayer().inventory.items

    self.data.context_options = {
        {
            name="Deliver",
            callback = function (_self)
                local item = _self.data.parent.item_grid:getSelection()
                if not item:isa(QlCargo) then
                    createPopup({text='This hub only accepts Quick Lock cargo'})
                else
                    if item.destination.name ~= g_SystemManager:getPlayer():getCurrentLocation().name then
                        createPopup({text='Wrong destination'})
                    else
                        g_SystemManager:getPlayer():removeFromInventory(item)
                        for k,v in pairs(g_SystemManager:getPlayer():getContractByType("DeliveryContract")) do
                            g_SystemManager:getPlayer():removeContract(v)
                            v:onComplete()
                        end
                    end
                end
                _self.data.parent.item_grid:drawGrid()
                _self.data.parent:focus()
                _self:remove()
            end
        }
    }
    
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

    self.data.right_sise_x = 200
    self.data.right_sise_y = 120

    self.data.right_side = gfx.sprite.new(getImageWithDitherMask('assets/facilities/namaste', true))
end

class('Starport').extends(GenericMenu)

function Starport:init()

    Starport.super.init(self)
    
    self.data.options = {
        {
            name = 'Garage',
            callback = function ()
                g_SceneManager:pushScene(LoadoutMenu({items=g_SystemManager:getPlayer().ship.loadout.items, read_only=false}), 'between menus')
            end
        },
        {
            name = 'Refuel - 10C',
            callback = function ()
                if g_SystemManager:getPlayer():chargeMoney(10) then
                    g_SystemManager:getPlayer().ship.fuel_current = g_SystemManager:getPlayer().ship.fuel_capacity
                    g_NotificationManager:notify("Fuel Refilled")
                end
            end
        },
        {
            name = 'Repair Hull - 100C',
            callback = function ()
                if g_SystemManager:getPlayer().ship.hull_current == g_SystemManager:getPlayer().ship.hull_total then
                    g_NotificationManager:notify("Hull does not need repair")
                else
                    if g_SystemManager:getPlayer():chargeMoney(100) then
                        g_SystemManager:getPlayer().ship.hull_current = g_SystemManager:getPlayer().ship.hull_total
                        g_NotificationManager:notify("Hull Repaired")
                    end
                end
            end
        },
    }
    self.data.right_sise_x = 200
    self.data.right_sise_y = 120

    self.data.right_side = gfx.sprite.new(getImageWithDitherMask('assets/facilities/starport'))
    
end

class('Market').extends(GenericMenu)

function Market:init(data)

    Market.super.init(self, data)

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

    self.data.right_sise_x = 200
    self.data.right_sise_y = 120

    self.data.right_side = gfx.sprite.new(getImageWithDitherMask('assets/facilities/market_2', true)) --gfx.sprite.new(gfx.image.new('assets/facilities/market'))
    
end

class('ShopInventory').extends(GenericInventory)

function ShopInventory:init(data)

    ShopInventory.super.init(self, data)

    self.data.items = self.data.shop_items

    self.data.context_options = {
        {
            name="Buy",
            callback = function (_self)
                local item = _self.data.parent.item_grid:getSelection()

                if g_SystemManager:getPlayer():chargeMoney(item:getCurrentPrice()) then
                    g_SystemManager:getPlayer():addToInventory(item)

                    --table.remove(self.data.items, _self.data.parent.item_grid:getSelectionIndex())
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



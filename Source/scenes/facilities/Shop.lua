
local pd <const> = playdate
local gfx <const> = pd.graphics

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
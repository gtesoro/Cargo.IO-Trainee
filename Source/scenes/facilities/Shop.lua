
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Shop').extends(GenericMenu)

function Shop:init()

    Shop.super.init(self)
    
    self.data.options = {
        {
            name = 'Buy',
            callback = function ()
                g_SceneManager:pushScene(ShopInventory())
            end
        },
        {
            name = 'Sell',
            callback = function ()
                g_SceneManager:pushScene(ShopPlayerInventory())
            end
        }
    }

    self.data.right_side = gfx.sprite.new(gfx.image.new('assets/backgrounds/facilities/shop'))
    
end

class('ShopInventory').extends(GenericInventory)

function ShopInventory:init()

    ShopInventory.super.init(self)

    self.data.items = {}

    self.data.item_panel = ItemPanelShop(180, 150)

    self.data.context_options = {
        {
            name="Buy",
            callback = function (_self)
                local item = _self.data.parent.item_grid:getSelection()
                g_player.inventory.items[#g_player.inventory.items+1] = item
                table.remove(self.data.items, _self.data.parent.item_grid:getSelectionIndex())
                _self.data.parent.item_grid:drawGrid()
                _self.data.parent.item_grid:focus()
                _self:remove()
            end
        }
    }
    
end

class('ShopPlayerInventory').extends(GenericInventory)

function ShopPlayerInventory:init()

    ShopPlayerInventory.super.init(self)

    self.data.items = g_player.inventory.items
    self.data.item_panel = ItemPanelShop(180, 150)

    self.data.context_options = {
        {
            name="Sell",
            callback = function (_self)
                local item = _self.data.parent.item_grid:getSelection()
                local price = item:getCurrentPrice()

                local pop_up_data = {
                    text = string.format("Sell for %s for %i?", item.name, price),
                    options = {
                        {
                            name="Yes",
                            callback = function ()
                                g_player.money += price
                                local idx = _self.data.parent.item_grid:getSelectionIndex()
                                table.remove(g_player.inventory.items, idx)
                                _self.data.parent.item_grid:drawGrid()
                            end
                        },
                        {
                            name="No",
                            callback = function ()
                            end
                        }
                    }
                }

                self.context_menu:remove()
                g_SceneManager:pushScene(Popup(pop_up_data))
            end
        }
    }
    
end
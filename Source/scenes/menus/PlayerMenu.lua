
local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlayerMenu').extends(GenericMenu)

function PlayerMenu:init()

    PlayerMenu.super.init(self)

    self.data.options = {
        {
            name = 'Inventory',
            callback = function ()
                g_SceneManager:pushScene(PlayerInventory(), 'between menus')
            end
        },
        {
            name = 'Map',
            callback = function ()
                g_SceneManager:pushScene(Map(), 'between menus')
            end
        }
    }

    self.data.right_side = gfx.sprite.new(gfx.image.new('assets/iso_ship'))
    
end

class('PlayerInventory').extends(GenericInventory)

function PlayerInventory:init()

    PlayerInventory.super.init(self)

    self.data.items = g_player.inventory.items
    self.data.item_panel = ItemPanel(180, 150)

    self.data.context_options = {
        {
            name="Drop",
            callback = function (_self)
                table.remove(self.data.items, _self.data.parent.item_grid:getSelectionIndex())
                _self.data.parent.item_grid:drawGrid()
                _self.data.parent.item_grid:focus()
                _self:remove()
            end
        }
    }
    
end
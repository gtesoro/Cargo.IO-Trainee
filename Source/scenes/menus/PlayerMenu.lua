
local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlayerMenu').extends(GenericMenu)

function PlayerMenu:init()

    PlayerMenu.super.init(self)

    self.data.options = {
        {
            name = 'Inventory',
            sprite = gfx.sprite.new(gfx.image.new('assets/menus/inventory')),
            callback = function ()
                g_SceneManager:pushScene(PlayerInventory(), 'between menus')
            end
        },
        {
            name = 'Map',
            sprite = gfx.sprite.new(gfx.image.new('assets/menus/map')),
            callback = function ()
                g_SceneManager:pushScene(Map(), 'between menus')
            end
        },
        {
            name = 'Contracts',
            sprite = gfx.sprite.new(gfx.image.new('assets/menus/contracts')),
            callback = function ()
                g_SceneManager:pushScene(ContractListMenu(), 'between menus')
            end
        },
        {
            name = 'Functions',
            callback = function ()
                g_SceneManager:pushScene(FunctionsMenu(), 'between menus')
            end
        }
    }

    self.data.right_side = gfx.sprite.new(gfx.image.new('assets/iso_ship'))
    
end

class('FunctionsMenu').extends(GenericMenu)

function FunctionsMenu:init()

    FunctionsMenu.super.init(self)

    self.data.options = {
        {
            name = 'Suicide',
            callback = function ()
                g_SystemManager:death()
            end
        }
    }
end

class('ContractMenu').extends(GenericMenu)

function ContractMenu:init(contract)

    ContractMenu.super.init(self)
    self.data.options = {
        {
            name = "Contract",
            callback = function ()
                g_SceneManager:pushScene(ImageViewer({image=contract:getContractImage()}), "between menus")
            end
        },
        {
            name = "Cancel"
        }
    }
    
end

class('ContractListMenu').extends(GenericMenu)

function ContractListMenu:init()

    ContractListMenu.super.init(self)
    self.data.options = {}
    for k, v in pairs(g_SystemManager:getPlayer().contracts) do
        self.data.options[#self.data.options+1] = {
            name = v.name,
            sprite = v:getIcon(),
            callback = function ()
                g_SceneManager:pushScene(ContractMenu(v), 'between menus')
            end
        }
    end
end

class('PlayerInventory').extends(GenericInventory)

function PlayerInventory:init()

    PlayerInventory.super.init(self)

    self.data.items = g_SystemManager:getPlayer().inventory.items
    self.data.item_panel = ItemPanel(180, 150)

    self.data.context_options = {
        {
            name="Drop",
            callback = function (_self)

                g_SystemManager:getPlayer():removeFromInventory(_self.data.parent.item_grid:getSelection())
                
                _self.data.parent.item_grid:drawGrid()
                _self.data.parent:focus()
                _self:remove()
            end
        }
    }
    
end
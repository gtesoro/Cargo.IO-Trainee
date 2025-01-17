
local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlayerMenu').extends(GenericMenu)

function PlayerMenu:init()

    PlayerMenu.super.init(self)

    self.data.options = {

        {
            name = 'Status',
            sprite = gfx.sprite.new(getStatusImg()),
            callback = function ()
                g_SceneManager:pushScene(LoadoutMenu({items=g_SystemManager:getPlayer().ship.loadout.items, read_only=true}), 'between menus')
            end
        },
        {
            name = 'Inventory',
            sprite = gfx.sprite.new(gfx.image.new('assets/menus/inventory')),
            callback = function ()
                g_SceneManager:pushScene(PlayerInventory(), 'between menus')
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
            name = 'Codex',
            sprite = gfx.sprite.new(gfx.image.new('assets/menus/codex')),
            callback = function ()
                g_SceneManager:pushScene(CodexListMenu(), 'between menus')
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
            name = 'Functions',
            callback = function ()
                g_SceneManager:pushScene(FunctionsMenu(), 'between menus')
            end
        }
    }
    
end

function PlayerMenu:clean()
    PlayerMenu.super.clean(self)
end

class('FunctionsMenu').extends(GenericMenu)

function FunctionsMenu:init()

    FunctionsMenu.super.init(self)

    self.data.options =  {
            {
                name = 'Exit Ship',
                callback = function ()
                    
                    g_SceneManager:pushScene(Popup({text='Space contains no breathtable gases.\nAre you sure?', options={
                        {
                            name='Yes',
                            no_exit=true,
                            callback= function ()
                                g_SystemManager:disableControl()
                                g_SceneManager:popToSystem()
                                local _t = pd.timer.new(1000)
                                _t.timerEndedCallback = function ()
                                    g_SystemManager:enableControl()
                                    g_SystemManager:death()
                                end
                            end
                        },
                        {
                            name='No'
                        }
                    }}), 'stack')
                end
            }
        }
end

class('ContractMenu').extends(GenericMenu)

function ContractMenu:init(contract)

    ContractMenu.super.init(self)
    self.data.options = contract:getOptions()
end

class('ContractListMenu').extends(GenericMenu)

function ContractListMenu:init()

    ContractListMenu.super.init(self)
    self.data.options = function ()
        local _ret = {}

        for k, v in pairs(g_SystemManager:getPlayer().contracts) do
            _ret[#_ret+1] = {
                name = v.name,
                sprite = v:getIcon(),
                callback = function ()
                    g_SceneManager:pushScene(ContractMenu(v), 'between menus')
                end
            }
        end

        return _ret
    end
    
end

class('CodexListMenu').extends(GenericMenu)

function CodexListMenu:init()

    CodexListMenu.super.init(self)
    self.data.options = {
        {
            name = "Notifications",
            callback = function ()
                g_SceneManager:pushScene(NotificationsMenu(), 'between menus')
            end
        },
        {
            name = "Systems",
            callback = function ()
                g_SceneManager:pushScene(CodexSystemListMenu(), 'between menus')
            end
        },
        {
            name = "Planets",
            callback = function ()
                g_SceneManager:pushScene(CodexPlanetListMenu(), 'between menus')
            end
        }
    }
end

class('NotificationsMenu').extends(GenericMenu)

function NotificationsMenu:init()

    NotificationsMenu.super.init(self)

    local _list = {}
        
    local _table = g_SystemManager:getPlayer().notifications
    for i = #_table, 1, -1 do
        _list[#_list+1] = {
            name = string.format("Cycle %i - %s", _table[i].cycle, _table[i].text)
        }
    end

    self.data.options = _list
end

class('CodexSystemListMenu').extends(GenericMenu)

function CodexSystemListMenu:init()

    CodexPlanetListMenu.super.init(self)

    local _list = {}
        
    for k, v in pairs(g_SystemManager:getPlayer().codex.systems) do
        local _system = g_SystemManager:getSystemByName(v)
        _list[#_list+1] = {
            name = _system.name,
            sprite = function ()
                return AnimatedSprite(_system.sun, 100)
            end,
            callback = function ()
                g_SceneManager:pushScene(CodexSystemMenu(_system), 'between menus')
            end
        }
    end

    table.sort(_list, function (a, b)
        return a.name < b.name
    end)

    self.data.options = _list
end


class('CodexPlanetListMenu').extends(GenericMenu)

function CodexPlanetListMenu:init()

    CodexPlanetListMenu.super.init(self)


    local _list = {}
        
    for k, v in pairs(g_SystemManager:getPlayer().codex.planets) do
        local _planet = g_SystemManager:getPlanet(v)
        _list[#_list+1] = {
            name = _planet.name,
            sprite = function ()
                return AnimatedSprite(_planet.img, 100)
            end,
            callback = function ()
                g_SceneManager:pushScene(ImageViewer({image=PlanetDescription(_planet)}), 'between menus')
            end
        }
    end

    table.sort(_list, function (a, b)
        return a.name < b.name
    end)

    self.data.options = _list
end

class('CodexPlanetMenu').extends(GenericMenu)

function CodexPlanetMenu:init()

    CodexPlanetMenu.super.init(self)
    self.data.options = {}
end

class('CodexSystemMenu').extends(GenericMenu)

function CodexSystemMenu:init()

    CodexSystemMenu.super.init(self)
    self.data.options = {}

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
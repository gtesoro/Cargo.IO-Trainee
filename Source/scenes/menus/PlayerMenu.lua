
local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlayerMenu').extends(GenericMenuList)

function PlayerMenu:init()

    PlayerMenu.super.init(self)

    self.data.options = {

        {
            name = 'Ship',
            sprite = gfx.sprite.new(getStatusImg()),
            callback = function ()
                g_SceneManager:pushScene(LoadoutMenu({items=g_SystemManager:getPlayer().ship.loadout.items, read_only=true}), 'between menus')
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
                g_SceneManager:pushScene(CodexMaintMenu(), 'between menus')
            end
        },
        {
            name = 'Functions',
            sprite = gfx.sprite.new(gfx.image.new('assets/menus/functions')),
            callback = function ()
                g_SceneManager:pushScene(FunctionsMenu(), 'between menus')
            end
        }
    }
    
end

function PlayerMenu:clean()
    PlayerMenu.super.clean(self)
end

class('FunctionsMenu').extends(GenericMenuList)

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
                                g_SoundManager:stopComputerHum()
                                g_SystemManager:disableControl()
                                g_SceneManager:popToSystem()
                                g_SoundManager:playChoking()
                                local _t = pd.timer.new(3000)
                                _t.timerEndedCallback = function ()
                                    g_SystemManager:enableControl()
                                    g_EventManager:trigger(EVENT_DEATH)
                                end
                            end
                        },
                        {
                            name='No'
                        }
                    }}))
                end
            }
        }
    
    if #g_SystemManager:getPlayer():getLoadoutByType('LeapEngine') > 0 then
        table.insert(self.data.options, {
            name = "Leap",
            callback = function ()
                g_SceneManager:pushScene(TextInput(
                {
                    callback = function (text)
                        local x, y, z = string.match(text, "(%d+)%.(%d+)%.(%d+)")
                        if x and y and z then
                            x = tonumber(x)
                            y = tonumber(y)
                            z = tonumber(z)
                            goTo(x, y, z)
                        else
                           g_NotificationManager:notify('Invalid System') 
                        end
                    end
                }
                ), "between menus")
            end
        })
    end
end

class('ContractMenu').extends(GenericMenuList)

function ContractMenu:init(contract)

    ContractMenu.super.init(self)
    self.data.options = contract:getOptions()
end

class('ContractListMenu').extends(GenericMenuList)

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

class('CodexMaintMenu').extends(GenericMenuList)

function CodexMaintMenu:init()

    CodexMaintMenu.super.init(self)
    self.data.options = {
        {
            name = "Notifications",
            callback = function ()
                g_SceneManager:pushScene(NotificationsMenu(), 'between menus')
            end
        }
    }

    for k,v in pairs(g_SystemManager.static.codex) do
        local _entry = {
            name = v.name,
            callback = function ()
                g_SceneManager:pushScene(CodexListMenu({list=v.children}), 'between menus')
            end
        }
        table.insert(self.data.options, _entry)
    end

end


class('CodexListMenu').extends(GenericMenuList)

function CodexListMenu:init(data)

    CodexListMenu.super.init(self, data)

    local _list = {}
        
    -- for k, v in pairs(g_SystemManager:getPlayer().codex.locations) do
    --     local _location = g_SystemManager:getLocation(v)
    --     _list[#_list+1] = {
    --         name = _location.name,
    --         sprite = function ()
    --             return AnimatedSprite(_location.img, 100)
    --         end,
    --         callback = function ()
    --             g_SceneManager:pushScene(ImageViewer({image=LocationDescription(_location)}), 'between menus')
    --         end
    --     }
    -- end
    for k,v in pairs(self.data.list) do
        local _entry = nil

        if v.children then
            _entry = {
                name = v.name,
                callback = function ()
                    g_SceneManager:pushScene(CodexListMenu({list=children}), 'between menus')
                end
            }
        else
            _entry = v
        end

        table.insert(_list, _entry)
    end

    table.sort(_list, function (a, b)
        return a.name < b.name
    end)

    self.data.options = _list
end

class('NotificationsMenu').extends(GenericMenuList)

function NotificationsMenu:init()

    NotificationsMenu.super.init(self)

    local _list = {}
        
    local _table = g_SystemManager:getPlayer().notifications
    for i = #_table, 1, -1 do
        _list[#_list+1] = {
            name = string.format("Cycle %i.%02d - %s", _table[i].cycle, _table[i].time, _table[i].text)
        }
    end

    self.list_box_w = 330

    self.data.options = _list
end


class('PlayerInventory').extends(GenericInventory)

function PlayerInventory:init()

    PlayerInventory.super.init(self)

    self.data.items = g_SystemManager:getPlayer().inventory.items

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
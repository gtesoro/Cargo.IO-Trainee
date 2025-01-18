local pd <const> = playdate
local gfx <const> = playdate.graphics


class('SystemManager').extends()

function SystemManager:init()

    self.frame_counter = 0

    self.on_death = {}
    self.autosave_filename = 'auto'

    self.crank_menu_sensitivity = 45
    self.fading_grid = gfx.imagetable.new("assets/backgrounds/fading_grid")

    -- Cycle control
    self.cycle_length = 1

    self.disable_control = false

    self:initStatic()
    
end

function SystemManager:disableControl()
    self.disable_control = true
end

function SystemManager:enableControl()
    self.disable_control = false
end

function SystemManager:canControl()
    return not self.disable_control
end

function SystemManager:getFadingGrid()
    return self.fading_grid
end

function SystemManager:pause()
    self.cycle_timer:pause()
end

function SystemManager:unpause()
    self.cycle_timer:start()
end

function SystemManager:getCycle()
    return self.state.player.cycle, math.floor((self.cycle_timer.currentTime + self.cycle_compensation)*100/(self.cycle_length*60*1000))
end

function SystemManager:update()
    
    self.frame_counter += 1
    if self.frame_counter > 50 then
        self.frame_counter = 1
    end
end

function SystemManager:death()

    pd.datastore.delete(self.autosave_filename)
    g_SceneManager:reset()
    g_SceneManager:pushScene(GameOver())

end


function SystemManager:isTick(x)
    return math.fmod(self.frame_counter, x) == 0
end


function SystemManager:initStatic()
    self.static = getStaticData()

end

function SystemManager:initState()

    self.state = {}

    self.state.global = {}

    -- Player
    local _player = {}
    self.state.player = _player

    _player.last_position = {}
    _player.current_position = {
        x = 0,
        y = 0,
        z = 0
    }
    _player.money = 1000
    _player.inventory = {
        items = List(),
        capacity = 9
    }

    _player.ship = {
        hull_total = 100,
        hull_current = 100,
        fuel_current = 100,
        fuel_capacity = 100,
        fuel_usage = 0.005,
        loadout = {
            capacity = 4,
            items = {}
        }
    }

    _player.map = {}

    _player.cycle = 1
    _player.cycle_time = 0

    _player.inventory.items = {}
    _player.inventory.items[#_player.inventory.items+1] = { className='YggdrasilAtlas'}
    _player.inventory.items[#_player.inventory.items+1] = { className='Laser'}

    _player.contracts = {}

    _player.codex = {
        planets={},
        systems={},
        terms={}
    }

    return self.state
end

function SystemManager:initCycleManagement()

    g_EventManager:subscribe('notify', EVENT_NEXT_CYCLE, function (cycle)
        g_NotificationManager:notify(string.format("Cycle %i", cycle), nil, false)
    end)

    if self.cycle_timer then
        self.cycle_timer:pause()
        self.cycle_timer:remove()
    end

    if self.state.player.cycle_time ~= 0 then
        self.cycle_timer = pd.timer.new(self.cycle_length*60*1000 - self.state.player.cycle_time)
        self.cycle_compensation = self.state.player.cycle_time

        self.cycle_timer.timerEndedCallback = function ()
            print('Cycle Finished')
            g_SystemManager:getPlayer().cycle += 1
            g_EventManager:trigger(EVENT_NEXT_CYCLE, g_SystemManager:getCycle())
            self.cycle_compensation = 0
            self.cycle_timer = pd.timer.new(self.cycle_length*60*1000)
            self.cycle_timer.repeats = true

            self.cycle_timer.timerEndedCallback = function ()
                g_SystemManager:getPlayer().cycle += 1
                g_EventManager:trigger(EVENT_NEXT_CYCLE, g_SystemManager:getCycle())
            end
        end

    else
        self.cycle_compensation = 0
        self.cycle_timer = pd.timer.new(self.cycle_length*60*1000)
        self.cycle_timer.repeats = true

        self.cycle_timer.timerEndedCallback = function ()
            g_SystemManager:getPlayer().cycle += 1
            g_EventManager:trigger(EVENT_NEXT_CYCLE, g_SystemManager:getCycle())
        end

    end
    

    self.cycle_timer:pause()
    
end

function SystemManager:load(file)

    g_EventManager:reset()

    if not file then
        file = self.autosave_filename
    end

    self.state = {}
    self.state = playdate.datastore.read(file)

    if not self.state then
        self.state = self:initState()
    end

    self:initCycleManagement()
    

    g_EventManager:subscribe('death', EVENT_DEATH, function ()
        g_SystemManager:death()
    end)

    -- Load Sateful objects
    for _, table in pairs({ self.state.player.inventory.items, self.state.player.contracts, self.state.player.ship.loadout.items}) do
        for k,v in pairs(table) do
            local _o = _G[v.className]()
            if v.state then
                _o:load(v.state)
            end
            table[k] = _o
        end
    end

    self.state.player = Player(self.state.player)

end

function SystemManager:save(file)
    if not file then
        file = self.autosave_filename
    end

    local _current_system = self.state.player.current_system
    self.state.player.current_system = nil

    -- Save Cycle info
    self.state.player.cycle_time = self.cycle_timer.currentTime

    -- Save item class names
    local _inventory_items = self.state.player.inventory.items
    local _save_inventory_items = {}
    for k,v in pairs(self.state.player.inventory.items) do
        _save_inventory_items[k] = v:save()
    end
    self.state.player.inventory.items = _save_inventory_items

    -- Save contracts class names
    local _contracts = self.state.player.contracts
    local _save_contracts = {}
    for k,v in pairs(_contracts) do
        _save_contracts[k] = v:save()
    end
    self.state.player.contracts = _save_contracts

    -- Save ship loadout class names
    local _loadout_items = self.state.player.ship.loadout.items
    local _save_loadout_items = {}
    for k,v in pairs(_loadout_items) do
       _save_loadout_items[k] = v:save()
    end
    self.state.player.ship.loadout.items = _save_loadout_items

    playdate.datastore.write(self.state, file)

    self.state.player.contracts = _contracts
    self.state.player.inventory.items = _inventory_items
    self.state.player.current_system = _current_system
    self.state.player.ship.loadout.items = _loadout_items
end

function SystemManager:getPlayer()
    if self.state then
        return self.state.player
    end
    return nil
end

function SystemManager:getGlobalState()
    if self.state then
        return self.state.global
    end
    return nil
end

function SystemManager:getSystems()
    if self.state then
        return self.static.systems
    end
    return nil
end

function SystemManager:getSystem(x, y, z)
    for k,v in pairs(self.static.systems) do
        if v.x == x and v.y == y and v.z == z then
            return v
        end
    end
    return nil
end

function SystemManager:getSystemByName(system)
    for k,v in pairs(self.static.systems) do
        if v.name == system then
            return v
        end
    end
    return nil
end

function SystemManager:getLocation(location)
    for k,v in pairs(self.static.locations) do
        if v.name == location then
            return v
        end
    end
end

function SystemManager:getLocations()
    if self.state then
        return self.static.locations
    end
    return nil
end

class('Player').extends()

function Player:init(player)
    tableUpdate(self, player)
end

function Player:getInventory()
    return self.inventory
end

function Player:logNotification(str)
    if not self.notifications then
        self.notifications = {}
    end

    table.insert(self.notifications, {text=str, cycle=self.cycle})

    if #self.notifications > 100 then
        table.remove(self.notifications, 1)
    end

end

function Player:addContract(contract)
    self.contracts[#self.contracts+1] = contract
    contract:onGain()

    return true
end

function Player:removeContract(contract)
    local _key = nil
    for k, v in pairs(self.contracts) do
        if v == contract then
            _key = k
            break
        end
    end
    if _key then
        table.remove(self.contracts, _key)
        contract:onLose()
        return true
    end

    return false
end

function Player:freeInventory()
    return self.inventory.capacity - #self.inventory.items
end

function Player:addToInventory(item, notify)

    if notify == nil then
        notify = true
    end

    local _i_c = #self.inventory.items
    if _i_c < self.inventory.capacity then
        self.inventory.items[#self.inventory.items+1] = item
        item:onGain()
        if notify then
            g_NotificationManager:notify(string.format("Item Gained: %s", item.name))
        end
        return true
    else
        g_NotificationManager:notify("Inventory Full")
    end
    return false
end

function Player:removeFromInventory(item, notify)

    if notify == nil then
        notify = true
    end

    local _key = nil
    for k, v in pairs(self.inventory.items) do
        if v == item then
            _key = k
            break
        end
    end
    if _key then
        table.remove(self.inventory.items, _key)
        if notify then
            g_NotificationManager:notify(string.format("Item Lost: %s", item.name))
        end
        item:onLose()
        return true
    end

    return false
end


function Player:setCurrentSystem(system)
    self.current_system = system
end

function Player:getCurrentSystem()
    return self.current_system 
end

function Player:setCurrentLocation(location)
    self.current_location = location
end

function Player:getCurrentLocation()
    return self.current_location 
end

function Player:doHullDamage(amount)

    if amount == 0 or amount == nil then
        return
    end
    self.ship.hull_current -= amount

    if self.ship.hull_current < 0 then
        g_SystemManager:death()
    else
        g_NotificationManager:notify(string.format("Hull Damage - %i%% : %i%%", amount, self.ship.hull_current))
    end
    
end

function Player:chargeMoney(amount)

    if amount == 0 or amount == nil then
        return true
    end
    
    if self.money >= amount then
        self.money -= amount
        g_NotificationManager:notify(string.format("-%iC : %iC", amount, self.money))
        return true
    end
    g_NotificationManager:notify("Insufficient Funds")
    return false
    
end

function Player:gainMoney(amount)

    if amount == 0 or amount == nil then
        return true
    end
    
    self.money += amount
    g_NotificationManager:notify(string.format("+%iC : %iC", amount, self.money))

    return true
    
end

function Player:hasContract(contract)

    for k,v in pairs(self.contracts) do
        if v == contract then
            return true
        end
    end

    return false
    
end


function Player:getContractByType(contract)

    local _ret = {}

    for k,v in pairs(self.contracts) do
        if v.className == contract then
            _ret[#_ret+1] = v
        end
    end

    return _ret
    
end

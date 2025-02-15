local pd <const> = playdate
local gfx <const> = playdate.graphics


class('SystemManager').extends()

function SystemManager:init()

    -- PD Stuff
    local menu = pd.getSystemMenu()

	menu:addMenuItem("Show FPS", function()
		g_fps = not g_fps
	end)

	menu:addMenuItem("Save", function()
		g_SystemManager:save()
	end)
	
	menu:addMenuItem("Delete Save", function()
        if g_SystemManager.meta.saves and g_SystemManager.meta.saves[g_SystemManager.save_slot] then
            g_SystemManager.meta.saves[g_SystemManager.save_slot] = nil
        end
        pd.datastore.write(g_SystemManager.meta, META)
		pd.datastore.delete(g_SystemManager.save_slot)
		g_SceneManager:reset()
		g_SceneManager:pushScene(Intro())
	end)

    self.frame_counter = 0

    self.on_death = {}
    self.save_slot = nil

    self.crank_menu_sensitivity = 5
    self.scroll_sensitivity = 25

    self.cache = {}
    self.cache['fading_grid'] = gfx.imagetable.new("assets/backgrounds/fading_grid")

    -- Cycle control
    self.cycle_length = 1

    self.disable_control = false

    self:loadMeta()

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
    return self.cache['fading_grid'] 
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

    if g_SystemManager.meta.saves and g_SystemManager.meta.saves[g_SystemManager.save_slot] then
        g_SystemManager.meta.saves[g_SystemManager.save_slot] = nil
    end
    pd.datastore.write(g_SystemManager.meta, META)
    pd.datastore.delete(g_SystemManager.save_slot)
    g_SceneManager:reset()
    g_SceneManager:pushScene(GameOver())

end

function SystemManager:getButtonImage(button_id)
    
    local _t = gfx.imagetable.new('assets/ui/icons')
    return _t:getImage(button_id)

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

    -- PlayerData
    local _player = {}
    self.state.player = _player

    _player.siegel_img = nil

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
    _player.inventory.items[#_player.inventory.items+1] = { className='LeapEngine'}

    _player.contracts = {}

    _player.codex = {
        Locations={},
        Terms={}
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
            g_SystemManager:getPlayerData().cycle += 1
            g_EventManager:trigger(EVENT_NEXT_CYCLE, g_SystemManager:getCycle())
            self.cycle_compensation = 0
            self.cycle_timer = pd.timer.new(self.cycle_length*60*1000)
            self.cycle_timer.repeats = true

            self.cycle_timer.timerEndedCallback = function ()
                g_SystemManager:getPlayerData().cycle += 1
                g_EventManager:trigger(EVENT_NEXT_CYCLE, g_SystemManager:getCycle())
            end
        end

    else
        self.cycle_compensation = 0
        self.cycle_timer = pd.timer.new(self.cycle_length*60*1000)
        self.cycle_timer.repeats = true

        self.cycle_timer.timerEndedCallback = function ()
            g_SystemManager:getPlayerData().cycle += 1
            g_EventManager:trigger(EVENT_NEXT_CYCLE, g_SystemManager:getCycle())
        end

    end
    

    self.cycle_timer:pause()
    
end

function SystemManager:loadMeta()

    self.meta = playdate.datastore.read(META)

    if not self.meta then
        self.meta = {}
    end

end

function SystemManager:load(file)

    g_EventManager:reset()

    self.state = {}
    self.state = playdate.datastore.read(file)

    self.save_slot = file

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

    self.state.player = PlayerData(self.state.player)

end

function SystemManager:save(file)
    if not file then
        file = self.save_slot
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

    -- Meta

    if not self.meta.saves then
        self.meta.saves = {}
    end

    if not self.meta.saves[self.save_slot] then
        self.meta.saves[self.save_slot] = {}
    end

    self.meta.saves[self.save_slot] = {
        system = _current_system.data.name or systemNameFromCoords(_current_system.data.x, _current_system.data.y, _current_system.data.z),
        credits = self.state.player.money
    }

    playdate.datastore.write(self.meta, META)


end

function SystemManager:getOverlayImage()
    img = gfx.image.new('assets/backgrounds/ui_overlay')

    -- if g_SystemManager:getPlayerData() and g_SystemManager:getPlayerData():getSiegelImage() then
    --     inContext(img, function ()
    --         gfx.setColor(gfx.kColorBlack)
    --         gfx.fillRect(354, 194, 36, 36)
    --         gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    --         g_SystemManager:getPlayerData():getSiegelImage():scaledImage(0.5):draw(356, 196)
    --     end)
    -- end

    return img
end

function SystemManager:getPlayerData()
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

class('PlayerData').extends()

function PlayerData:init(player)
    tableUpdate(self, player)
end

function PlayerData:getInventory()
    return self.inventory
end

function PlayerData:logNotification(str)
    if not self.notifications then
        self.notifications = {}
    end

    local _c, _t = g_SystemManager:getCycle()
    table.insert(self.notifications, {text=str, cycle=_c, time=_t})

    if #self.notifications > 100 then
        table.remove(self.notifications, 1)
    end

end

function PlayerData:addContract(contract)
    self.contracts[#self.contracts+1] = contract
    contract:onGain()

    return true
end

function PlayerData:getSiegelImage()
    if g_SystemManager:getPlayerData().siegel_img then
        return gfx.image.new(g_SystemManager:getPlayerData().siegel_img)
    end
    return nil
end

function PlayerData:removeContract(contract)
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

function PlayerData:freeInventory()
    return self.inventory.capacity - #self.inventory.items
end

function PlayerData:addToInventory(item, notify)

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

function PlayerData:removeFromInventory(item, notify)

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


function PlayerData:setCurrentSystem(system)
    self.current_system = system
end

function PlayerData:getCurrentSystem()
    return self.current_system 
end

function PlayerData:setCurrentLocation(location)
    self.current_location = location
end

function PlayerData:getCurrentLocation()
    return self.current_location 
end

function PlayerData:doHullDamage(amount)

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

function PlayerData:chargeMoney(amount)

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

function PlayerData:gainMoney(amount)

    if amount == 0 or amount == nil then
        return true
    end
    
    self.money += amount
    g_NotificationManager:notify(string.format("+%iC : %iC", amount, self.money))

    return true
    
end

function PlayerData:getLoadoutByType(item_type)

    local _ret = {}

    for k,v in pairs(self.ship.loadout.items) do
        if v.className == item_type then
            _ret[#_ret+1] = v
        end
    end

    return _ret
    
end

function PlayerData:getItemsByType(item_type)

    local _ret = {}

    for k,v in pairs(self.inventory.items) do
        if v.className == item_type then
            _ret[#_ret+1] = v
        end
    end

    return _ret
    
end

function PlayerData:hasContract(contract)

    for k,v in pairs(self.contracts) do
        if v == contract then
            return true
        end
    end

    return false
    
end


function PlayerData:getContractByType(contract)

    local _ret = {}

    for k,v in pairs(self.contracts) do
        if v.className == contract then
            _ret[#_ret+1] = v
        end
    end

    return _ret
    
end

local pd <const> = playdate
local gfx <const> = playdate.graphics


class('SystemManager').extends(gfx.sprite)

function SystemManager:init()

    self.frame_counter = 0

    self.on_death = {}
    self.autosave_filename = 'auto'

    self.crank_menu_sensitivity = 45

    self.fading_grid = gfx.imagetable.new("assets/backgrounds/fading_grid")

    self.planet_hd_img_table = gfx.imagetable.new(500)

    self:add()

    -- Cycle control

    self.on_cycle = {}

    self.on_cycle['notify'] = function (cycle)
        g_NotificationManager:notify(string.format("Cycle %i", cycle))
    end

    self.cycle_length = 0.5

    self.cycle_timer = pd.timer.new(self.cycle_length*60*1000)
    self.cycle_timer.repeats = true

    self.cycle_timer.timerEndedCallback = function ()
        self:nextCycle()
    end

    self.cycle_timer:pause()

    self:initStatic()
    
end

function SystemManager:pause()
    self.cycle_timer:pause()
end

function SystemManager:unpause()
    self.cycle_timer:start()
end

function SystemManager:nextCycle()
    
    self.state.player.cycle += 1

    for k, v in pairs(self.on_cycle) do
        v(self.state.player.cycle)
    end
end

function SystemManager:update()
    
    self.frame_counter += 1
    if self.frame_counter > 50 then
        self.frame_counter = 1
    end
end

function SystemManager:death()

    

    for k,f in pairs(self.on_death) do
        f()
        return
    end

    playdate.datastore.delete(self.autosave_filename)
    g_SceneManager:reset()
    g_SceneManager:pushScene(Intro(), 'wipe down')

end


function SystemManager:isTick(x)
    return math.fmod(self.frame_counter, x) == 0
end

function SystemManager:initStatic()
    self.static = {}

    -- Planets
    self.static.planets = {}

    local _freja = {
        img="assets/planets/planet3",
        img_hd="assets/planets/placeholder_hd",
        name="Freja",
        orbit_size=300,
        speed=1,
        outline=true,
        facilities= {
            'Market'
        }
    }

    self.static.planets[#self.static.planets+1] = _freja
    
    local _thor = {
        img="assets/planets/thor/thor",
        img_hd="assets/planets/thor/thor_hd",
        name="Thor",
        orbit_size=500,
        speed=1,
        outline=true,
        facilities= {
            'Fuel Station'
        }
    }

    self.static.planets[#self.static.planets+1] = _thor
    
    local _loki = {
        img="assets/planets/loki/sd",
        img_hd="assets/planets/loki/hd",
        name="Loki",
        orbit_size=600,
        speed=0.5,
        outline=true,
        facilities= {
            'Cloning Facility'
        }
    }

    self.static.planets[#self.static.planets+1] = _loki
    
    local _odin = {
        img="assets/planets/planet1",
        name="Odin",
        img_hd="assets/planets/placeholder_hd",
        orbit_size=900,
        speed=0.3,
        outline=true,
        facilities= {
    
            
        }
    }

    self.static.planets[#self.static.planets+1] = _odin

    -- Systems
    local _systems = {}
    self.static.systems = _systems

    local empty = {
        class = 'EmptySystem',
        name = "Unknown",
        emtpy = true,
        playfield_width = 3000,
        playfield_height = 3000,
        background = "assets/backgrounds/bg2"
    }

    _systems['empty'] = empty
    
    local _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = 1,
        y = 1,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/bg3",
        asteroid_count = 10,
    }
    
    _systems[string.format("%i.%i.%i", _sys.x, _sys.y, _sys.z)] = _sys
    
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = 1,
        y = -1,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/bg3",
        asteroid_count = 10,
    }
    
    _systems[string.format("%i.%i.%i", _sys.x, _sys.y, _sys.z)] = _sys
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = 0,
        y = -2,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/bg3",
        asteroid_count = 10,
    }
    
    _systems[string.format("%i.%i.%i", _sys.x, _sys.y, _sys.z)] = _sys
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = -1,
        y = -1,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/bg3",
        asteroid_count = 10,
    }
    
    _systems[string.format("%i.%i.%i", _sys.x, _sys.y, _sys.z)] = _sys
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = -2,
        y = 0,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/bg3",
        asteroid_count = 10,
    }
    
    _systems[string.format("%i.%i.%i", _sys.x, _sys.y, _sys.z)] = _sys
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = -1,
        y = 1,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/bg3",
        asteroid_count = 10,
    }
    
    _systems[string.format("%i.%i.%i", _sys.x, _sys.y, _sys.z)] = _sys
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = 0,
        y = 2,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/bg3",
        asteroid_count = 10,
    }
    
    _systems[string.format("%i.%i.%i", _sys.x, _sys.y, _sys.z)] = _sys
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = 2,
        y = 0,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/bg3",
        asteroid_count = 10,
    }

    _systems[string.format("%i.%i.%i", _sys.x, _sys.y, _sys.z)] = _sys
    
    
    _sys = {
        class = 'PlanetSystem',
        name = "Yggdrasil",
        x = 0,
        y = 0,
        z = 0,
        playfield_width = 2000,
        playfield_height = 2000,
        background = "assets/backgrounds/bg1",
        sun = "assets/planets/star",
        angle = 0.6,
        planets = {
            _freja, 
            _thor,
            _odin,
            _loki
        }

    }
    
    _systems[string.format("%i.%i.%i", _sys.x, _sys.y, _sys.z)] = _sys
end

function SystemManager:initState()

    self.state = {}

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
        fuel_current = 100,
        fuel_capacity = 100,
        fuel_usage = 0.005
    }

    _player.map = {}

    _player.cycle = 1

    _player.inventory.items = {}
    _player.inventory.items[#_player.inventory.items+1] = { className='FuelCell'}
    _player.inventory.items[#_player.inventory.items+1] = { className='Radar'}
    _player.inventory.items[#_player.inventory.items+1] = { className='Radio'}

    _player.contracts = {}

    return self.state
end

function SystemManager:load(file)

    if not file then
        file = self.autosave_filename
    end

    self.state = playdate.datastore.read(file)

    if not self.state then
        self.state = self:initState()
    end

    -- Load Sateful objects
    for _, table in pairs({ self.state.player.inventory.items, self.state.player.contracts}) do
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

    local _current_system = self.current_system
    self.current_system = nil

    -- Save item class names
    local _inventory_items = self.state.player.inventory.items
    local _save_inventory_items = {}
    for k,v in pairs(self.state.player.inventory.items) do
        print(v:isa(Stateful), Item():isa(Stateful))
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

    playdate.datastore.write(self.state, file)

    self.state.player.contracts = _contracts
    self.state.player.inventory.items = _inventory_items
    self.current_system = _current_system
end

function SystemManager:getPlayer()
    if self.state then
        return self.state.player
    end
    return nil
end

function SystemManager:getSystems()
    if self.state then
        return self.static.systems
    end
    return nil
end

function SystemManager:getPlanets()
    if self.state then
        return self.static.planets
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

function Player:addToInventory(item)
    local _i_c = #self.inventory.items+1
    if _i_c < self.inventory.capacity then
        self.inventory.items[#self.inventory.items+1] = item
        item:onGain()
        return true
    else
        g_NotificationManager:notify("Inventory Full")
    end
    return false
end

function Player:removeFromInventory(item)
    local _key = nil
    for k, v in pairs(self.inventory.items) do
        if v == item then
            _key = k
            break
        end
    end
    if _key then
        table.remove(self.inventory.items, _key)
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

function Player:chargeMoney(amount)

    if amount == 0 or amount == nil then
        return true
    end
    
    if self.money >= amount then
        self.money -= amount
        g_NotificationManager:notify(string.format("-%iC", amount))
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
    g_NotificationManager:notify(string.format("+%iC", amount))

    return true
    
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

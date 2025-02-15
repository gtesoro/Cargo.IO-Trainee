function getStaticData()

    local static = {}
    
    -- Locations
    static.locations = {}

    local _valhalla_station = {
        img = 'assets/space/cylinder_station_thumb',
        img_delay = 250,
        img_hd = 'assets/space/cylinder_station_hd',
        name = "Valhalla Station",
        x = 690,
        y = 285,
        facilities= {
            FACILITY_STARPORT,
            FACILITY_CARGO
        },
        thumbnail = function ()
            return AnimatedSprite('assets/space/cylinder_station_thumb', 250)  
        end
    }
    static.locations[#static.locations+1] = _valhalla_station

    local _freja = {
        img="assets/planets/planet3",
        img_hd="assets/planets/placeholder_hd",
        name="Freja",
        orbit_size=300,
        speed=1,
        outline=true,
        description=lorem_ipsum,
        facilities= {
            FACILITY_STARPORT,
            FACILITY_CARGO
        },
        thumbnail = function ()
            return AnimatedSprite('assets/planets/planet3')  
        end
    }

    static.locations[#static.locations+1] = _freja
    
    local _thor = {
        img="assets/planets/thor/thor",
        img_hd="assets/planets/thor/thor_hd",
        name="Thor",
        orbit_size=500,
        speed=1,
        outline=true,
        description=lorem_ipsum,
        facilities= {
            FACILITY_MARKET,
            FACILITY_CARGO
        },
        thumbnail = function ()
            return AnimatedSprite('assets/planets/thor/thor')  
        end
    }

    static.locations[#static.locations+1] = _thor
    
    local _loki = {
        img="assets/planets/loki/sd",
        img_hd="assets/planets/loki/hd",
        name="Loki",
        orbit_size=600,
        description=lorem_ipsum,
        speed=0.5,
        outline=true,
        facilities= {
            FACILITY_CLONING,
            FACILITY_CARGO
        },
        thumbnail = function ()
            return AnimatedSprite('assets/planets/loki/sd')  
        end
    }

    static.locations[#static.locations+1] = _loki
    
    local _odin = {
        img="assets/planets/planet1",
        name="Odin",
        img_hd="assets/planets/placeholder_hd",
        orbit_size=900,
        description=lorem_ipsum,
        speed=0.3,
        outline=true,
        facilities= {
            FACILITY_CARGO
        },
        thumbnail = function ()
            return AnimatedSprite('assets/planets/planet1')  
        end
    }

    static.locations[#static.locations+1] = _odin

    -- Systems
    local _systems = {{{}}}
    static.systems = _systems

    local _sys = {
        class = 'System',
        name = "Outer Reach",
        x = 2,
        y = 3,
        z = 0,
        playfield_width = 800,
        playfield_height = 480,
        background = "assets/backgrounds/space/valhalla",
        locations = {
            _valhalla_station
        },
        thumbnail = function ()
            return AnimatedSprite('assets/space/cylinder_station_thumb', 250)  
        end
    }
    
    
    table.insert(_systems, _sys)
    
    local _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = 1,
        y = 1,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/space/asteroid_belt",
        asteroid_count = 10,
        thumbnail = function ()
            return AnimatedSprite("assets/asteroids/thumbnail", 100)  
        end
    }
    
    
    table.insert(_systems, _sys)
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = 1,
        y = -1,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/space/asteroid_belt",
        asteroid_count = 10,
        thumbnail = function ()
            return AnimatedSprite("assets/asteroids/thumbnail", 100)  
        end,
    }
    
    table.insert(_systems, _sys)
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = 0,
        y = -2,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/space/asteroid_belt",
        asteroid_count = 10,
        thumbnail = function ()
            return AnimatedSprite("assets/asteroids/thumbnail", 100)  
        end,
    }
    
    table.insert(_systems, _sys)
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = -1,
        y = -1,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/space/asteroid_belt",
        asteroid_count = 10,
        thumbnail = function ()
            return AnimatedSprite("assets/asteroids/thumbnail", 100)  
        end,
    }
    
    table.insert(_systems, _sys)
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = -2,
        y = 0,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/space/asteroid_belt",
        asteroid_count = 10,
        thumbnail = function ()
            return AnimatedSprite("assets/asteroids/thumbnail", 100)  
        end,
    }
    
    table.insert(_systems, _sys)
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = -1,
        y = 1,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/space/asteroid_belt",
        asteroid_count = 10,
        thumbnail = function ()
            return AnimatedSprite("assets/asteroids/thumbnail", 100)  
        end,
    }
    
    table.insert(_systems, _sys)
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = 0,
        y = 2,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/space/asteroid_belt",
        asteroid_count = 10,
        thumbnail = function ()
            return AnimatedSprite("assets/asteroids/thumbnail", 100)  
        end,
    }
    
    table.insert(_systems, _sys)
    
    _sys = {
        class = 'AsteroidSystem',
        name = "Asteroid Belt",
        x = 2,
        y = 0,
        z = 0,
        playfield_width = 3200,
        playfield_height = 1920,
        background = "assets/backgrounds/space/asteroid_belt",
        asteroid_count = 10,
        thumbnail = function ()
            return AnimatedSprite("assets/asteroids/thumbnail", 100)  
        end,
    }
    
    
    table.insert(_systems, _sys)
    
    _sys = {
        class = 'PlanetSystem',
        name = "Yggdrasil",
        x = 0,
        y = 0,
        z = 0,
        playfield_width = 2000,
        playfield_height = 2000,
        background = "assets/backgrounds/space/yggdrasil",
        sun = "assets/planets/star",
        angle = 0.6,
        locations = {
            _freja, 
            _thor,
            _odin,
            _loki
        },
        thumbnail = function ()
            return AnimatedSprite("assets/planets/star", 100, 1)  
        end
    }
    
    table.insert(_systems, _sys)

    _sys = {
        class = 'StageSystem',
        name = "DevStage",
        background = "assets/backgrounds/space/empty_2",
        stage = "Ship02",
        stage_overlay = "assets/spaceships/N.01-C",
        stage_middle = "assets/spaceships/N.01-C_Middle",
        stage_offset_x = 0,
        stage_offset_y = 0,
        x = -3,
        y = 0,
        z = 0,
        playfield_width = 2000,
        playfield_height = 2000,
    }

    table.insert(_systems, _sys)

    _sys = {
        class = 'StageSystem',
        name = "DevStage2",
        background = "assets/checker_test_16",
        stage = "Test",
        stage_offset_x = 0,
        stage_offset_y = 0,
        x = -4,
        y = 0,
        z = 0,
        playfield_width = 400,
        playfield_height = 240,
    }
    
    table.insert(_systems, _sys)

    local _codex_locations = {
        name= "Locations",
        children = {}
    }

    local _codex_terms = {
        name= "Terms",
        children = {}
    }

    static.codex = {
        _codex_locations,
        _codex_terms 
    }

    for k,v in pairs(static.locations) do
        table.insert(_codex_locations.children, {
            name=v.name, 
            sprite=v.thumbnail,
            callback=function ()
                local _img = LocationDescription(v)
                _img:load()
                g_SceneManager:pushScene(ImageViewer({image=_img}), 'between menus')
        end})
    end

    return static

end

function addToCodexPath(path, element)
    
end
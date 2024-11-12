g_systems = {}
local obj = nil

empty = {
    class = System,
    name = "Unknown",
    emtpy = true,
    playfield_width = 3000,
    playfield_height = 3000,
    background = "assets/backgrounds/bg2"
}

--

obj = {
    class = System,
    name = "Asteroid Belt",
    x = 1,
    y = 1,
    z = 0,
    playfield_width = 3200,
    playfield_height = 1920,
    background = "assets/backgrounds/bg3",
    asteroid_count = 10,
}

g_systems[string.format("%i.%i.%i", obj.x, obj.y, obj.z)] = obj


obj = {
    class = System,
    name = "Asteroid Belt",
    x = 1,
    y = -1,
    z = 0,
    playfield_width = 3200,
    playfield_height = 1920,
    background = "assets/backgrounds/bg3",
    asteroid_count = 10,
}

g_systems[string.format("%i.%i.%i", obj.x, obj.y, obj.z)] = obj

obj = {
    class = System,
    name = "Asteroid Belt",
    x = 0,
    y = -2,
    z = 0,
    playfield_width = 3200,
    playfield_height = 1920,
    background = "assets/backgrounds/bg3",
    asteroid_count = 10,
}

g_systems[string.format("%i.%i.%i", obj.x, obj.y, obj.z)] = obj

obj = {
    class = System,
    name = "Asteroid Belt",
    x = -1,
    y = -1,
    z = 0,
    playfield_width = 3200,
    playfield_height = 1920,
    background = "assets/backgrounds/bg3",
    asteroid_count = 10,
}

g_systems[string.format("%i.%i.%i", obj.x, obj.y, obj.z)] = obj

obj = {
    class = System,
    name = "Asteroid Belt",
    x = -2,
    y = 0,
    z = 0,
    playfield_width = 3200,
    playfield_height = 1920,
    background = "assets/backgrounds/bg3",
    asteroid_count = 10,
}

g_systems[string.format("%i.%i.%i", obj.x, obj.y, obj.z)] = obj

obj = {
    class = System,
    name = "Asteroid Belt",
    x = -1,
    y = 1,
    z = 0,
    playfield_width = 3200,
    playfield_height = 1920,
    background = "assets/backgrounds/bg3",
    asteroid_count = 10,
}

g_systems[string.format("%i.%i.%i", obj.x, obj.y, obj.z)] = obj

obj = {
    class = System,
    name = "Asteroid Belt",
    x = 0,
    y = 2,
    z = 0,
    playfield_width = 3200,
    playfield_height = 1920,
    background = "assets/backgrounds/bg3",
    asteroid_count = 10,
}

g_systems[string.format("%i.%i.%i", obj.x, obj.y, obj.z)] = obj


obj = {
    class = System,
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
        {
            img="assets/planets/planet3",
            img_hd="assets/planets/planet5",
            name="Planet 3",
            orbit_size=300,
            speed=1,
            outline=true,
            facilities= {
                {
                    name = 'Shop',
                    callback = function ()
                        g_SceneManager:pushScene(Shop(), 'hwipe')
                    end
                }
                
            }
        },
        {
            img="assets/planets/planet2",
            img_hd="assets/planets/planet5",
            name="Planet 2",
            orbit_size=500,
            speed=1,
            outline=true,
            facilities= {
                {
                    name = 'Shop',
                    callback = function ()
                        g_SceneManager:pushScene(Shop(), 'hwipe')
                    end
                }
                
            }
        },
        {
            img="assets/planets/planet4",
            img_hd="assets/planets/planet5",
            name="Planet 4",
            orbit_size=600,
            speed=0.5,
            outline=false,
            facilities= {
                {
                    name = 'Shop',
                    callback = function ()
                        g_SceneManager:pushScene(Shop(), 'hwipe')
                    end
                }
                
            }
        },
        {
            img="assets/planets/planet1",
            name="Planet 1",
            img_hd="assets/planets/planet5",
            orbit_size=900,
            speed=0.3,
            outline=true,
            facilities= {
                {
                    name = 'Shop',
                    callback = function ()
                        g_SceneManager:pushScene(Shop(), 'hwipe')
                    end
                }
                
            }
        }
    }

}

g_systems[string.format("%i.%i.%i", obj.x, obj.y, obj.z)] = obj




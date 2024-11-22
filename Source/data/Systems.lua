g_systems = {}
local obj = nil

empty = {
    class = EmptySystem,
    name = "Unknown",
    emtpy = true,
    playfield_width = 3000,
    playfield_height = 3000,
    background = "assets/backgrounds/bg2"
}

--

obj = {
    class = AsteroidSystem,
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
    class = AsteroidSystem,
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
    class = AsteroidSystem,
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
    class = AsteroidSystem,
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
    class = AsteroidSystem,
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
    class = AsteroidSystem,
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
    class = AsteroidSystem,
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
    class = AsteroidSystem,
    name = "Asteroid Belt",
    x = 2,
    y = 0,
    z = 0,
    playfield_width = 3200,
    playfield_height = 1920,
    background = "assets/backgrounds/bg3",
    asteroid_count = 10,
}


obj = {
    class = PlanetSystem,
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
        g_p_freja, 
        g_p_thor,
        g_p_odin,
        g_p_loki
    }

}

g_systems[string.format("%i.%i.%i", obj.x, obj.y, obj.z)] = obj




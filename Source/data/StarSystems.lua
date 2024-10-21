empty = {}
empty.playfield_width = 1600
empty.playfield_height = 960
empty.background = "sprites/space_background"

sol = {}
sol.playfield_width = 1600
sol.playfield_height = 960
sol.background = "sprites/space_background"
sol.sun = "sprites/planets/star"
sol.angle = 0.35
sol.planets = {
    {
        img="sprites/planets/planet3",
        orbit_size=200,
        speed=1,
        outline=true
    },
    {
        img="sprites/planets/planet2",
        orbit_size=300,
        speed=1,
        outline=true
    },
    {
        img="sprites/planets/planet1",
        orbit_size=400,
        speed=1,
        outline=true
    },
    {
        img="sprites/planets/planet4",
        orbit_size=700,
        speed=1,
        outline=false
    }
}


empty = {
    playfield_width = 3000,
    playfield_height = 3000,
    background = "assets/backgrounds/bg2"
}

asteroid_field = {
    x = 1,
    y = 1,
    z = 0,
    playfield_width = 3200,
    playfield_height = 1920,
    background = "assets/backgrounds/bg3",
    asteroids = {
        table.deepcopy(asteroid2),
        table.deepcopy(asteroid2),
        table.deepcopy(asteroid2),
        table.deepcopy(asteroid2),
        table.deepcopy(asteroid2),
        table.deepcopy(asteroid2),
        table.deepcopy(asteroid2),
        table.deepcopy(asteroid2),
        table.deepcopy(asteroid2),
        table.deepcopy(asteroid2)
    }
}


sol = {
    x = 0,
    y = 0,
    z = 0,
    playfield_width = 2000,
    playfield_height = 2000,
    background = "assets/backgrounds/bg1",
    sun = "assets/planets/star",
    angle = 0.6,
    asteroids = {
        asteroid2
    },
    planets = {
        {
            img="assets/planets/planet3",
            img_hd="assets/planets/planet5",
            orbit_size=300,
            speed=1,
            outline=true,
            facilities= {"Facility_1", "Facility_2"}
        },
        {
            img="assets/planets/planet2",
            img_hd="assets/planets/planet5",
            orbit_size=500,
            speed=1,
            outline=true,
            facilities= {"Facility_1", "Facility_2"}
        },
        {
            img="assets/planets/planet4",
            img_hd="assets/planets/planet5",
            orbit_size=600,
            speed=0.5,
            outline=false,
            facilities= {"Facility_1", "Facility_2"}
        },
        {
            img="assets/planets/planet1",
            img_hd="assets/planets/planet5",
            orbit_size=900,
            speed=0.3,
            outline=true,
            facilities= {"Facility_1", "Facility_2"}
        }
    }

}



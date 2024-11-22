g_p_freja = {
    img="assets/planets/planet3",
    img_hd="assets/planets/planet5",
    name="Freja",
    orbit_size=300,
    speed=1,
    outline=true,
    facilities= {
        {
            name = 'Fuel Station',
            callback = function ()
                g_SceneManager:pushScene(FuelStation(), 'between menus')
            end
        }
    }
}

g_p_thor = {
    img="assets/planets/planet2",
    img_hd="assets/planets/planet5",
    name="Thor",
    orbit_size=500,
    speed=1,
    outline=true,
    facilities= {
        {
            name = 'Shop',
            callback = function ()
                g_SceneManager:pushScene(Shop(), 'between menus')
            end
        }
        
    }
}

g_p_loki = {
    img="assets/planets/planet4",
    img_hd="assets/planets/planet5",
    name="Loki",
    orbit_size=600,
    speed=0.5,
    outline=false,
    facilities= {
        {
            name = 'Shop',
            callback = function ()
                g_SceneManager:pushScene(Shop(), 'between menus')
            end
        }
        
    }
}

g_p_odin = {
    img="assets/planets/planet1",
    name="Odin",
    img_hd="assets/planets/planet5",
    orbit_size=900,
    speed=0.3,
    outline=true,
    facilities= {
        {
            name = 'Shop',
            callback = function ()
                g_SceneManager:pushScene(Shop(), 'between menus')
            end
        }
        
    }
}
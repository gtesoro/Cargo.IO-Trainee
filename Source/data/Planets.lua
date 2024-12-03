g_p_freja = {
    img="assets/planets/planet3",
    img_hd="assets/planets/placeholder_hd",
    name="Freja",
    orbit_size=300,
    speed=1,
    outline=true,
    facilities= {

        {
            name = 'Shop',
            callback = function ()
                g_SceneManager:pushScene(Shop(
                    {
                        shop_items = {
                            FuelCell()
                        }
                    }
                ), 'between menus')
            end
        }
        
    }
}

g_p_thor = {
    img="assets/planets/thor/thor",
    img_hd="assets/planets/thor/thor_hd",
    name="Thor",
    orbit_size=500,
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

g_p_loki = {
    img="assets/planets/loki/sd",
    img_hd="assets/planets/loki/hd",
    name="Loki",
    orbit_size=600,
    speed=0.5,
    outline=true,
    facilities= {
        {
            name = 'Cloning Facility',
            callback = function ()
                g_SceneManager:pushScene(CloningFacility(), 'between menus')
            end
        }
        
    }
}

g_p_odin = {
    img="assets/planets/planet1",
    name="Odin",
    img_hd="assets/planets/placeholder_hd",
    orbit_size=900,
    speed=0.3,
    outline=true,
    facilities= {

        
    }
}
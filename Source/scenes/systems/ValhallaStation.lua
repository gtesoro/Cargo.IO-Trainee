local pd <const> = playdate
local gfx <const> = pd.graphics

class('ValhallaStation').extends(System)

function ValhallaStation:startScene()

    ValhallaStation.super.startScene(self)

    self:initStation()
    
end

function ValhallaStation:initStation()
    self.station = AnimatedSprite('assets/space/cylinder_station_thumb', 250)
    self.station:moveTo(self.data.playfield_width*0.75, self.data.playfield_height*0.25)
    self.station:setZIndex(1)
    self.station:add()
    self.station:setCollideRect( 0, 0, self.station:getSize() )
    self.station.interactuable = true

    self.station.data = {
        img_hd = 'assets/space/cylinder_station_hd',
        img_hd_delay = 250,
        name = "Valhalla Station",
        facilities= {
            'Starport',
            'CargoHub'
        }

    }
    local _self = self
    function self.station:interact()
        g_SceneManager:pushScene(PlanetMenu(_self.station.data), 'to menu')
    end

    table.insert(self.sprites, self.station)

end

function ValhallaStation:doUpdate()

    ValhallaStation.super.doUpdate(self)
    
end

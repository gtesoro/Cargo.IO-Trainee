local pd <const> = playdate
local gfx <const> = pd.graphics

class('EmptySystem').extends(System)

function EmptySystem:startScene()

    self.data.background = self:getRandomBackground()
    self.data.bg_random_flip = true
    self.data.playfield_width = 2000
    self.data.playfield_height = 2000
    
    EmptySystem.super.startScene(self)
    self:initAnomaly()

end

function EmptySystem:initAnomaly()

    local _anomaly_roll = math.random(1, 100)
    local _anomaly_threshold = 30

    if _anomaly_roll <= _anomaly_threshold then
        local _anomaly = math.random(1,2)

        if _anomaly == 1 then
            self.space_time_anomaly = true
            self:initSpaceTimeAnomaly()
        end

        if _anomaly == 2 then
            self.electrical_anomaly = true
            self:initElectricalAnomaly()
        end
    end
    
end

function EmptySystem:getRandomBackground()

    local _num = math.random(1,3)
    return string.format("assets/backgrounds/space/empty_%i", _num)
    
end

-- Pirates Begin --

function EmptySystem:initEnemy()

    self.enemy = Enemy(self.ship)
    self.enemy:setZIndex(self.ship:getZIndex())
    self.enemy:add()
    self.enemy:moveTo(self.ship.x + 200, self.ship.y + 120)
    
    table.insert(self.sprites, self.enemy)

end

-- Pirates End --


-- Space Time Anomaly Beging --

function EmptySystem:initSpaceTimeAnomaly()

    g_NotificationManager:notify("Space-Time Anomalies Detected")

    self.underlay = gfx.sprite.new(gfx.image.new('assets/backgrounds/noise'))
    self.underlay:setIgnoresDrawOffset(true)
    self.underlay:setZIndex(self.bg_sprite:getZIndex()-1)
    self.underlay:moveTo(200, 120)
    self.underlay:add()

    table.insert(self.sprites, self.underlay)

    self:initFloaters()
    
end

function EmptySystem:generateFloater(x, y, floater_min_size,floater_max_size)

    local _diameter = math.floor(math.random(floater_min_size, floater_max_size))

    inContext(self.bg_sprite:getImage(), function ()
        gfx.setColor(gfx.kColorClear)
        gfx.fillCircleAtPoint(x, y, _diameter/2)

        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillCircleAtPoint(x, y, self.swallow_distance/2)
    end)

    return {x, y, _diameter}
    
end

function EmptySystem:initFloaters()

    self.columns = 5
    self.rows = 5

    self.floaters = {}
    self.swallowing = false

    self.swallow_distance = 10

    local _left = false

    local _row_height = self.data.playfield_height/self.rows
    local _col_width = self.data.playfield_width/self.rows

    for r=1,self.rows do
        
        for c=1,self.columns do
            local _x, _y = (c-1)*_col_width + _col_width/2 + math.random(-_col_width/2, _col_width/2), (r-1)*_row_height + _row_height/2 + math.random(-_row_height/2, _row_height/2)

            if pd.geometry.point.new(_x, _y):distanceToPoint(pd.geometry.point.new(self.ship.x, self.ship.y)) > 240 then
                local _max_d = math.max(_row_height, _col_width)
                local _f = self:generateFloater(_x, _y, _max_d*0.5, _max_d*0.9)

                table.insert(self.floaters, _f)
            end
            
        end
        _left = not _left
    end
    
end

function EmptySystem:doUpdateSpaceTimeAnomaly()
    local _ship_point = pd.geometry.point.new(self.ship:getPosition())

    for k,v in pairs(self.floaters) do
        local _floater_point = pd.geometry.point.new(v[1], v[2])
        local _floater_diameter = v[3]

        if _floater_point:distanceToPoint(_ship_point) < _floater_diameter/2 then
            local _v = (_ship_point - _floater_point)
            self.ship.speed_vector -= _v:normalized() * 0.20 * (_v:magnitude()/(_floater_diameter/2))
        end

        if _floater_point:distanceToPoint(_ship_point) < self.swallow_distance then

            self.ship:moveTo(self.spawn_point)
            self.ship:stop()
            --g_SystemManager:nextCycle()
        end
    end
end

-- Space Time Anomaly  End --

-- Electrical Anomaly Begin --

function EmptySystem:initElectricalAnomaly()

    g_NotificationManager:notify("Electrical Anomaly Detected")

    self.columns = 6
    self.rows = 6

    self.rays = {}

    local _row_height = self.data.playfield_height/self.rows
    local _col_width = self.data.playfield_width/self.rows

    local image_table = gfx.imagetable.new('assets/space/ray')

    for r=1,self.rows do
        for c=1,self.columns do
            local _x, _y = (c-1)*_col_width + _col_width/2 + math.random(-math.floor(_col_width/2), math.floor(_col_width/2)), (r-1)*_row_height + _row_height/2 + math.random(-math.floor(_row_height/2), math.floor(_row_height/2))

            if pd.geometry.point.new(_x, _y):distanceToPoint(pd.geometry.point.new(self.ship.x, self.ship.y)) > 240 then
                local _ray = AnimatedSprite(image_table)
                _ray:moveTo(_x, _y)
                _ray:setZIndex(self.bg_sprite:getZIndex()+1)
                _ray:add()
                _ray:setRotation(math.random(0, 360))

                function _ray:getLine()

                    local x1, y1 = getRelativePoint(_x, _y, -64, 0, _ray:getRotation())
                    local x2, y2 = getRelativePoint(_x, _y, 64, 0, _ray:getRotation())
                    
                    return pd.geometry.lineSegment.new(x1, y1, x2, y2)
                end

                table.insert(self.sprites, _ray)
                table.insert(self.rays, _ray)
            end
            
        end
    end
    
end

local _ray_p = pd.geometry.point.new(0, 0)
local _ship_p = pd.geometry.point.new(0, 0)

function EmptySystem:doUpdateElectricalAnomaly()

    pd.display.setOffset(0, 0)

    local _ship_rect = self.ship:getBoundsRect()

    _ship_p.x = self.ship.x
    _ship_p.y = self.ship.y

    for k, v in pairs(self.rays) do

        _ray_p.x = v.x
        _ray_p.y = v.y

        if _ray_p:distanceToPoint(_ship_p) < 240 then
            
            if v:getLine():intersectsRect(_ship_rect) then
                pd.display.setOffset(math.random(-1, 1), math.random(-1, 1))
                
                if not self.invulnerable then
                    self.invulnerable = true
                    self.ship.speed_vector += pd.geometry.vector2D.newPolar(math.random(5, 10), math.random(0, 359))
                    g_SystemManager:getPlayer():doHullDamage(math.random(10, 20))
                    local _timer = pd.timer.new(1500)
                    _timer.updateCallback = function ()
                        self.ship:setVisible(not self.ship:isVisible())
                    end
                    _timer.timerEndedCallback = function ()
                        self.invulnerable = false
                        self.ship:setVisible(true)
                    end
                end
            end

        end
    end    

    -- self.ray_overlay:markDirty()
end

-- Eletrical Anomaly End --

function EmptySystem:doUpdate()
    local _self <const> = self

    EmptySystem.super.doUpdate(_self)

    if _self.space_time_anomaly then
        _self:doUpdateSpaceTimeAnomaly()
    end

    if _self.electrical_anomaly then
        _self:doUpdateElectricalAnomaly()
    end

end

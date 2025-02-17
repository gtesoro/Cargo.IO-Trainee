local pd <const> = playdate
local gfx <const> = pd.graphics

class('MiningLaser').extends(Scene)

function MiningLaser:add()
    gfx.setDrawOffset(0,0)
    MiningLaser.super.add(self)
    g_SystemManager:unpause()
end

function MiningLaser:remove()
    MiningLaser.super.remove(self)
    g_SystemManager:pause()
end

function MiningLaser:startScene()

    self.exiting = false
    self.firing = false
    self.exploding = false

    self:initBg()
    self:initAsteroid()
    self:initLaser()
    self:initMinerals()
    self:initDoor()
    self:animateShipIn()
    self:initInputs()

end

function MiningLaser:initBg() 

    self.bg_sprite = gfx.sprite.new(self.data.bg_img:blurredImage(0.5, 2, gfx.image.kDitherTypeScreen)) --gfx.sprite.new(gfx.image.new("assets/backgrounds/asteroid_bg") )
    self.bg_sprite:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.bg_sprite:setIgnoresDrawOffset(true)
    self.bg_sprite:setZIndex(0)

    table.insert(self.sprites, self.bg_sprite)

    self.ship_overlay = gfx.sprite.new(gfx.image.new("assets/backgrounds/asteroid_bg_overlay") )
    self.ship_overlay:moveTo(pd.display.getWidth()/2, pd.display.getHeight()*1.5)
    self.ship_overlay:setIgnoresDrawOffset(true)
    self.ship_overlay:setZIndex(5)

    table.insert(self.sprites, self.ship_overlay)

end

function MiningLaser:animateShipIn()

    self.animating_ship = true

    local timer = pd.timer.new(1000, 0, pd.display.getHeight(), pd.easingFunctions.outCubic)
    timer.updateCallback = function(timer)
        self.ship_overlay:moveTo(pd.display.getWidth()/2, pd.display.getHeight()*1.5-timer.value)
    end

    timer.timerEndedCallback = function()
        self.animating_ship = false
        self.ship_overlay:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    end
end

function MiningLaser:initMinerals()

    self.minerals = {}

    self.trigger_radius = math.random(5,10)

    local _x_split = 2
    local _y_split = 2

    for i=0,_x_split-1 do
        for j=0,_y_split-1 do

            local _covered = false
            local _x_start, _y_start = math.floor(i*self.asteroid_img.width/_x_split), math.floor(j*self.asteroid_img.height/_y_split)
            local _x_end, _y_end = math.floor((i+1)*self.asteroid_img.width/_x_split), math.floor((j+1)*self.asteroid_img.height/_y_split)
            local _x, _y = _x_start, _y_start
            local _d = 0

            while not _covered do
                _x, _y = math.random(_x_start, _x_end), math.random(_y_start, _y_end)
                _d = math.random(10, 20)
                _covered = self:checkCirlcecIsCovered(_x, _y, _d/2, self.asteroid_img)
            end

            local img = gfx.image.new(_d, _d)
            gfx.pushContext(img)
                gfx.setColor(gfx.kColorWhite)
                gfx.fillCircleAtPoint(img.width/2, img.height/2, img.width/2)
                gfx.setColor(gfx.kColorBlack)
                gfx.setLineWidth(2)
                gfx.drawCircleAtPoint(img.width/2, img.height/2, img.width/2)
            gfx.popContext()
            local sprt = gfx.sprite.new(img)
            sprt:moveTo(_x + pd.display.getWidth()/2 - self.asteroid_img.width/2, _y + pd.display.getHeight()/2 - self.asteroid_img.height/2)
            sprt:setZIndex(4)
            self.minerals[#self.minerals+1] = {sprt, sprt.x, sprt.y}
            table.insert(self.sprites, sprt)

        end
    end

    

    self.trigger_animator = gfx.animator.new(1000, 0, 1, playdate.easingFunctions.inOutCubic)
    self.trigger_animator.repeatCount = -1 
    self.trigger_animator.reverses = true

    local img = gfx.image.new(self.trigger_radius*2, self.trigger_radius*2)
    local sprt = gfx.sprite.new(img)
    sprt:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    sprt:setZIndex(5)
    table.insert(self.sprites, sprt)
    self.trigger_point = sprt
    self:drawTrigger()
end

function MiningLaser:drawTrigger()
    local img = self.trigger_point:getImage() --gfx.image.new(self.trigger_point:getSize()) --

    gfx.pushContext(img)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(img.width/2, img.height/2, img.width/2)
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(self.trigger_animator:currentValue(), gfx.image.kDitherTypeBayer8x8)
        gfx.fillCircleAtPoint(img.width/2, img.height/2, img.width/2)
        gfx.setColor(gfx.kColorWhite)
    gfx.popContext()

    self.trigger_point:markDirty()
end

function MiningLaser:rotateMinerals()
    for k,v in pairs(self.minerals) do
        local _x, _y = rotatePoint(v[2], v[3], pd.display.getWidth()/2, pd.display.getHeight()/2, self.asteroid_rotation + self.vibration)
        v[1]:moveTo(_x, _y)
    end
end

function MiningLaser:animateMineral(mineral)

    self:openDoor()

    local line = pd.geometry.lineSegment.new(mineral.x, mineral.y, 200, 230)

    local timer = pd.timer.new(1000, 0, line:length(), pd.easingFunctions.inCubic)
    timer.updateCallback = function(timer)
        local _p = line:pointOnLine(timer.value)
        mineral:moveTo(_p.x, _p.y)
    end

    timer.timerEndedCallback = function()
        mineral:remove()
        self:closeDoor()
    end

    g_SystemManager:getPlayerData():addToInventory(getRandomMineral())

end

function MiningLaser:initDoor()

    local _c_x, _c_y = 200, 210
    local _s = 80
    local _thick = 10
    local _line_sprite = gfx.sprite.new(gfx.image.new(_s, _thick))
    _line_sprite:moveTo(_c_x, _c_y+_thick/2)
    _line_sprite:setZIndex(6)

    self.door_sprite = _line_sprite
    
    table.insert(self.sprites, _line_sprite)

end

function MiningLaser:closeDoor()

    local img = self.door_sprite:getImage()
    local timer = pd.timer.new(500, img.width/2, 0, pd.easingFunctions.inBounce)
    timer.updateCallback = function(timer)
        gfx.pushContext(img)
            gfx.clear()
            gfx.setColor(gfx.kColorBlack)
            gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
            gfx.setLineWidth(img.height)
            gfx.drawLine(img.width/2, img.height/2, img.width/2 + timer.value, img.height/2)
            gfx.drawLine(img.width/2, img.height/2, img.width/2 - timer.value, img.height/2)
        gfx.popContext()
    end

end

function MiningLaser:openDoor()

    local img = self.door_sprite:getImage()
    local timer = pd.timer.new(500, 0, img.width/2, pd.easingFunctions.outBounce)
    timer.updateCallback = function(timer)
        gfx.pushContext(img)
            gfx.clear()
            gfx.setColor(gfx.kColorBlack)
            gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
            gfx.setLineWidth(img.height)
            gfx.drawLine(img.width/2, img.height/2, img.width/2 + timer.value, img.height/2)
            gfx.drawLine(img.width/2, img.height/2, img.width/2 - timer.value, img.height/2)
        gfx.popContext()
    end
end

function MiningLaser:checkCirlcecIsCovered(x, y, r, img)
    local _arc = pd.geometry.arc.new(x, y, r, 0, 360)
    if img:sample(x, y) == gfx.kColorClear then
        return false
    end
    
    if pd.geometry.distanceToPoint(x, y, img.width/2, img.height/2) < self.trigger_radius + r then
        return false
    end

    for d=0,_arc:length() do
        local _p = _arc:pointOnArc(d)
        if img:sample(_p.x, _p.y) == gfx.kColorClear then
            return false
        end
    end

    return true
end

function MiningLaser:checkCore()
    local img = self.asteroid_canvas:getImage()
    local _arc = pd.geometry.arc.new(img.width/2, img.height/2, self.trigger_radius, 0, 360)
    local _free = math.floor(_arc:length()*.25)
    for d=0,_arc:length() do
        local _p = _arc:pointOnArc(d)
        if img:sample(_p.x, _p.y) == gfx.kColorClear then
            _free -= 1
            if _free < 0 then
                break
            end
        end
    end
    if _free <= 0 then
        self:triggerExplosion()
    end
end

function MiningLaser:triggerExplosion()

    local img = gfx.image.new(pd.display.getWidth(), pd.display.getHeight())
    local sprt = gfx.sprite.new(img)
    sprt:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    sprt:setZIndex(6)
    sprt:add()
    table.insert(self.sprites, sprt)
    self.explosion = sprt
    self.exploding = true
    self.explosion_animator = gfx.animator.new(3000, 0, math.sqrt(pd.display.getWidth()^2 + pd.display.getHeight()^2)/2, playdate.easingFunctions.outCubic)

end

function MiningLaser:drawExplotion()

    local img = self.explosion:getImage()

    gfx.pushContext(img)
        gfx.clear()
        
        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillCircleAtPoint(img.width/2, img.height/2, self.explosion_animator:currentValue()*1.2)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(img.width/2, img.height/2, self.explosion_animator:currentValue())
    gfx.popContext()

    self.explosion:markDirty()

end

function MiningLaser:checkFreeMinerals()
    local img = self.asteroid_canvas:getImage()
    for k,v in pairs(self.minerals) do
        local _arc = pd.geometry.arc.new(v[1].x, v[1].y, v[1]:getImage().width/2, 0, 360)
        local _free = math.floor(_arc:length()*.75)
        for d=0,_arc:length() do
            local _p = _arc:pointOnArc(d)
            if img:sample(_p.x, _p.y) == gfx.kColorClear then
                _free -= 1
                if _free < 0 then
                    break
                end
            end
        end
        if _free <= 0 then
            self:animateMineral(v[1])
            table.remove(self.minerals, k)
        end
    end
end

function MiningLaser:initAsteroid() 

    self.asteroid_cache = {}

    self.asteroid_img_quantum = 2

    self.asteroid_rotation = 1
    self.vibration = 0
    self.vibration_range = 3
    self.asteroid_angular_speed = 0


    local img_path = string.format('assets/asteroids/a%i', math.random(1,2))
    self.asteroid_img = gfx.image.new(img_path, gfx.kColorClear)

    self.asteroid_canvas = gfx.sprite.new()
    self.asteroid_canvas:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.asteroid_canvas:setZIndex(1)

    for a=0,360,self.asteroid_img_quantum do
        local img = gfx.image.new(pd.display.getWidth(), pd.display.getHeight(), gfx.kColorClear)
        gfx.pushContext(img)
            self.asteroid_img:drawRotated(pd.display.getWidth()/2, pd.display.getHeight()/2, a)
        gfx.popContext()
        self.asteroid_cache[#self.asteroid_cache+1] = img
        self.asteroid_cache[#self.asteroid_cache+1] = img
    end

    if self.asteroid_cache[self.asteroid_rotation+self.vibration] then
        self.asteroid_canvas:setImage(self.asteroid_cache[self.asteroid_rotation+self.vibration])
    end

    table.insert(self.sprites, self.asteroid_canvas)

end

function MiningLaser:initLaser()

    self.beam_size = 5
    self.remaining_beam = self.beam_size
    self.beam_rate = 0.1

    self.laser_counter = 0
    self.laser_update = 25

    self.laser_origin_x = 70
    self.laser_origin_y = 120
    self.laser_target_x = 330
    self.laser_target_y = 120

    local img = gfx.image.new(pd.display.getWidth(), pd.display.getHeight(), gfx.kColorClear)
    self.laser_sprite = gfx.sprite.new(img)
    self.laser_sprite:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.laser_sprite:setZIndex(3)

    table.insert(self.sprites, self.laser_sprite)
end

function MiningLaser:castRay(img, _laser_line)
    for d=0, _laser_line:length() do 
        local _p = _laser_line:pointOnLine(d)
        local _p_x, _p_y = _p.x, _p.y -- math.floor(_p.x), math.floor(_p.y)
        for b=0,self.remaining_beam/2 do
            if img:sample(_p_x, _p_y + b) ~= gfx.kColorClear then
                return true, _p_x, _p_y
            end
        end
        for b=0,self.remaining_beam/2 do
            if img:sample(_p_x, _p_y - b) ~= gfx.kColorClear then
                return true, _p_x, _p_y
            end
        end
    end
    return false, nil, nil
end

function MiningLaser:applyLaser()

    local _laser_line = pd.geometry.lineSegment.new(self.laser_origin_x, self.laser_origin_y, 400, 120)

    _hit, self.laser_target_x, self.laser_target_y = self:castRay(self.asteroid_canvas:getImage(), _laser_line)

    self.vibration = math.random(-self.vibration_range, self.vibration_range)

    if self.laser_counter == self.laser_update then

        --self.remaining_beam -= self.beam_rate
        
        _laser_line = pd.geometry.lineSegment.new(self.laser_origin_x, self.laser_origin_y, self.laser_target_x, self.laser_target_y)
        local _hit, _t_x, _t_y = self:castRay(self.asteroid_canvas:getImage(), _laser_line)

        if _hit then
            self.laser_target_x, self.laser_target_y = _t_x, _t_y
            for k,v in pairs(self.asteroid_cache) do
                gfx.pushContext(v)
                    gfx.setColor(gfx.kColorClear)
                    local _x, _y = rotatePoint(self.laser_target_x, self.laser_target_y, pd.display.getWidth()/2, pd.display.getHeight()/2, 360 - self.asteroid_rotation + k)
                    gfx.fillCircleAtPoint(_x, _y, self.remaining_beam)
                gfx.popContext()
            end
            self:checkFreeMinerals()
            self:checkCore()
        else
            self.laser_target_x = 330
            self.laser_target_y = 120
        end
    end

    gfx.pushContext(self.laser_sprite:getImage())
        local _rumble_x , _rumble_y = math.random(-1,1), math.random(-1,1)/2
        gfx.clear()
        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(self.remaining_beam)
        gfx.drawLine(self.laser_origin_x + _rumble_x , self.laser_origin_y + _rumble_y, self.laser_target_x + _rumble_x,self.laser_target_y + _rumble_y)
        gfx.fillCircleAtPoint(self.laser_target_x + _rumble_x, self.laser_target_y + _rumble_y, self.remaining_beam/2)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillCircleAtPoint(self.laser_target_x + math.random(-1,1), self.laser_target_y + math.random(-1,1), self.remaining_beam*2)
    gfx.popContext()

    self.laser_sprite:markDirty()

end

function MiningLaser:initInputs()

    local _acc_mod = 1/250
    local _max_speed = 3

    self.input_handlers = {

        cranked = function (change, acceleratedChange)
            self.asteroid_rotation = math.floor(pd.getCrankPosition())
        end,

        AButtonDown = function ()
            self.firing = true
        end,

        AButtonUp = function ()
            self.firing = false
            self.vibration = 0
        end,

        BButtonDown = function ()
            self.exiting = true
        end,

        BButtonUp = function ()
            self.exiting = false
        end,

        downButtonDown = function ()
            g_SceneManager:pushScene(PlayerMenu(), 'to menu')
        end

    }
end

function MiningLaser:doUpdate()

    if self.exploding then
        self:drawExplotion()
        if self.explosion_animator:ended() then
            g_SystemManager:death()
        end
        return
    end

    self:drawTrigger()

    self.laser_counter += 1

    if self.ship_overlay.y <= pd.display.getHeight()/2 and self.firing and self.remaining_beam > 0 then
        pd.display.setOffset(math.random(-2,2), math.random(-2,2))
        self.laser_sprite:add()
        self:applyLaser()
    else
        pd.display.setOffset(0,0)
        if self.remaining_beam < self.beam_size then
            self.remaining_beam += (self.beam_size/pd.getFPS())
        end
        self.laser_sprite:remove()
    end

    if not self.animating_ship then
        if self.exiting then
            if self.ship_overlay.y > pd.display.getHeight()*1.5 then
                g_SceneManager:popScene('wipe down')
            end
            self.ship_overlay:moveBy(0, 5)
        else
            if self.ship_overlay.y > pd.display.getHeight()/2 then
                self.ship_overlay:moveBy(0, -5)
            end
        end
    end

    self:rotateMinerals()

    if self.asteroid_cache[self.asteroid_rotation+self.vibration] then
        self.asteroid_canvas:setImage(self.asteroid_cache[self.asteroid_rotation+self.vibration])
    end

    if self.laser_counter > self.laser_update then
        self.laser_counter = 0
    end
end
local pd <const> = playdate
local gfx <const> = playdate.graphics

class('NotificationManager').extends(gfx.sprite)

function NotificationManager:init()

    self.notifications = List()
    self.default_duration = 1500

    self.y_pos = 10

    self.wait_timer = nil

    self.current = {}

    self.in_out_duration = 300

    self.easing = pd.easingFunctions.outBounce

    self:add()
    
end

function NotificationManager:notify(str, duration)

    if not duration then
        duration = self.default_duration
    end

    self.notifications:append({value = str, duration = duration})
    
end

function NotificationManager:update()
    local _n = self.notifications:get(1)
    if not g_SceneManager.transitioning and _n and self.wait_timer == nil then
        if self:_notify(_n.value, _n.duration) then
            self.notifications:remove(_n)
        end
    end
end

function NotificationManager:_notify(str, duration)

    local _w, _h = gfx.getTextSize(string.format("*%s*",str))

    local _h_padding = 5
    local _w_padding = 10

    local _y_spacing = 5

    local _float = 5

    _w += _w_padding*2 + _float
    _h += _h_padding*2 + _float

    local _x, _y = _w/2 + 400 , self.y_pos + _h/2

    if _y + _h/2 >= 240 - _y_spacing then
        return false
    end

    self.y_pos += _h + _y_spacing*2

    local img = gfx.image.new(_w, _h)
    gfx.pushContext(img)
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRoundRect(_float, _float, img.width, img.height, 1)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(0, 0, img.width-_float, img.height-_float, 1)
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(2)
        gfx.drawRoundRect(0, 0, img.width-_float, img.height-_float, 1)
        gfx.drawTextInRect(string.format("*%s*",str), _w_padding, _h_padding, img.width - _w_padding -_float, img.height -_h_padding -_float, nil, nil, kTextAlignment.left)
    gfx.popContext()
    local spr = gfx.sprite.new(img)
    spr:setIgnoresDrawOffset(true)

    spr:setZIndex(30000)
    spr:add()

    spr:moveTo(_x, _y)

    local timer_in = pd.timer.new(self.in_out_duration, 0, _w - _float, self.easing)
    local timer_out = nil
    local timer_wait = nil
    local timer_global = pd.timer.new(self.in_out_duration *2 + duration)
    timer_global.timerEndedCallback = function ()
        spr:remove()
        self.y_pos -= _h + _y_spacing*2
        table_remove(self.current, timer_global)
    end

    self.current[#self.current+1] = timer_global

    timer_in.updateCallback = function (timer)
        spr:moveTo(_x - timer.value, _y)
    end

    timer_in.timerEndedCallback = function ()
        timer_wait = pd.timer.new(duration)
        timer_wait.timerEndedCallback = function ()
            timer_out = pd.timer.new(self.in_out_duration, _w - _float, 0, self.easing)
            timer_out.updateCallback = function (timer)
                spr:moveTo(_x - timer.value, _y)
            end
        end
    end

    self.wait_timer = pd.timer.new(500)
    self.wait_timer.timerEndedCallback = function ()
        self.wait_timer = nil
    end

    return true

end

function NotificationManager:reset()


    -- for k,v in pairs(self.current) do
    --     v.timerEndedCallback()
    --     v:remove()
    -- end

    -- self.notifications = List()
end
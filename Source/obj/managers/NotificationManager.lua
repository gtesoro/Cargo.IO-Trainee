local pd <const> = playdate
local gfx <const> = playdate.graphics

class('NotificationManager').extends()

function NotificationManager:init()

    self.notifications = List()
    self.base_duration = 1000

    self.y_pos = 240 * 0.1

    self.wait_timer = nil

    self.current = {}

    self.in_out_duration = 500

    self.active_notifications = {}

    self.easing = pd.easingFunctions.outBounce
    
end

function NotificationManager:notify(str, duration, log)

    if not duration then
        duration = self.base_duration + str:len() * 80
    end

    if not log then
        log = true
    end

    self.notifications:append({value = str, duration = duration, log = log})
    
end

function NotificationManager:update()

    local _n = self.notifications:get(1)
    if not g_SceneManager.transitioning and _n and self.wait_timer == nil then
        if self:_notify(_n.value, _n.duration, _n.log) then
            self.notifications:remove(_n)
        end
    end
end

function NotificationManager:_notify(str, duration, log)

    gfx.setFont(g_font_18)

    local _w, _h = gfx.getTextSize(str)

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
        gfx.drawTextInRect(string.format("%s",str), _w_padding, _h_padding, img.width - _w_padding -_float, img.height -_h_padding -_float, nil, nil, kTextAlignment.left)
    gfx.popContext()
    local spr = gfx.sprite.new(img)
    spr:setIgnoresDrawOffset(true)

    spr:setZIndex(30000)
    spr:add()

    spr:moveTo(_x, _y)

    self.active_notifications[#self.active_notifications+1] = spr

    local timer_in = pd.timer.new(self.in_out_duration, 0, _w - _float, self.easing)
    local timer_out = nil
    local timer_wait = nil
    local timer_global = pd.timer.new(self.in_out_duration *2 + duration)
    timer_global.timerEndedCallback = function ()
        spr:remove()
        for k,v in pairs(self.active_notifications) do
            if v ~= spr and v.y > spr.y then
                local _move_timer = pd.timer.new(250, 0, _h + _y_spacing*2, self.easing)
                local _s_y = v.y
                _move_timer.updateCallback = function (timer)
                    if v then
                        v:moveTo(v.x, _s_y - timer.value)
                    end
                end
            end
        end
        table_remove(self.active_notifications, spr)
        self.y_pos -= _h + _y_spacing*2
        table_remove(self.current, timer_global)
    end

    self.current[#self.current+1] = timer_global

    timer_in.updateCallback = function (timer)
        spr:moveTo(_x - timer.value, spr.y)
    end

    timer_in.timerEndedCallback = function ()

        g_SoundManager:playNotificationDing()
        timer_wait = pd.timer.new(duration)
        timer_wait.timerEndedCallback = function ()
            g_SoundManager:playNotification(self.in_out_duration)
            timer_out = pd.timer.new(self.in_out_duration, _w - _float, 0, self.easing)
            timer_out.updateCallback = function (timer)
                spr:moveTo(_x - timer.value, spr.y)
            end
        end
    end

    self.wait_timer = pd.timer.new(500)
    self.wait_timer.timerEndedCallback = function ()
        self.wait_timer = nil
    end

    g_SoundManager:playNotification(self.in_out_duration)

    if log then
        g_SystemManager:getPlayerData():logNotification(str)
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
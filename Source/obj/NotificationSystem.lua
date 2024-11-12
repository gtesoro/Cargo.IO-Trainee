local pd <const> = playdate
local gfx <const> = playdate.graphics

class('NotificationSystem').extends(gfx.sprite)

function NotificationSystem:init()

    self.notifications = List()
    self.default_duration = 3000

    self:add()
    
end

function NotificationSystem:notify(str, duration)

    if not duration then
        duration = self.default_duration
    end

    self.notifications:append({value = str, duration = duration})
    
end

function NotificationSystem:update()
    local _n = self.notifications:get(1)
    if not self.notifying and _n then
        self:_notify(_n.value, _n.duration)
        self.notifications:remove(_n)
    end
end

function NotificationSystem:_notify(str, duration)

    self.notifying = true

    local _w, _h = gfx.getTextSize(string.format("*%s*",str))

    local _h_padding = 5
    local _w_padding = 10

    local _float = 5

    _w += _w_padding*2 + _float
    _h += _h_padding*2 + _float

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

    local _x, _y = _w/2 + 400 , 30 + _h/2

    spr:moveTo(_x, _y)

    local timer_in = pd.timer.new(500, 0, _w - _float, pd.easingFunctions.outBounce)
    timer_in.updateCallback = function (timer)
        spr:moveTo(_x - timer.value, _y)
    end

    timer_in.timerEndedCallback = function ()
        local timer_wait = pd.timer.new(duration)
        timer_wait.timerEndedCallback = function ()
            local timer_out = pd.timer.new(500, _w - _float, 0, pd.easingFunctions.outBounce)
            timer_out.updateCallback = function (timer)
                spr:moveTo(_x - timer.value, _y)
            end
            timer_out.timerEndedCallback = function ()
                spr:remove()
                self.notifying = false
            end
        end
    end

end
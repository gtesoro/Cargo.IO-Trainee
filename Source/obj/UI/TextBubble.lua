local pd <const> = playdate
local gfx <const> = pd.graphics

class('TextBubble').extends(gfx.sprite)

function TextBubble:init(text, w, type, margin, animate, delay)

    self.margin = margin or 0

    self.text = text

    self.intro_duration = 250

    self.type = type or DIAG_OTHER

    if self.type == DIAG_OTHER or self.type == DIAG_PLAYER then
        self.font = g_font_text_family
    else
        self.font = g_font_desc_family
    end
    
    --gfx.setFont(self.font)
    gfx.setFontFamily(self.font)
    local _w, _h = gfx.getTextSizeForMaxWidth(self.text, w - self.margin*2)

    self._h = _h+3
    self._w = _w
    
    self.canvas = gfx.image.new(w, self._h + self.margin*2)
    self.animate = animate or true
    self.delay = delay or 30
    self.current_pos = 1

    self:setImage(self.canvas)

end

function TextBubble:getDuration()
    return self.delay*string.len(self.text)
end

function TextBubble:add()
    TextBubble.super.add(self)

    if self.animate and not self.finished then
        g_SoundManager:playBeginTransmission()
        local _target = self.canvas.width
        if self.type == DIAG_DESC then
            _target = self.canvas.height*2
        end
        self.animate_in_timer = pd.timer.new(self.intro_duration, 0, _target, pd.easingFunctions.outQuad)
        self.animate_in_timer.updateCallback = function (timer)
            gfx.pushContext(self.canvas)
                self:drawBubbleBg(timer.value)
            gfx.popContext()
            self:markDirty()
        end

        self.animate_in_timer.timerEndedCallback = function ()
            self.animate_timer = pd.timer.new(self.delay)
            self.animate_timer.repeats = true
            self.animate_timer.timerEndedCallback = function ()
                if self.current_pos == string.len(self.text) then
                    self:finish()
                else
                    self:drawText(self.current_pos)
                    self:markDirty()
                    self.current_pos += 1
                end
            end
        end

    else
        self:drawText(string.len(self.text))
    end
    
end

function TextBubble:drawBubbleBg(value)

    gfx.clear()
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    local _hover = 3
    if self.type == DIAG_OTHER then
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRoundRect(_hover, _hover, (value or self.canvas.width)-_hover, self.canvas.height-_hover,2)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(0,0, (value or self.canvas.width)-_hover, self.canvas.height-_hover,2)
    elseif self.type == DIAG_DESC then
        -- gfx.setColor(gfx.kColorWhite)
        -- gfx.fillRoundRect(2,2, (value or self.canvas.width)-2, self.canvas.height-2,2)
        -- gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(4)
        if value and value > self.canvas.height then
            gfx.drawLine(2, value - self.canvas.height, 2, self.canvas.height)
        end
        if value and  value <= self.canvas.height then
            gfx.drawLine(2,0, 2, value)
        end
        -- gfx.setColor(gfx.kColorBlack)
        -- gfx.fillRoundRect(_hover,_hover, (value or self.canvas.width)-2, self.canvas.height-2,2)
        -- gfx.setColor(gfx.kColorWhite)
        -- gfx.fillRoundRect(_hover*2,_hover*2, (value or self.canvas.width)-2, self.canvas.height-2,2)

        
    else
        -- gfx.setColor(gfx.kColorBlack)
        -- gfx.fillRoundRect(0,0, self.canvas.width, value or self.canvas.height, 2)
        -- gfx.setColor(gfx.kColorWhite)
        -- gfx.fillRect(self.canvas.width-_bar_thick,0, _bar_thick, value or self.canvas.height)
        -- gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRoundRect(_hover + self.canvas.width-(value or self.canvas.width) , _hover, (value or self.canvas.width)-_hover, self.canvas.height-_hover,2)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRoundRect(self.canvas.width-(value or self.canvas.width),0, (value or self.canvas.width)-_hover, self.canvas.height-_hover,2)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawRoundRect(self.canvas.width-(value or self.canvas.width),0, (value or self.canvas.width)-_hover, self.canvas.height-_hover,2)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    end
    
end

function TextBubble:drawText(length)

    gfx.setFont(self.font)

    if string.sub(self.text, length, length) ~= ' ' then
        g_SoundManager:playKeyPress()
    end

    local _str = string.sub(self.text, 1, length)

    gfx.pushContext(self.canvas)
        self:drawBubbleBg()
        if self.type == DIAG_PLAYER then
            gfx.drawTextInRect(_str, self.canvas.width-self.margin-self._w-3, self.canvas.height-self.margin-self._h, self._w, self._h, nil , nil, kTextAlignment.right)
        -- elseif self.type == DIAG_DESC then
        --     gfx.drawTextInRect(_str, self.margin + 3, self.margin + 3, self._w-3, self._h-3)
        else
            gfx.drawTextInRect(_str, self.margin, self.margin, self._w, self._h)
        end
    gfx.popContext()

end

function TextBubble:finish()

    self.finished = true
    if self.animate_in_timer then
        self.animate_in_timer:remove()
    end
    if self.animate_timer then
        self.animate_timer:remove()
    end
    self:drawText(string.len(self.text))
    g_SoundManager:playEndTransmission()
    if self.on_finish then
        self.on_finish()
    end
end
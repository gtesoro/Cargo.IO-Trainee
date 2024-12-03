local pd <const> = playdate
local gfx <const> = pd.graphics

class('TextBox').extends(gfx.sprite)

function TextBox:init(text, w, h) 
    self.text = text

    self.margin = 10

    
    gfx.setFont(g_font_18)
    local _w, _h = gfx.getTextSizeForMaxWidth(self.text, w - self.margin *2)
    self.text_img = gfx.image.new(_w, _h)
    inContext(self.text_img, function ()
        --gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
        gfx.drawTextInRect(self.text,0,0, self.text_img:getSize())
        gfx.setFont()
    end)

    local img = gfx.image.new(w, h)
    inContext(img, function ()

        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(0, 0, w, h, 4)
        self.text_img:draw(self.margin , self.margin)
        
    end)

    self:setImage(img)

    if _h > h then
        self.scroll = _h - h + self.margin
    end

end

function TextBox:update()

    if self.scroll then
        if not self.timer then
            self.timer = pd.timer.new(1000*self.scroll/10, 0, self.scroll, pd.easingFunctions.inOutCubic)
            self.timer.reverses = true
            self.timer.repeats = true
            self.timer.updateCallback = function (timer)
                inContext(self:getImage(), function ()
                    gfx.clear()
                    gfx.setColor(gfx.kColorWhite)
                    gfx.fillRoundRect(0, 0, self:getImage().width, self:getImage().height, 4)
                    self.text_img:draw(self.margin , self.margin - timer.value)
                    
                end)
                self:markDirty()
            end
        end
    end
    
end
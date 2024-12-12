local pd <const> = playdate
local gfx <const> = pd.graphics

class('TextBox').extends(gfx.sprite)

function TextBox:init(text, w, h, aligment, margin, bg, font) 
    
    self.text = text

    self.margin = margin
    if not self.margin then
        self.margin = 3
    end

    self.bg = bg
    if not self.bg then
        self.bg = gfx.kColorWhite
    end

    self.font = font
    if not self.font then
        self.font = g_font_18
    end

    local _w, _h = gfx.getTextSize(self.text)
    
    gfx.setFont(g_font_18)

    local _box_w, _box_h = _w + self.margin*2, _h + self.margin*2

    if w and w > _box_w then
        _box_w = w
    end

    if h and h > _box_h then
        _box_h = h
    end

    local img = gfx.image.new(_box_w, _box_h)
    inContext(img, function ()

        gfx.setColor(self.bg)
        gfx.fillRoundRect(0, 0, img.width, img.height, 4)

        gfx.drawTextAligned(self.text, img.width/2, img.height/2 - _h/2, kTextAlignment.center)
    end)

    self:setImage(img)

    -- if _h > h then
    --     self.scroll = _h - h + self.margin
    -- end

end

function TextBox:update()

    -- if self.scroll then
    --     if not self.timer then
    --         self.timer = pd.timer.new(1000*self.scroll/10, 0, self.scroll, pd.easingFunctions.inOutCubic)
    --         self.timer.reverses = true
    --         self.timer.repeats = true
    --         self.timer.updateCallback = function (timer)
    --             inContext(self:getImage(), function ()
    --                 gfx.clear()
    --                 gfx.setColor(gfx.kColorWhite)
    --                 gfx.fillRoundRect(0, 0, self:getImage().width, self:getImage().height, 4)
    --                 self.text_img:draw(self.margin , self.margin - timer.value)
                    
    --             end)
    --             self:markDirty()
    --         end
    --     end
    -- end
    
end
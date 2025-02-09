local pd <const> = playdate
local gfx <const> = pd.graphics

class('TextBox').extends(gfx.sprite)

function TextBox:init(text, w, h, font, alignment, margin, bg) 
    
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

    gfx.setFont(self.font)

    local _align = alignment or kTextAlignment.center

    local _w, _h = gfx.getTextSize(self.text)
    

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

        gfx.drawTextAligned(self.text, img.width/2, img.height/2 - _h/2, _align)
    end)

    self:setImage(img)

    self:setCollideRect(0,0, self:getSize())

end
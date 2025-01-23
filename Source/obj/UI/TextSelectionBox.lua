local pd <const> = playdate
local gfx <const> = pd.graphics

class('TextSelectionBox').extends(gfx.sprite)

function TextSelectionBox:init(options)

    self.padding = 5

    self.left_offset = 15

    self._w = 165
    self._h = 180

    local _max_h = 0
    gfx.setFont(g_font_text)
    for k,v in pairs(options) do
        local _w, _h = gfx.getTextSizeForMaxWidth(v.text, self._w - 2*self.padding)
        _max_h = math.max(_h, _max_h)
    end

    self._h = math.min(self._h, (_max_h)*#options + (self.padding*2)*#options)
    
    self.listview = pd.ui.gridview.new(0, _max_h)
    self.listview:setNumberOfRows(#options)
    self.listview:setCellPadding(self.padding,self.padding,self.padding,self.padding)

    function self.listview:drawCell(section, row, column, selected, x, y, width, height)
        gfx.setFont(g_font_text)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawTextInRect(options[row].text, x, y, width, height)
        if not selected then
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            gfx.setColor(gfx.kColorBlack)
            gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
            gfx.fillRect(x, y, width, height)
        end
    end

    self:setImage(gfx.image.new(self._w + self.left_offset, self._h))

    self:drawList()
end

function TextSelectionBox:drawList()
    
    gfx.pushContext(self:getImage())
        gfx.clear()
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRoundRect(0, 0, self._w + self.left_offset, self._h, 4)

        self.listview:drawInRect(self.left_offset, 0, self:getSize())

        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(4)
        gfx.drawRoundRect(-2, 0, self._w + self.left_offset+2, self._h, 4)
        
    gfx.popContext()

    self:markDirty()
end

function TextSelectionBox:update()
    TextSelectionBox.super.update(self)
    if self.listview.needsDisplay == true then
        self:drawList()
    end
end

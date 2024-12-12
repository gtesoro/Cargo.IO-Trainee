local pd <const> = playdate
local gfx <const> = playdate.graphics

class('ItemPanel').extends(Widget)

function ItemPanel:init(w, h)

    self._w = w
    self._h = h

end

function ItemPanel:setItem(item)
    local img = gfx.image.new(self._w, self._h)

    gfx.pushContext(img)
        local item_img = item:getImage()
        local padding = 6
        local _l = 5

        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(0, 0, self._w, self._h, 2)

        -- gfx.setColor(gfx.kColorBlack)
        -- gfx.setLineWidth(_l)
        -- gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        -- gfx.drawRect(_l/2, _l/2, item_img.width + padding + _l, item_img.height + padding + _l)

        gfx.drawTextInRect(item.name, 0, self._h*0.02, self._w, self._h*0.2, nil, nil, kTextAlignment.center, g_font_18)

        -- gfx.setImageDrawMode(gfx.kDrawModeXOR)
        -- item_img:draw(_l + padding/2, _l + padding/2)
        

        local cell_padding = 5

        local _attrs = item:getAttrs()

        self.grid = pd.ui.gridview.new((self._w)/2 - 2*cell_padding,  20)
        self.grid:setNumberOfColumns(2)
        self.grid:setNumberOfRows(#_attrs)
        self.grid:setCellPadding(cell_padding, cell_padding, 2, 2)

        function self.grid:drawCell(section, row, column, selected, x, y, width, height)
            local _c = 1
            local _desc = _attrs[row]

            -- gfx.setColor(gfx.kColorBlack)
            -- gfx.setLineWidth(1)
            -- gfx.drawRect( x, y, width, height)

            gfx.setFont(g_font_text)

            local _text = "n/a"
            if column == 1 then
                _text = string.format("%s:", _desc[1])
                gfx.drawTextInRect(_text, x, y, width, height, nil, nil, kTextAlignment.left)
            end
            if column == 2 then
                _text = _desc[2]
                gfx.drawTextInRect(_text, x, y, width, height, nil, nil, kTextAlignment.right)
            end
            
        end

        self.grid:drawInRect(0, self._h*0.25,  self._w, self._h*0.98)

    gfx.popContext()

    self:setImage(img)
    self:markDirty()
end

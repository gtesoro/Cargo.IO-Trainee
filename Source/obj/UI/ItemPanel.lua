local pd <const> = playdate
local gfx <const> = playdate.graphics

class('ItemPanel').extends(Widget)

function ItemPanel:init(item)

    local _row_height = 15
    local cell_padding_x = 0
    local cell_padding_y = 2
    local _w = 150
    gfx.setFont(g_font_18)
    local _, _header_height = gfx.getTextSizeForMaxWidth(item.name, _w)
    _header_height += cell_padding_y * 2

    local _attrs = item:getAttrs()
    local img = gfx.image.new(150, _header_height+(_row_height+cell_padding_y * 2)*#_attrs*2)

    gfx.pushContext(img)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawTextInRect(item.name, 0, 0, img.width, _header_height, nil, nil, kTextAlignment.center, g_font_18)

        self.grid = pd.ui.gridview.new(0,  _row_height)
        self.grid:setNumberOfRows(#_attrs*2)
        self.grid:setCellPadding(cell_padding_x, cell_padding_x, cell_padding_y, cell_padding_y)

        function self.grid:drawCell(section, row, column, selected, x, y, width, height)
            gfx.setFont(g_font_text)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            local _desc = _attrs[math.modf((row-1)/2)+1]
            
            local _text = "n/a"
            if math.fmod(row, 2) ~= 0 then
                _text = string.format("%s.", _desc[1])
                gfx.drawTextInRect(_text, x, y, width, height, nil, nil, kTextAlignment.left)
            else
                
                if type(_desc[2]) == "function" then
                    _text = string.format("%i", item:getCurrentPrice())
                else
                    _text = _desc[2]
                end
                gfx.drawTextInRect(_text, x, y, width, height, nil, nil, kTextAlignment.right)
            end
            
        end

        self.grid:drawInRect(0, _header_height,  img.width, img.height-_header_height)

    gfx.popContext()

    self:setImage(img)

    print(_header_height, self:getSize())

end

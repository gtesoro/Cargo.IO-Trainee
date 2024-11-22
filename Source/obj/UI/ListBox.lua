local pd <const> = playdate
local gfx <const> = playdate.graphics

class('ListBox').extends(Widget)

function ListBox:init(data, width, height, item_height)

    if not data then
        data = {}
    end

    self.data = data

    local padding = 2

    local _w, _h = 0, 0
    local text_offset = 5
    local _item_height = 0

    local _min_width = 0

    gfx.setFont(g_font_18)
        
    for k,v in pairs(self.data.options) do
        local __w, __h = gfx.getTextSize(v.name)
        if __w > _min_width then
            _min_width = __w
        end
        _item_height = __h
    end

    _item_height = text_offset*2 + _item_height

    if item_height then
        _item_height = item_height
    end

    _w = _min_width + text_offset*2 + padding*2
    _h = _item_height * #self.data.options + text_offset*2 + padding*2

    if width and height then
        _w = width
        _h = height
    end

    self.list_color = gfx.kColorBlack
    self.listview = playdate.ui.gridview.new(0, _item_height)
    self.listview:setNumberOfRows(#self.data.options)
    self.listview:setCellPadding(padding,padding,padding,padding)
    local img = gfx.image.new(_w, _h)
    gfx.pushContext(img)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(0, 0, _w, _h, 4)
    gfx.popContext()
    self.listview.backgroundImage = img

    function self.listview:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        gfx.setFont(g_font)
        --gfx.drawTextAligned(string.format("*%s*", data[row].name), x+text_offset , y+text_offset, kTextAlignment.left)
        --gfx.drawTextInRect(string.format("%s", data[row].name), x+text_offset , y+text_offset, width, height, nil, nil, kTextAlignment.left, g_font)
        gfx.drawText(string.format("%s", data.options[row].name), x + text_offset , y + text_offset)
    end

    self:setImage(gfx.image.new(_w, _h))

    self:drawList()

    self:initInputs()
    
end

function ListBox:drawList()

    gfx.pushContext(self:getImage())
        gfx.clear()
        gfx.setColor(self.list_color)
        self.listview:drawInRect(0, 0, self:getSize())
    gfx.popContext()

    self:markDirty()
end

function ListBox:setListColor(color)
    self.list_color = color
    self:drawGrid()
end


function ListBox:initInputs()

    self.input_handlers = {

        AButtonUp = function ()
            local s, r, c = self.listview:getSelection()

            if self.data.options[r].callback then
                self.data.options[r].callback(self)
            end
        end,

        BButtonUp = function ()
            if self.b_callback then
                self.b_callback(self)
            end
        end,

        upButtonDown = function ()
            self.listview:selectPreviousRow(false)
            self:drawList()
        end,

        downButtonDown = function ()
            self.listview:selectNextRow(false)
            self:drawList()
        end

    }
    
end
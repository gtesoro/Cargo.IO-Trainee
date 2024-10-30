local pd <const> = playdate
local gfx <const> = playdate.graphics

class('ListBox').extends(playdate.graphics.sprite)

function ListBox:init(data) 

    if not data then
        data = {}
    end

    self.data = data

    local _w, _h = 0, 0

    local _min_width = 0
    local _item_height = 0

    for k,v in pairs(data) do
        local _w, _h = gfx.getTextSize(v.name)
        if _w > _min_width then
            _min_width = _w
        end
        _item_height = _h
    end

    self.list_mod = false
    self.focused = true
    self.outline = false

    local text_offset = 5

    self.float = 5

    _item_height = text_offset + _item_height

    _w = _min_width + self.float + text_offset 
    _h = _item_height * #data + self.float + text_offset
    

    self.listview = playdate.ui.gridview.new(0, _item_height)
    self.listview:setNumberOfRows(#data)

    -- self.listview:setCellPadding(5, 5, 2, 2)
    -- self.listview:setContentInset(5, 5, 5, 5)

    function self.listview:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRoundRect(x, y, width-text_offset, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        gfx.drawTextAligned(string.format("*%s*", data[row].name), x+text_offset , y+text_offset, kTextAlignment.left)
    end

    self:setImage(gfx.image.new(_w, _h))

    self:updateImg()
    
end

function ListBox:setData(data)
    
    self.data = data
    function self.listview:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        gfx.drawTextAligned(string.format("*%s*", data[row].name), x+text_offset , y+text_offset, kTextAlignment.left)
    end

    self:updateImg()

end

function ListBox:updateImg()

    local _w, _h =  self:getSize()

    gfx.pushContext(self:getImage())
        gfx.clear()

        gfx.setColor(playdate.graphics.kColorBlack)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRoundRect(self.float, self.float, _w, _h, 4)
        gfx.setColor(playdate.graphics.kColorWhite)
        gfx.fillRoundRect(0,0, _w - self.float, _h - self.float, 4)

        local outline_size = 2

        self.listview:drawInRect(outline_size, outline_size, _w - outline_size - self.float, _h - outline_size - self.float)
        
        if self.outline then
            gfx.setColor(gfx.kColorBlack)
            gfx.setLineWidth(outline_size)
            gfx.drawRoundRect(outline_size, outline_size, _w - outline_size - self.float, _h - outline_size - self.float, 4)
        end

    gfx.popContext()

end


function ListBox:handleControls()
    if not self.focused then
        return 
    end

    if pd.buttonJustPressed(pd.kButtonUp) then
        self.listview:selectPreviousRow(false)
        self.list_mod = true
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        self.listview:selectNextRow(false)
        self.list_mod = true
    end

    if pd.buttonJustReleased(pd.kButtonA) then
        local s, r, c = self.listview:getSelection()

        if self.data[r].callback then
            self.data[r].callback()
        end

    end

    if pd.buttonJustReleased(pd.kButtonB) then
        if self.b_callback then
            self.b_callback()
        end
    end
end

function ListBox:update()

    self:handleControls() 

    if self.list_mod then
        self:updateImg()
        self:markDirty()
    end

    
end
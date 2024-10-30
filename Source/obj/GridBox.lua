local pd <const> = playdate
local gfx <const> = playdate.graphics

class('GridBox').extends(Widget)

function GridBox:init(data, r, c, g_w, g_h, w, h)

    self.data = data

    self.cell_padding = 2
    self.grid_color = gfx.kColorWhite
    self.rows = r
    self.columns = c

    if not g_w then
        g_w = 32
    end

    if not g_h then
        g_h = 32
    end

    if not w then
        w = c * (g_w + self.cell_padding *2)
    end

    if not h then
        h = r * (g_h + self.cell_padding *2)
    end

    self.g_w = g_w
    self.g_h = g_h

    self.grid = pd.ui.gridview.new(self.g_w,self.g_h)
    self.grid:setNumberOfColumns(c)
    self.grid:setNumberOfRows(r)
    self.grid:setCellPadding(self.cell_padding, self.cell_padding, self.cell_padding, self.cell_padding)
    self.grid.backgroundImage = gfx.image.new(w, h, gfx.kColorBlack)

    function self.grid:drawCell(section, row, column, selected, x, y, width, height)
        if data[((row-1)*c) + column] then
            local img = data[((row-1)*c) + column]:getImage()
            local _s = math.max(g_w, g_h)/math.max(img.width, img.height)
            img:scaledImage(_s):drawAnchored(x+ width/2, y + height/2, 0.5, 0.5)
        end

        if selected then
            gfx.setLineWidth(3)
            gfx.drawRoundRect(x-1, y-1, width+1, height+1, 2)
        else
            gfx.setLineWidth(0)
            gfx.drawRect(x, y, width, height)
        end

    end
    
    print(w, h)
    local img = gfx.image.new(w, h)
    self:setImage(img)
    self:drawGrid()
    

end

function GridBox:setBackgroundImage(img)
    self.grid.backgroundImage = img
    self:drawGrid()
end

function GridBox:setGridColor(color)
    self.grid_color = color
    self:drawGrid()
end

function GridBox:drawGrid()

    local _w, _h = self:getSize()

    gfx.pushContext(self:getImage())
        gfx.clear()
        gfx.setColor(self.grid_color)
        self.grid:drawInRect(0, 0, self:getSize())
    gfx.popContext()

    self:markDirty()
end

function GridBox:remove()
    if self.exitCallback then
        self.exitCallback()
    end

    GridBox.super.remove(self)

end

function GridBox:handleControls()

    if not self:hasFocus() then
        return
    end

    local grid_draw = false

    if pd.buttonJustPressed(pd.kButtonUp) then
        self.grid:selectPreviousRow(true)
        grid_draw = true
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        self.grid:selectNextRow(true)
        grid_draw = true
    end

    if pd.buttonJustPressed(pd.kButtonRight) then
        self.grid:selectNextColumn(true)
        grid_draw = true
    end

    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.grid:selectPreviousColumn(true)
        grid_draw = true
    end

    if pd.buttonJustReleased(pd.kButtonA) then
        if self.a_callback then
            self.a_callback()
        end
        
    end

    if pd.buttonJustReleased(pd.kButtonB) then
        if self.b_callback then
            print('b_callback')
            self.b_callback()
        end
    end

    if grid_draw then
        self:drawGrid()
    end

end

function GridBox:getSelection()
    local s, r, c = self.grid:getSelection()

    return self.data[((r-1)*self.columns) + c]

end

function GridBox:getSelectionIndex()
    local s, r, c = self.grid:getSelection()

    return ((r-1)*self.columns) + c

end

function GridBox:getSelectionPosition()

    local s, r, c = self.grid:getSelection()

    return self.x - self.width/2 + (c-1)*(self.g_w + self.cell_padding*2) + (self.g_w+self.cell_padding)/2, self.y - self.height/2 + (r-1)*(self.g_h + self.cell_padding*2) + (self.g_h+self.cell_padding)/2
end

function GridBox:update()

    self:handleControls()
    
end
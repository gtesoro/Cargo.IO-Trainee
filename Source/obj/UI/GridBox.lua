local pd <const> = playdate
local gfx <const> = playdate.graphics

class('GridBox').extends(Widget)

function GridBox:init(data, r, c, g_w, g_h, w, h, scale_icons)

    self.data = data

    self.last_crank = pd.getCrankPosition()

    self.cell_padding = 2
    self.grid_color = gfx.kColorWhite
    self.rows = r
    self.columns = c

    self.accumulated_crank = 0

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
    self.grid.backgroundImage = gfx.image.new(w, h, gfx.kColorClear)
    self.grid:setScrollDuration(100)

    local _self = self

    function self.grid:drawCell(section, row, column, selected, x, y, width, height)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(x, y, width, height)
        if data.items[((row-1)*c) + column] then
            local img = data.items[((row-1)*c) + column] :getImage()
            local _s =  1
            if scale_icons then
                _s = (math.max(g_w, g_h)-math.max(img.width, img.height)*0.2)/math.max(img.width, img.height)
            end
            img:scaledImage(_s):drawAnchored(x+ width/2, y + height/2, 0.5, 0.5)
        end
        gfx.setColor(gfx.kColorWhite)
        if selected and _self:hasFocus() then
            gfx.setLineWidth(3)
            --gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer4x4)
            gfx.drawRoundRect(x-1, y-1, width+1, height+1, 2)
        else
            gfx.setLineWidth(0)
            gfx.drawRect(x, y, width, height)
        end

    end

    self:initInputs()

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

    inContext(self:getImage(), function ()
        gfx.clear()
        self.grid:drawInRect(0, 0, self:getSize())
    end)
    self:markDirty()
end

function GridBox:remove()
    if self.exitCallback then
        self.exitCallback()
    end

    GridBox.super.remove(self)

end

function GridBox:update()
    if self.grid.needsDisplay == true then
        self:drawGrid()
    end
end

function GridBox:initInputs()

    self.input_handlers = {
        
        cranked = function (change, acceleratedChange)

            local _sensitivity = g_SystemManager.crank_menu_sensitivity
            self.accumulated_crank += acceleratedChange

            if math.abs(self.accumulated_crank) > _sensitivity then
                if self.accumulated_crank > 0 then
                    g_SoundManager:playMenuListChange()
                    self.grid:selectNextColumn(true)
                else
                    g_SoundManager:playMenuListChange()
                    self.grid:selectPreviousColumn(true)
                end
                if self.on_change then
                    self.on_change(self:getSelection())
                end
                self.accumulated_crank = 0
            end
        end,

        AButtonUp = function ()
            if self.a_callback then
                self.a_callback(self)
            end
        end,

        BButtonUp = function ()
            if self.b_callback then
                self.b_callback(self)
            end
        end,

        upButtonDown = function ()
            g_SoundManager:playMenuListChange()
            self.grid:selectPreviousRow(true)
            if self.on_change then
                self.on_change(self:getSelection())
            end
        end,

        downButtonDown = function ()
            g_SoundManager:playMenuListChange()
            self.grid:selectNextRow(true)
            if self.on_change then
                self.on_change(self:getSelection())
            end
        end,

        leftButtonDown = function ()
            g_SoundManager:playMenuListChange()
            self.grid:selectPreviousColumn(true)
            if self.on_change then
                self.on_change(self:getSelection())
            end
        end,

        rightButtonDown = function ()
            g_SoundManager:playMenuListChange()
            self.grid:selectNextColumn(true)
            if self.on_change then
                self.on_change(self:getSelection())
            end
        end

    }
    
end

function GridBox:getSelection()
    local s, r, c = self.grid:getSelection()

    return self.data.items[((r-1)*self.columns) + c]

end

function GridBox:getSelectionIndex()
    local s, r, c = self.grid:getSelection()

    return ((r-1)*self.columns) + c

end

function GridBox:getSelectionPosition()

    local s, r, c = self.grid:getSelection()

    return self.x - self.width/2 + (c-1)*(self.g_w + self.cell_padding*2) + (self.g_w+self.cell_padding)/2, self.y - self.height/2 + (r-1)*(self.g_h + self.cell_padding*2) + (self.g_h+self.cell_padding)/2
end

function GridBox:focus()
    GridBox.super.focus(self)
    self:drawGrid()
end

function GridBox:unfocus()
    GridBox.super.unfocus(self)
    self:drawGrid()
end
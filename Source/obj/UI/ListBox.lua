local pd <const> = playdate
local gfx <const> = playdate.graphics

class('ListBox').extends(Widget)

function ListBox:init(data, width, height, item_height)

    if not data then
        data = {}
    end

    self.data = data

    self.padding = 2
    self.text_offset = 5

    self.accumulated_crank = 0

    local _w, _h = 0, 0
    
    local _item_height = 0

    local _min_width = 0


    if type(self.data.options) ~= "function" then
        local _options = self.data.options
        self.data.options = function ()
            return _options
        end
    end

    self.options = self.data.options()

    gfx.setFont(g_font_18)

    for k,v in pairs(self.options) do
        local __w, __h = gfx.getTextSize(v.name)
        if __w > _min_width then
            _min_width = __w
        end
        if __h > _item_height then
            _item_height = __h
        end
    end

    _item_height = self.text_offset*2 + _item_height

    if item_height then
        _item_height = item_height
    end

    _w = _min_width + self.text_offset*2 + self.padding*2
    _h = _item_height * #self.options + self.padding*2

    if width and width > _w then
        _w = width
    end

    if height then
        _h = height
    end

    self:setImage(gfx.image.new(_w, _h))

    self.item_height = _item_height
    self:initList(self.item_height, self.options)

    self:drawList()
    self:initInputs()
    
end

function ListBox:initList(_item_height, _options)

    self.listview = playdate.ui.gridview.new(0, _item_height)
    self.listview:setNumberOfRows(#_options)
    self.listview:setCellPadding(self.padding,self.padding,self.padding,self.padding)
    local img = gfx.image.new(self.width, self.height)
    gfx.pushContext(img)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(0, 0, self.width, self.height, 4)
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(1)
        gfx.drawRoundRect(0, 0, self.width, self.height, 4)
    gfx.popContext()
    self.listview.backgroundImage = img

    self.listview:setScrollDuration(100)

    local _self = self

    function self.listview:drawCell(section, row, column, selected, x, y, width, height)
        
        if selected then
            gfx.setFont(g_font_18)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            local _text = _options[row].name
            local __w, __h = gfx.getTextSize(_text)
            gfx.drawText(_text, x + _self.text_offset/2, (y + height/2) - __h/2)
        else
            gfx.setFont(g_font_14)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            local _text = _options[row].name
            local __w, __h = gfx.getTextSize(_text)
            gfx.drawText(_text, x + _self.text_offset/2, (y + height/2) - __h/2)
        end
        
    end

end

function ListBox:drawList()
    
    gfx.pushContext(self:getImage())
        gfx.clear()
        self.listview:drawInRect(0, 0, self:getSize())
    gfx.popContext()

    self:markDirty()
end

function ListBox:update()
    if #self.options ~= #self.data.options() then
        self.options = self.data.options()
        self:initList(self.item_height, self.options)
        inContext(self:getImage(), function ()
            self.listview:drawInRect(0, 0, self:getSize())
        end)
    end

    if self.listview.needsDisplay == true then
        inContext(self:getImage(), function ()
            self.listview:drawInRect(0, 0, self:getSize())
        end)
        self:markDirty()
    end
end

function ListBox:getSelected()

    local s, r, c = self.listview:getSelection()

    return self.options[r]

end


function ListBox:initInputs()

    self.input_handlers = {

        cranked = function (change, acceleratedChange)
            -- local _sensitivity = g_SystemManager.crank_menu_sensitivity
            -- self.accumulated_crank += change

            -- if math.abs(self.accumulated_crank) > _sensitivity then
            --     if self.accumulated_crank < 0 then
            --         g_SoundManager:playMenuListChange()
            --         self.listview:selectPreviousRow(false)
            --     else
            --         g_SoundManager:playMenuListChange()
            --         self.listview:selectNextRow(false)
            --     end
            --     self.accumulated_crank = 0
            -- end

            local _t = -pd.getCrankTicks(g_SystemManager.crank_menu_sensitivity)
            if _t > 0 then
                g_SoundManager:playMenuListChange()
                self.listview:selectPreviousRow(false)
            end
            if _t < 0 then
                g_SoundManager:playMenuListChange()
                self.listview:selectNextRow(false)
            end
        end,

        AButtonUp = function ()
            if #self.options == 0 then
                return
            end

            local s, r, c = self.listview:getSelection()

            if self.options[r].callback then
                self.options[r].callback(self)
            end
        end,

        BButtonUp = function ()
            if self.b_callback then
                self.b_callback(self)
            end
        end,

        upButtonDown = function ()
            g_SoundManager:playMenuListChange()
            self.listview:selectPreviousRow(true, true, true)
        end,

        downButtonDown = function ()
            g_SoundManager:playMenuListChange()
            self.listview:selectNextRow(true, true, true)
        end

    }
    
end
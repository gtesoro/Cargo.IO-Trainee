
local pd <const> = playdate
local gfx <const> = pd.graphics

class('ImageSelector').extends(GenericMenu)

function ImageSelector:startScene()

    ImageSelector.super.startScene(self)

    self:initGrids()

end

function ImageSelector:initGrids()

    local _items = {}

    for k,v in pairs(self.data.images) do
        local _img = gfx.image.new(v)
        local _spr = gfx.sprite.new(_img)
        _spr:setVisible(false)
        _spr:moveTo(200 + 182/2, 120)
        _spr:setZIndex(5)
        _spr.image_path = v
        table.insert(self.sprites, _spr)
        table.insert(_items, _spr)
    end

    local _grid_box_data = {
        items = _items,
        parent = self
    }

    self.item_grid = GridBox(_grid_box_data, math.max(math.ceil(#self.data.images/3),3), 3, 40, 40, 132, 132, true)
    self.item_grid:setGridColor(gfx.kColorWhite)
    self.item_grid:moveTo(100, 120)
    self.item_grid:setZIndex(2)
    self.item_grid:drawGrid()
    self.item_grid.a_callback = function (_self)
        g_SoundManager:playMenuListChange()
        if self.data.a_callback then
            self.data.a_callback(_self)
        end
    end

    self.item_grid.b_callback = function ()
        if self.data.b_callback then
            self.data.b_callback()
        else    
            g_SceneManager:popScene('between menus')
        end
    end

    self.item_grid.on_change = function (item)
        for k,v in pairs(_grid_box_data.items) do
            v:setVisible(false)
        end
        if item then
            item:setVisible(true)
        end
    end

    table.insert(self.sprites, self.item_grid)

    local _img = gfx.image.new(self.item_grid.width+50, self.item_grid.height+15*2)
    
    gfx.pushContext(_img)
        gfx.clear(gfx.kColorWhite)
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.2, gfx.image.kDitherTypeScreen)
        gfx.fillRoundRect(0, 0, _img.width, _img.height, 4)

        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(4)
        gfx.drawRoundRect(-2, 0, _img.width+2, _img.height, 4)
        
    gfx.popContext()

    self.item_grid_bg = gfx.sprite.new(_img)
    self.item_grid_bg:setCenter(0, 0.5)
    self.item_grid_bg:moveTo(0,120)
    self.item_grid_bg:setZIndex(1)
    self.item_grid_bg:add()

    table.insert(self.sprites, self.item_grid_bg)

    self.item_panel_underlays = {}
    self.scrolled = 0

    img = gfx.image.new('assets/ui/dialog_bg')--gfx.image.new(180, 240, gfx.kColorBlack)

    self.item_panel_underlay_1 = gfx.sprite.new(img)
    self.item_panel_underlay_1:setCenter(0, 0.5)
    self.item_panel_underlay_1:moveTo(playdate.display.getWidth()*0.5, playdate.display.getHeight()/2-img.height)
    self.item_panel_underlay_1:setZIndex(1)
    self.item_panel_underlay_1:add()

    table.insert(self.item_panel_underlays, self.item_panel_underlay_1)

    table.insert(self.sprites, self.item_panel_underlay_1)

    self.item_panel_underlay_2 = gfx.sprite.new(img)
    self.item_panel_underlay_2:setCenter(0, 0.5)
    self.item_panel_underlay_2:moveTo(playdate.display.getWidth()*0.5, playdate.display.getHeight()/2)
    self.item_panel_underlay_2:setZIndex(1)
    self.item_panel_underlay_2:add()

    table.insert(self.item_panel_underlays, self.item_panel_underlay_2)
    table.insert(self.sprites, self.item_panel_underlay_2)

    self.item_panel_underlay_3 = gfx.sprite.new(img)
    self.item_panel_underlay_3:setCenter(0, 0.5)
    self.item_panel_underlay_3:moveTo(playdate.display.getWidth()*0.5, playdate.display.getHeight()/2 + img.height)
    self.item_panel_underlay_3:setZIndex(1)
    self.item_panel_underlay_3:add()

    table.insert(self.item_panel_underlays, self.item_panel_underlay_3)
    table.insert(self.sprites, self.item_panel_underlay_3)

    local _s = self.item_grid:getSelection()
    if _s then
        _s:setVisible(true)
    end

end


function ImageSelector:scrollItemPanel(amount)
    for k,v in pairs(self.item_panel_underlays) do
        v:moveBy(0, amount)
        if v.y < -playdate.display.getHeight()/2 then
            v:moveBy(0,v.height*2)
        end
        if v.y > playdate.display.getHeight()*1.5 then
            v:moveBy(0,-v.height*2)
        end
    end
    if self.item_panel then
        self.item_panel:moveBy(0, amount)
    end
end

function ImageSelector:focus()
    if self.item_grid then
        self:unfocus()
        self.item_grid:focus()
    end
end

function ImageSelector:unfocus()
    if self.item_grid then
        self.item_grid:unfocus()
    end
end


function ImageSelector:doUpdate()

    -- local _t = -pd.getCrankTicks(g_SystemManager.scroll_sensitivity)
    -- if math.fmod(_t, 2) ~= 0 then
    --     _t += 1 * (_t/math.abs(_t))
    -- end
    -- if self.scrolled - _t < 0 then
    --     self:scrollItemPanel(-self.scrolled)
    --     self.scrolled = 0
    -- else
    --     self:scrollItemPanel(_t)
    --     self.scrolled -= _t
    -- end
    
end
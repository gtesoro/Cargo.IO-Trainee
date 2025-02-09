
local pd <const> = playdate
local gfx <const> = pd.graphics

class('GenericInventory').extends(Scene)

function GenericInventory:startScene()

    self:initGrids()
    self:initBg()
    
end

function GenericInventory:generateContextMenu(grid)


    local _options = {}

    if grid:getSelection() == nil then
        return 
    end

    for k,v in pairs(grid:getSelection():getOptions()) do
        if v.blacklist and v.blacklist[self.className] then
            
        else
            _options[#_options+1] = v
        end
    end

    for k,v in pairs(self.data.context_options) do
        _options[#_options+1] = v
    end

    local _list_box_data = {
        options = function ()
            return _options
        end,
        parent = self
    }

    self.context_menu = ListBox(_list_box_data)

    grid:unfocus()
    self.context_menu:setCenter(0,0)
    self.context_menu:moveTo(grid:getSelectionPosition())
    self.context_menu:setZIndex(2)
    self.context_menu.b_callback = function ()
        grid:focus()
        g_SoundManager:playMenuListChange()
        self.context_menu:remove()
    end
    self.context_menu:focus()
    self.context_menu:add()
end

function GenericInventory:initGrids()

    local _grid_box_data = {
        items = self.data.items,
        parent = self
    }

    self.item_grid = GridBox(_grid_box_data, math.max(math.ceil(#self.data.items/3),3), 3, 40, 40, 132, 132)
    self.item_grid:setGridColor(gfx.kColorWhite)
    self.item_grid:moveTo(100, 120)
    self.item_grid:setZIndex(2)
    self.item_grid:drawGrid()
    self.item_grid.a_callback = function (_self)
        g_SoundManager:playMenuListChange()
        if self.data.a_callback then
            self.data.a_callback(_self)
        else 
            self:generateContextMenu(self.item_grid)
        end
    end

    self.item_grid.b_callback = function ()
        g_SceneManager:popScene('between menus')
    end

    self.item_grid.on_change = function (item)
        self:setItem(item)
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

    img = gfx.image.new('assets/ui/item_box_bg')--gfx.image.new(180, 240, gfx.kColorBlack)

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
        self:setItem(_s)
    end

end

function GenericInventory:setItem(_s)
    if self.item_panel then
        self.item_panel:remove()
        table_remove(self.sprites, self.item_panel)
        self.item_panel = nil 
    end

    self.scrolled = 0

    if _s then
        self.item_panel = ItemPanel(_s)
        self.item_panel:setCenter(0, 0)
        self.item_panel:add()
        self.item_panel:moveTo(playdate.display.getWidth()*0.5+16, pd.display.getHeight()*0.15)
        self.item_panel:setZIndex(2)
        table.insert(self.sprites, self.item_panel)
    end    
end


function GenericInventory:scrollItemPanel(amount)
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

function GenericInventory:initBg()

    local img = gfx.image.new(400, 240, gfx.kColorBlack)
    gfx.pushContext(img)
        local _i = gfx.image.new('assets/backgrounds/grid')
        _i:drawAnchored(pd.display.getWidth()/2, pd.display.getHeight()/2, 0.5, 0.5)
    gfx.popContext()


    self.bg_image = img:blurredImage(1, 2, gfx.image.kDitherTypeScreen)
    self.bg_sprite = gfx.sprite.new(self.bg_image)
    self.bg_sprite:setIgnoresDrawOffset(true)
    self.bg_sprite:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.bg_sprite:setZIndex(0)
    self.bg_sprite:add()
    table.insert(self.sprites, self.bg_sprite)

    self.ui_overlay = gfx.sprite.new(gfx.image.new('assets/backgrounds/ui_overlay'))
    self.ui_overlay:setIgnoresDrawOffset(true)
    self.ui_overlay:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.ui_overlay:setZIndex(2)
    self.ui_overlay:add()

    table.insert(self.sprites, self.ui_overlay)

end

function GenericInventory:focus()
    if self.item_grid then
        self:unfocus()
        self.item_grid:focus()
    end
end

function GenericInventory:unfocus()
    if self.item_grid then
        self.item_grid:unfocus()
    end
end

function GenericInventory:add()
    GenericInventory.super.add(self)
    applyFlicker(self.bg_sprite)
end

function GenericInventory:remove()
    GenericInventory.super.remove(self)
    for k, v in pairs(self.sprites) do
        if v.flicker_timer then
            v.flicker_timer:remove()
            v.flicker_timer = nil
        end
    end
end


function GenericInventory:doUpdate()

    --local _a = pd.getCrankChange()*0.25

    local _t = -pd.getCrankTicks(25)
    if math.fmod(_t, 2) ~= 0 then
        _t += 1 * (_t/math.abs(_t))
    end
    if self.scrolled - _t < 0 then
        self:scrollItemPanel(-self.scrolled)
        self.scrolled = 0
    else
        self:scrollItemPanel(_t)
        self.scrolled -= _t
    end
    
end
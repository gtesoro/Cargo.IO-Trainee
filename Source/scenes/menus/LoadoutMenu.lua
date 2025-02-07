
local pd <const> = playdate
local gfx <const> = pd.graphics

class('LoadoutMenu').extends(Scene)

function LoadoutMenu:startScene()

    self:initGrids()
    self:initBg()
    
end

function LoadoutMenu:generateContextMenu(grid)


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
        self.context_menu:remove()
    end
    self.context_menu:focus()
    self.context_menu:add()
end

function LoadoutMenu:initGrids()

    local _grid_box_data = {
        items = self.data.items,
        parent = self
    }

    self.item_grid = GridBox(_grid_box_data, 1, math.max(#self.data.items, 4), 32, 32, 144, 36)

    self.item_grid:setGridColor(gfx.kColorWhite)
    self.item_grid:moveTo(playdate.display.getWidth()*.25, 195 - self.item_grid.height/2)
    self.item_grid:setZIndex(2)
    self.item_grid:drawGrid()
    self.item_grid.a_callback = function ()

        local _source = self.item_grid:getSelection()

        if self.data.read_only then
            --return
        end

        local _items = {}
        for k,v in pairs(g_SystemManager:getPlayer().inventory.items) do
            if v.type == 'Equipment' then
                table.insert(_items, v)
            end
        end

        local _cross = Cross()
        if _source then 
            table.insert(_items, _cross)
        end

        if #_items == 0 then
            createPopup({text="No equipment avaialble in inventory."})
        else
            local _myself = self
            g_SceneManager:pushScene(GenericInventory({
                items=_items,
                rows=1,
                columns=#_items,
                a_callback= function (_self)
                    local _item = _self:getSelection()
                    if _item then
                        if _item == _cross then
                            if g_SystemManager:getPlayer():addToInventory(_source, false) then
                                table.remove(_myself.data.items, _myself.item_grid:getSelectionIndex())
                                g_NotificationManager:notify(string.format("%s Unequiped", _source.name))
                                _source:onUnequip()
                                _myself.item_grid:drawGrid()
                            end
                        else
                            if _source then
                                table.remove(_myself.data.items, _myself.item_grid:getSelectionIndex())
                                g_NotificationManager:notify(string.format("%s Unequiped", _source.name))
                                _source:onUnequip()
    
                                g_SystemManager:getPlayer():removeFromInventory(_item, false)
                                table.insert(_myself.data.items, _item)
                                _myself.item_grid:drawGrid()
                                _item:onEquip()
                                g_NotificationManager:notify(string.format("%s Equiped", _item.name))
    
                                g_SystemManager:getPlayer():addToInventory(_source, false)
    
                                
                                
                            else
                                g_SystemManager:getPlayer():removeFromInventory(_item, false)
                                table.insert(_myself.data.items, _item)
                                _myself.item_grid:drawGrid()
                                _item:onEquip()
                                g_NotificationManager:notify(string.format("%s Equiped", _item.name))

                                _myself.item_grid:drawGrid()
    
                            end
                        end
                        if _myself.item_grid:getSelection() then
                            _myself:setItem(_myself.item_grid:getSelection())
                        end
                        g_SceneManager:popScene('between menus')
                    end
                    
                end
            }), "between menus")

        end

    end

    self.item_grid.b_callback = function ()
        g_SceneManager:popScene('between menus')
    end

    table.insert(self.sprites, self.item_grid)

    self.item_grid.on_change = function (item)
        self:setItem(item)
    end

    local _img = gfx.image.new(190, 180)
    
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

function LoadoutMenu:setItem(_s)

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


function LoadoutMenu:initBg()

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
    self.ui_overlay:setZIndex(3)
    self.ui_overlay:add()

    table.insert(self.sprites, self.ui_overlay)

    self.ship = gfx.sprite.new(gfx.image.new('assets/iso_ship'))
    self.ship:setIgnoresDrawOffset(true)
    self.ship:moveTo(playdate.display.getWidth()*.25, playdate.display.getHeight()*.4)
    self.ship:setZIndex(1)
    self.ship:add()

    table.insert(self.sprites, self.ship)

end

function LoadoutMenu:focus()
    if self.item_grid then
        self:unfocus()
        self.item_grid:focus()
    end
end

function LoadoutMenu:unfocus()
    if self.item_grid then
        self.item_grid:unfocus()
    end
end

function LoadoutMenu:scrollItemPanel(amount)
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

function LoadoutMenu:doUpdate()
    if not self.noise_timer then
        self.noise_timer = pd.timer.new(math.random(3000, 10000))
        self.noise_timer.updateCallback = function (timer)
            if timer.timeLeft < 200 then
                self.bg_sprite:setImage(g_SystemManager.fading_grid:getImage(100):vcrPauseFilterImage())
            end
        end
        self.noise_timer.timerEndedCallback = function ()
            self.bg_sprite:setImage(g_SystemManager.fading_grid:getImage(100))
            self.bg_sprite:markDirty()
            self.noise_timer = nil
        end
    end

    local _a = pd.getCrankChange()*0.25
    if self.scrolled - _a < 0 then
        self:scrollItemPanel(-self.scrolled)
        self.scrolled = 0
    else
        self:scrollItemPanel(_a)
        self.scrolled -= _a
    end
end
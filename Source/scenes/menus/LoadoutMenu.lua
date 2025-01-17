
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
    self.item_grid:setZIndex(1)
    self.item_grid:drawGrid()
    self.item_grid.a_callback = function ()

        local _source = self.item_grid:getSelection()

        if self.data.read_only then
            return
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
            g_SceneManager:pushScene(InventoryPopup({
                items=_items,
                rows=1,
                columns=#_items,
                a_callback= function (_self)
                    local _item = _self:getSelection()
                    if _item == _cross then
                        if g_SystemManager:getPlayer():addToInventory(_source, false) then
                            table.remove(self.data.items, self.item_grid:getSelectionIndex())
                            g_NotificationManager:notify(string.format("%s Unequiped", _source.name))
                            self.item_grid:drawGrid()
                        end
                    else
                        g_SystemManager:getPlayer():removeFromInventory(_item, false)
                        table.insert(self.data.items, _item)
                        self.item_grid:drawGrid()
                        g_NotificationManager:notify(string.format("%s Equiped", _item.name))
                    end
                    if self.item_grid:getSelection() then
                        self.item_panel:setVisible(true)
                        self.item_panel:setItem(self.item_grid:getSelection())
                    else
                        self.item_panel:setVisible(false)
                    end
                end
            }), "stack")

        end

        
    end

    self.item_grid.b_callback = function ()
        g_SceneManager:popScene('between menus')
    end

    table.insert(self.sprites, self.item_grid)

    self.item_panel = ItemPanel(180, 150)
    self.item_panel:setVisible(false)
    self.item_panel:setZIndex(2)
    self.item_panel:add()
    self.item_panel:moveTo(280, 120)

    local _s = self.item_grid:getSelection()
    if _s then
        self.item_panel:setVisible(true)
        self.item_panel:setItem(_s)
    end

    self.item_grid.on_change = function (item)
        self.item_panel:setVisible(false)
        if item then
            self.item_panel:setVisible(true)
            self.item_panel:setItem(item)
        end
    end

    table.insert(self.sprites, self.item_panel)

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
    self.ui_overlay:setZIndex(2)
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
end
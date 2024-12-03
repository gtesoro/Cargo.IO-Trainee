
local pd <const> = playdate
local gfx <const> = pd.graphics

class('GenericInventory').extends(Scene)

function GenericInventory:startScene()

    self:initGrids()
    self:initBg()
    
end

function GenericInventory:generateContextMenu(grid)


    local _options = {}

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
        options = _options,
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

function GenericInventory:initGrids()

    local _grid_box_data = {
        items = self.data.items,
        parent = self
    }

    self.item_grid = GridBox(_grid_box_data, math.sqrt(g_SystemManager:getPlayer().inventory.capacity), math.sqrt(g_SystemManager:getPlayer().inventory.capacity), 40, 40)
    self.item_grid:setBackgroundImage(gfx.image.new(180, 220, gfx.kColorBlack))
    self.item_grid:setGridColor(gfx.kColorWhite)
    self.item_grid:moveTo(100, 120)
    self.item_grid:setZIndex(1)
    self.item_grid:drawGrid()
    self.item_grid.a_callback = function ()
        self:generateContextMenu(self.item_grid)
    end

    self.item_grid.b_callback = function ()
        g_SceneManager:popScene('between menus')
    end

    self.item_grid.on_change = function (item)
        if item then
            self.item_panel:setVisible(true)
            self.item_panel:setItem(item)
        else
            self.item_panel:setVisible(false)
        end
    end

    self.item_panel = self.data.item_panel
    local _s = self.item_grid:getSelection()
    if _s then
        self.item_panel:setItem(_s)
    end
    self.item_panel:setZIndex(2)
    self.item_panel:add()
    self.item_panel:moveTo(280, 120)

    self.sprites:append(self.item_grid)
    self.sprites:append(self.item_panel)

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
    self.sprites:append(self.bg_sprite)

    self.ui_overlay = gfx.sprite.new(gfx.image.new('assets/backgrounds/ui_overlay'))
    self.ui_overlay:setIgnoresDrawOffset(true)
    self.ui_overlay:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.ui_overlay:setZIndex(2)
    self.ui_overlay:add()

    self.sprites:append(self.ui_overlay)

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

function GenericInventory:doUpdate()
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
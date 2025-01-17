local pd <const> = playdate
local gfx <const> = pd.graphics

class('InventoryPopup').extends(Scene)

function InventoryPopup:init(data)
    InventoryPopup.super.init(self, data)
    self.previous_scene_img = gfx.getDisplayImage()
end

function InventoryPopup:startScene()

    self:initBg()
    self:initGrids()
end

function InventoryPopup:focus()
    InventoryPopup.super.focus(self)
    if self.item_grid then
        self:unfocus()
        self.item_grid:focus()
    end
end

function InventoryPopup:unfocus()
    InventoryPopup.super.unfocus(self)
    if self.item_grid then
        self.item_grid:unfocus()
    end
end

function InventoryPopup:initBg()

    self.base_bg_img = gfx.image.new(400, 240)
    self.bg_spr = gfx.sprite.new(self.base_bg_img)

    self.bg_spr:moveTo(200,120)

    table.insert(self.sprites, self.bg_spr)
    
end

function InventoryPopup:initGrids()

    local _grid_box_data = {
        items = self.data.items,
        parent = self
    }

    self.item_grid = GridBox(_grid_box_data, self.data.rows, self.data.columns, nil, nil, 180)
    self.item_grid:setGridColor(gfx.kColorWhite)
    self.item_grid:moveTo(200, 200)
    self.item_grid:setZIndex(1)
    self.item_grid:drawGrid()
    self.item_grid.a_callback = function (_self)
        if self.data.a_callback then
            self.data.a_callback(_self)
            self:unblur(function ()
                g_SceneManager:popScene('unstack')
            end)
        end
    end

    self.item_grid.b_callback = function ()
        if self.data.b_callback then
            self.data.b_callback()
        end
        self:unblur(function ()
            g_SceneManager:popScene('unstack')
        end)
    end

    self.item_panel = ItemPanel(300, 150)
    self.item_panel:setVisible(false)
    local _s = self.item_grid:getSelection()
    if _s and _s:isa(Item) then
        self.item_panel:setVisible(true)
        self.item_panel:setItem(_s)
    end
    self.item_panel:setZIndex(3)
    self.item_panel:add()
    self.item_panel:moveTo(200, 90)

    self.item_panel_shadow = getShadowSprite(self.item_panel)
    self.item_panel_shadow:setZIndex(2)
    self.item_panel_shadow:add()
    table.insert(self.sprites, self.item_panel_shadow)

    self.item_grid.on_change = function (item)
        if item and item:isa(Item) then
            self.item_panel:setVisible(true)
            self.item_panel:setItem(item)
        else
            self.item_panel:setVisible(false)
        end
    end

    table.insert(self.sprites, self.item_panel)

    table.insert(self.sprites, self.item_grid)

end

function InventoryPopup:unblur(callback)
    local unblur_timer = pd.timer.new(250, 4, 0, pd.easingFunctions.inLinear)
    unblur_timer.updateCallback = function(timer)
        self:setImage(self.previous_scene_img:blurredImage(timer.value, 2, gfx.image.kDitherTypeBayer8x8))
        self:markDirty()
    end

    unblur_timer.timerEndedCallback = function ()
        self:setImage(nil)
        callback()
    end
end


function InventoryPopup:doUpdate()

    if not self.blur_timer_in then
        self.blur_timer_in = pd.timer.new(250, 0, 4, pd.easingFunctions.inLinear)
        self.blur_timer_in.updateCallback = function(timer)
            self:setImage(self.previous_scene_img:blurredImage(timer.value, 2, gfx.image.kDitherTypeBayer8x8))
            self:markDirty()
        end
    end

end
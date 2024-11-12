
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Inventory').extends(Scene)

function Inventory:startScene()

    g_Notifications:notify("Inventory", 500)
    self:initGrids()
    self:initBg()
    
end

function Inventory:generateContextMenu(grid)

    local data = {
        {
            name="Drop"
        }
    }

    local _l = ListBox(data)

    data[1].callback = function ()
        table.remove(g_player.inventory.items, grid:getSelectionIndex())
        grid:drawGrid()
        grid:focus()
        _l:remove()
    end

    grid:unfocus()
    _l:setCenter(0,0)
    _l:moveTo(grid:getSelectionPosition())
    _l:setZIndex(2)
    _l.b_callback = function ()
        grid:focus()
        _l:remove()
    end
    _l:focus()
    _l:add()
end

function Inventory:initGrids()

    self.player_grid = GridBox(g_player.inventory.items, math.sqrt(g_player.inventory.capacity), math.sqrt(g_player.inventory.capacity), 40, 40)
    self.player_grid:setBackgroundImage(gfx.image.new(180, 220, gfx.kColorBlack))
    self.player_grid:setGridColor(gfx.kColorWhite)
    self.player_grid:moveTo(100, 120)
    self.player_grid:setZIndex(1)
    self.player_grid:drawGrid()
    self.player_grid.a_callback = function ()
        self:generateContextMenu(self.player_grid)
    end

    self.player_grid.b_callback = function ()
        g_SceneManager:popScene('unstack')
    end

    self.player_grid.on_change = function (item)
        if item then
            self.item_panel:setVisible(true)
            self.item_panel:setItem(item)
        else
            self.item_panel:setVisible(false)
        end
    end

    self.item_panel = ItemPanel(180, 150)
    self.item_panel:setItem(self.player_grid:getSelection())
    self.item_panel:setZIndex(2)
    self.item_panel:add()
    self.item_panel:moveTo(280, 120)

    self.sprites:append(self.player_grid)
    self.sprites:append(self.item_panel)

end

function Inventory:initBg()

    local img = gfx.image.new(pd.display.getWidth(), pd.display.getHeight(), gfx.kColorBlack)

    self.bg_sprite = gfx.sprite.new(img)
    self.bg_sprite:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.bg_sprite:setIgnoresDrawOffset(true)
    self.bg_sprite:setZIndex(0)

    self.sprites:append(self.bg_sprite)

    self.ui_overlay = gfx.sprite.new(gfx.image.new('assets/backgrounds/ui_overlay'))
    self.ui_overlay:setIgnoresDrawOffset(true)
    self.ui_overlay:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.ui_overlay:setZIndex(2)
    self.ui_overlay:add()

    self.sprites:append(self.ui_overlay)

end

function Inventory:focus()
    if self.player_grid then
        self:unfocus()
        self.player_grid:focus()
    end
end

function Inventory:unfocus()
    if self.player_grid then
        self.player_grid:unfocus()
    end
end
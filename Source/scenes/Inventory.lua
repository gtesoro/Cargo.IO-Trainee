
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Inventory').extends(Scene)

function Inventory:startScene()

    self:initGrids()
    self:initBg()
    
end

function Inventory:generateContextMenu(grid)

    local data = {
        {
            name="Use"
        },
        {
            name="Drop"
        }
    }

    local _l = ListBox(data)

    data[2].callback = function ()
        local idx = grid:getSelectionIndex()
        g_player.inventory.items[idx] = nil
        table.remove(g_player.inventory.items, idx)
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
    _l:add()
end

function Inventory:initGrids()

    local player_grid = GridBox(g_player.inventory.items, math.sqrt(g_player.inventory.capacity), math.sqrt(g_player.inventory.capacity))
    player_grid:setBackgroundImage(gfx.image.new(180, 220, gfx.kColorBlack))
    player_grid:setGridColor(gfx.kColorWhite)
    player_grid:moveTo(100, 120)
    player_grid:setZIndex(1)
    player_grid:focus()
    player_grid.a_callback = function ()
        self:generateContextMenu(player_grid)
    end

    player_grid.b_callback = function ()
        -- player_grid:unfocus()
        -- self:focus()

        g_SceneManager:popScene('hwipe')
    end

    self.sprites[#self.sprites+1] = player_grid

end

function Inventory:addPlayerItems()

end


function Inventory:initBg()

    local img = gfx.image.new(pd.display.getWidth(), pd.display.getHeight(), gfx.kColorBlack)

    self.bg_sprite = gfx.sprite.new(img) --gfx.sprite.new(gfx.image.new("assets/backgrounds/asteroid_bg") )
    self.bg_sprite:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.bg_sprite:setIgnoresDrawOffset(true)
    self.bg_sprite:setZIndex(0)

    self.sprites[#self.sprites+1] = self.bg_sprite

end

function Inventory:update()

    Inventory.super.update(self)
    
    if self.focused then
        if pd.buttonJustReleased(pd.kButtonB) then
            g_SceneManager:popScene('hwipe')
        end
    end
    
end
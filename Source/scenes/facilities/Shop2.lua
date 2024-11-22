
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Shop').extends(Scene)

function Shop:startScene()

    gfx.setDrawOffset(0,0)

    self:initBg()
    self:initGrids()
    self:initInputs()
end

function Shop:initBg()

    local img = gfx.image.new("assets/backgrounds/facilities/shop")
    assert(img)

    self.bg_sprite = gfx.sprite.new(img)
    self.bg_sprite:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.bg_sprite:setIgnoresDrawOffset(true)
    self.bg_sprite:setZIndex(0)

    self.sprites:append(self.bg_sprite)

end

function Shop:initGrids()

    self.vertical_center_breakpoint = .55

    self.shadow_offset = 3

    self.player_grid = GridBox(g_player.inventory.items, math.sqrt(g_player.inventory.capacity), math.sqrt(g_player.inventory.capacity), 40, 40)
    self.player_grid.starting_position = {}
    self.player_grid.starting_position.x = pd.display.getWidth()*.25
    self.player_grid.starting_position.y = pd.display.getHeight()*self.vertical_center_breakpoint - pd.display.getHeight()
    self.player_grid:moveTo(self.player_grid.starting_position.x , self.player_grid.starting_position.y)
    self.player_grid:setZIndex(2)
    self.player_grid.a_callback = function ()
        self:generateContextMenuPlayer(self.player_grid)
    end

    self.sprites:append(self.player_grid)

    local shadow_img = gfx.image.new(self.player_grid:getSize())
    gfx.pushContext(shadow_img)
        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRoundRect(0,0, shadow_img.width, shadow_img.height, 4)
    gfx.popContext()

    self.player_grid.shadow = gfx.sprite.new(shadow_img)
    self.player_grid.shadow:setZIndex(1)
    self.player_grid.shadow:moveTo(self.player_grid.starting_position.x + self.shadow_offset, self.player_grid.starting_position.y + self.shadow_offset)
    self.sprites:append(self.player_grid.shadow)


    self.shop_grid = GridBox(List(), 3, 3, 40, 40)
    self.shop_grid:setZIndex(2)

    self.shop_grid.starting_position = {}
    self.shop_grid.starting_position.x = pd.display.getWidth()*.25
    self.shop_grid.starting_position.y = pd.display.getHeight()*self.vertical_center_breakpoint
    self.shop_grid:moveTo(self.shop_grid.starting_position.x , self.shop_grid.starting_position.y)
    self.shop_grid.a_callback = function ()
        self:generateContextMenuShop(self.shop_grid)
    end

    self.sprites:append(self.shop_grid)

    shadow_img = gfx.image.new(self.shop_grid:getSize())
    gfx.pushContext(shadow_img)
        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRoundRect(0,0, shadow_img.width, shadow_img.height, 4)
    gfx.popContext()

    self.shop_grid.shadow = gfx.sprite.new(shadow_img)
    self.shop_grid.shadow:setZIndex(1)
    self.shop_grid.shadow:moveTo(self.shop_grid.starting_position.x + self.shadow_offset, self.shop_grid.starting_position.y + self.shadow_offset)
    self.sprites:append(self.shop_grid.shadow)


    self.selection_sprite = gfx.sprite.new(gfx.image.new(self.shop_grid.width + 25 + self.shadow_offset, self.shop_grid.height + 25 + self.shadow_offset))
    gfx.pushContext(self.selection_sprite:getImage())
        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.setLineWidth(5)
        gfx.drawRoundRect(0,0, self.selection_sprite:getImage().width, self.selection_sprite:getImage().height, 6)
    gfx.popContext()
    self.selection_sprite:moveTo(pd.display.getWidth()*.25 + self.shadow_offset, pd.display.getHeight()*self.vertical_center_breakpoint + self.shadow_offset)
    self.sprites:append(self.selection_sprite)

    self.shop_grid.b_callback = function ()
        self.shop_grid:unfocus()
        self.shop_grid:drawGrid()
        self:focus()
    end

    self.player_grid .b_callback = function ()
        self.player_grid:unfocus()
        self.player_grid:drawGrid()
        self:focus()
    end

    self.label = gfx.sprite.new(gfx.image.new(self.selection_sprite.width, 30))
    self.label:moveTo(pd.display.getWidth()*.25 + self.shadow_offset, pd.display.getHeight()*.15)
    self.sprites:append(self.label)

    self:drawLabel('SHOP')

end

function Shop:drawLabel(str)
    gfx.pushContext(self.label:getImage())
        gfx.clear()
        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.setLineWidth(5)
        gfx.drawRoundRect(0,0, self.label:getImage().width, self.label:getImage().height, 5)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawTextInRect(string.format("%s", str), 0, 5, self.label:getImage().width, self.label:getImage().height, nil, nil, kTextAlignment.center, g_font)
        --gfx.drawTextAligned("*Sell*", self.label:getImage().width/2, self.label:getImage().height*.25, kTextAlignment.center)
    gfx.popContext()

    self.label:markDirty()
end

function Shop:generateContextMenuPlayer(grid)

    local _self = self

    local data = {
        {
            name="Sell",
        }
    }

    local _l = ListBox(data)

    data[1].callback = function ()

        local item = grid:getSelection()
        local idx = grid:getSelectionIndex()
        math.randomseed(g_player.cycle + idx)
        local price = math.random(item.price_min, item.price_max)

        local pop_up_data = {
            text = string.format("Sell for %s for %i?", item.name, price),
            options = {
                {
                    name="Yes",
                    callback = function ()
                        g_player.money += price
                        g_player.inventory.items[idx] = nil
                        table.remove(g_player.inventory.items, idx)
                        grid:drawGrid()
                    end
                },
                {
                    name="No",
                    callback = function ()
                    end
                }
            }
        }

        _l:remove()
        g_SceneManager:pushScene(Popup(pop_up_data))

    end

    grid:unfocus()
    _l:setCenter(0,0)
    _l:moveTo(grid:getSelectionPosition())
    _l:setZIndex(2)
    _l.b_callback = function ()
        _self.last_focus = grid
        grid:focus()
        _l:remove()
    end
    _self.last_focus = _l
    _l:focus()
    _l:add()
end

function Shop:generateContextMenuShop(grid)

    local data = {
        {
            name="Buy"
        }
    }

    local _l = ListBox(data)

    data[1].callback = function ()
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
    _l:focus()
    _l:add()
end

function Shop:processAnimations()
    if self.grid_animator then
        
        if self.grid_animator:ended() then
            self.grid_animator = nil
            return
        end

        self.player_grid:moveTo(self.player_grid.x, self.player_grid.starting_position.y + self.grid_animator:currentValue())
        self.player_grid.shadow:moveTo(self.player_grid.shadow.x, self.player_grid.starting_position.y + self.shadow_offset + self.grid_animator:currentValue())

        self.shop_grid:moveTo(self.shop_grid.x, self.shop_grid.starting_position.y + self.grid_animator:currentValue())
        self.shop_grid.shadow:moveTo(self.shop_grid.shadow.x, self.shop_grid.starting_position.y + self.shadow_offset + self.grid_animator:currentValue())

    end
end

function Shop:initInputs()

    self.input_handlers = {

        AButtonUp = function ()
            if  self.player_grid.y == pd.display.getHeight()*self.vertical_center_breakpoint then
                self:unfocus()
                self.player_grid:focus()
            end

            if  self.shop_grid.y == pd.display.getHeight()*self.vertical_center_breakpoint then
                self:unfocus()
                self.shop_grid:focus()
            end
        end,

        BButtonUp = function ()
            g_SceneManager:popScene('hwipe')
        end,

        upButtonDown = function ()
            if not self.grid_animator and self.player_grid.y == pd.display.getHeight()*self.vertical_center_breakpoint then
                self.grid_animator = gfx.animator.new(500, pd.display.getHeight(), 0, playdate.easingFunctions.outQuart)
                self:drawLabel('SHOP')
            end
        end,

        downButtonDown = function ()
            if not self.grid_animator and self.shop_grid.y == pd.display.getHeight()*self.vertical_center_breakpoint then
                self.grid_animator = gfx.animator.new(500, 0, pd.display.getHeight(), playdate.easingFunctions.outQuart)
                self:drawLabel('INVENTORY')
            end
        end

    }
    
end

function Shop:doUpdate()
    self:processAnimations()
end

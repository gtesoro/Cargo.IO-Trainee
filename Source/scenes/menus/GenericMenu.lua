
local pd <const> = playdate
local gfx <const> = pd.graphics

class('GenericMenu').extends(Scene)

function GenericMenu:startScene()

    self:initGrids()
    self:initBg()
    
end

function GenericMenu:initGrids()

    local _list_box_data = {
        options = self.data.options,
        parent = self
    }

    self.list_box = ListBox(_list_box_data, 150, 150)
    self.list_box:moveTo(110, 120)
    self.list_box:setZIndex(2)

    self.list_box:add()

    self.list_box.b_callback = function ()
        
        local _prev = g_SceneManager.scene_stack[#g_SceneManager.scene_stack -1]
        if _prev and _prev:isa(System) then
            g_SceneManager:popScene('out menu')
        else
            g_SceneManager:popScene('between menus')
        end
        
    end

    self.sprites:append(self.list_box)

end

function GenericMenu:initBg()

    local img = gfx.image.new(400, 240, gfx.kColorBlack)
    gfx.pushContext(img)
        local _i = gfx.image.new('assets/backgrounds/grid')
        _i:drawAnchored(pd.display.getWidth()/2, pd.display.getHeight()/2, 0.5, 0.5)
    gfx.popContext()

    self.bg_image = img:blurredImage(1, 2, gfx.image.kDitherTypeScreen)

    self.bg_sprite = gfx.sprite.new(self.bg_image)
    self.bg_sprite:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.bg_sprite:setZIndex(0)
    self.bg_sprite:add()
    self.sprites:append(self.bg_sprite)

    self.ui_overlay = gfx.sprite.new(gfx.image.new('assets/backgrounds/ui_overlay'))
    self.ui_overlay:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.ui_overlay:setZIndex(2)
    self.ui_overlay:add()

    self.sprites:append(self.ui_overlay)

    if self.data.right_side then
        self:setRightSide(self.data.right_side)
    end
end

function GenericMenu:setRightSide(spr)

    if self.right_side then
        self.right_side:remove()
        self.sprites:remove(self.right_side)
    end

    if spr then
        self.right_side = spr
        self.right_side:moveTo(290, 120)
        self.right_side:setZIndex(0)
        self.right_side:add()

        self.sprites:append(self.right_side)
    end
end

function GenericMenu:focus()
    if self.list_box then
        self:unfocus()
        self.list_box:focus()
    end
end

function GenericMenu:unfocus()
    if self.list_box then
        self.list_box:unfocus()
    end
end

function GenericMenu:remove()
    GenericMenu.super.remove(self)
    self.data.right_side = nil
end

function GenericMenu:doUpdate()

    if self.current_selected ~= self.list_box:getSelected() then
        self.current_selected = self.list_box:getSelected()
        if self.current_selected.sprite then
            self:setRightSide(self.current_selected.sprite)
        else
            self:setRightSide(self.data.right_side)
        end
    end

    if not self.noise_timer then
        self.noise_timer = pd.timer.new(math.random(3000, 10000))
        self.noise_timer.delay = 1000
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
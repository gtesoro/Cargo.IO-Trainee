
local pd <const> = playdate
local gfx <const> = pd.graphics

class('GenericMenu').extends(Scene)

function GenericMenu:startScene()

    self:initBg()
    
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
    table.insert(self.sprites, self.bg_sprite)

    self.ui_overlay = gfx.sprite.new(g_SystemManager:getOverlayImage())
    self.ui_overlay:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.ui_overlay:setZIndex(4)
    self.ui_overlay:add()

    table.insert(self.sprites, self.ui_overlay)

end

function GenericMenu:add()
    GenericMenu.super.add(self)
    applyFlicker(self.bg_sprite)
end

function GenericMenu:remove()
    GenericMenu.super.remove(self)
    for k, v in pairs(self.sprites) do
        if v.flicker_timer then
            v.flicker_timer:remove()
            v.flicker_timer = nil
        end
        v:remove()
    end
end
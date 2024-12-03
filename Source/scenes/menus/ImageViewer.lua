
local pd <const> = playdate
local gfx <const> = pd.graphics

class('ImageViewer').extends(Scene)

function ImageViewer:startScene()

    self:initBg()
    self:initImage()
    self:initInputs()
end

function ImageViewer:initBg()

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

end

function ImageViewer:initImage()

    self.image_sprite = gfx.sprite.new(self.data.image)
    self.image_sprite:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()*0.2+ self.data.image.height/2)
    self.image_sprite:setZIndex(1)
    self.image_sprite:add()
    self.sprites:append(self.image_sprite)

end


function ImageViewer:initInputs()
    self.input_handlers = {

        cranked = function (change, acceleratedChange)
            self.image_sprite:moveBy(0, -change/10)
        end,

        BButtonDown = function ()
            
        end,

        BButtonUp = function ()
            g_SceneManager:popScene('between menus')
        end,

        AButtonDown = function ()
            
        end,

        AButtonUp = function ()
            if self.data.a_callback then
                self.data.a_callback(self)
            end
        end,

        upButtonDown = function ()
        end,

        downButtonDown = function ()

        end

    }
end
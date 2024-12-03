
local pd <const> = playdate
local gfx <const> = pd.graphics

class('TextViewer').extends(Scene)

function TextViewer:startScene()

    self:initBg()
    self:initText()
    self:initInputs()
end

function TextViewer:initBg()

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

function TextViewer:initText()


    local _w, _h = 400*0.8, 240

    gfx.setFont(g_font_18)
    _w, _h = gfx.getTextSizeForMaxWidth(self.data.text, _w)
    local img = gfx.image.new(_w, _h)
    inContext(img, function ()
        
        
        gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
        gfx.drawTextInRect(self.data.text,0,0, img:getSize())
        gfx.setFont()

    end)


    self.text_sprite = gfx.sprite.new(img)
    self.text_sprite:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()*0.2+ img.height/2)
    self.text_sprite:setZIndex(1)
    self.text_sprite:add()
    self.sprites:append(self.text_sprite)

end


function TextViewer:initInputs()
    self.input_handlers = {

        cranked = function (change, acceleratedChange)
            self.text_sprite:moveBy(0, -change/10)
        end,

        BButtonDown = function ()
            
        end,

        BButtonUp = function ()
            g_SceneManager:popScene('between menus')
        end,

        upButtonDown = function ()
        end,

        downButtonDown = function ()

        end

    }
end
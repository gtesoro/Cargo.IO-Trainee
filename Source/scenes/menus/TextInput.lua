local pd = playdate
local gfx <const> = pd.graphics
class('TextInput').extends(Scene)

function TextInput:init(data)
    TextInput.super.init(self, data)
    self.bg_img = gfx.getDisplayImage():blurredImage(1, 2, gfx.image.kDitherTypeScreen)
    inContext(self.bg_img, function ()
        gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
        gfx.fillRect(0, 0, 400, 240)
    end)
end


function TextInput:startScene()

    
    self.bg_sprite = gfx.sprite.new(self.bg_img:copy())
    self.bg_sprite:moveTo(200,120)
    self.bg_sprite:setZIndex(0)

    self.bg_sprite:add()

    table.insert(self.sprites, self.bg_sprite)

    local _img = gfx.image.new(190, 180)
    
    gfx.pushContext(_img)
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.2, gfx.image.kDitherTypeScreen)
        gfx.fillRoundRect(0, 0, _img.width, _img.height, 4)

        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(4)
        gfx.drawRoundRect(-2, 0, _img.width+2, _img.height, 4)
        
    gfx.popContext()

    self.text_bg = gfx.sprite.new(_img)
    self.text_bg:setCenter(0, 0.5)
    self.text_bg:moveTo(0,120)
    self.text_bg:setZIndex(1)
    self.text_bg:add()

    table.insert(self.sprites, self.text_bg)

    self.text_spr = gfx.sprite.new(gfx.image.new(190, 180))
    self.text_spr:setCenter(0, 0)
    self.text_spr:moveTo(32, 34)
    self.text_spr:setZIndex(2)
    self.text_spr:add()

    table.insert(self.sprites, self.text_spr)


    self.ui_overlay = gfx.sprite.new(g_SystemManager:getOverlayImage())
    self.ui_overlay:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.ui_overlay:setZIndex(4)
    self.ui_overlay:add()

    table.insert(self.sprites, self.ui_overlay)

    pd.keyboard.show()

    pd.keyboard.keyboardWillHideCallback = function (ok)
        if ok then
            self.data.text = playdate.keyboard.text
            if self.data.callback then
                self.data.callback(self.data.text)
            end
        else
            self.data.text = nil
        end        
    end

    pd.keyboard.keyboardDidHideCallback = function ()
        g_SceneManager:popScene()
    end

    pd.keyboard.textChangedCallback = function ()
        inContext(self.text_spr:getImage(), function ()
            gfx.clear(gfx.kColorClear)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.setFont(g_font_24)
            gfx.drawTextInRect(playdate.keyboard.text,0, 0, 124, 176, nil, nil, kTextAlignment.center)
            
        end)
        self.text_spr:markDirty()
    end

end

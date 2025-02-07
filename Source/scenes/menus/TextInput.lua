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
        inContext(self.bg_sprite:getImage(), function ()
            gfx.clear()
            self.bg_img:draw(0,0)

            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.setFont(g_font_24)
            gfx.drawTextAligned(playdate.keyboard.text, 100, 120, kTextAlignment.center)
            
        end)
        self.bg_sprite:markDirty()
    end

end


local pd <const> = playdate
local gfx <const> = pd.graphics

class('ImageViewer').extends(GenericMenu)

function ImageViewer:startScene()

    ImageViewer.super.startScene(self)

    self:initWidgets()
    self:initImage()
    self:initInputs()
end

function ImageViewer:initWidgets()
    self.underlays = {}

    img = gfx.image.new('assets/ui/imageviewer_bg')
    -- gfx.pushContext(img)
    --     gfx.setColor(gfx.kColorBlack)
    --     gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
    --     gfx.fillRect(0,0, img:getSize())
    -- gfx.popContext()

    self.underlay_1 = gfx.sprite.new(img)

    self.underlay_1:moveTo(playdate.display.getWidth()*0.5, playdate.display.getHeight()/2-img.height)
    self.underlay_1:setZIndex(0)
    self.underlay_1:add()

    table.insert(self.underlays, self.underlay_1)
    table.insert(self.sprites, self.underlay_1)

    self.underlay_2 = gfx.sprite.new(img)

    self.underlay_2:moveTo(playdate.display.getWidth()*0.5, playdate.display.getHeight()/2)
    self.underlay_2:setZIndex(0)
    self.underlay_2:add()

    table.insert(self.underlays, self.underlay_2)
    table.insert(self.sprites, self.underlay_2)

    self.underlay_3 = gfx.sprite.new(img)
    self.underlay_3:moveTo(playdate.display.getWidth()*0.5, playdate.display.getHeight()/2 + img.height)
    self.underlay_3:setZIndex(0)
    self.underlay_3:add()

    table.insert(self.underlays, self.underlay_3)
    table.insert(self.sprites, self.underlay_3)

end

function ImageViewer:initImage()

    local _top_margin = 20
    local _left_margin = 50

    self.image_sprite = self.data.image

    self.image_sprite:setCenter(0, 0)
    self.image_sprite:moveTo(_left_margin,  _top_margin )
    self.image_sprite:setZIndex(1)
    self.image_sprite:add()
    table.insert(self.sprites, self.image_sprite)

end

function ImageViewer:scroll(amount)
    for k,v in pairs(self.underlays) do
        v:moveBy(0, amount)
        if v.y < -playdate.display.getHeight()/2 then
            v:moveBy(0,v.height*2)
        end
        if v.y > playdate.display.getHeight()*1.5 then
            v:moveBy(0,-v.height*2)
        end
    end

    self.image_sprite:moveBy(0, amount)
end


function ImageViewer:initInputs()
    self.input_handlers = {

        cranked = function (change, acceleratedChange)
            local _t = -pd.getCrankTicks(g_SystemManager.scroll_sensitivity)
            if math.fmod(_t, 2) ~= 0 then
                _t += 1 * (_t/math.abs(_t))
            end
            self:scroll(_t)
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
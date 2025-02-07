local pd <const> = playdate
local gfx <const> = pd.graphics

class('Popup').extends(Scene)

function Popup:init(data)
    Popup.super.init(self, data)
    self.previous_scene_img = gfx.getDisplayImage()
    self:setZIndex(1000)
    self.blur_duration = 100
end

function Popup:startScene()

    local _new_options = {}

    g_SoundManager:playPopupIn()

    if self.data.options then

        for k,v in pairs(self.data.options) do
            local _func = nil

            _func = function ()
                if v.callback then
                    v.callback()
                end
                if not v.no_exit then
                    self:unblur(function ()
                        g_SoundManager:playPopupOut()
                        g_SceneManager:popScene()
                    end)
                end
            end

            _new_options[k] = {
                name = v.name,
                callback = _func
            }

        end

        self.data.options = _new_options

    end

    self:initBg()
    self:initDialog()
    self:initInputs()
    -- self:animateIn()
end

function Popup:focus()
    Popup.super.focus(self)
    if self.list_box then
        self:unfocus()
        self.list_box:focus()
    end
end

function Popup:unfocus()
    Popup.super.unfocus(self)
    if self.list_box then
        self.list_box:unfocus()
    end
end

function Popup:initBg()

    self.base_bg_img = gfx.image.new(400, 240)
    self.bg_spr = gfx.sprite.new(self.base_bg_img)

    self.bg_spr:moveTo(200,120)

    table.insert(self.sprites, self.bg_spr)
    
end

function Popup:animateIn()

    self.blur_target = 2
    self.blur_tick = 2
    self.blur_duration = 300
    self.move_duration = 300

    local _blur_timer = pd.timer.new(self.blur_duration, 0, self.blur_target, pd.easingFunctions.outCubic)
    _blur_timer.updateCallback = function(timer)
        if g_SystemManager:isTick(self.blur_tick) then
            self.bg_spr:setImage(self.base_bg_img:blurredImage(timer.value, 1, gfx.image.kDitherTypeScreen))
            self.bg_spr:markDirty()
        end
    end

    _blur_timer.timerEndedCallback = function ()
        local _move_timer = pd.timer.new(self.move_duration, 0, 240, pd.easingFunctions.outCubic)
        _move_timer.updateCallback = function (timer)
            self.box_spr:moveTo(self.box_spr_x, -120 + timer.value)
            self.box_spr_shadow:moveTo(self.box_spr_x + self.shdow_float, -120 + self.shdow_float + timer.value)
            self.list_box:moveTo(self.list_box_x, -120 + timer.value)
            self.list_box_shadow:moveTo(self.list_box_x + self.shdow_float, -120 + self.shdow_float + timer.value)
        end

        _move_timer.timerEndedCallback = function ()
            self:focus()
        end

    end
end

function Popup:unblur(callback)

    self.box_spr:remove()
    self.box_spr_shadow:remove()
    if self.list_box then
        self.list_box:remove()
        self.list_box_shadow:remove()
    end

    local unblur_timer = pd.timer.new(self.blur_duration, 4, 0, pd.easingFunctions.inLinear)
    unblur_timer.updateCallback = function(timer)
        self:setImage(self.previous_scene_img:blurredImage(timer.value, 2, gfx.image.kDitherTypeBayer8x8))
        self:markDirty()
    end

    unblur_timer.timerEndedCallback = function ()
        self:setImage(nil)
        self.ui_overlay:remove()
        callback()
    end
end

function Popup:initInputs()
    self.input_handlers = {

        BButtonUp = function ()
            self:unblur(function ()
                g_SoundManager:playPopupOut()
                g_SceneManager:popScene()
            end)
        end

    }
end


function Popup:initDialog()

    if self.data.options then
        local _list_box_data = {
            options = function ()
                return self.data.options
            end,
            parent = self
        }

        self.list_box = ListBox(_list_box_data)
        self.list_box:setZIndex(2)

        self.list_box.b_callback = function ()
            self:unblur(function ()
                g_SceneManager:popScene()
            end)
        end
    end

    gfx.setFont(g_font_text)

    local _w, _h = gfx.getTextSizeForMaxWidth(self.data.text, 300)

    local padding = 5
    _w += padding*2
    _h += padding*2

    if self.list_box then
        if _h < self.list_box.height then
            _h = self.list_box.height
        end
    end

    local box = gfx.image.new(_w, _h)
    inContext(box, function ()
        
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(0,0, _w,_h, 4)
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(1)
        gfx.drawRoundRect(0,0, _w,_h, 4)

        gfx.drawTextInRect(self.data.text, padding, padding, _w-padding, _h-padding)
    end)

    gfx.setFont()

    self.shdow_float = 5

    self.box_spr_x = 200

    if self.list_box then
        self.list_box:setZIndex(1002)
        

        self.list_box_shadow = getShadowSprite(self.list_box)
        self.list_box_shadow:setZIndex(1002)
        table.insert(self.sprites, self.list_box_shadow)
        self.list_box_x = (200 + _w/2) + padding/2
        self.list_box:moveTo(self.list_box_x, 120)
        self.list_box_shadow:moveTo(self.list_box_x + self.shdow_float, 120 + self.shdow_float)
        table.insert(self.sprites, self.list_box)
        self.box_spr_x = 200 - self.list_box.width/2 - padding/2
    end

    self.box_spr = gfx.sprite.new(box)
    self.box_spr:setZIndex(2)
    self.box_spr_shadow = getShadowSprite(self.box_spr)

    self.box_spr:setZIndex(1002)
    self.box_spr_shadow:setZIndex(1002)

    table.insert(self.sprites, self.box_spr_shadow)
    self.box_spr:moveTo(self.box_spr_x, 120)
    self.box_spr_shadow:moveTo(self.box_spr_x + self.shdow_float, 120 + self.shdow_float)
    table.insert(self.sprites, self.box_spr)
    
end

function Popup:animateOut()
    
    self:unfocus()
    local _move_timer = pd.timer.new(self.move_duration, 240, 0, pd.easingFunctions.inCubic)
    _move_timer.updateCallback = function (timer)
        self.box_spr:moveTo(self.box_spr_x, -120 + timer.value)
        self.box_spr_shadow:moveTo(self.box_spr_x + self.shdow_float, -120 + self.shdow_float + timer.value)
        self.list_box:moveTo(self.list_box_x, -120 + timer.value)
        self.list_box_shadow:moveTo(self.list_box_x + self.shdow_float, -120 + self.shdow_float + timer.value)
    end

    _move_timer.timerEndedCallback = function ()
        local _blur_timer = pd.timer.new(self.blur_duration, self.blur_target, 0, pd.easingFunctions.outCubic)
        _blur_timer.updateCallback = function(timer)
            if g_SystemManager:isTick(self.blur_tick) then
                self.bg_spr:setImage(self.base_bg_img:blurredImage(timer.value, 1, gfx.image.kDitherTypeScreen))
                self.bg_spr:markDirty()
            end
        end
        _blur_timer.timerEndedCallback = function ()
            g_SceneManager:popScene()
        end 
    end

end 

function Popup:doUpdate()   

    if not self.blur_timer_in then

        self.ui_overlay = gfx.sprite.new(gfx.image.new('assets/backgrounds/ui_overlay'))
        self.ui_overlay:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
        self.ui_overlay:setZIndex(1005)
        self.ui_overlay:add()

        table.insert(self.sprites, self.ui_overlay)

        self.blur_timer_in = pd.timer.new(self.blur_duration, 0, 4, pd.easingFunctions.inLinear)
        self.blur_timer_in.updateCallback = function(timer)
            self:setImage(self.previous_scene_img:blurredImage(timer.value, 2, gfx.image.kDitherTypeBayer8x8))
            self:markDirty()
        end
    end

end
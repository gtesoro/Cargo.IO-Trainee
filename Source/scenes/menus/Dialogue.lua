
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Dialogue').extends(GenericMenu)

function Dialogue:startScene()

    Dialogue.super.startScene(self)

    self:initInputs()
    self:initDialogueWidgets()
end

function Dialogue:initDialogueWidgets()

    self.dialogue = self.data.dialogue
    self.current_dialogue = self.dialogue
    self.current_dialogue_index = 1

    self.text_input = {text = ''}

    img = gfx.image.new('assets/ui/dialog_bg')--gfx.image.new(180, 240, gfx.kColorBlack)
    gfx.pushContext(img)
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
        gfx.fillRect(0,0, img:getSize())
    gfx.popContext()

    self.animations = 0
    self.scrolled = 0
    self.dialog_hidden = false
    self.selection_box_hidden = false

    self.dialog_underlays = {}
    self.bubbles = {}
    
    self.dialog_underlay_1 = gfx.sprite.new(img)
    self.dialog_underlay_1:setCenter(0, 0.5)
    self.dialog_underlay_1:moveTo(playdate.display.getWidth()*0.5, playdate.display.getHeight()/2-img.height)
    self.dialog_underlay_1:setZIndex(2)
    self.dialog_underlay_1:add()

    table.insert(self.dialog_underlays, self.dialog_underlay_1)

    table.insert(self.sprites, self.dialog_underlay_1)

    self.dialog_underlay_2 = gfx.sprite.new(img)
    self.dialog_underlay_2:setCenter(0, 0.5)
    self.dialog_underlay_2:moveTo(playdate.display.getWidth()*0.5, playdate.display.getHeight()/2)
    self.dialog_underlay_2:setZIndex(2)
    self.dialog_underlay_2:add()

    table.insert(self.dialog_underlays, self.dialog_underlay_2)
    table.insert(self.sprites, self.dialog_underlay_2)

    self.dialog_underlay_3 = gfx.sprite.new(img)
    self.dialog_underlay_3:setCenter(0, 0.5)
    self.dialog_underlay_3:moveTo(playdate.display.getWidth()*0.5, playdate.display.getHeight()/2 + img.height)
    self.dialog_underlay_3:setZIndex(2)
    self.dialog_underlay_3:add()

    table.insert(self.dialog_underlays, self.dialog_underlay_3)
    table.insert(self.sprites, self.dialog_underlay_3)

end

function Dialogue:removeElement(spr, callback)

    local _start = 200
    local _end = -200

    self.animations += 1

    local _t = pd.timer.new(250, _start, _end, pd.easingFunctions.outCubic)
    _t.updateCallback = function (timer)
        spr:moveTo(timer.value, spr.y)
    end
    _t.timerEndedCallback = function ()
        self.animations -= 1
        spr:remove()
        table_remove(self.sprites, spr)
        if spr.flicker_timer then
            spr.flicker_timer:remove()
            spr.flicker_timer = nil
        end
        if callback then
            callback()
        end
    end
end

function Dialogue:addElement(spr, callback, no_flicker)

    local _start = -200
    local _end = 200
    self.animations += 1
    local _t = pd.timer.new(250, _start, _end, pd.easingFunctions.outCubic)
    _t.updateCallback = function (timer)
        spr:moveTo(timer.value, spr.y)
    end
    _t.timerEndedCallback = function ()
        self.animations -= 1
        if not no_flicker then
            applyFlicker(spr)
        end
        if callback then
            callback()
        end
    end
end

function Dialogue:removeBg(callback)
    if self.character_bg then
        self:removeElement(self.character_bg, callback)
        self.character_bg = nil
    end
end

function Dialogue:addBg(image, callback)

    if animated then
        self.character_bg = AnimatedSprite(image)
    else
        self.character_bg = gfx.sprite.new(gfx.image.new(image))--getImageWithDitherMask(image, true))
    end

    self.character_bg:moveTo(-playdate.display.getWidth()*0.5, playdate.display.getHeight()/2)
    self.character_bg:setZIndex(1)
    self.character_bg:add()
    table.insert(self.sprites, self.character_bg)


    self:addElement(self.character_bg, callback)
    
end

function Dialogue:removeCharacter(callback)
    if self.character then
        self:removeElement(self.character, callback)
        self.character = nil
    end

    if self.character_label then
        self:removeElement(self.character_label)
        self.character_label = nil
    end
end

function Dialogue:addCharacter(image, animated, callback)

    if animated then
        self.character = AnimatedSprite(image)
    else
        self.character = gfx.sprite.new(gfx.image.new(image))
    end

    self.character:moveTo(-playdate.display.getWidth()*0.5, playdate.display.getHeight()/2)
    self.character:setZIndex(1)
    self.character:add()

    table.insert(self.sprites, self.character)

    self:addElement(self.character, callback)
    
end

function Dialogue:addCharacterLabel(name)

    local _img = gfx.image.new(400,240)

    inContext(_img, function ()
        gfx.setFont(g_font_18)
        local _w, _h = gfx.getTextSizeForMaxWidth(name, 150)
        local _margin = 2

        gfx.setColor(gfx.kColorBlack)
        gfx.fillRoundRect(-2, 192 - _h/2 - _margin, 182, _h + _margin, 2)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawRoundRect(-2, 192 - _h/2 - _margin, 182, _h + _margin, 2)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        
        gfx.drawTextInRect(name, 0, 192 - _h/2, 180, _h, nil, nil, kTextAlignment.center)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        
    end)

    self.character_label = gfx.sprite.new(_img)
    self.character_label:moveTo(-playdate.display.getWidth()*0.5, playdate.display.getHeight()/2)
    self.character_label:setZIndex(2)
    self.character_label:add()
    table.insert(self.sprites, self.character_label)

    self:addElement(self.character_label, nil , true)
    
end

function Dialogue:dialogueFinished()
    return self.current_dialogue_index > #self.current_dialogue
    
end

function Dialogue:nextDialogue()

    if self.waiting_for_answer then

        local _s, _r, _col = self.selection_box.listview:getSelection()

        local _d = self.current_dialogue[self.current_dialogue_index].options[_r]

        local _c = function ()
            if _d.trigger then
                _d.trigger()
            end
            if _d.continue then
                self:nextDialogue()
            end
        end
        
        self:addDialogue(_d.answer, DIAG_PLAYER, _c)
        self.current_dialogue = _d.dialogue
        self.current_dialogue_index = 1
        self.waiting_for_answer = false
        self:animateSelectionBoxOut()
        return
    end

    local _d = self.current_dialogue[self.current_dialogue_index]

    local _c = function ()
        if _d.trigger then
            _d.trigger()
        end
        if _d.continue then
            self:nextDialogue()
        end
    end

    if self.waiting_for_text_input then

        local _next = _d.default

        if _d.options then
            for k,v in pairs(_d.options) do
                if v.answer == self.text_input.text then
                    _next = v.dialogue
                end
            end
        end
        
        self.current_dialogue = _next
        self.current_dialogue_index = 1
        self.waiting_for_text_input = false

        if self.text_input.text then
            self:addDialogue(self.text_input.text, DIAG_PLAYER, _c)
        else
            self:nextDialogue()
        end

        return
    end
    
    if self:dialogueFinished() then
        g_SoundManager:playEndTransmission()
        rumbleSprite(self.bubbles[#self.bubbles], 250)
        return nil
    end

    if _d.type == DIAG_EMPTY then
        _c()
        self.current_dialogue_index += 1
        return
    end

    if _d.type == DIAG_BG_IN then
        self:addBg(_d.file, _c)
        self.current_dialogue_index += 1
        return
    end

    if _d.type == DIAG_CHAR_IN then
        self:addCharacter(_d.file, _d.animated, _c)
        if _d.name then
            self:addCharacterLabel(_d.name)
        end
        self.current_dialogue_index += 1
        return
    end

    if _d.type == DIAG_BG_OUT then
        self:removeBg(_c)
        self.current_dialogue_index += 1
        return
    end

    if _d.type == DIAG_CHAR_OUT then
        self:removeCharacter(_c)
        self.current_dialogue_index += 1
        return
    end

    if _d.type == DIAG_INPUT_TEXT then
        g_SceneManager:pushScene(TextInput(self.text_input))
        self.waiting_for_text_input = true
        return
    end

    if _d.type == DIAG_INPUT_OPTIONS then

        if self.selection_box then
            self.selection_box:remove()
        end

        local _options = {}

        for k2, o in pairs(_d.options) do
            table.insert(_options, {text=o.answer})
        end

        self.selection_box = TextSelectionBox(_options)
        self.selection_box:setCenter(0, 1)
        self.selection_box:moveTo(-self.selection_box.width, 200)
        self.selection_box:setZIndex(3)
        self.selection_box:add()
        self:animateSelectionBoxIn()

        self.waiting_for_answer = true
        return
    end

    if type(_d.text) == "function" then
        _d.text = _d.text()
    end

    self:addDialogue(_d.text, _d.type, _c)
    self.current_dialogue_index += 1
    

end

function Dialogue:addDialogue(text, type, callback)

    local _dialog_bubble = TextBubble(text, 156, type, 5)

    table.insert(self.bubbles, _dialog_bubble)
    table.insert(self.sprites, _dialog_bubble)

    local _t = nil
    if type == DIAG_OTHER then
        _t = rumbleSprite(self.character, nil, 4)
    end

    local _c = function ()
        if callback then
            callback()
        end
        if type == DIAG_OTHER then
            _t.timerEndedCallback()
            _t:remove()
        end
    
        if type == DIAG_PLAYER then
            self:nextDialogue()
        end
    end

    _dialog_bubble.on_finish = _c

    if #self.bubbles == 0 then
        _dialog_bubble:setCenter(0,1)
        _dialog_bubble:moveTo(playdate.display.getWidth()*0.5+12, pd.display.getHeight()*0.75)
        _dialog_bubble:setZIndex(3)
        _dialog_bubble:add()

        return
    end

    local _w, _h = _dialog_bubble:getSize()
    _h += 5

    self.animations += 1

    local _prev = 0

    local _timer_reset_scroll = pd.timer.new(math.min(self.scrolled, 250), 0, self.scrolled, pd.easingFunctions.inOutQuint)

    _timer_reset_scroll.updateCallback = function (timer)
        local _val = math.ceil(timer.value)
        self:moveDialog(-(_val - _prev))
        _prev = _val
    end

    _timer_reset_scroll.timerEndedCallback = function (timer)
        local _val = math.ceil(timer.value)
        self:moveDialog(-(_val - _prev))
        _prev = _val
        self.scrolled = 0

        local _timer_bubble = pd.timer.new(250, 0, _h, pd.easingFunctions.outQuint)
        local _prev = 0
        _timer_bubble.updateCallback = function (timer)
            local _val = math.ceil(timer.value)
            self:moveDialog(-(_val - _prev))
            _prev = _val
        end

        _timer_bubble.timerEndedCallback = function (timer)
            local _val = math.ceil(timer.value)
            self:moveDialog(-(_val - _prev))
            _prev = _val
            _dialog_bubble:setCenter(0,1)
            _dialog_bubble:moveTo(playdate.display.getWidth()*0.5+12, pd.display.getHeight()*0.75)
            _dialog_bubble:setZIndex(3)
            _dialog_bubble:add()

            self.animations -= 1
        end
    end

    return _dialog_bubble

end

function Dialogue:scrollBg(amount)
    for k,v in pairs(self.dialog_underlays) do
        v:moveBy(0, amount)
        if v.y < -playdate.display.getHeight()/2 then
            v:moveBy(0,v.height*2)
        end
        if v.y > playdate.display.getHeight()*1.5 then
            v:moveBy(0,-v.height*2)
        end
    end
end

function Dialogue:moveDialog(amount)
    for k,v in pairs(self.bubbles) do
        v:moveBy(0, amount)
    end
    self:scrollBg(amount)
end

function Dialogue:toggleDialog()

    self.animations += 1
    if self.dialog_hidden then
        local _timer = pd.timer.new(250, 380, 200, pd.easingFunctions.outCubic)
        _timer.updateCallback = function (timer)
            for k,v in pairs(self.dialog_underlays) do
                v:moveTo(timer.value, v.y)
            end

            for k,v in pairs(self.bubbles) do
                v:moveTo(timer.value+12, v.y)
            end
        end
        _timer.timerEndedCallback = function ()
            self.animations -= 1
            self.dialog_hidden = false
        end
    else
        local _timer = pd.timer.new(250, 200, 380 , pd.easingFunctions.outCubic)
        _timer.updateCallback = function (timer)
            for k,v in pairs(self.dialog_underlays) do
                v:moveTo(timer.value, v.y)
            end

            for k,v in pairs(self.bubbles) do
                v:moveTo(timer.value+12, v.y)
            end
        end
        _timer.timerEndedCallback = function ()
            self.animations -= 1
            self.dialog_hidden = true
        end
    end
end

function Dialogue:animateSelectionBoxOut()
    self.animations += 1
    local _timer = pd.timer.new(250, 0, self.selection_box.width, pd.easingFunctions.outCubic)
    _timer.updateCallback = function (timer)
        self.selection_box:moveTo(-timer.value, self.selection_box.y)
    end
    _timer.timerEndedCallback = function ()
        self.animations -= 1
        self.selection_box:moveTo(-self.selection_box.width, self.selection_box.y)
        self.selection_box:remove()
        self.selection_box = nil
    end
end

function Dialogue:animateSelectionBoxIn()

    self.animations += 1

    local _timer = pd.timer.new(250, self.selection_box.width, 0, pd.easingFunctions.outCubic)
    _timer.updateCallback = function (timer)
        self.selection_box:moveTo(-timer.value, self.selection_box.y)
    end
    _timer.timerEndedCallback = function ()
        self.animations -= 1
        self.selection_box:moveTo(0, self.selection_box.y)
    end
end

function Dialogue:toggleDialogSelection()

    if not self.selection_box then
        return
    end

    self.animations += 1
    if self.selection_box_hidden then
        local _timer = pd.timer.new(250, self.selection_box.width - 20, 0, pd.easingFunctions.outCubic)
        _timer.updateCallback = function (timer)
            self.selection_box:moveTo(-timer.value, self.selection_box.y)
        end
        _timer.timerEndedCallback = function ()
            self.animations -= 1
            self.selection_box_hidden = false
            self.selection_box:moveTo(0, self.selection_box.y)
        end
    else
        local _timer = pd.timer.new(250, 0, self.selection_box.width - 20, pd.easingFunctions.outCubic)
        _timer.updateCallback = function (timer)
            self.selection_box:moveTo(-timer.value, self.selection_box.y)
        end
        _timer.timerEndedCallback = function ()
            self.animations -= 1
            self.selection_box_hidden = true
            self.selection_box:moveTo(-(self.selection_box.width - 20), self.selection_box.y)
        end
    end
end

function Dialogue:initInputs()

    self.input_handlers = {

        cranked = function (change, acceleratedChange)
            if self.animations == 0 and not self.dialog_hidden and #self.bubbles > 0 then
                local _t = -pd.getCrankTicks(g_SystemManager.scroll_sensitivity)
                if math.fmod(_t, 2) ~= 0 then
                    _t += 1 * (_t/math.abs(_t))
                end
                if self.scrolled + _t < 0 then
                    self:moveDialog(-self.scrolled)
                    self.scrolled = 0
                else
                    self:moveDialog(_t)
                    self.scrolled += _t
                end
            end
        end,

        BButtonUp = function ()

            if self:dialogueFinished() then
                local _prev = g_SceneManager.scene_stack[#g_SceneManager.scene_stack -1]
                if _prev and _prev:isa(System) then
                    g_SceneManager:popScene('out menu')
                else
                    g_SceneManager:popScene('between menus')
                end 
            end
        end,

        leftButtonUp = function ()

            if self.animations == 0 then
                self:toggleDialogSelection()
            end

        end,

        rightButtonUp = function ()
            
            if self.animations == 0  then
                self:toggleDialog()
            end
        end,

        upButtonDown = function ()
            if self.selection_box then
                g_SoundManager:playMenuListChange()
                self.selection_box.listview:selectPreviousRow(true, true, true)
            end
        end,

        downButtonDown = function ()
            if self.selection_box then
                g_SoundManager:playMenuListChange()
                self.selection_box.listview:selectNextRow(true, true, true)
            end
        end,
        
        AButtonUp = function ()

            if self.animations > 0 then
                return 
            end
            
            if self.dialog_hidden then
                return 
            end

            if self.selection_box and self.selection_box_hidden then
                return 
            end

            local _all_finished = true
            for k,v in pairs(self.bubbles) do
                if not v.finished then
                    _all_finished = false
                    v:finish()
                end
            end

            if _all_finished then
                self:nextDialogue()
            end
        end
    }
    
end

function Dialogue:remove()
    Dialogue.super.remove(self)

    if self.character then
        self.character:remove()
    end
    if self.character_bg then
        self.character_bg:remove()
    end
    if self.character_label then
        self.character_label:remove()
    end
    if self.selection_box then
        self.selection_box:remove()
    end
end

function Dialogue:add()
    Dialogue.super.add(self)

    if self.character and not self.character.flicker_timer then
        applyFlicker(self.character)
    end
    if self.character_bg and not self.character_bg.flicker_timer then
        applyFlicker(self.character_bg)
    end

    self.animations += 1

    local _timer_start = pd.timer.new(300)
    _timer_start.timerEndedCallback = function (timer)
        self.animations -= 1
        self:nextDialogue()
    end
end
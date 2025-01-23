
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Dialogue').extends(Scene)

function Dialogue:startScene()
    self:initInputs()
    self:initBg()
end


local _test_dialog = {
    {
        text = "Hello! I'm the dialog test robot.",
        type = DIAG_OTHER
    },
    {
        text = "The robot seems strange. as if he wanted to challenge you. As much as robots want things anyhow.\nBe careful.",
        type = DIAG_DESC
    },
    {
        text = "Please choose an option.",
        type = DIAG_OTHER,
        options = {
            {
                answer = "I dont trust you",
                dialogue = {
                    {
                        text = "I'm very friendly!",
                        type = DIAG_OTHER
                    },
                    {
                        text = "Do NOT trust this robot",
                        type = DIAG_DESC
                    },
                }
            },
            {
                answer = "Sure, I will choose an option...",
                dialogue = {
                    {
                        text = "Mwhahaha! You fell into my trap",
                        type = DIAG_OTHER
                    },
                    {
                        text = "Wow, evil robot, fantastic",
                        type = DIAG_DESC
                    },
                }
            },
            {
                answer = "I'm leaving",
                dialogue = {
                    {
                        text = "Ok, you can do whatever you want",
                        type = DIAG_OTHER
                    },
                    {
                        text = "The passive-aggressive module of the robot seems to be working overtime",
                        type = DIAG_DESC
                    },
                    {
                        text = "Bye",
                        type = DIAG_OTHER
                    },
                }
            }
        }
    },
}

-- _test_dialog = {
--     {
--         text = "Hola! Soy el robot de pruebas para el sistema de dialogo.",
--         type = DIAG_OTHER
--     },
--     {
--         text = "Ojo cuidado, creo que es Cesar disfrazado.",
--         type = DIAG_DESC
--     },
--     {
--         text = "Por favor, elige una opcion.",
--         type = DIAG_OTHER,
--         options = {
--             {
--                 answer = "Venga, una opcion",
--                 dialogue = {
--                     {
--                         text = "Muy bien!",
--                         type = DIAG_OTHER
--                     },
--                     {
--                         text = "Decepcionante",
--                         type = DIAG_DESC
--                     },
--                 }
--             },
--             {
--                 answer = "Hmm, crees que el pastel es mentira?",
--                 dialogue = {
--                     {
--                         text = "No todos los robots somos como Glados.",
--                         type = DIAG_OTHER
--                     },
--                     {
--                         text = "Eso dicen todos",
--                         type = DIAG_DESC
--                     },
--                 }
--             },
--             {
--                 answer = "Cesar, quitate el disfraz y ponte el tanga",
--                 dialogue = {
--                     {
--                         text = "Pensaba que nunca me lo pedirias!",
--                         type = DIAG_OTHER
--                     },
--                     {
--                         text = "Dale Zelda",
--                         type = DIAG_DESC
--                     },
--                 }
--             }
--         }
--     }
    
-- }

function Dialogue:initBg()

    local img = gfx.image.new(400, 240, gfx.kColorBlack)
    gfx.pushContext(img)
        local _i = gfx.image.new('assets/backgrounds/grid')
        _i:drawAnchored(pd.display.getWidth()/2, pd.display.getHeight()/2, 0.5, 0.5)
    gfx.popContext()

    self.dialogue = _test_dialog
    self.current_dialogue = self.dialogue
    self.current_dialogue_index = 1

    self.bg_image = img:blurredImage(1, 2, gfx.image.kDitherTypeScreen)

    self.bg_sprite = gfx.sprite.new(self.bg_image)
    self.bg_sprite:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.bg_sprite:setZIndex(0)
    self.bg_sprite:add()
    table.insert(self.sprites, self.bg_sprite)

    self.ui_overlay = gfx.sprite.new(gfx.image.new('assets/backgrounds/ui_overlay'))
    self.ui_overlay:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.ui_overlay:setZIndex(4)
    self.ui_overlay:add()

    table.insert(self.sprites, self.ui_overlay)

    img = gfx.image.new('assets/ui/dialog_bg')--gfx.image.new(180, 240, gfx.kColorBlack)
    gfx.pushContext(img)
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
        gfx.fillRect(0,0, img:getSize())
    gfx.popContext()

    self.animating = false
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

    self.character_bg = gfx.sprite.new(getImageWithDitherMask('assets/characters/test_char_bg', true))
    self.character_bg:moveTo(playdate.display.getWidth()*0.5, playdate.display.getHeight()/2)
    self.character_bg:setZIndex(1)
    self.character_bg:add()

    table.insert(self.sprites, self.character_bg)

    self.character = gfx.sprite.new(gfx.image.new('assets/characters/test_char'))
    self.character:moveTo(playdate.display.getWidth()*0.5, playdate.display.getHeight()/2)
    self.character:setZIndex(1)
    self.character:add()

    table.insert(self.sprites, self.character)    

end

function Dialogue:dialogueFinished()

    return self.current_dialogue_index > #self.current_dialogue
    
end

function Dialogue:nextDialogue()

    if self.waiting_for_anser then

        local _s, _r, _c = self.selection_box.listview:getSelection()
        self:addDialogue(self.current_dialogue[self.current_dialogue_index].options[_r].answer, DIAG_PLAYER)
        self.current_dialogue = self.current_dialogue[self.current_dialogue_index].options[_r].dialogue
        self.current_dialogue_index = 1
        self.waiting_for_anser = false
        self:animateSelectionBoxOut()
        return
    end
    
    if self:dialogueFinished() then
        g_SoundManager:playEndTransmission()
        rumbleSprite(self.bubbles[#self.bubbles], 250)
        return nil
    end

    local _d = self.current_dialogue[self.current_dialogue_index]

    if _d.options then

        if self.selection_box then
            self.selection_box:remove()
        end

        local _options = {}

        for k2, o in pairs(_d.options) do
            table.insert(_options, {text=o.answer})
        end

        local _bubble = self:addDialogue(_d.text, _d.type)
        local _f = _bubble.on_finish
        _bubble.on_finish = function ()
            if _f then
                _f()
            end
            self.selection_box = TextSelectionBox(_options)
            self.selection_box:setCenter(0, 1)
            self.selection_box:moveTo(-self.selection_box.width, 200)
            self.selection_box:setZIndex(3)
            self.selection_box:add()
            self:animateSelectionBoxIn()
        end

        self.waiting_for_anser = true
        
    else
        self:addDialogue(_d.text, _d.type)
        self.current_dialogue_index += 1
    end

end

function Dialogue:addDialogue(text, type)

    local _dialog_bubble = TextBubble(text, 156, type, 5)

    if type == DIAG_OTHER then
        local _t = rumbleSprite(self.character)
        _dialog_bubble.on_finish = function ()
            _t.timerEndedCallback()
            _t:remove()
        end 
    end

    if #self.bubbles == 0 then
        _dialog_bubble:setCenter(0,1)
        _dialog_bubble:moveTo(playdate.display.getWidth()*0.5+12, pd.display.getHeight()*0.75)
        _dialog_bubble:setZIndex(3)
        _dialog_bubble:add()

        table.insert(self.bubbles, _dialog_bubble)
        table.insert(self.sprites, _dialog_bubble)
        return
    end

    local _w, _h = _dialog_bubble:getSize()
    _h += 5

    self.animating = true

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

            table.insert(self.bubbles, _dialog_bubble)
            table.insert(self.sprites, _dialog_bubble)

            self.animating = false
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

    self.animating = true
    if self.dialog_hidden then
        self.animating = true
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
            self.animating = false
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
            self.animating = false
            self.dialog_hidden = true
        end
    end
end

function Dialogue:animateSelectionBoxOut()
    local _timer = pd.timer.new(250, 0, self.selection_box.width, pd.easingFunctions.outCubic)
    _timer.updateCallback = function (timer)
        self.selection_box:moveTo(-timer.value, self.selection_box.y)
    end
    _timer.timerEndedCallback = function ()
        self.animating = false
        self.selection_box:moveTo(-self.selection_box.width, self.selection_box.y)
        self.selection_box:remove()
        self.selection_box = nil
    end
end

function Dialogue:animateSelectionBoxIn()
    local _timer = pd.timer.new(250, self.selection_box.width, 0, pd.easingFunctions.outCubic)
    _timer.updateCallback = function (timer)
        self.selection_box:moveTo(-timer.value, self.selection_box.y)
    end
    _timer.timerEndedCallback = function ()
        self.animating = false
        self.selection_box:moveTo(0, self.selection_box.y)
    end
end

function Dialogue:toggleDialogSelection()

    if not self.selection_box then
        return
    end

    self.animating = true
    if self.selection_box_hidden then
        local _timer = pd.timer.new(250, self.selection_box.width - 20, 0, pd.easingFunctions.outCubic)
        _timer.updateCallback = function (timer)
            self.selection_box:moveTo(-timer.value, self.selection_box.y)
        end
        _timer.timerEndedCallback = function ()
            self.animating = false
            self.selection_box_hidden = false
            self.selection_box:moveTo(0, self.selection_box.y)
        end
    else
        local _timer = pd.timer.new(250, 0, self.selection_box.width - 20, pd.easingFunctions.outCubic)
        _timer.updateCallback = function (timer)
            self.selection_box:moveTo(-timer.value, self.selection_box.y)
        end
        _timer.timerEndedCallback = function ()
            self.animating = false
            self.selection_box_hidden = true
            self.selection_box:moveTo(-(self.selection_box.width - 20), self.selection_box.y)
        end
    end
end

function Dialogue:initInputs()

    self.input_handlers = {

        cranked = function (change, acceleratedChange)
            if not self.animating and not self.dialog_hidden and #self.bubbles > 0 then
                local _a = change*0.25
                if self.scrolled + _a < 0 then
                    self:moveDialog(-self.scrolled)
                    self.scrolled = 0
                else
                    self:moveDialog(_a)
                    self.scrolled += _a
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

            if not self.animating then
                self:toggleDialogSelection()
            end

        end,

        rightButtonUp = function ()
            
            if not self.animating  then
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

            if self.animating or self.dialog_hidden then
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


function Dialogue:add()
    Dialogue.super.add(self)
    self.distort_timer_char = applyDistortionVCR(self.character)
    self.distort_timer_bg = applyDistortionVCR(self.character_bg)

end

function Dialogue:remove()
    Dialogue.super.remove(self)
    self.distort_timer_char:remove()
    self.distort_timer_char = nil

    self.distort_timer_bg:remove()
    self.distort_timer_bg = nil

    if self.selection_box then
        self.selection_box:remove()
    end
end
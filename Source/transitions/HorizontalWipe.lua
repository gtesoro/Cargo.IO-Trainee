local pd <const> = playdate
local gfx <const> = pd.graphics

class('Wipe').extends(gfx.sprite)

function Wipe:init(duration, dir, reversed)

    if g_SceneManager:getCurrentScene() and g_SceneManager:getCurrentScene():isa(System) then
        self.image = g_SceneManager:getCurrentScene():getCurrentBg()
    else
        self.image = gfx.image.new(400, 240, gfx.kColorBlack)
    end

    local _img = gfx.image.new(400, 240, gfx.kColorWhite)

    _img:addMask(true)

    inContext(_img:getMaskImage(), function ()
        g_SystemManager:getPlayer():getSiegelImage():drawAnchored(380,220, 1, 1)
    end)

    inContext(self.image, function ()
        _img:draw(0,0)
    end)

    self:setZIndex(TRANSITIONS_Z_INDEX)
    self:setIgnoresDrawOffset(true)
    self:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)

    self:setImage(self.image)

    -- if reversed then
    --     self:setImage(self.imageTable:getImage(15))
    --     local _animator = pd.timer.new(duration, self.imageTable:getLength(), 1, pd.easingFunctions.linear)
    --     _animator.updateCallback = function (timer)
    --         self:setImage(self.imageTable:getImage(clamp(math.floor(timer.value),1, self.imageTable:getLength())))
    --     end
    -- else
    --     self:setImage(self.imageTable:getImage(15))
    --     local _animator = pd.timer.new(duration, 1, self.imageTable:getLength(), pd.easingFunctions.linear)
    --     _animator.updateCallback = function (timer)
    --         self:setImage(self.imageTable:getImage(clamp(math.floor(timer.value),1, self.imageTable:getLength())))
    --     end
    -- end
    
    if dir == 'left' then
        if reversed then
            self:setClipRect(0,0, 401, 241)
            self.timer = pd.timer.new(duration, 401, 0, pd.easingFunctions.outQuint)
            self.timer.updateCallback = function(timer)
                self:setClipRect(0,0, timer.value, 241)
            end
        else
            self:setClipRect(401, 0, 401, 241)
            self.timer = pd.timer.new(duration, 401, 0, pd.easingFunctions.outQuint)
            self.timer.updateCallback = function(timer)
                self:setClipRect(timer.value, 0, 401, 241)
            end
        end
    end


    if dir == 'right' then
        if reversed then
            self:setClipRect(0,0, 401, 241)
            self.timer = pd.timer.new(duration, 0, 401, pd.easingFunctions.outQuint)
            self.timer.updateCallback = function(timer)
                self:setClipRect(timer.value,0, 401, 241)
            end
        else
            self:setClipRect(0, 0, 0, 241)
            self.timer = pd.timer.new(duration, 0, 401, pd.easingFunctions.outQuint)
            self.timer.updateCallback = function(timer)
                self:setClipRect(0, 0, timer.value, 241)
            end
        end
    end


    if dir == 'up' then
        if reversed then
            self:setClipRect(0,0, 401, 241)
            self.timer = pd.timer.new(duration, 241, 0, pd.easingFunctions.outQuint)
            self.timer.updateCallback = function(timer)
                self:setClipRect(0,0, 401, timer.value)
            end
        else
            self:setClipRect(0, 241, 401, 241)
            self.timer = pd.timer.new(duration, 241, 0, pd.easingFunctions.outQuint)
            self.timer.updateCallback = function(timer)
                self:setClipRect(0, timer.value, 401, 241)
            end
        end
    end

    if dir == 'down' then
        if reversed then
            self:setClipRect(0, 0, 401, 241)
            self.timer = pd.timer.new(duration, 0, 241, pd.easingFunctions.outQuint)
            self.timer.updateCallback = function(timer)
                self:setClipRect(0, timer.value, 401, 241)
            end
        else
            self:setClipRect(0,0, 401, 0)
            self.timer = pd.timer.new(duration, 0, 241, pd.easingFunctions.outQuint)
            self.timer.updateCallback = function(timer)
                self:setClipRect(0,0, 401, timer.value)
            end
        end
    end

    self.timer.timerEndedCallback = function(timer)
        if self.endCallback then
            self.endCallback()
        end
        self:remove()
    end

end
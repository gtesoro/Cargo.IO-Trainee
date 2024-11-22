local gfx <const> = playdate.graphics
local pd <const> = playdate

class('SceneManager').extends(playdate.graphics.sprite)

function SceneManager:init()

    self.scene_stack = {}

    self.transition_duration = 500
    self.transitioning = false

    local _initial_scene = Intro() --MiningLaser({bg_img = gfx.image.new(400, 240, gfx.kColorBlack)}) --
    _initial_scene:load()
    _initial_scene:focus()

    self.scene_stack[#self.scene_stack+1] = _initial_scene
    
    _initial_scene:add()

    self:add()

end

function SceneManager:getCurrentImageAsSprite()

    local _s = gfx.sprite.new(gfx.getDisplayImage())
    _s:setZIndex(0)
    _s:moveTo(200,120)
    return _s

end

function SceneManager:switchSceneStack(scene, duration)
    
    self.transitioning = true

    gfx.setDrawOffset(0, 0)
    g_NotificationManager:reset()

    local _t1 = Stack(duration, gfx.image.new(400,240, gfx.kColorBlack))
    
    _t1.endCallback = function ()    

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:unfocus()
            self.scene_stack[#self.scene_stack]:remove()
        end
        self.scene_stack[#self.scene_stack] = scene
        scene:load()
        scene:focus()
        scene:add()

        self.transitioning = false
    end

    _t1:add()

end

function SceneManager:switchSceneHWipe(scene, duration)

    local _t_in = HorizontalWipe(duration, 0, pd.display.getWidth())
    _t_in.endCallback = function ()
        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:unfocus()
            self.scene_stack[#self.scene_stack]:remove()
        end
        self.scene_stack[#self.scene_stack] = scene
        scene:load()
        scene:focus()
        scene:add()
        local _t_out = HorizontalWipe(duration, 0, pd.display.getWidth(), true)
        _t_out.endCallback = function ()
            self.transitioning = false
        end
        _t_out:add()
    end
    _t_in:add()

end

function SceneManager:pushSceneHWipe(scene, duration)

    self.transitioning = true

    local _t_in = HorizontalWipe(duration, 0, pd.display.getWidth())
    _t_in.endCallback = function ()
        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:unfocus()
            self.scene_stack[#self.scene_stack]:remove()
        end
        self.scene_stack[#self.scene_stack+1] = scene
        scene:load()
        scene:focus()
        scene:add()
        local _t_out = HorizontalWipe(duration, 0, pd.display.getWidth(), true)
        _t_out.endCallback = function ()
            self.transitioning = false
        end
        _t_out:add()
    end
    _t_in:add()

end

function SceneManager:pushSceneUnstack(scene, duration)

    local _t1 = Unstack(duration)

    self.transitioning = false

    if #self.scene_stack > 0 then
        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
    end
    self.scene_stack[#self.scene_stack+1] = scene
    scene:load()
    scene:focus()
    scene:add()
    
    _t1.endCallback = function ()    

        
    end

    _t1:add()

end

function SceneManager:pushSceneToMenu(scene, duration, blur)

    local _t1 = ToMenu(1000, blur)

    if #self.scene_stack > 0 then
        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
    end
    self.scene_stack[#self.scene_stack+1] = scene
    
    
    _t1.endCallback = function ()

        local _t2 = BetweenMenusIn(500)
        
        _t1.endCallback = function ()
            self.transitioning = false
        end
        _t2:add()
        scene:load()
        scene:focus()
        scene:add()
        
    end

    _t1:add()

end

function SceneManager:pushSceneStack(scene, duration, blur)

    local _t1 = Stack(duration, blur)

    if #self.scene_stack > 0 then
        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
    end
    self.scene_stack[#self.scene_stack+1] = scene
    scene:load()
    scene:focus()
    scene:add()
    
    _t1.endCallback = function ()    
        self.transitioning = false
    end

    _t1:add()

end

function SceneManager:pushSceneBetweenMenus(scene, duration, blur)

    local _t1 = BetweenMenusOut(500, blur)

    if #self.scene_stack > 0 then
        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
    end
    self.scene_stack[#self.scene_stack+1] = scene
    
    
    _t1.endCallback = function ()

        local _t2 = BetweenMenusIn(500)
        
        _t1.endCallback = function ()
            self.transitioning = false
        end
        _t2:add()
        scene:load()
        scene:focus()
        scene:add()
        
    end

    _t1:add()

end

function SceneManager:popSceneOutMenu(duration)
    local _t1 = BetweenMenusOut(500)

    _t1.endCallback = function ()

        local _t2 = OutMenu(1000)

        self.transitioning = false

        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
        table.remove(self.scene_stack, #self.scene_stack)

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:focus()
            self.scene_stack[#self.scene_stack]:add()
        end

        _t2:add()
        
    end

    _t1:add()
end

function SceneManager:popSceneBetweenMenus(duration)
    local _t1 = BetweenMenusOut(500)

    _t1.endCallback = function ()

        local _t2 = BetweenMenusIn(500)

        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
        table.remove(self.scene_stack, #self.scene_stack)

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:focus()
            self.scene_stack[#self.scene_stack]:add()
        end

        _t2:add()

    end

    _t1:add()
end

function SceneManager:popSceneUnstack(duration)
    local _t1 = Unstack(duration)

    self.transitioning = false

    self.scene_stack[#self.scene_stack]:unfocus()
    self.scene_stack[#self.scene_stack]:remove()
    table.remove(self.scene_stack, #self.scene_stack)

    if #self.scene_stack > 0 then
        self.scene_stack[#self.scene_stack]:focus()
        self.scene_stack[#self.scene_stack]:add()
    end

    _t1.endCallback = function ()
        
    end

    _t1:add()
end

function SceneManager:popSceneHWipe(duration)
    
    local _t_in = HorizontalWipe(duration, 0, pd.display.getWidth())

    _t_in.endCallback = function ()
        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
        table.remove(self.scene_stack, #self.scene_stack)
        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:focus()
            self.scene_stack[#self.scene_stack]:add()
        end
        local _t_out = HorizontalWipe(duration, 0, pd.display.getWidth(), true)
        _t_out.endCallback = function ()
            self.transitioning = false
        end
        _t_out:add()
    end
    _t_in:add()
end

function SceneManager:popScene(transition, duration)

    self.transitioning = true
    gfx.setDrawOffset(0, 0)
    g_NotificationManager:reset()

    if not duration then
        duration = self.transition_duration
    end

    if transition then
        if transition == 'stack' then
            self:popSceneStack(duration)
        elseif transition == 'hwipe' then
            self:popSceneHWipe(duration)
        elseif transition == 'unstack' then
            self:popSceneUnstack(duration/2)
        elseif transition == 'out menu' then
            self:popSceneOutMenu(duration)
        elseif transition == 'between menus' then
            self:popSceneBetweenMenus(duration)
        end
    else

        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
        table.remove(self.scene_stack, #self.scene_stack)
        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:focus()
            self.scene_stack[#self.scene_stack]:add()
        end
        self.transitioning = false
    end

    

end

function SceneManager:pushScene(scene, transition, duration)

    self.transitioning = true

    gfx.setDrawOffset(0, 0)
    g_NotificationManager:reset()

    if not duration then
        duration = self.transition_duration
    end

    if transition then
        if transition == 'stack' then
            self:pushSceneStack(scene, duration)
        elseif transition == 'stack blur' then
            self:pushSceneStack(scene, duration, true)
        elseif transition == 'hwipe' then
            self:pushSceneHWipe(scene, duration)
        elseif transition == 'unstack' then
            self:pushSceneUnstack(scene, duration/2)
        elseif transition == 'to menu' then
            self:pushSceneToMenu(scene, duration)
        elseif transition == 'between menus' then
            self:pushSceneBetweenMenus(scene, duration)
        end 
    else

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:unfocus()
            self.scene_stack[#self.scene_stack]:remove()
        end
        self.scene_stack[#self.scene_stack+1] = scene
        scene:load()
        scene:focus()
        scene:add()
        self.transitioning = false
    end

    

end

function SceneManager:switchScene(scene, transition, duration)

    self.transitioning = true

    if not duration then
        duration = self.transition_duration
    end

    if transition then
        if transition == 'stack' then
            self:switchhSceneStack(scene, duration)
        elseif transition == 'stack blur' then
            self:switchhSceneStack(scene, duration, true)
        elseif transition == 'hwipe' then
            self:switchSceneHWipe(scene, duration)
        else
            assert(false)
        end
        
    else

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:unfocus()
            self.scene_stack[#self.scene_stack]:remove()
        end
        self.scene_stack[#self.scene_stack] = scene
        scene:load()
        scene:focus()
        scene:add()
        self.transitioning = false
    end



end

function SceneManager:reset(scene)

    for k, v in pairs(self.scene_stack) do
        v:remove()
    end

    self.scene_stack = {}

end

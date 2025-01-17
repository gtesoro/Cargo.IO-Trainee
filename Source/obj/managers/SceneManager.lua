local gfx <const> = playdate.graphics
local pd <const> = playdate

class('SceneManager').extends()

function SceneManager:init()

    self.scene_stack = {}

    self.transition_duration = 600
    self.transitioning = false

    self.stack_unstack_duration = 700

    local _initial_scene = Intro() --MiningLaser({bg_img = gfx.image.new(400, 240, gfx.kColorBlack)}) --
    _initial_scene:load()
    _initial_scene:focus()

    self.scene_stack[#self.scene_stack+1] = _initial_scene
    
    _initial_scene:add()

    local _initial_scene = nil

end

function SceneManager:getCurrentImageAsSprite()

    local _s = gfx.sprite.new(gfx.getDisplayImage())
    _s:setZIndex(0)
    _s:moveTo(200,120)
    return _s

end

function SceneManager:getCurrentScene()
    return self.scene_stack[#self.scene_stack]
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
            self.scene_stack[#self.scene_stack]:clean()
        end
        self.scene_stack[#self.scene_stack] = scene
        collectGarbage()
        scene:load()
        scene:focus()
        scene:add()

        self.transitioning = false
    end

    _t1:add()

end

function SceneManager:switchSceneHWipe(scene, duration, dir)

    local _t_in = Wipe(duration, dir, false)
    _t_in.endCallback = function ()
        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:unfocus()
            self.scene_stack[#self.scene_stack]:remove()
            self.scene_stack[#self.scene_stack]:clean()
        end
        self.scene_stack[#self.scene_stack] = scene
        collectGarbage()
        scene:load()
        scene:focus()
        scene:add()
        local _t_out = Wipe(duration, dir, true)
        _t_out.endCallback = function ()
            self.transitioning = false
        end
        _t_out:add()
    end
    _t_in:add()

end

function SceneManager:pushSceneHWipe(scene, duration, dir)

    self.transitioning = true

    local _t_in = Wipe(duration, dir, false)
    _t_in.endCallback = function ()
        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:unfocus()
            self.scene_stack[#self.scene_stack]:remove()
        end
        self.scene_stack[#self.scene_stack+1] = scene
        scene:load()
        scene:focus()
        scene:add()
        local _t_out = Wipe(duration, dir, true)
        _t_out.endCallback = function ()
            self.transitioning = false
        end
        _t_out:add()
    end
    _t_in:add()

end

function SceneManager:pushSceneUnstack(scene, duration)

    local _t1 = Unstack(duration)

    _t1.endCallback = function ()    
        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:unfocus()
            self.scene_stack[#self.scene_stack]:remove()
        end
        self.scene_stack[#self.scene_stack+1] = scene
        self.transitioning = false

        scene:load()
        scene:focus()
        scene:add()

    end

    _t1:add()

end

function SceneManager:pushSceneToMenu(scene, duration, blur)

    local _t1 = ToMenu(duration, blur)

    if #self.scene_stack > 0 then
        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
    end
    self.scene_stack[#self.scene_stack+1] = scene
    
    
    _t1.endCallback = function ()

        local _t2 = BetweenMenusIn(duration/2)
        
        _t2.endCallback = function ()
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

    if #self.scene_stack > 0 then
        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
    end

    self.scene_stack[#self.scene_stack+1] = scene
    scene:load()
    scene:focus()
    scene:moveTo(200, -120)
    scene:add()

    local _t1 = Stack(duration, blur)
    
    _t1.endCallback = function ()    
        self.transitioning = false
    end

    _t1:add()

end

function SceneManager:pushSceneBetweenMenus(scene, duration, blur)

    local _t1 = BetweenMenusOut(duration/2, blur)

    if #self.scene_stack > 0 then
        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
    end
    self.scene_stack[#self.scene_stack+1] = scene
    
    
    _t1.endCallback = function ()

        local _t2 = BetweenMenusIn(duration/2)
        
        _t2.endCallback = function ()
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

    local _t1 = BetweenMenusOut(duration/2)

    _t1.endCallback = function ()

        local _t2 = OutMenu(duration)

        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
        self.scene_stack[#self.scene_stack]:clean()
        table.remove(self.scene_stack, #self.scene_stack)
        
        collectGarbage()

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:focus()
            self.scene_stack[#self.scene_stack]:add()
        end
        _t2.endCallback = function ()
            self.transitioning = false
        end
        _t2:add()
        
    end

    _t1:add()
end

function SceneManager:popSceneBetweenMenus(duration)
    local _t1 = BetweenMenusOut(duration/2)

    _t1.endCallback = function ()

        local _t2 = BetweenMenusIn(duration/2)

        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
        self.scene_stack[#self.scene_stack]:clean()
        table.remove(self.scene_stack, #self.scene_stack)

        collectGarbage()

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:focus()
            self.scene_stack[#self.scene_stack]:add()
        end

        _t2.endCallback = function ()
            self.transitioning = false 
        end
        _t2:add()

    end

    _t1:add()
end

function SceneManager:popSceneUnstack(duration)
    local _t1 = Unstack(duration)

    _t1.endCallback = function ()

        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
        self.scene_stack[#self.scene_stack]:clean()
        table.remove(self.scene_stack, #self.scene_stack)

        collectGarbage()

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:focus()
            self.scene_stack[#self.scene_stack]:add()
        end

        self.transitioning = false
        
    end

    _t1:add()
end

function SceneManager:popSceneHWipe(duration, dir)
    
    local _t_in = Wipe(duration, dir)

    _t_in.endCallback = function ()
        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
        self.scene_stack[#self.scene_stack]:clean()
        table.remove(self.scene_stack, #self.scene_stack)

        collectGarbage()

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:focus()
            self.scene_stack[#self.scene_stack]:add()
        end
        local _t_out = Wipe(duration, dir, true)
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
        elseif transition == 'wipe down' then
            self:popSceneHWipe(duration, 'down')
        elseif transition == 'unstack' then
            self:popSceneUnstack(self.stack_unstack_duration)   
        elseif transition == 'out menu' then
            self:popSceneOutMenu(duration)
        elseif transition == 'between menus' then
            self:popSceneBetweenMenus(500)
        end
    else

        self.scene_stack[#self.scene_stack]:unfocus()
        self.scene_stack[#self.scene_stack]:remove()
        self.scene_stack[#self.scene_stack]:clean()
        table.remove(self.scene_stack, #self.scene_stack)

        collectGarbage()

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:focus()
            self.scene_stack[#self.scene_stack]:add()
        end
        self.transitioning = false
    end

    print('Pop Scene Ends:',transition, #self.scene_stack)

end

function SceneManager:popToSystem(transition, duration)

    self.transitioning = true

    while not self:getCurrentScene():isa(System) do
        self:popScene()
    end

    self.transitioning = false

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
            self:pushSceneStack(scene, self.stack_unstack_duration)
        elseif transition == 'wipe down' then
            self:pushSceneHWipe(scene, duration, 'down')
        elseif transition == 'unstack' then
            self:pushSceneUnstack(scene, 250)
        elseif transition == 'to menu' then
            self:pushSceneToMenu(scene, 1000)
        elseif transition == 'between menus' then
            self:pushSceneBetweenMenus(scene, 500)
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

    print('Push Scene Ends:', #self.scene_stack)

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
        elseif transition == 'wipe left' then
            self:switchSceneHWipe(scene, duration, 'left')
        elseif transition == 'wipe right' then
            self:switchSceneHWipe(scene, duration, 'right')
        elseif transition == 'wipe down' then
            self:switchSceneHWipe(scene, duration, 'down')
        elseif transition == 'wipe up' then
            self:switchSceneHWipe(scene, duration, 'up')
        else
            assert(false)
        end
        
    else

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:unfocus()
            self.scene_stack[#self.scene_stack]:remove()
            self.scene_stack[#self.scene_stack]:clean()
        end
        self.scene_stack[#self.scene_stack] = scene

        collectGarbage()
        
        scene:load()
        scene:focus()
        scene:add()
        self.transitioning = false
    end

    print('Switch Scene Ends:', #self.scene_stack)
end

function SceneManager:reset(scene)

    for k, v in pairs(self.scene_stack) do
        self:popScene()
    end

end

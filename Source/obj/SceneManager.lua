import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "scenes/Intro"
import "scenes/StarSystem"
import "scenes/MiningLaser"
import "transitions/HorizontalWipe"
import "transitions/Unstack"
import "transitions/Stack"



local gfx <const> = playdate.graphics
local pd <const> = playdate

class('SceneManager').extends(playdate.graphics.sprite)

function SceneManager:init()

    self.scene_stack = {}

    self.transition_duration = 500
    self.transitioning = false

    local _initial_scene = MiningLaser()
    _initial_scene:load()

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

function SceneManager:pushSceneStack(scene, duration)

    self.transitioning = true
    local _t1 = Stack(duration, gfx.image.new(400,240, gfx.kColorBlack))
    
    _t1.endCallback = function ()    

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:remove()
        end
        self.scene_stack[#self.scene_stack+1] = scene
        scene:load()
        scene:add()

        self.transitioning = false
    end

    _t1:add()

end

function SceneManager:pushSceneHWipe(scene, duration)

    self.transitioning = true

    local _t_in = HorizontalWipe(duration, 0, pd.display.getWidth())
    _t_in.endCallback = function ()
        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:remove()
        end
        self.scene_stack[#self.scene_stack+1] = scene
        scene:load()
        scene:add()
        local _t_out = HorizontalWipe(duration, 0, pd.display.getWidth(), true)
        _t_out.endCallback = function ()
            self.transitioning = false
        end
        _t_out:add()
    end
    _t_in:add()

end


function SceneManager:pushScene(scene, transition, duration)

    if not duration then
        duration = self.transition_duration
    end

    if transition then
        if transition == 'stack' then
            self:pushSceneStack(scene, duration)
        elseif transition == 'hwipe' then
            self:pushSceneHWipe(scene, duration)
        end
    else

        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:remove()
        end
        self.scene_stack[#self.scene_stack+1] = scene
        scene:load()
        scene:add()

    end

end

function SceneManager:popSceneHWipe(duration)
    self.transitioning = true
    local _t1 = Unstack(duration)

    self.scene_stack[#self.scene_stack]:remove()
    table.remove(self.scene_stack, #self.scene_stack)

    if #self.scene_stack > 0 then
        self.scene_stack[#self.scene_stack]:add()
    end

    _t1.endCallback = function ()
        self.transitioning = false
    end

    _t1:add()
end

function SceneManager:popSceneHWipe(duration)
    self.transitioning = true
    
    local _t_in = HorizontalWipe(duration, 0, pd.display.getWidth())
    _t_in.endCallback = function ()
        self.scene_stack[#self.scene_stack]:remove()
        table.remove(self.scene_stack, #self.scene_stack)
        if #self.scene_stack > 0 then
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

    if not duration then
        duration = self.transition_duration
    end

    if transition then
        if transition == 'stack' then
            self:popSceneStack(duration)
        elseif transition == 'hwipe' then
            self:popSceneHWipe(duration)
        end
    else

        self.scene_stack[#self.scene_stack]:remove()
        table.remove(self.scene_stack, #self.scene_stack)
        if #self.scene_stack > 0 then
            self.scene_stack[#self.scene_stack]:add()
        end

    end

end


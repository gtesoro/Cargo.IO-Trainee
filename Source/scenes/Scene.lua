import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "CoreLibs/animator"
import "CoreLibs/sprites"
import "CoreLibs/math"

import "tools/tools"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Scene').extends(gfx.sprite)

function Scene:init(data)
    print(data)
    if data then
        self.data = data
    end
    self.sprites = {} 
end

function Scene:load()
    self:startScene()
end

function Scene:startScene()
end

function Scene:update()
    gfx.setDrawOffset(0,0)

    if g_SceneManager.transitioning then
        return
    end
end

function Scene:add()
    for k,v in pairs(self.sprites) do
        v:add()
    end
    Scene.super.add(self)

end

function Scene:remove()
    for k,v in pairs(self.sprites) do
        v:remove()
    end
    Scene.super.remove(self)

end
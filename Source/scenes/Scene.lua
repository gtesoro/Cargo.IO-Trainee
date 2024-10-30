local pd <const> = playdate
local gfx <const> = pd.graphics

class('Scene').extends(Widget)

function Scene:init(data)
    if data then
        self.data = data
    end
    self.loaded = false
    self.sprites = {} 
end

function Scene:load()
    if not self.loaded then
        self:startScene()
    end
    self.loaded = true
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
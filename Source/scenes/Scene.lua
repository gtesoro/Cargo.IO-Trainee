local pd <const> = playdate
local gfx <const> = pd.graphics

class('Scene').extends(Widget)

function Scene:init(data)
    if data then
        self.data = data
    end
    self.loaded = false
    self.sprites = List()
end

function Scene:load()
    if not self.loaded then
        self:startScene()
    end
    self.loaded = true
end

function Scene:unload()
    if self.loaded then
        self:stopScene()
    end
    self.loaded = false
end


function Scene:startScene()
end

function Scene:add()
    for v in self.sprites:iter() do
        v:add()
    end
    Scene.super.add(self)

end

function Scene:remove()
    for v in self.sprites:iter() do
        v:remove()
    end
    Scene.super.remove(self)

end
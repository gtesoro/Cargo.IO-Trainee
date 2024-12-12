local pd <const> = playdate
local gfx <const> = pd.graphics

class('Scene').extends(Widget)

function Scene:init(data)

    if data then
        self.data = data
    else
        self.data = {}
    end

    self.loaded = false
    self.sprites = List()

    self:setZIndex(0)

    self:moveTo(200, 120)
end

function Scene:moveTo(x , y)
    for spr in self.sprites:iter() do
        spr:moveBy(x - self.x, y - self.y)
    end
    Scene.super.moveTo(self, x, y)
end

function Scene:moveBy(x , y)
    for spr in self.sprites:iter() do
        spr:moveBy(x, y)
    end
    Scene.super.moveBy(self, x, y)
end

function Scene:setZIndex(z)
    for spr in self.sprites:iter() do
        spr:setZIndex(z - self:getZIndex() + spr:getZIndex())
    end
    Scene.super.setZIndex(self, z)
end

function Scene:preload()

end

function Scene:load()
    
    if not self.loaded then
        self:preload()
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
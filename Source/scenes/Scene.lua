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
    self.sprites = {}

    print('Scene Init', self.className)
    print('-- Data --')
    printTable(self.data)
    print('----------')
    
end

function Scene:moveTo(x , y)
    for k, spr in pairs(self.sprites) do
        spr:moveBy(x - self.x, y - self.y)
    end
    Scene.super.moveTo(self, x, y)
end

function Scene:moveBy(x , y)
    for k, spr in pairs(self.sprites) do
        spr:moveBy(x, y)
    end
    Scene.super.moveBy(self, x, y)
end

function Scene:setZIndex(z)
    for k, spr in pairs(self.sprites) do
        spr:setZIndex(z - self:getZIndex() + spr:getZIndex())
    end
    Scene.super.setZIndex(self, z)
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
    for k, v in pairs(self.sprites) do
        v:add()
    end
    Scene.super.add(self)

end

function Scene:remove()
    for k, v in pairs(self.sprites) do
        v:remove()
    end
    Scene.super.remove(self)

end

function Scene:clean()
    --print('Cleaning', self.className)
    for k, v in pairs(self.sprites) do
        v:remove()
        self.sprites[k] = nil
    end
    self.sprites = nil
end
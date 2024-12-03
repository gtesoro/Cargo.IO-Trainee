local pd <const> = playdate
local gfx <const> = pd.graphics

class('EmptySystem').extends(System)

function EmptySystem:startScene()
    
    EmptySystem.super.startScene(self)

    self:initEnemy()
end

function System:initEnemy()

    self.enemy = Enemy(self.ship)
    self.enemy:setZIndex(self.ship:getZIndex())
    self.enemy:add()
    self.enemy:moveTo(self.ship.x + 200, self.ship.y + 120)
    
    self.sprites:append(self.enemy)

end

function EmptySystem:doUpdate()

    if not self.enemy and math.random(0, 100) < 20 then
        self:initEnemy()
    end

    self.enemy:doUpdate()

    EmptySystem.super.doUpdate(self)

end

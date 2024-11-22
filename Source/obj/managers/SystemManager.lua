local pd <const> = playdate
local gfx <const> = playdate.graphics

class('SystemManager').extends(gfx.sprite)

function SystemManager:init()

    self.frame_counter = 0

    self.fading_grid = gfx.imagetable.new("assets/backgrounds/fading_grid")

    self:add()
    
end

function SystemManager:update()
    
    self.frame_counter += 1
    if self.frame_counter > 50 then
        self.frame_counter = 1
    end
end

function SystemManager:isTick(x)
    return math.fmod(self.frame_counter, x) == 0
end
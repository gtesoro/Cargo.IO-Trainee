local pd <const> = playdate
local gfx <const> = pd.graphics

class('Stateful').extends(Object)

function Stateful:init()
    self.state = {}
end

function Stateful:save()
    return {
        className = self.className,
        state = self.state
    }
end

function Stateful:load(state)
    self.state = state
end
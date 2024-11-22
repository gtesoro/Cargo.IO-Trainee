local pd <const> = playdate
local gfx <const> = playdate.graphics

class('CycleManager').extends(gfx.sprite)

function CycleManager:init()

    self.on_cycle = {}

    self.on_cycle['notify'] = function (cycle)
        g_NotificationManager:notify(string.format("Cycle %i", cycle))
    end

    self.cycle_length = 5

    self.cycle_timer = pd.timer.new(self.cycle_length*60*1000)
    self.cycle_timer.repeats = true

    self.cycle_timer.timerEndedCallback = function ()
        self:nextCycle()
    end

    self.cycle_timer:pause()
    
end

function CycleManager:pause()
    self.cycle_timer:pause()
end

function CycleManager:unpause()
    self.cycle_timer:start()
end

function CycleManager:nextCycle()
    
    g_player.cycle += 1

    for k, v in pairs(self.on_cycle) do
        v(g_player.cycle)
    end
end
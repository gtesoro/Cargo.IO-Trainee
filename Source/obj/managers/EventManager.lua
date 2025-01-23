local pd <const> = playdate
local gfx <const> = playdate.graphics

class('EventManager').extends()

function EventManager:init()

    self.events= {}
    
end

function EventManager:trigger(event, data)
    for k, subscriber in pairs(self.events[event]) do
        subscriber.callback(data)
        if subscriber.consume then
            break
        end
    end
end

function EventManager:subscribe(id, event, callback, priority, consume)

    if not self.events[event] then
        self.events[event] = {}
    end

    table.insert(self.events[event], {
        id = id,
        callback = callback,
        priority = priority or 99,
        consume = consume or false
    })

    table.sort(self.events[event], function (a, b)
        return a.priority < b.priority
    end)

end

function EventManager:unsubscribe(id, event)

    if not self.events[event] then
        self.events[event] = {}
    end

    for i=1, #self.events[event] do
        if self.events[event][i].id == id then
            table.remove(self.events[event], i)
            break
        end
    end

end

function EventManager:reset()

    self.events= {}

end


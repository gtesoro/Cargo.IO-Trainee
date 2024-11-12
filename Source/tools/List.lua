class("List").extends()

function List:init()

    self.first = nil
    self.length = 0
    
end

function List:get(idx)

    local c = self.first
    local _c = 1

    while c do
        if c and idx == _c then
            return c.value
        end 
        _c += 1
        c = c.next
    end

    return nil

end

function List:append(o)

    if not self.first then
        self.first = {next = nil, value = o}
    else

        local c = self.first
        local p = self.first

        while c do
            p = c
            c = c.next
        end

        p.next = {next = nil, value = o}

    end

    self.length += 1
    
end

function List:remove(o)
    

    if self.first and self.first.value == o then
        self.first = self.first.next
        self.length -= 1
        return
    end

    local c = self.first
    local p = self.first

    while c do
        if c.value == o then
            p.next = c.next
            self.length -= 1
            break
        end
        p = c
        c = c.next
    end
    
end

function List:iter()
    local c = self.first
    return function ()
        local ret = nil
        if c then
            ret = c.value
            c = c.next
        end
        return ret
    end
end
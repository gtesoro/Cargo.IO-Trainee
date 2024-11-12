local pd <const> = playdate
local gfx <const> = pd.graphics

class('Widget').extends(gfx.sprite)

function Widget:focus()
    self.focused = true

    if self.input_handlers then
        print('Setting inputs for:', self.className)
        pd.inputHandlers.push(self.input_handlers)
    end

    print('Focusing:', self.className)
end

function Widget:unfocus()
    self.focused = false

    if self.input_handlers then
        print('Popping inputs for:', self.className)
        pd.inputHandlers.pop()
    end

    print('Unfocusing:', self.className)

end

function Widget:hasFocus()

    if self.focus_next_check then
        self.focus_next_check = false
        return
    end

    if self.focused == nil then
        self.focused = false
    end

    return self.focused
end

function Widget:update()
    if self.x_offset and self.y_offset then
        gfx.setDrawOffset(-self.x_offset, -self.y_offset)
    else
        gfx.setDrawOffset(0, 0)
    end

    if g_SceneManager.transitioning then
        return
    end

    self:doUpdate()
    
end

function Widget:doUpdate()
    
end
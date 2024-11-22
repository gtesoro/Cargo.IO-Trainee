local pd <const> = playdate
local gfx <const> = pd.graphics

class('Widget').extends(gfx.sprite)

function Widget:init(data)
    if data then
        self.data = data
    else
        self.data = {}
    end
end

function Widget:focus()
    self.focused = true
    if self.input_handlers then
        pd.inputHandlers.push(self.input_handlers)
    end
end

function Widget:unfocus()
    self.focused = false

    if self.input_handlers then
        pd.inputHandlers.pop()
    end

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
    if g_SceneManager.transitioning then
        return
    end


    self:doUpdate()
    
end

function Widget:doUpdate()
    
end
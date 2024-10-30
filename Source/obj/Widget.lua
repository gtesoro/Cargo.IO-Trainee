local pd <const> = playdate
local gfx <const> = pd.graphics

class('Widget').extends(gfx.sprite)

function Widget:focus()
    self.focused = true
end

function Widget:unfocus()
    self.focused = false
end

function Widget:hasFocus()

    if self.focused == nil then
        self.focused = false
    end

    return self.focused
end
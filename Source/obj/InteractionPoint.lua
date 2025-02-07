local pd <const> = playdate
local gfx <const> = pd.graphics

local _interaction_point_functions = {
    computer01 = function ()
        local _diag = {
            {
                file = 'assets/backgrounds/ship01',
                type = DIAG_BG_IN,
                continue = true
            },
            {
                text = "At the back of the ship, you see a computer node that seems to be active.\nAs you get closer you can make out a message on the screen.",
                type = DIAG_DESC
            },
            {
                file = 'assets/characters/computer',
                type = DIAG_CHAR_IN,
                continue = true
            },
            {
                text = "Please input activation code",
                type = DIAG_OTHER,
            },
            {
                type = DIAG_INPUT_TEXT,
                default = {
                    {
                        text = "Activation code not recognized. Exiting...",
                        type = DIAG_OTHER
                    }
                },
                options = {
                    {
                        answer = '123',
                        dialogue = {
                            {
                                text = "Activation code matches database records.\nActivating...",
                                trigger = function ()
                                    g_NotificationManager:notify("Door opened")
                                end,
                                type = DIAG_OTHER
                            }
                        }
                    }
                }
            }
            
        }
    
        g_SceneManager:pushScene(Dialogue({dialogue = _diag}), 'to menu')
    end
}

class('InteractionPoint').extends(gfx.sprite)

function InteractionPoint:init(func_name, w, h)

    self:setImage(gfx.image.new(w or 16, h or 16))

    self:setCollideRect(0,0, self:getSize())
    self.interactuable = true

    self.funct = _interaction_point_functions[func_name]

end

function InteractionPoint:interact()
    self.funct()
end
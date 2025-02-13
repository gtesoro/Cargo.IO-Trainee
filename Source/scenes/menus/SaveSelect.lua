local pd <const> = playdate
local gfx <const> = pd.graphics

class('SaveSelect').extends(GenericMenuList)

function SaveSelect:getOption(name, slot)

    return {
        name = name,
        sprite = function ()
            local _text = "New Game"
            if g_SystemManager.meta.saves and g_SystemManager.meta.saves[slot] then
                _text = string.format('System:\n  %s\nCredits:\n  %s',g_SystemManager.meta.saves[slot].system, g_SystemManager.meta.saves[slot].credits)
            end 
            return gfx.sprite.new(
                gfx.imageWithText(
                    _text, 200, 200, gfx.kColorWhite
                )
            )
        end,
        callback = function ()
            if g_SystemManager.meta.saves and g_SystemManager.meta.saves[slot] then
                g_SystemManager:load(slot)
                g_SoundManager:stopComputerHum()
                g_SoundManager:playDegauss()
                g_SoundManager:playMenuSwitch()
                goTo(g_SystemManager:getPlayer().current_position.x, g_SystemManager:getPlayer().current_position.y, g_SystemManager:getPlayer().current_position.z, nil, true)
            else
                g_SceneManager:pushScene(NewGame(slot), 'between menus')
            end
        end
    }
    
end

function SaveSelect:init()

    SaveSelect.super.init(self)

    self.data = {}

    self.b_callback = function ()
        g_SoundManager:stopComputerHum()
    end

    self.data.options = {

        self:getOption("Slot 1", SAVE_SLOT_1),
        self:getOption("Slot 2", SAVE_SLOT_2),
        self:getOption("Slot 3", SAVE_SLOT_3)
    }

end


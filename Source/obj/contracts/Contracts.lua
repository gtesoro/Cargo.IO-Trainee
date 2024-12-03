local pd <const> = playdate
local gfx <const> = pd.graphics

class('Contract').extends(Stateful)

function Contract:init()

    Contract.super.init(self)

    self.name = nil
    self.start = nil
    self.duration = nil

    self.save_name = 'clone'

end

class('Cloning').extends(Contract)

function Cloning:init()

    Cloning.super.init(self)

    self.name = "Cloning"
    self.start = nil
    self.duration = 10

    self.sign_price = 500

    self.contract_text = string.format("Upon payment of %iC and for a duration of %i Cycles from signature's date, in case of contractee's death, a clone will be produced at a Namaste Cloning facility.\nThe contract holder will be able to update their clone memories on any Namaste Cloning facility without additional cost.", self.sign_price, self.duration)

    self.provider = "Namaste Cloning Inc."

end

function Cloning:getIcon()

    return gfx.sprite.new(gfx.image.new('assets/menus/cloning'))--TextBox(self.description, 150, 150)
    
end

function Cloning:getContractImage()
    

    local img = gfx.image.new('assets/contracts/contract_base')
    inContext(img, function ()

        gfx.setFont(g_font_24)

        gfx.drawTextAligned(self.name, img.width/2, img.height*0.05, kTextAlignment.center)
        
        gfx.setFont(g_font_14)

        local _system_coords = string.format("%i.%i.%i", g_SystemManager:getPlayer().current_position.x, g_SystemManager:getPlayer().current_position.y, g_SystemManager:getPlayer().current_position.z)
        local _system_name = "Unknown"
        if g_SystemManager:getSystems()[_system_coords] then
            _system_name = g_SystemManager:getSystems()[_system_coords].name
        end
        local _cycle = g_SystemManager:getPlayer().cycle

        if self.state.sign_system then
            _system_name = self.state.sign_system
        end

        if self.state.sign_cycle then
            _cycle = self.state.sign_cycle
        end

        gfx.drawTextAligned(string.format('%s, Cycle %i', _system_name, _cycle), img.width*0.90, img.height*0.15, kTextAlignment.right)

        gfx.setFont()

        gfx.setLineWidth(5)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawLine(img.width*0.1, img.height*0.20, img.width*0.9, img.height*0.20)

        gfx.drawTextInRect(self.contract_text, img.width*0.1, img.height*0.30, img.width*0.8, img.height*0.60)

        gfx.setFont(g_font_14)
        gfx.drawTextAligned(self.provider, img.width*0.1, img.height*0.9, kTextAlignment.left)
        
    end)

    return img
    
end

function Cloning:getSignPrice()
    return self.sign_price
    
end

function Cloning:load(state)

    Cloning.super.load(self, state)
    self:onGain()
end

function Cloning:onSign()

    local _system_coords = string.format("%i.%i.%i", g_SystemManager:getPlayer().current_position.x, g_SystemManager:getPlayer().current_position.y, g_SystemManager:getPlayer().current_position.z)
    local _system = g_SystemManager:getSystems()[_system_coords]

    self.state.sign_system = _system.name
    self.state.sign_date = g_SystemManager:getPlayer().cycle

end

function Cloning:onGain()

    g_SystemManager.on_death[self.name] = function ()
        self:onDeath()
    end

end

function Cloning:onLose()

    g_SystemManager.on_death[self.name] = nil

end

function Cloning:updateMemory()
    g_SystemManager:save(self.save_name)
    g_NotificationManager:notify('Clone Memory Updated')
end

function Cloning:onDeath()
    g_SystemManager:load(self.save_name)
    g_SceneManager:reset()
    g_NotificationManager:notify('Clone Deployed')
    goTo(g_SystemManager:getPlayer().current_position.x, g_SystemManager:getPlayer().current_position.y, g_SystemManager:getPlayer().current_position.z, true)
end
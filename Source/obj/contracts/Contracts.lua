local pd <const> = playdate
local gfx <const> = pd.graphics

class('Contract').extends(Stateful)

function Contract:init()

    Contract.super.init(self)

    self.name = 'Contract-Name'
    self.start = 1
    self.duration = 999
    self.provider = 'Contract-provider'
    self.contract_text = 'Contract-text'
    self.sign_price  = 0

end

function Contract:generate()

end

function Contract:getIcon()
    if self.icon then
        return self.icon
    else
        local _icon = self:getContractImage()
        return gfx.sprite.new(_icon:scaledImage(150/_icon.height))
    end
end

function Contract:getSignPrice()
    return self.sign_price
end

function Contract:getContractImage()
    

    local img = gfx.image.new('assets/contracts/contract_base')
    inContext(img, function ()

        gfx.setFont(g_font_24)

        gfx.drawTextAligned(self.name, img.width/2, img.height*0.05, kTextAlignment.center)
        
        gfx.setFont(g_font_14)

        _system_name = g_SystemManager:getPlayer():getCurrentSystem().data.name
        local _cycle = g_SystemManager:getPlayer().cycle

        if self.state.sign_system then
            _system_name = self.state.sign_system
        end

        if self.state.sign_cycle then
            _cycle = self.state.sign_cycle
        end

        gfx.drawTextAligned(string.format('%s, Cycle %i', _system_name, _cycle), img.width*0.90, img.height*0.15, kTextAlignment.right)

        gfx.setFont(gfx.font.new('font/Full Circle/font-full-circle'))

        gfx.setLineWidth(5)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawLine(img.width*0.1, img.height*0.20, img.width*0.9, img.height*0.20)

        gfx.drawTextInRect(self.contract_text, img.width*0.1, img.height*0.30, img.width*0.8, img.height*0.60)

        gfx.setFont(g_font_14)
        gfx.drawTextAligned(self.provider, img.width*0.1, img.height*0.9, kTextAlignment.left)

        if self.state.signed then
            gfx.image.new('assets/contracts/contract_stamp'):drawAnchored(img.width*0.8, img.height*0.9, 0.5, 0.5)
        end
        
    end)

    return img
    
end

function Contract:load(state)
    Contract.super.load(self, state)
    self:onGain()
end

function Contract:onGain()
    
end

function Contract:onSign()

    local _system_coords = string.format("%i.%i.%i", g_SystemManager:getPlayer().current_position.x, g_SystemManager:getPlayer().current_position.y, g_SystemManager:getPlayer().current_position.z)
    local _system = g_SystemManager:getSystems()[_system_coords]

    self.state.sign_system = _system.name
    self.state.sign_date = g_SystemManager:getPlayer().cycle
    self.state.signed = true

end

class('CloningContract').extends(Contract)

function CloningContract:init()

    CloningContract.super.init(self)

    self.name = "Cloning"
    self.duration = 10

    self.save_name = 'clone'

    self.sign_price = 500

    self.contract_text = string.format("Upon payment of %iC and for a duration of %i Cycles from signature's date, in case of contractee's death, a clone will be produced at a Namaste Cloning facility.\nThe contract holder may update its clone memories on any Namaste Cloning facility without additional cost.", self.sign_price, self.duration)

    self.provider = "Namaste Cloning Inc."

    self.icon = gfx.sprite.new(gfx.image.new('assets/menus/cloning'))

end


function CloningContract:onGain()

    g_SystemManager.on_death[self.name] = function ()
        self:onDeath()
    end

end

function CloningContract:onLose()

    g_SystemManager.on_death[self.name] = nil

end

function CloningContract:updateMemory()
    g_SystemManager:save(self.save_name)
    g_NotificationManager:notify('Clone Memory Updated')
end

function CloningContract:onDeath()
    g_SystemManager:load(self.save_name)
    g_SceneManager:reset()
    g_NotificationManager:notify('Clone Deployed')
    goTo(g_SystemManager:getPlayer().current_position.x, g_SystemManager:getPlayer().current_position.y, g_SystemManager:getPlayer().current_position.z)
end

class('DeliveryContract').extends(Contract)

function DeliveryContract:init()

    DeliveryContract.super.init(self)

    self.name = "Delivery"
    self.provider = "Quick Lock Corporation"

    self.contract_text = "Upon signing, the contractee commits to deliver the provided cargo to:\n  - %s, %s\nbefore Cycle %i in exchange for:\n  - %i Credits\nThis amount will be paid upon delivery of the cargo to its destination.\nDamaging, losing or stealing the provided cargo will be punished by law."
                                        
end

function DeliveryContract:generateLocalContract()

    local _current_system = g_SystemManager:getPlayer():getCurrentSystem()

    math.randomseed(g_SystemManager:getPlayer().cycle + stringToSeed(_current_system.data.name))

    local _planets = _current_system.data.planets

    self.state.destination_system = _current_system.data
    self.state.destination = _planets[math.random(1, #_planets)]
    self.state.length = math.random(1,2)
    self.state.reward = math.random(50, 100)

    self.contract_text = self:renderText()

    
end

function DeliveryContract:renderText()

    return string.format(self.contract_text, self.state.destination.name, 
                                                           self.state.destination_system.name,
                                                           g_SystemManager:getPlayer().cycle+self.state.length,
                                                           self.state.reward 
                                      )

end

function DeliveryContract:load(state)
    DeliveryContract.super.load(self, state)

    self.contract_text = self:renderText()
end

function DeliveryContract:generate()
    self:generateLocalContract()
end

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
        local _icon = self:getContractImage(gfx.kColorWhite)
        return gfx.sprite.new(_icon:scaledImage(150/_icon.height))
    end
end

function Contract:getSignPrice()
    return self.sign_price
end

function Contract:getContractImage(bg)

    local _bg = bg or gfx.kColorClear

    local _img_width = 300

    local _x_margin = 20

    local _header = gfx.image.new(_img_width, 80)
    inContext(_header, function ()

        local _current_y = 10
        gfx.setFont(g_font_24)

        local _w, _h = gfx.getTextSizeForMaxWidth(self.name, _img_width - _x_margin*2)
        gfx.drawTextInRect(self.name, _x_margin, _current_y, _img_width - _x_margin*2, _h, nil, nil, kTextAlignment.center)

        _current_y += _h + 10
        
        gfx.setFont(g_font_text_bold)

        local _system_name = 'Ruhe'

        if g_SystemManager:getPlayerData():getCurrentSystem() then
            _system_name = g_SystemManager:getPlayerData():getCurrentSystem():getName()
        end

        local _cycle, _time = g_SystemManager:getCycle()

        if self.state.sign_system then
            _system_name = self.state.sign_system
        end

        if self.state.sign_date then
            _cycle = self.state.sign_date
        end

        local _text = table.concat({_system_name,', Cycle ', _cycle})
        local _w, _h = gfx.getTextSizeForMaxWidth(_text, _img_width - _x_margin*3)
        gfx.drawTextInRect(_text, _x_margin*1.5, _current_y, _img_width - _x_margin*3, _h, nil, nil, kTextAlignment.right)

        _current_y += _h + 6

        gfx.setLineWidth(4)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.drawLine(_x_margin, _current_y, _img_width - _x_margin, _current_y)
    end)

    local _footer = gfx.image.new(_img_width, 90, _bg)
    inContext(_footer, function ()

        gfx.setLineWidth(4)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.drawLine(_x_margin, 2, _img_width - _x_margin, 2)

        gfx.setFontFamily(g_font_text_family)

        local _current_y = 10
        gfx.setFont(g_font_text_bold)
        local _w, _h = gfx.getTextSizeForMaxWidth(self.provider, _img_width - _x_margin*3)
        gfx.drawTextInRect(self.provider, _x_margin*1.5, _current_y, (_img_width - _x_margin*3)/2, _h, nil, nil, kTextAlignment.left)

        if self.state.signed then
            g_SystemManager:getPlayerData():getSiegelImage():drawAnchored(_img_width - _x_margin*1.5, _current_y, 1, 0)
        end
        
    end)

    gfx.setFontFamily(g_font_text_family)
    local _w, _h = gfx.getTextSizeForMaxWidth(self.contract_text, _img_width - _x_margin*3)
    local img = gfx.image.new(_img_width, _header.height + _h + _footer.height + 20, _bg)
    inContext(img, function ()

        _header:draw(0,0)

        local _current_y = 10 + _header.height

        gfx.setFontFamily(g_font_text_family)
        local _w, _h = gfx.getTextSizeForMaxWidth(self.contract_text, _img_width - _x_margin*3)
        gfx.drawTextInRect(self.contract_text, _x_margin*1.5, _current_y, _img_width - _x_margin*3, _h, nil, nil, kTextAlignment.left)

        _current_y += _h + 10

        _footer:draw(0,_current_y)

        --gfx.drawRect(0,0, img:getSize())
        
    end)

    return img
    
end

function Contract:load(state)
    Contract.super.load(self, state)
end

function Contract:onGain()
    
end

function Contract:onLose()

end

-- function Contract:onCancel()

--     if g_SystemManager:getPlayerData():hasContract(self) then
--         g_SceneManager:pushScene(Popup({text='Cancel Contract?', options={
--             {
--                 name='Yes',
--                 callback= function ()
--                     g_NotificationManager:notify(string.format("Contract Canceled: %s", self.name))
--                     self:onLose()
--                     g_SystemManager:getPlayerData():removeContract(self)
--                     g_SceneManager:popScene('between menus')
--                 end
--             },
--             {
--                 name='No'
--             }
--         }}))
--         return true
--     end
--         return false
-- end

function Contract:canSign()
    return true
end

function Contract:onSign()

    local _system = 'Ruhe'
    if g_SystemManager:getPlayerData():getCurrentSystem() then
        _system = g_SystemManager:getPlayerData():getCurrentSystem().name
    end

    self.state.sign_system = _system
    self.state.sign_date, self.state.sign_time = g_SystemManager:getCycle()
    self.state.signed = true

end

function Contract:getOptions()

    return {
        {
            name = "View",
            callback = function ()
                g_SceneManager:pushScene(ImageViewer({image=gfx.sprite.new(self:getContractImage())}), "between menus")
            end
        }
    }
end

class('WanderlustContract').extends(Contract)

function WanderlustContract:init()

    WanderlustContract.super.init(self)

    self.name = "Wanderlust"
    self.duration = 1000

    self.contract_text = [[
Lore ipsum bla blaba
This is just some placeholdcer
There will be constraints
]]
    self.provider = "Ruhe"

end

class('CloningContract').extends(Contract)

function CloningContract:init()

    CloningContract.super.init(self)

    self.name = "Cloning"
    self.duration = 100

    self.save_name = 'clone'

    self.sign_price = 500

    self.contract_text = string.format("Upon payment of %iC and for a duration of %i Cycles from signature's date, in case of contractee's death, a clone will be produced at a Namaste Cloning facility.\nThe contract holder may update its clone memories on any Namaste Cloning facility without additional cost.", self.sign_price, self.duration)

    self.provider = "Namaste Cloning Inc."

    self.icon = gfx.sprite.new(gfx.image.new('assets/menus/cloning'))

end

function CloningContract:cycleCheck(cycle)
    if cycle >= self.state.sign_date + self.duration then
        g_NotificationManager:notify('Cloning Contract Expired')
        g_SystemManager:getPlayerData():removeContract(self)
        self:onLose()
    end
end

function CloningContract:load(state)

    CloningContract.super.load(self, state)

    self:onGain()

end

function CloningContract:canSign()
    return g_SystemManager:getPlayerData():chargeMoney(self:getSignPrice())
end


function CloningContract:onGain()

    g_EventManager:subscribe(self.name, EVENT_DEATH, function ()
        self:onDeath()
    end, 0, true)


    g_EventManager:subscribe(self.name, EVENT_NEXT_CYCLE, function (cycle)
        self:cycleCheck(cycle)
    end)

end

function CloningContract:onLose()

    g_EventManager:unsubscribe(self.name, EVENT_DEATH)
    g_EventManager:unsubscribe(self.name, EVENT_NEXT_CYCLE)

end

function CloningContract:updateMemory()
    g_SystemManager:save(self.save_name)
    g_NotificationManager:notify('Clone Memory Updated')
end

function CloningContract:onDeath()
    g_SystemManager:load(self.save_name)
    g_SceneManager:reset()
    g_NotificationManager:notify('Clone Deployed')
    goTo(g_SystemManager:getPlayerData().current_position.x, g_SystemManager:getPlayerData().current_position.y, g_SystemManager:getPlayerData().current_position.z)
end

class('DeliveryContract').extends(Contract)

function DeliveryContract:init()

    DeliveryContract.super.init(self)

    self.name = "Delivery"
    self.provider = "Quick Lock Corporation"

    self.contract_text = [[
Upon signing, the contractee commits to deliver the provided cargo to:
  - *%s* (%s)
before the end of *Cycle %i* in exchange for:  
  - *%i* Credits
upon delivery. 
Delays will have penalties on the reward amount.
Damaging, loosing or stealing the provided cargo will be fined with half of the contractee's net worth.
]]
                                        
end

function DeliveryContract:generateLocalContract()

    local _current_system = g_SystemManager:getPlayerData():getCurrentSystem()

    math.randomseed(g_SystemManager:getPlayerData().cycle + stringToSeed(_current_system.data.name))

    local _locations = _current_system.locations

    self.state.destination_system = _current_system.data
    self.state.destination = _locations[math.random(1, #_locations)].location_data

    while self.state.destination == g_SystemManager:getPlayerData():getCurrentLocation() do
        self.state.destination = _locations[math.random(1, #_locations)].location_data
    end
    self.state.length = 1
    self.state.reward = math.random(50, 100)
    if g_SystemManager:getGlobalState().ql_number == nil then
        g_SystemManager:getGlobalState().ql_number = 1
    else
        g_SystemManager:getGlobalState().ql_number += 1
    end
    self.state.number = g_SystemManager:getGlobalState().ql_number
    self.name = string.format("%s #%i", self.name, self.state.number)
    self.contract_text = self:renderText()

end

function DeliveryContract:generateSystemContract()

    local _current_system = g_SystemManager:getPlayerData():getCurrentSystem()

    math.randomseed(g_SystemManager:getPlayerData().cycle + stringToSeed(_current_system.data.name))

    local _possible_systems = {}

    for k, _sys in pairs(g_SystemManager:getSystems()) do
        if _sys.name ~= _current_system.data.name and _sys.locations and _sys.z == _current_system.data.z then
            for k, _loc in pairs(_sys.locations) do
                if tableHasElement(_loc.facilities, FACILITY_CARGO) then
                    table.insert(_possible_systems, _sys)
                end
                break
            end
        end
    end

    self.state.destination_system = _possible_systems[math.random(1, #_possible_systems)] 

    local _possible_locations = {}

    for k, _loc in pairs(self.state.destination_system.locations) do
        if tableHasElement(_loc.facilities, FACILITY_CARGO) then
            table.insert(_possible_locations, _loc)
        end
    end

    self.state.destination = _possible_locations[math.random(1, #_possible_locations)]

    self.state.length = math.floor((math.abs(_current_system.data.x - self.state.destination_system.x) + math.abs(_current_system.data.y - self.state.destination_system.y))/2)
    self.state.reward = math.random(200, 500)
    if g_SystemManager:getGlobalState().ql_number == nil then
        g_SystemManager:getGlobalState().ql_number = 1
    end
    self.state.number = g_SystemManager:getGlobalState().ql_number
    self.name = string.format("%s #%i", self.name, self.state.number)
    self.contract_text = self:renderText()

end

function DeliveryContract:onSign()
    DeliveryContract.super.onSign(self)
    g_SystemManager:getGlobalState().ql_number += 1
end

function DeliveryContract:renderText()

    return string.format(self.contract_text, 
                         self.state.destination.name, 
                         self.state.destination_system.name,
                         g_SystemManager:getPlayerData().cycle+self.state.length,
                         self.state.reward)

end

function DeliveryContract:canSign() 
    return g_SystemManager:getPlayerData():freeInventory() > 1
end

function DeliveryContract:onGain()
    g_SystemManager:getPlayerData():addToInventory(QlCargo(self.state.destination))
end

function DeliveryContract:onComplete()
    self.state.completed = true
    
    local _reward = self.state.reward
    if self.state.sign_date + self.state.length < g_SystemManager:getPlayerData().cycle then
        local _diff = g_SystemManager:getPlayerData().cycle - (self.state.sign_date + self.state.length)
        g_NotificationManager:notify(string.format("Late Penalty: -%i", _reward - math.floor(_reward/(2 ^ _diff))))
        _reward = math.floor(_reward/(2 ^ _diff))
    end
    g_NotificationManager:notify(string.format("Contract Completed: %s", self.name))
    g_SystemManager:getPlayerData():gainMoney(_reward)
end

function DeliveryContract:load(state)
    DeliveryContract.super.load(self, state)

    self.contract_text = self:renderText()
    self.name = string.format("%s #%i", self.name, self.state.number)
end

function DeliveryContract:generate()
    self:generateLocalContract()
end

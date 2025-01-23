local gfx <const> = playdate.graphics
local pd <const> = playdate

class('SoundManager').extends()

function SoundManager:init()
    self.engine_sample = pd.sound.sampleplayer.new('assets/sounds/engine')
    self.engine_sample:setVolume(0)
    self.engine_volume = 1
    self.engine_fade = 1000

    self.radio = pd.sound.fileplayer.new("assets/music/Im_Gonna_Get_Me_A_Man_Thats_All", 10)
    self.radio:setVolume(0.5)

    self.menu_list_change = pd.sound.sampleplayer.new('assets/sounds/menu_list_change')
    self.menu_list_change:setVolume(0.6)

    self.pop_up_in = pd.sound.sampleplayer.new('assets/sounds/popup_in')
    self.pop_up_in:setVolume(0.5)

    self.pop_up_out = pd.sound.sampleplayer.new('assets/sounds/popup_out')
    self.pop_up_out:setVolume(0.5)

    self.stamp = pd.sound.sampleplayer.new('assets/sounds/stamp')
    self.stamp:setVolume(1)

    self.switch = pd.sound.sampleplayer.new('assets/sounds/switch')
    self.switch:setVolume(0.6)

    self.degauss = pd.sound.sampleplayer.new('assets/sounds/degauss')
    self.degauss:setVolume(0.6)

    self.click = pd.sound.sampleplayer.new('assets/sounds/click')
    self.click:setVolume(1)

    self.notification = pd.sound.sampleplayer.new('assets/sounds/notification')
    self.notification:setVolume(0.5)

    self.notification_ding = pd.sound.sampleplayer.new('assets/sounds/notification_ding')
    self.notification_ding:setVolume(0.5)

    self.computer_hum = pd.sound.sampleplayer.new('assets/sounds/cassete_hum')
    self.computer_hum:setVolume(0.2)

    self.choking = pd.sound.sampleplayer.new('assets/sounds/choking')
    self.choking:setVolume(1)
    
    self.spacebar = pd.sound.sampleplayer.new('assets/sounds/spacebar')
    self.spacebar:setVolume(0.1)

    self.gears = pd.sound.sampleplayer.new('assets/sounds/gears')
    self.gears:setVolume(1)

    self.key_presses = {}
    table.insert(self.key_presses, pd.sound.sampleplayer.new(string.format('assets/sounds/key_press_01')))
    table.insert(self.key_presses, pd.sound.sampleplayer.new(string.format('assets/sounds/key_press_02')))
    table.insert(self.key_presses, pd.sound.sampleplayer.new(string.format('assets/sounds/key_press_03')))

end

function SoundManager:playGears()
    self.gears:play()
end

function SoundManager:playSpacebar()
    self.spacebar:setVolume(math.random(5, 30)/100)
    self.spacebar:play()
end

function SoundManager:playKeyPress()
    local _k = self.key_presses[math.random(1,3)]
    _k:setVolume(math.random(50, 100)/100)
    _k:play()
end

function SoundManager:playBeginTransmission()

    local _s = pd.sound.sampleplayer.new(string.format('assets/sounds/begin_transmission'))
    _s:setVolume(1)

    _s:play()
end

function SoundManager:playEndTransmission()

    local _s = pd.sound.sampleplayer.new(string.format('assets/sounds/end_transmission'))
    _s:setVolume(0.5)

    _s:play()
end

function SoundManager:playNotificationDing(duration)

    self.notification_ding:play()
end

function SoundManager:playNotification(duration)

    self.notification:play()

    -- local _attack, _decay, _sustain, _release = 0.3, 0, 0.5, 0.4
    -- duration = duration or 500
    -- local _freq = 1800

    -- -- Initialize a new synth
    -- local synth = pd.sound.synth.new(playdate.sound.kLFOSine)
    -- local lfo = pd.sound.lfo.new(playdate.sound.kLFOSine)
    -- lfo:setDepth(0.25)
    -- lfo:setRate(24000)

    -- synth:setADSR(_attack, _decay, _sustain, _release)
    -- synth:setFrequencyMod(lfo)


    -- -- Play the sound
    -- synth:playNote(_freq)
    -- local _timer = pd.timer.new(_attack + duration +_decay)
    -- _timer.timerEndedCallback = function ()
    --     synth:noteOff()
    -- end
    
end

function SoundManager:playSpaceBg()
    local _freq = 500

    if not self.space_noise then
        local space_channel = pd.sound.channel.new()

        local _attack, _decay, _sustain, _release = 0.1, 0.6, 0.5, 1
        duration = duration or 500
        

        -- Initialize a new synth
        self.space_noise = pd.sound.synth.new(playdate.sound.kWaveNoise)
        local filter = pd.sound.twopolefilter.new(pd.sound.kFilterLowPass)
        filter:setFrequency(300)
        filter:setResonance(0.5)

        self.space_noise:setADSR(_attack, _decay, _sustain, _release)

        -- Play the sound
        space_channel:addEffect(filter)
        space_channel:addSource(self.space_noise)
    end

    self.space_noise:playNote(_freq, 0.1)

end

function SoundManager:stopSpaceBg()
    self.space_noise:noteOff()
end

function SoundManager:playPopupIn()
    self.pop_up_in:play()
end

function SoundManager:playPopupOut()
    self.pop_up_out:play()
end

function SoundManager:playComputerHum()
    self.computer_hum:play(0)
end

function SoundManager:stopComputerHum()
    self.computer_hum:stop()
end

function SoundManager:playChoking()
    self.choking:play(1)
end

function SoundManager:playDegauss()
    self.degauss:play(1)
end

function SoundManager:playMenuSwitch()
    self.switch:play(1)
end

function SoundManager:playStamp()
    self.stamp:play(1)
end

function SoundManager:playClick()
    self.click:play(1)
end

function SoundManager:playMenuListChange()
    self.menu_list_change:play(1)
end

function SoundManager:playEngine()
    if self.engine_fade_in then 
        self.engine_fade_in:remove()
    end

    if self.engine_fade_out then 
        self.engine_fade_out:remove()
    end

    self.engine_fade_in = pd.timer.new(self.engine_fade, 0, self.engine_volume, pd.easingFunctions.outCubic)
    self.engine_fade_in.updateCallback = function (timer)
        self.engine_sample:setVolume(timer.value)
    end

    self.engine_fade_in.timerEndedCallback = function ()
        self.engine_sample:setVolume(1)
    end

    self.engine_fade_in.timerEndedCallback = function ()
        self.engine_fade_in = nil
    end

    self.engine_sample:play(0)
end

function SoundManager:stopEngine()

    if self.engine_fade_out then 
        self.engine_fade_out:remove()
    end

    if self.engine_fade_in then 
        self.engine_fade_in:remove()
    end

    self.engine_fade_out = pd.timer.new(self.engine_fade, self.engine_volume, 0, pd.easingFunctions.outCubic)
    self.engine_fade_out.updateCallback = function (timer)
        self.engine_sample:setVolume(timer.value)
    end
    self.engine_fade_out.timerEndedCallback = function ()
        self.engine_sample:stop()
        self.engine_fade_out = nil
    end
end

function SoundManager:getRadio()
    return self.radio
end

function SoundManager:switchRadio()
    if self.radio:isPlaying() then
        self.radio:stop(0)
    else
        self.radio:play(0)
    end
end

function SoundManager:playRadio()
    self.radio:play(0)
end

function SoundManager:stopRadio()
    self.radio:play()
end

local gfx <const> = playdate.graphics
local pd <const> = playdate

class('SoundManager').extends(playdate.graphics.sprite)

function SoundManager:init()
    self.synth = pd.sound.synth.new()
    
end

function SoundManager:play()
    self.synth:playMIDINote("Bb3")
end

function SoundManager:stop()
    self.synth:playMIDINote("Bb3")
end

function SoundManager:playIntro()
    self.intro:play()
end

function SoundManager:stopIntro()
    self.intro:stop()
end
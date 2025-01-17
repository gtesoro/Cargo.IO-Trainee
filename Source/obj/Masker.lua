local pd <const> = playdate
local gfx <const> = pd.graphics

class('Masker').extends(playdate.graphics.sprite)

function Masker:init(image, mask)


    self.base = image
    self.mask = mask
    self:setImage(gfx.image.new(self.base:getSize()))

    inContext(self:getImage(), function ()
        gfx.clear()
        self.base:draw(0,0)

    end)
    self:markDirty()

    self.base_table = {}
    self.mask_table = {}

    for i=0,100 do
        self.base_table[i+1] = self.base:fadedImage(i/100, gfx.image.kDitherTypeBayer8x8)
        self.mask_table[i+1] = self.mask:fadedImage(i/100, gfx.image.kDitherTypeBayer8x8)
    end


    local mask_timer = pd.timer.new(5000, -1, 2, pd.easingFunctions.linear)
    mask_timer.reverses = true
    mask_timer.repeats = true

    self.offset_x = 0
    self.offset_y = 0

    local offset_timer = pd.timer.new(3000, 0, -10, pd.easingFunctions.inOutSine)
    offset_timer.reverses = true
    offset_timer.repeats = true
    offset_timer.updateCallback = function (timer)
        self.offset_x = timer.value
        self.offset_y = timer.value
    end

    mask_timer.updateCallback = function (timer)

        -- inContext(self:getImage(), function ()
        --     gfx.clear()
        --     --self.base_table[clamp(round(timer.value*100), 1, 100)]:draw(0,0)
            
        --     --self.mask_table[clamp(round(timer.value*100), 1, 100)]:draw(self.offset_x, self.offset_y)
        --     self.mask:draw(0,0)
        --     self.base:draw(math.random(-1,1), math.random(-1,1))
        --     --self.base_table[clamp(round(timer.value*100), 1, 100)]:draw(0,0)

        -- end)
        -- self:markDirty()
    end
    
end

function Masker:update()

    

    if not self.noise_timer then
        self.noise_timer = pd.timer.new(math.random(3000, 10000))
        self.noise_timer.updateCallback = function (timer)
            if timer.timeLeft < 1000 then
                if math.fmod(math.floor(timer.value), 2) == 0 then
                    inContext(self:getImage(), function ()
                        gfx.clear()
                        self.base:draw(0,0)
                        self.mask:draw(0,0)
                
                    end)
                    self:markDirty()
                else
                    inContext(self:getImage(), function ()
                        gfx.clear()
                        
                        self.mask:draw(0,0)
                        self.base:draw(0,0)
                
                    end)
                    self:markDirty()
                end
            end
        end
        self.noise_timer.timerEndedCallback = function ()
            inContext(self:getImage(), function ()
                gfx.clear()
                self.base:draw(0,0)
        
            end)
            self:markDirty()
            self.noise_timer = nil
        end
    end
    
end

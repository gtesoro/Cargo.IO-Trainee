local pd = playdate
local gfx <const> = pd.graphics
class('Intro').extends(Scene)


function Intro:startScene()

    self:initInputs()

    local _num = math.random(1,3)
    local _stars_img = gfx.image.new("assets/intro_stars")
    self.stars_1 =  gfx.sprite.new(_stars_img)
    self.stars_1:setCenter(0,0)
    self.stars_1:moveTo(0,0)
    self.stars_1:setZIndex(0)

    table.insert(self.sprites, self.stars_1)


    self.bg =  gfx.sprite.new(gfx.image.new("assets/intro"))
    self.bg:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.bg:setZIndex(1)

    table.insert(self.sprites, self.bg)

    self.range = 1000

end

function Intro:add()

    Intro.super.add(self)

    g_SoundManager:playIntro()
    
end

function Intro:initInputs()

    self.input_handlers = {

        AButtonUp = function()
            self:unfocus()
            g_SoundManager:stopIntro(
                function ()
                    g_SceneManager:pushScene(SaveSelect(), "to menu")
                end
            )
        end
    }

end

function Intro:doUpdate()    

    if not self.star_timer_x then
        local _target = self.stars_1.x + math.random(-self.range , self.range )
        while _target < -(self.stars_1.width-400) or _target > 0 do
            _target = self.stars_1.x + math.random(-self.range , self.range )
        end
        self.star_timer_x = pd.timer.new(math.random(3000, 6000), self.stars_1.x , _target, pd.easingFunctions.inOutCubic)
        self.star_timer_x.updateCallback = function (timer)
            local _v =  math.floor(timer.value)
            if math.fmod(_v, 2) ~= 0 then
                _v += 1
            end
            self.stars_1:moveTo(_v, self.stars_1.y)
        end
        self.star_timer_x.timerEndedCallback = function ()
            self.star_timer_x = nil
        end
    end 

    if not self.star_timer_y then

        local _target = self.stars_1.y + math.random(-self.range , self.range )
        while _target < -(self.stars_1.height-240) or _target > 0  do
            _target = self.stars_1.y + math.random(-self.range , self.range )
        end

        self.star_timer_y = pd.timer.new(math.random(3000, 6000), self.stars_1.y, _target, pd.easingFunctions.inOutCubic)
        self.star_timer_y.updateCallback = function (timer)

            local _v =  math.floor(timer.value)
            if math.fmod(_v, 2) ~= 0 then
                _v += 1
            end
            self.stars_1:moveTo(self.stars_1.x, _v)
        end
        self.star_timer_y.timerEndedCallback = function ()
            self.star_timer_y = nil
        end
    end 
    
end


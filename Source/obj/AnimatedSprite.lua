local pd <const> = playdate
local gfx <const> = pd.graphics

class('AnimatedSprite').extends(playdate.graphics.sprite)

function AnimatedSprite:init(image_table, delay, scale, dont_loop)

    AnimatedSprite.super.init(self)

    local _loops = true
    if dont_loop then
        _loops = false
    end

    if not delay then
        self.delay = 100
    else
        self.delay = delay
    end

    if type(image_table) == "string" then
        image_table = gfx.imagetable.new(image_table)
    end

    self.image_table = image_table
    self.scale = scale

    self.imageTable = self.image_table
    self.animation = gfx.animation.loop.new(self.delay, self.imageTable, _loops)
    self.current_frame = self.animation.frame

    if self.scale then
        self:setImage(self.imageTable:getImage(1):scaledImage(scale))
    else
        self:setImage(self.imageTable:getImage(1))
    end
end

function AnimatedSprite:update()
    if self.current_frame == self.animation.frame then
        return 
    end

    local _ox, _oy = gfx.getDrawOffset()
    local _x, _y, _w, _h = pd.geometry.rect.fast_intersection(-1*_ox, -1*_oy, 400, 240, self:getBounds())

    if _w > 0 and _h > 0 then
        if self.scale then
            self:setImage(self.animation:image():scaledImage(self.scale))
        else
            self:setImage(self.animation:image())
        end
        self.current_frame = self.animation.frame

    end
end

-- function AnimatedSprite:add()
--     AnimatedSprite.super.add(self)

--     --print('AnimatedSprite added', self.image_table)
-- end

-- function AnimatedSprite:remove()
--     AnimatedSprite.super.remove(self)

--     --print('AnimatedSprite removed', self.image_table)
-- end





local pd <const> = playdate
local gfx <const> = pd.graphics

class('Map').extends('Scene')

function Map:startScene()

    self.cube_size = 30

    self:initInputs()

    local img = gfx.image.new(400, 240, gfx.kColorBlack)
    gfx.pushContext(img)
        local _i = gfx.image.new('assets/backgrounds/grid')
        _i:drawAnchored(pd.display.getWidth()/2, pd.display.getHeight()/2, 0.5, 0.5)
    gfx.popContext()

    self.bg_image = img:blurredImage(1, 2, gfx.image.kDitherTypeScreen)
    self.bg_sprite = gfx.sprite.new(self.bg_image)
    self.bg_sprite:setIgnoresDrawOffset(true)
    self.bg_sprite:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.bg_sprite:setZIndex(0)
    self.bg_sprite:add()
    self.sprites:append(self.bg_sprite)

    self.ui_overlay = gfx.sprite.new(gfx.image.new('assets/backgrounds/ui_overlay'))
    self.ui_overlay:setIgnoresDrawOffset(true)
    self.ui_overlay:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.ui_overlay:setZIndex(2)
    self.ui_overlay:add()

    self.sprites:append(self.ui_overlay)

    local map_img = gfx.image.new(pd.display.getWidth()*10, pd.display.getHeight()*10)

    self.map_sprite = gfx.sprite.new(map_img)

    self.map_sprite:setImage(map_img)
    self.map_sprite:moveTo(playdate.display.getWidth()/2, playdate.display.getHeight()/2)
    self.map_sprite:setZIndex(1)
    self.map_sprite:add()

    self.sprites:append(self.map_sprite)

    local _o_x, _o_y = self:drawMap()

    self.x_offset = _o_x
    self.y_offset = _o_y
    
end


function Map:drawMap()

    local _offset = self.cube_size* 1.2

    local img = self.map_sprite:getImage()

    local _x_offset = 0

    local _y_offset = 0

    gfx.pushContext(img)

        gfx.clear()
        for k, v in pairs(g_player.map) do
            local _type = 0
            if not v.empty then
                _type = 1
            end
            if v.x == g_player.current_position.x and v.y == g_player.current_position.y and v.z == g_player.current_position.z then
                _type = 2
            end
            local _x, _y = drawWireframeCube(-v.y * (self.cube_size + _offset), v.z *(self.cube_size + _offset), -v.x *(self.cube_size + _offset), self.cube_size, img.width, img.height, _type) 
            if _type == 2 then
                _x_offset =  -(img.width/2 - _x)
                _y_offset =  -(img.height/2 -_y) 
            end
        end
    gfx.popContext()



    self.map_sprite:markDirty()

    return _x_offset, _y_offset
    
end

function Map:initInputs()

    local _cam_speed = 6

    self.input_handlers = {

        cranked = function (change, acceleratedChange)
            self.cube_size += 5*(change/360)
            self.bg_sprite:setImage(self.bg_image:vcrPauseFilterImage())
            self.vcr = true
            self:drawMap()
        end,

        AButtonUp = function ()

        end,

        BButtonUp = function ()
            g_SceneManager:popScene('between menus')
        end,

        upButtonDown = function ()
            self.y_offset -= _cam_speed
            self.bg_sprite:setImage(self.bg_image:vcrPauseFilterImage())
            self.vcr = true
            gfx.setDrawOffset(-self.x_offset, -self.y_offset)
        end,

        downButtonDown = function ()
            self.y_offset += _cam_speed
            self.bg_sprite:setImage(self.bg_image:vcrPauseFilterImage())
            self.vcr = true
            gfx.setDrawOffset(-self.x_offset, -self.y_offset)
        end,

        leftButtonDown = function ()
            self.x_offset -= _cam_speed
            self.bg_sprite:setImage(self.bg_image:vcrPauseFilterImage())
            self.vcr = true
            gfx.setDrawOffset(-self.x_offset, -self.y_offset)
        end,

        rightButtonDown = function ()
            self.x_offset += _cam_speed
            self.bg_sprite:setImage(self.bg_image:vcrPauseFilterImage())
            self.vcr = true
            gfx.setDrawOffset(-self.x_offset, -self.y_offset)
        end

    }
    
end

function Map:doUpdate()

    if self.vcr then
        self.vcr = false
    else
        self.bg_sprite:setImage(self.bg_image)
    end

end
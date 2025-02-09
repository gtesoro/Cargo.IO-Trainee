local pd <const> = playdate
local gfx <const> = pd.graphics

class('StageSystem').extends(System)

function StageSystem:startScene()

    StageSystem.super.startScene(self)

    self:initStage()
    
end

function StageSystem:initStage()

    local _img = gfx.image.new(self.data.playfield_width, self.data.playfield_height)

    local _layers = {}

    for k,v in pairs(LDtk.get_layers(self.data.stage)) do
        v.name = k
        table.insert(_layers, v)
    end

    table.sort(_layers, function (a, b)
        return a.zIndex < b.zIndex
    end)
    
    for k, layer in pairs(_layers) do

        if layer.tiles then
            local _tilemap = LDtk.create_tilemap(self.data.stage, layer.name)
            local _bounds = gfx.sprite.addWallSprites( _tilemap, LDtk.get_empty_tileIDs( self.data.stage, "Solid", layer.name) )
            for k,v in pairs(_bounds) do
                v.solid = true
                v:moveBy(self.data.stage_offset_x , self.data.stage_offset_y)
                table.insert(self.sprites, v)
            end
            inContext(_img, function ()
                _tilemap:draw(self.data.stage_offset_x , self.data.stage_offset_y)
            end)
        end

        -- Entities
        for k, entity in pairs(LDtk.get_entities( self.data.stage, layer.name)) do
            --print(entity.name)
            --printTable(entity)
            if entity.name == "Item" then
                --print(entity.fields.class)
                local _item = ItemContainer(_G[entity.fields.class]())
                --printTable(_item)
                _item:moveTo(entity.position.x + self.data.stage_offset_x, entity.position.y + self.data.stage_offset_y)
                _item:setZIndex(entity.zIndex + 1)
                _item:add()

                table.insert(self.sprites, _item)

            end

            if entity.name == "InteractionPoint" then
                local _ip = InteractionPoint(entity.fields.funct, entity.fields.w, entity.fields.h)
                _ip:moveTo(entity.position.x + self.data.stage_offset_x, entity.position.y + self.data.stage_offset_y)
                _ip:setZIndex(entity.zIndex + 1)
                _ip:add()

                table.insert(self.sprites, _ip)
            end
            
        end

    end

    self.tilemap_layer = gfx.sprite.new(_img)
    self.tilemap_layer:moveTo(self.data.playfield_width/2, self.data.playfield_height/2)
    self.tilemap_layer:setZIndex(3)
    self.tilemap_layer:add()
    self.tilemap_layer:setVisible(false)

    table.insert(self.sprites, self.tilemap_layer)

    self.overlay_img = gfx.image.new(self.data.stage_overlay)
    self.overlay_img_orig = self.overlay_img:copy()
    self.overlay = gfx.sprite.new(self.overlay_img)
    self.overlay:setCenter(0,0)
    self.overlay:moveTo(self.data.stage_offset_x , self.data.stage_offset_y)
    self.overlay:setZIndex(self.data.playfield_height*2+1)
    self.overlay:add()

    table.insert(self.sprites, self.overlay)

    if self.data.stage_middle then
        self.stage_middle = gfx.sprite.new(gfx.image.new(self.data.stage_middle))
        self.stage_middle:setCenter(0,0)
        self.stage_middle:moveTo(self.data.stage_offset_x , self.data.stage_offset_y)
        self.stage_middle:setZIndex(self.bg_sprite:getZIndex()+1)
        self.stage_middle:add()

        table.insert(self.sprites, self.stage_middle)  
    end
    
end

function StageSystem:handleOverlayFocus()
    local _ship_x_relative, _ship_y_relative = self.ship.x - self.data.stage_offset_x, self.ship.y - self.data.stage_offset_y

    if _ship_x_relative > 0 and _ship_x_relative < self.overlay_img.width and
       _ship_y_relative > 0 and _ship_y_relative < self.overlay_img.height and
       self.overlay_img_orig:sample(_ship_x_relative, _ship_y_relative) ~= gfx.kColorClear then

        self.inside = true
        local _img = self.overlay_img
        inContext(_img, function ()
            gfx.setColor(gfx.kColorClear)
            gfx.setDitherPattern(0.4, gfx.image.kDitherTypeBayer8x8)
            gfx.fillCircleAtPoint(_ship_x_relative, _ship_y_relative, 100)

            gfx.setColor(gfx.kColorClear)
            gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer8x8)
            gfx.fillCircleAtPoint(_ship_x_relative, _ship_y_relative, 80)

            gfx.setColor(gfx.kColorClear)
            gfx.fillCircleAtPoint(_ship_x_relative, _ship_y_relative, 60)
        end)
        self.overlay:setImage(_img)
        self.overlay:markDirty()

        self.tilemap_layer:setVisible(true)
    else
        self.tilemap_layer:setVisible(false)
        self.overlay:setImage(self.overlay_img_orig)
        self.overlay:markDirty()
    end
end

function StageSystem:handleOverlayFocus2()
    local _ship_x_relative, _ship_y_relative = self.ship.x - self.data.stage_offset_x, self.ship.y - self.data.stage_offset_y

    if _ship_x_relative > 0 and _ship_x_relative < self.overlay_img.width and
       _ship_y_relative > 0 and _ship_y_relative < self.overlay_img.height then

        self.inside = true
        local _img = self.overlay_img:getMaskImage()
        inContext(_img, function ()
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(0.4, gfx.image.kDitherTypeBayer8x8)
            gfx.fillCircleAtPoint(_ship_x_relative, _ship_y_relative, 100)

            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer8x8)
            gfx.fillCircleAtPoint(_ship_x_relative, _ship_y_relative, 80)

            gfx.setColor(gfx.kColorBlack)
            gfx.fillCircleAtPoint(_ship_x_relative, _ship_y_relative, 60)
        end)
        self.overlay:getImage():setMaskImage(_img)
        self.overlay:markDirty()

        self.tilemap_layer:setVisible(true)
    else
        self.tilemap_layer:setVisible(false)
        self.overlay:setImage(self.overlay_img_orig)
        self.overlay:markDirty()
    end
end

function StageSystem:doUpdate()

    StageSystem.super.doUpdate(self)

    self:handleOverlayFocus()
    
end

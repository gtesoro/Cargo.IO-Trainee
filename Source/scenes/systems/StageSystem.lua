local pd <const> = playdate
local gfx <const> = pd.graphics

class('StageSystem').extends(System)

function StageSystem:startScene()

    StageSystem.super.startScene(self)

    self.tilemaps = {}
    self.bounds = {}
    self.tilemaps_base_z = 5

    self:initStage()
    
end

function StageSystem:initStage()

    

    local _layers = {}

    for k,v in pairs(LDtk.get_layers(self.data.stage)) do
        v.name = k
        table.insert(_layers, v)
    end

    for k, layer in pairs(_layers) do

        if layer.tiles then
            local _tilemap = LDtk.create_tilemap(self.data.stage, layer.name)
            local _bounds = gfx.sprite.addWallSprites( _tilemap, LDtk.get_empty_tileIDs( self.data.stage, "Solid", layer.name) )
            
            for k,v in pairs(_bounds) do
                v.solid = true
                v:moveBy(self.data.stage_offset_x , self.data.stage_offset_y)
                --v:setImage(gfx.image.new(v.width, v.height, gfx.kColorClear))
                table.insert(self.sprites, v)
                table.insert(self.bounds, v)
            end

            local _img = gfx.image.new(self.data.playfield_width, self.data.playfield_height)

            inContext(_img, function ()
                _tilemap:draw(self.data.stage_offset_x , self.data.stage_offset_y)
            end)
            
            local _tilemap_spr = gfx.sprite.new(_img)
            _tilemap_spr:moveTo(self.data.playfield_width/2, self.data.playfield_height/2)
            _tilemap_spr:setZIndex(layer.zIndex + self.tilemaps_base_z)
            _tilemap_spr:add()
            _tilemap_spr:setVisible(false)

            table.insert(self.sprites, _tilemap_spr)
            table.insert(self.tilemaps, _tilemap_spr)
        end

        -- Entities
        for k, entity in pairs(LDtk.get_entities( self.data.stage, layer.name)) do
            if entity.name == "Item" then
                local _item = ItemContainer(_G[entity.fields.class]())
                _item:moveTo(entity.position.x + self.data.stage_offset_x, entity.position.y + self.data.stage_offset_y)
                _item:setZIndex(entity.zIndex + self.tilemaps_base_z)
                _item:add()
                table.insert(self.sprites, _item)
            end

            if entity.name == "InteractionPoint" then
                local _ip = InteractionPoint(entity.fields.funct, entity.fields.w, entity.fields.h)
                _ip:moveTo(entity.position.x + self.data.stage_offset_x, entity.position.y + self.data.stage_offset_y)
                _ip:setZIndex(entity.zIndex + self.tilemaps_base_z)
                _ip:add()

                table.insert(self.sprites, _ip)
            end
            
        end

    end

    
    if self.data.stage_overlay then
        self.overlay_img = gfx.image.new(self.data.stage_overlay)
        self.overlay_img_orig = self.overlay_img:copy()
        self.overlay = gfx.sprite.new(self.overlay_img)
        self.overlay:setCenter(0,0)
        self.overlay:moveTo(self.data.stage_offset_x , self.data.stage_offset_y)
        self.overlay:setZIndex(self.data.playfield_height*2+1)
        self.overlay:add()

        table.insert(self.sprites, self.overlay)
    
    end

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
    if not self.overlay then
        for k,v in pairs(self.tilemaps) do
            v:setVisible(true)
        end
        return
    end

    local _ship_x_relative, _ship_y_relative = (self.player.x - self.data.stage_offset_x)*1/self.zoom, (self.player.y - self.data.stage_offset_y)*1/self.zoom

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

        for k,v in pairs(self.tilemaps) do
            v:setVisible(true)
        end
    else
        for k,v in pairs(self.tilemaps) do
            v:setVisible(false)
        end
        self.overlay:setImage(self.overlay_img_orig)
        self.overlay:markDirty()
    end
end

-- function StageSystem:handleOverlayFocus2()
--     local _ship_x_relative, _ship_y_relative = self.player.x - self.data.stage_offset_x, self.player.y - self.data.stage_offset_y

--     if _ship_x_relative > 0 and _ship_x_relative < self.overlay_img.width and
--        _ship_y_relative > 0 and _ship_y_relative < self.overlay_img.height then

--         self.inside = true
--         local _img = self.overlay_img:getMaskImage()
--         inContext(_img, function ()
--             gfx.setColor(gfx.kColorWhite)
--             gfx.setDitherPattern(0.4, gfx.image.kDitherTypeBayer8x8)
--             gfx.fillCircleAtPoint(_ship_x_relative, _ship_y_relative, 100)

--             gfx.setColor(gfx.kColorWhite)
--             gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer8x8)
--             gfx.fillCircleAtPoint(_ship_x_relative, _ship_y_relative, 80)

--             gfx.setColor(gfx.kColorBlack)
--             gfx.fillCircleAtPoint(_ship_x_relative, _ship_y_relative, 60)
--         end)
--         self.overlay:getImage():setMaskImage(_img)
--         self.overlay:markDirty()

--         self.tilemap_layer:setVisible(true)
--     else
--         self.tilemap_layer:setVisible(false)
--         self.overlay:setImage(self.overlay_img_orig)
--         self.overlay:markDirty()
--     end
-- end

function StageSystem:doUpdate()

    local _bound = self.bounds[1]

    StageSystem.super.doUpdate(self)

    self:handleOverlayFocus()
    
end

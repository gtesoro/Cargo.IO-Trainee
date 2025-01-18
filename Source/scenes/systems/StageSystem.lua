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
        print(k)
        printTable(layer.name, layer.zIndex)
        --printTable(k, v)
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

    self.tilemap_layer = gfx.sprite.new(_img)
    self.tilemap_layer:moveTo(self.data.playfield_width/2, self.data.playfield_height/2)
    self.tilemap_layer:setZIndex(1)
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
    
end

function StageSystem:doUpdate()

    StageSystem.super.doUpdate(self)

    local _ship_x_relative, _ship_y_relative = self.ship.x - self.data.stage_offset_x, self.ship.y - self.data.stage_offset_y

    if self.overlay_img_orig:sample(_ship_x_relative, _ship_y_relative) ~= gfx.kColorClear then

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

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('LocationDescription').extends(Scene)


function LocationDescription:startScene()

    local _margin_w = 50
    local _w = 400 - 2*_margin_w
    

    self.thumbnail = self.data.thumbnail()

    local _h = 10 + self.thumbnail.height/2

    self.thumbnail:setCenter(0, 0.5)
    self.thumbnail:moveTo(_w*0.1, _h)
    self.thumbnail:setZIndex(1)
    table.insert(self.sprites, self.thumbnail)

    self.label = gfx.sprite.new(gfx.imageWithText(self.data.name, _w*0.8, nil, gfx.kColorClear, nil, nil, nil, g_font_24))
    self.label:setCenter(1, 0.5)
    self.label:moveTo(_w*0.9, _h)
    self.label:setZIndex(1)
    table.insert(self.sprites, self.label)

    _h += math.max(self.label.height, self.thumbnail.height) + 10

    local _facilities = "Facilities:"
    for k,v in pairs(self.data.facilities) do
        _facilities = string.format("%s\n  - %s", _facilities, facility_v_options[v].name)
    end
    self.facilities = gfx.sprite.new(gfx.imageWithText(_facilities, _w*0.8, nil, gfx.kColorClear, nil, nil, nil, g_font_text))
    self.facilities:setCenter(0, 0)
    self.facilities:moveTo(_w*0.1, _h)
    self.facilities:setZIndex(1)
    table.insert(self.sprites, self.facilities)

    _h += self.facilities.height + 10

    self.description = gfx.sprite.new(gfx.imageWithText(self.data.description, _w*0.8, nil, gfx.kColorClear, nil, nil, nil, g_font_text))
    self.description:setCenter(0, 0)
    self.description:moveTo(_w*0.1, _h)
    self.description:setZIndex(1)
    table.insert(self.sprites, self.description)

    _h += self.description.height + 10

    self:setSize(_w, _h)
    self:setCollideRect(0,0, self:getSize())

    self:setCenter(0, 0)

end

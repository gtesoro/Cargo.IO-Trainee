local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlanetCard').extends(Scene)

function PlanetCard:initGrid()
     
    local menuOptions = self.data.facilities
    self.listview = playdate.ui.gridview.new(0, 30)
    self.listview:setNumberOfRows(#menuOptions)
    self.listview:setCellPadding(0, 0, 0, 0)
    self.listview:setContentInset(5, 5, 5, 5)

    function self.listview:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        gfx.drawTextInRect(string.format("*%s*",menuOptions[row]), x, y+height/4, width, height, nil, "...", kTextAlignment.center)
    end

    self.grid_sprite = gfx.sprite.new(gfx.image.new(self.data_width, self.data_height))
    self.grid_sprite:moveTo(self.data_x + self.data_width/2, self.data_y + self.data_height/2)
    self.grid_sprite:setZIndex(1)

    gfx.pushContext(self.grid_sprite:getImage())
        gfx.clear()
        self.listview:drawInRect(0,0, self.data_width, self.data_height)
        gfx.setColor(playdate.graphics.kColorBlack)
    gfx.popContext()

    self.sprites[#self.sprites+1] = self.grid_sprite
    
end

function PlanetCard:initBg()

    local offset_x = 10
    local offset_y = 20
    local float = 2
    local radius = 4

    local data_width = pd.display.getWidth()/2 - self.planet_offset*2

    local img = gfx.image.new(pd.display.getWidth(), pd.display.getHeight(), gfx.kColorBlack)
    gfx.pushContext(img)
        gfx.setColor(playdate.graphics.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRoundRect(offset_x + float, offset_y + float, data_width - offset_x*2 + float , pd.display.getHeight() - offset_y*2 + float, radius)
        gfx.setColor(playdate.graphics.kColorWhite)
        gfx.fillRoundRect(offset_x, offset_y, data_width- offset_x*2, pd.display.getHeight() - offset_y*2, radius)
        self.data_x = offset_x
        self.data_y = offset_y
        self.data_width = data_width- offset_x*2
        self.data_height = pd.display.getHeight() - offset_y*2
    gfx.popContext()
    self.bg_sprite = gfx.sprite.new(img)
    self.bg_sprite:moveTo(pd.display.getWidth()/2, pd.display.getHeight()/2)
    self.bg_sprite:setZIndex(0)

    self.sprites[#self.sprites+1] = self.bg_sprite

end

function PlanetCard:initPlanet()
    self.planet_offset = 20
    self.planet = AnimatedSprite(self.data.img_hd,100)
    self.planet:moveTo(pd.display.getWidth() - pd.display.getWidth()/4 - self.planet_offset, pd.display.getHeight()/2)

    local img = gfx.image.new(self.planet:getSize())
    gfx.pushContext(img)
        gfx.setColor(playdate.graphics.kColorWhite)
        gfx.setLineWidth(2)
        gfx.drawCircleAtPoint(self.planet.width/2, self.planet.width/2, self.planet.width/2 - 1)
    gfx.popContext()
    self.planet_outline = gfx.sprite.new(img)
    self.planet_outline:setZIndex(2)
    self.planet_outline:moveTo(pd.display.getWidth() - self.planet.width/2 - self.planet_offset, pd.display.getHeight()/2)

    self.sprites[#self.sprites+1] = self.planet_outline
    self.sprites[#self.sprites+1] = self.planet
    
end

function PlanetCard:startScene()
    self:initPlanet()
    self:initBg()
    self:initGrid()
end

function PlanetCard:update()
    PlanetCard.super.update(self)

    if pd.buttonJustReleased(pd.kButtonB) then
        g_SceneManager:popScene('hwipe')
    end

    local list_mod = false

    if pd.buttonJustPressed(pd.kButtonUp) then
        self.listview:selectPreviousRow(false)
        list_mod = true
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        self.listview:selectNextRow(false)
        list_mod = true
    end

    if list_mod then
        gfx.pushContext(self.grid_sprite:getImage())
            gfx.clear()
            self.listview:drawInRect(0,0, self.data_width, self.data_height)
            gfx.setColor(playdate.graphics.kColorBlack)
        gfx.popContext()
    end

end
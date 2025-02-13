
local pd <const> = playdate
local gfx <const> = pd.graphics

class('GenericMenuList').extends(GenericMenu)

function GenericMenuList:startScene()

    GenericMenuList.super.startScene(self)

    self:initGrids()
    
end

function GenericMenuList:initGrids()

    local _list_box_data = {
        options = self.data.options,
        parent = self
    }

    self.list_box_w = self.list_box_w or 150
    self.list_box_h = self.list_box_h or 150

    self.list_box_x = self.list_box_x or 35
    self.list_box_y = self.list_box_y or 120

    self.list_box_center_x = self.list_box_center_x or 0
    self.list_box_center_y = self.list_box_center_y or 0.5

    self.list_box = ListBox(_list_box_data, self.list_box_w, self.list_box_h)
    self.list_box:setCenter(self.list_box_center_x, self.list_box_center_y)
    self.list_box:moveTo(self.list_box_x, self.list_box_y)
    self.list_box:setZIndex(3)

    self.list_box_shadow = getShadowSprite(self.list_box)
    self.list_box_shadow:setZIndex(2) 

    self.list_box_shadow:add()

    table.insert(self.sprites, self.list_box_shadow)

    self.list_box:add()

    self.list_box.b_callback = function ()

        if self.b_callback then
            self.b_callback()     
        end
        local _prev = g_SceneManager.scene_stack[#g_SceneManager.scene_stack -1]
        if _prev and _prev:isa(System) then
            g_SceneManager:popScene('out menu')
        else
            g_SceneManager:popScene('between menus')
        end
        
    end
    
    table.insert(self.sprites, self.list_box)

end

function GenericMenuList:initBg()

    GenericMenuList.super.initBg(self)
    
    if self.data.right_side then
        self:setRightSide(self.data.right_side)
    end

end

function GenericMenuList:setRightSide(spr)

    if self.right_side then
        self.right_side:remove()
        table_remove(self.sprites, self.right_side)
    end

    if spr then
        self.right_side = spr
        self.right_side:moveTo(self.data.right_sise_x or 290,self.data.right_sise_y or 120)
        self.right_side:setZIndex(0)
        self.right_side:add()

        table.insert(self.sprites, self.right_side)
    end
end

function GenericMenuList:focus()
    if self.list_box then
        self:unfocus()
        self.list_box:focus()
    end
end

function GenericMenuList:unfocus()
    if self.list_box then
        self.list_box:unfocus()
    end
end

function GenericMenuList:clean()
    GenericMenuList.super.clean(self)
    if self.right_side then
        self.right_side:remove()
        self.right_side = nil
    end
end

function GenericMenuList:doUpdate()

    if self.current_selected ~= self.list_box:getSelected() then
        self.current_selected = self.list_box:getSelected()

        if self.current_selected then
            if self.current_selected.sprite then
                if type(self.current_selected.sprite) == "function" then
                    self:setRightSide(self.current_selected.sprite())
                else
                    self:setRightSide(self.current_selected.sprite)
                end
            elseif self.data.right_side then
                self:setRightSide(self.data.right_side)
            end
        else
            self:setRightSide(nil)
        end
        
    end
    
end
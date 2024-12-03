local pd <const> = playdate
local gfx <const> = pd.graphics

class('CloningFacility').extends(GenericMenu)

function CloningFacility:init()

    CloningFacility.super.init(self)

    self.ref_contract = Cloning()

    local _contract = g_SystemManager:getPlayer():getContractByType('Cloning')
    self.data.options = {
        {
            name = 'Sign Contract',
            callback = function ()
                g_SceneManager:pushScene(ImageViewer({image=self.ref_contract:getContractImage(), a_callback=function (_image_viewer)

                    g_SceneManager:pushScene(Popup({text='Sign Contract?', options={
                        {
                            name='Yes',
                            callback= function ()
                                if g_SystemManager:getPlayer():chargeMoney(self.ref_contract:getSignPrice()) then
                                    inContext(_image_viewer.image_sprite:getImage(), function ()
                                        gfx.image.new('assets/contracts/contract_stamp'):drawAnchored(240, 368, 0.5, 0.5)
                                    end)
                                    g_NotificationManager:notify('Contract Signed')
                                    self.ref_contract:onSign()
                                    g_SystemManager:getPlayer():addContract(self.ref_contract)
                                    _image_viewer.image_sprite:markDirty()
                                end
                            end
                        },
                        {
                            name='No'
                        }
                    }}), 'stack')
                    
                end}), 'between menus')
            end
        },
        {
            name = 'Renew Contract',
            callback = function ()
                if g_SystemManager:getPlayer():chargeMoney(10) then
                    _contract.start = g_SystemManager:getPlayer().cycle
                    _contract.stop = _contract.start + 50
                end
            end
        },
        {
            name = 'Update Memory',
            callback = function ()
                self.ref_contract:updateMemory()
            end
        }
    }

    
end


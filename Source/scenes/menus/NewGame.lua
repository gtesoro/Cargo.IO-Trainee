local pd <const> = playdate
local gfx <const> = pd.graphics

class('NewGame').extends(Dialogue)


function NewGame:init(slot)

    local _diag = {
        {
            text = "As you step in to the holochamber, you can already smell the freshly cut grass even before the visual enviroment starts loading.",
            type = DIAG_DESC
        },
        {
            file = "assets/backgrounds/ruhe_bg",
            type = DIAG_BG_IN,
            continue = true
        },
        {
            text = "Your eyes take a bit of time to adapt to the artificial sunlight. The birds chirp in the distance and you could swear there is a mild breeze coming from the forest nearby.",
            type = DIAG_DESC
        },
        {
            text = "This is not your first time in a holochamber but it is always impressive.",
            type = DIAG_DESC
        },
        {
            text = "As the simulated reality settles in, you see an avatar approaching you.",
            type = DIAG_DESC
        },
        {
            file = 'assets/characters/ruhe',
            name = 'Ruhe Avatar',
            type = DIAG_CHAR_IN,
            continue = true
        },
        {
            text = "Greetings.\nI'm a *Ruhe* avatar. Congratulations on your 7000 cycle.",
            type = DIAG_OTHER
        },
        {
            text = "Would you please tell me how may I refer to you?",
            type = DIAG_OTHER
        },
        {
            trigger = function ()
                g_SceneManager:pushScene(TextInput({callback= function (text)
                    g_SystemManager:getPlayer().name = text
                end}), 'between menus')
            end,
            type = DIAG_EMPTY
        },
        {
            text = function ()
                return string.format('Thank you, %s.', g_SystemManager:getPlayer().name)
            end,
            type = DIAG_OTHER
        },
        {
            text = "As a descendent of the *Ruhevolk* reaching adulthood, you have the possibility of starting your *Wanderlust* period.",
            type = DIAG_OTHER
        },
        {
            text = "During this period, you will be given a personal ship and some funds to explore the galaxy and the *Ruhe* society.",
            type = DIAG_OTHER
        },
        {
            text = "For a maximum duration of 1000 Cycles, you are welcome to explore at your own pace, discovering the ways of the *Ruhevolk* and hopefully, also yourself.",
            type = DIAG_OTHER
        },
        {
            text = "By the end of your *Wanderlust*, you would need to decide if you stay a memeber of *Ruhe* or if you instead go back to *Sol*.",
            type = DIAG_OTHER
        },
        {
            text = "As you know, every citizen of *Ruhe* needs to have a *Ruhesiegel* and this will be required for you too if you decide to start your *Wanderlust*.",
            type = DIAG_OTHER
        },
        {
            text = "This implant will make you participant of the contract system, enforcing any terms for contracts you sign.\nContracts are the foundation of our society.",
            type = DIAG_OTHER
        },
        {
            text = function ()
                return string.format('Is this acceptable for you, %s?', g_SystemManager:getPlayer().name)
            end,
            type = DIAG_OTHER
        },
        {
            type = DIAG_INPUT_OPTIONS,
            options = {
                {              
                    answer = "Yes",
                    dialogue = {
                        {
                            text = "Great.",
                            type = DIAG_OTHER
                        },
                        {
                            text = "Siegels are implanted via tattoo on the back of your wrist, please select one that represents you.",
                            type = DIAG_OTHER
                        },
                        {
                            trigger = function ()
                                local _data = {
                                    images = {
                                        'assets/contracts/siegel_01',
                                        'assets/contracts/siegel_02',
                                        'assets/contracts/siegel_03',
                                    },
                                    a_callback = function (_self)
                                        g_SceneManager:pushScene(Popup({text='Are you sure?', options={
                                            {
                                                name='Yes',
                                                callback= function ()
                                                    g_SystemManager:getPlayer().siegel_img = _self:getSelection().image_path
                                                    g_SceneManager:popScene('between menus')
                                                end
                                            },
                                            {
                                                name='No'
                                            }
                                        }}))
                                    end,
                                    b_callback = function ()
                                        
                                    end
                                }
                                g_SceneManager:pushScene(ImageSelector(_data), "between menus")
                            end,
                            type = DIAG_EMPTY
                        },
                        {
                            text = "That's a great choice",
                            type = DIAG_OTHER
                        },
                        {
                            text = "Now please read the *Wanderlust* contract carefully and sign it if you agree.",
                            type = DIAG_OTHER
                        },
                        {
                            type = DIAG_EMPTY,
                            trigger = function ()
                                signContractMenu(WanderlustContract())
                            end
                        },
                        {
                            text = function ()
                                return string.format("Welcome to the *Ruhevolk*. Enjoy your *Wonderlust*.\nSee you at the end, %s!", g_SystemManager:getPlayer().name)
                            end,
                            type = DIAG_OTHER
                        },
                        {
                            trigger = function ()
                                g_SoundManager:stopComputerHum()
                                g_SoundManager:playDegauss()
                                g_SoundManager:playMenuSwitch()
                                goTo(g_SystemManager:getPlayer().current_position.x, g_SystemManager:getPlayer().current_position.y, g_SystemManager:getPlayer().current_position.z, nil, true)
                            end,
                            type = DIAG_EMPTY
                        }
                    }
                },
                {
                    answer = "No",
                    dialogue = {
                        {
                            text = "That's too bad to hear.\nIf you change your mind, please let a *Ruhe* representative know and we will meet again.",
                            type = DIAG_OTHER
                        },
                        {
                            text = "Now if you are so kind, step out of the holochamber. A transport will take you *Sol*.",
                            type = DIAG_OTHER
                        },
                        {
                            type = DIAG_CHAR_OUT,
                            continue = true
                        },
                        {
                            text = 'The avatar fades in front of you. The birds have stopped chirping.',
                            type = DIAG_DESC
                        },
                        {
                            type = DIAG_BG_OUT,
                            continue = true
                        },
                        {
                            text = 'The holochamber powers down with a low pitch drone and you find yourself staring at the pitch black walls once again.',
                            type = DIAG_DESC
                        },
                        {
                            text = 'As you step you of the chamber you wonder if that was the right call. Either way, Sol awaits...',
                            type = DIAG_DESC
                        },
                        {
                            trigger = function ()
                                g_SceneManager:switchScene(Intro(), 'wipe down')
                            end,
                            type = DIAG_EMPTY
                        }
                    }
                }
            }
        },
    }


    local _data = {
        dialogue = _diag
    }

    g_SystemManager:load(slot)

    NewGame.super.init(self, _data)

end


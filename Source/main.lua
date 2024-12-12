import "init"

local pd <const> = playdate
local gfx <const> = pd.graphics

local function loadGame()

	SCENE_Z_INDEX = 0
	UI_Z_INDEX = 10000
	TRANSITIONS_Z_INDEX = 20000

	g_font_24 = gfx.font.new('font/BH93_24')
	g_font_18 = gfx.font.new('font/BH93_18')
	g_font_14 = gfx.font.new('font/BH93_14')
	g_font_text = gfx.font.new('font/Full Circle/font-full-circle')
	assert(g_font_24)
	--gfx.setFont(g_font_24)

	g_inverted = false
	g_fps = false
	playdate.display.setInverted(g_inverted)

	local menu = playdate.getSystemMenu()

	local menuItem, error = menu:addMenuItem("Show FPS", function()
		g_fps = not g_fps
	end)

	playdate.display.setRefreshRate(50)
	gfx.setBackgroundColor(playdate.graphics.kColorClear)

	g_SystemManager = SystemManager()
	g_SoundManager = SoundManager()
	g_NotificationManager = NotificationManager()
	g_SceneManager = SceneManager()

	--pd.setCollectsGarbage(false)

	local menuItem, error = menu:addMenuItem("Save", function()
		g_SystemManager:save()
	end)
	

	local menuItem, error = menu:addMenuItem("Delete Save", function()
		pd.datastore.delete(g_SystemManager.autosave_filename)
		g_SceneManager:reset()
		g_SceneManager:pushScene(Intro())
	end)

	once = true

end

function pd.gameWillPause()
	if g_SystemManager:getPlayer() then
		pd.setMenuImage(drawPauseMenu())
	end
	pd.stop()
end


function pd.gameWillResume()
	pd.start()
end

function pd.deviceWillSleep()
	pd.stop()
end


function pd.deviceWillLock()
	pd.stop()
end

function pd.deviceDidUnlock()
	pd.start()
end

loadGame()

function playdate.update()
	pd.timer.updateTimers()
	gfx.sprite.update()
	
	if g_fps then
		playdate.drawFPS(0, 0)
	end

	if once then
		once = false

		-- local img = gfx.image.new(400, 240, gfx.kColorBlack)
		-- gfx.pushContext(img)
		-- 	local _i = gfx.image.new('assets/backgrounds/grid')
		-- 	_i:drawAnchored(pd.display.getWidth()/2, pd.display.getHeight()/2, 0.5, 0.5)
		-- gfx.popContext()

		-- img = img:blurredImage(1, 2, gfx.image.kDitherTypeScreen)

		-- for i=0,100 do
		-- 	pd.simulator.writeToFile(img:fadedImage(i/100, gfx.image.kDitherTypeBayer4x4), string.format("C:\\playdate\\Assets\\sim\\fading_grid_%i.png", i))
		-- end

	end
end
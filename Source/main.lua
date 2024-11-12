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
	assert(g_font_24)
	--gfx.setFont(g_font_24)

	g_inverted = false
	g_fps = false
	playdate.display.setInverted(g_inverted)

	local menu = playdate.getSystemMenu()

	local menuItem, error = menu:addMenuItem("Theme", function()
		g_inverted = not g_inverted
		playdate.display.setInverted(g_inverted)
	end)

	local menuItem, error = menu:addMenuItem("Show FPS", function()
		g_fps = not g_fps
	end)

	playdate.display.setRefreshRate(50)
	gfx.setBackgroundColor(playdate.graphics.kColorClear)

	g_SceneManager = SceneManager()
	g_Notifications = NotificationSystem()

	once = true

end

function pd.gameWillPause()
	pd.setMenuImage(drawPauseMenu())
	pd.stop()
end


function pd.gameWillResume()
	pd.start()
end

loadGame()

function playdate.update()
	gfx.sprite.update()

	playdate.timer.updateTimers()
	
	if g_fps then
		playdate.drawFPS(0, 0)
	end

	if once then
		l = List()
		local _t1 = {test="First Element"}
		local _t2 = {test="Second Element"}
		local _t3 = {test="Third Element"}

		l:append(_t1)
		l:append(_t2)
		l:append(_t3)
		print(l.length)
		for v in l:iter() do
			print(v.test)
		end

		print(l:get(1).test)

		l:remove(_t2)

		print(l.length)

		for v in l:iter() do
			print(v.test)
		end

		local _test = {'value1', 'value2', 'value3'}

		print(_test[2], #_test)

		table.remove(_test, 2)

		print(_test[2], #_test)

		once = false
	end
end
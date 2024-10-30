import "init"

local pd <const> = playdate
local gfx <const> = pd.graphics

local function loadGame()

	SCENE_Z_INDEX = 0
	UI_Z_INDEX = 10000
	TRANSITIONS_Z_INDEX = 20000

	local font = gfx.font.new('font/BAUHAUS93')
	gfx.setFont(font)

	g_inverted = false
	g_fps = true
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

	g_SceneManager= SceneManager()

	initMap()

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
end
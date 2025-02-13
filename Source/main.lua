import "init"

local pd <const> = playdate
local gfx <const> = pd.graphics

local function init()

	g_font_24 = gfx.font.new('font/BAUHAUS/BH93_24')
	g_font_18 = gfx.font.new('font/BAUHAUS/BH93_18')
	g_font_14 = gfx.font.new('font/BAUHAUS/BH93_14')
	g_font_text = gfx.font.new('font/mecha')
	assert(g_font_text)
	g_font_text_bold = gfx.font.new('font/mecha-bold')
	assert(g_font_text_bold)
	g_font_desc = gfx.font.new('font/Oklahoma-Bold-Italic')

	g_font_text_family = {
		[playdate.graphics.font.kVariantNormal] = g_font_text,
		[playdate.graphics.font.kVariantBold] = g_font_text_bold,
		[playdate.graphics.font.kVariantItalic] = g_font_text
	}

	g_font_desc_family = {
		[playdate.graphics.font.kVariantNormal] = g_font_desc,
		[playdate.graphics.font.kVariantBold] = g_font_desc,
		[playdate.graphics.font.kVariantItalic] = g_font_desc
	}

	g_fps = false

	playdate.display.setRefreshRate(50)
	gfx.setBackgroundColor(gfx.kColorClear)

	g_SystemManager = SystemManager()
	g_EventManager = EventManager()
	g_SoundManager = SoundManager()
	g_NotificationManager = NotificationManager()
	g_SceneManager = SceneManager()

	once = true

	LDtk.load( "stages/test.ldtk" )

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

init()

local _update <const> = gfx.sprite.update
local _update_timers <const> = pd.timer.updateTimers


function playdate.update()

	if g_SystemManager then
		g_SystemManager:update()
	end
	
	if g_NotificationManager then
		g_NotificationManager:update()
	end

	_update()

	_update_timers()
	
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
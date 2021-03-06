
local composer = require("composer")
local display = require("display")
local native = require("native")
local audio = require("audio")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local musicTrack

local function goToGame()
	composer.gotoScene("game", { time = 800, effect = "crossFade" })
end

local function goToHighScores()
	composer.gotoScene("highscores", { time = 800, effect = "crossFade" })
end

local function goToSettings()
	composer.gotoScene("settings", { time = 800, effect = "crossFade" })
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

	-- Code here runs when the scene is first created but has not yet appeared on screen
	local sceneGroup = self.view

	-- Load the background
	local background = display.newImageRect(sceneGroup, "background.png", 800, 1400)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	-- Load the title
	local title = display.newImageRect(sceneGroup, "title.png", 500, 80)
	title.x = display.contentCenterX
	title.y = 200

	-- Load the buttons
	local playButton = display.newText(sceneGroup, "Play", display.contentCenterX, 700, native.systemFont, 44)
	playButton:setFillColor(0.80, 0.85, 1)
	local highScoresButton = display.newText(sceneGroup, "High Scores", display.contentCenterX, 800, native.systemFont, 44)
	highScoresButton:setFillColor(0.70, 0.75, 1)
	local settingsButton = display.newText(sceneGroup, "Settings", display.contentCenterX, 900, native.systemFont, 44)
	settingsButton:setFillColor(0.60, 0.65, 1)

	-- Button handlers
	playButton:addEventListener("tap", goToGame)
	highScoresButton:addEventListener("tap", goToHighScores)
	settingsButton:addEventListener("tap", goToSettings)

	-- Background music
	musicTrack = audio.loadSound("audio/Escape_Looping.wav")
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		-- Start background music
		audio.play(musicTrack, {channel=1, loops=-1})
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		-- Remove the background music
		audio.stop(1)

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	-- Dispose of background music
	audio.dispose(musicTrack)
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene

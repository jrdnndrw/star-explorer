local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize variables
local json = require("json")
local scoreTable = {}
local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)
local musicTrack

local function loadScores()
	local file = io.open(filePath, "r")

	if file then
		local contents = file:read("*a")
		io.close(file)
		scoreTable = json.decode(contents)
	end

	if (scoreTable ==  nil or #scoreTable == 0) then
		scoreTable = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	end
end

local function saveScores()
	for i = #scoreTable, 11, -1 do
		table.remove(scoreTable, i)
	end

	local file = io.open(filePath, "w")

	if file then
		file:write(json.encode(scoreTable))
		io.close(file)
	end
end

local function goToMenu()
	composer.gotoScene("menu", { time = 800, effect = "crossFade" })
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local sceneGroup = self.view
	-- Load the previous scores
	loadScores()
	-- Insert the saved score from last game, then reset it
	table.insert(scoreTable, composer.getVariable("finalScore"))
	composer.setVariable("finalScore", 0)
	-- Sort the scores from high to low
	local function compare(a, b)
		return a > b
	end
	table.sort(scoreTable, compare)
	-- Saves the score
	saveScores()
	-- Load the background
	local background = display.newImageRect(sceneGroup, "background.png", 800, 1400)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	local highScoresHeader = display.newText(sceneGroup, "High Scores", display.contentCenterX, 100, native.systemFont, 44)
	for i = 1, 10 do
		if (scoreTable[i]) then
			local yPos = 150 +(i * 56)
			local rankNum = display.newText(sceneGroup, i..")", display.contentCenterX-50, yPos, native.systemFont, 36)
			rankNum:setFillColor(0.8)
			rankNum.anchorX = 1
			local thisScore = display.newText(sceneGroup, scoreTable[i], display.contentCenterX-30, yPos, native.systemFont, 36)
			thisScore.anchorX = 0
		end
	end
	local menuButton = display.newText(sceneGroup, "Menu", display.contentCenterX, 810, native.systemFont, 44)
	menuButton:setFillColor(0.75,0.78,1)
	menuButton:addEventListener("tap", goToMenu)
	-- Background music
	musicTrack = audio.loadSound("audio/Midnight-Crawlers_Looping.wav")
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
		composer.removeScene("highscores")
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

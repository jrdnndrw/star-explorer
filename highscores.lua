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
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

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

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

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

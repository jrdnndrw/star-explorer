-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Hide the status bar
display.setStatusBar(display.HiddenStatusBar)

-- Start the physics
local physics = require("physics")
physics.start()
physics.setGravity(0,0)

-- Seed the random number generator
math.randomseed(os.time())

-- Configure image sheet
local sheetOptions = {
    frames = {
        { -- astroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        { -- astroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        { -- astroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        { -- ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        { -- laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}
local objectSheet = graphics.newImageSheet("gameObjects.png", sheetOptions)

-- Initialized variables
local lives = 3
local score = 0
local died = false

local asteroidsTable = {}

local background
local ship
local gameLoopTimer
local livesText
local scoreText

-- Set up display groups, order is important
local backGroup = display.newGroup() -- for the background image
local mainGroup = display.newGroup() -- for the ship, astroid, lasers, etc
local uiGroup = display.newGroup() -- for the ui objects like score and lives

-- Load the background
background = display.newImageRect(backGroup, "background.png", 800, 1400)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Load the ship
ship = display.newImageRect(mainGroup, objectSheet, 4, 98, 79)
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody(ship, { radius=30, isSensor=true })
ship.myName = "ship" -- will help determine collisions

-- Display lives and scores
livesText = display.newText(uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36)
scoreText = display.newText(uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36)

-- Upates the lives and scores
local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: "  .. score
end

-- Create an asteroid
local function createAsteroid()
    local newAsteroid = display.newImageRect(mainGroup, objectSheet, 1, 102, 85)
    table.insert(asteroidsTable, newAsteroid)
    physics.addBody(newAsteroid, "dynamic", { radius=40, bounce=0.8})
    newAsteroid.myName = "asteroid"

    local whereFrom = math.random(3)
    if (whereFrom == 1) then
        -- 1 is from the left
        newAsteroid.x = -60 -- create outside the screan
        newAsteroid.y = math.random(500) -- randomly generate between top (1) and center (500) of the screen
        newAsteroid:setLinearVelocity(math.random(40, 120), math.random(20, 60)) -- random direction and velocity
    elseif (whereFrom == 2) then
        -- 2 is from the top
        newAsteroid.x = math.random(display.contentWidth)
        newAsteroid.y = -60
        newAsteroid:setLinearVelocity(math.random(-40, 40), math.random(40, 120))
    elseif (whereFrom == 3) then
        -- 3 is from the right
        newAsteroid.x = display.contentWidth + 60
        newAsteroid.y = math.random(500)
        newAsteroid:setLinearVelocity(math.random(-120, -40), math.random(20, 60))
    end
end
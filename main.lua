-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

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
local objectSheet = graphics.newImageSheet("gameObjects.png",sheetOptions)

-- Initialized variables
local lives = 3
local score = 0
local died = false

local astroidsTable = {}

local ship
local gameLoopTimer
local livesText
local scoreText

-- Set up display groups, order is important
local backGroup = display.newGroup() -- for the background image
local mainGroup = display.newGroup() -- for the ship, astroid, lasers, etc
local uiGroup = display.newGroup() -- for the ui objects like score and lives

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
local stringLives = "Lives: "
local score = 0
local stringScore = "Score: "
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
physics.addBody(ship, { radius = 30, isSensor = true })
ship.myName = "ship" -- will help determine collisions

-- Display lives and scores
livesText = display.newText(uiGroup, stringLives .. lives, 200, 80, native.systemFont, 36)
scoreText = display.newText(uiGroup, stringScore .. score, 400, 80, native.systemFont, 36)

-- Upates the lives and scores
local function updateText()
    livesText.text = stringLives .. lives
    scoreText.text = stringScore  .. score
end

-- Create an asteroid
local function createAsteroid()
    local newAsteroid = display.newImageRect(mainGroup, objectSheet, 1, 102, 85)
    table.insert(asteroidsTable, newAsteroid)
    physics.addBody(newAsteroid, "dynamic", { radius = 40, bounce = 0.8})
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
    newAsteroid:applyTorque(math.random(-6, 6))
end

local function fireLaser()
    local newLaser = display.newImageRect(mainGroup, objectSheet, 5, 14, 40)
    physics.addBody(newLaser, "dynamic", { isSensor = true })
    newLaser.isBullet = true
    newLaser.myName = "laser"
    newLaser.x = ship.x
    newLaser.y = ship.y
    newLaser:toBack()
    transition.to(newLaser, { y = -40, time = 500,
        onComplete = function() display.remove(newLaser) end
    })
end

ship:addEventListener("tap", fireLaser)

local function dragShip(event)
    local ship = event.target
    local phase = event.phase
    if (phase == "began") then
        -- Set touch focus on the ship
        display.currentStage:setFocus(ship)
        -- Store initial offset position
        ship.touchOffSetX = event.x - ship.x
        -- Store the ship on the y axis
        -- ship.touchOffSetY = event.y - ship.y
    elseif (phase == "moved") then
        -- Move the ship to the new touch position
        ship.x = event.x - ship.touchOffSetX
        -- Moving the ship on the y axis
        -- ship.y = event.y - ship.touchOffSetY
    elseif (phase == "ended" or phase == "cancelled") then
        -- Release touch focus on ship
        display.currentStage:setFocus(nil)
    end
    return true -- Prevents touch propagation to underlying objects
end

ship:addEventListener("touch", dragShip)

local function gameLoop()
    -- Create new asteroid
    createAsteroid()
    -- Remove asteroids that have drifted off screen
    -- Starts at asteroidsTable, stops at 1 and decrements 1
    for i = #asteroidsTable, 1, -1 do
        local thisAsteroid = asteroidsTable[i]
        if (
            thisAsteroid.x < -100 or
            thisAsteroid.x > display.contentWidth + 100 or
            thisAsteroid.y < -100 or
            thisAsteroid.y > display.contentHeight + 100
        ) then
            -- Removes the asteroid from display
            display.remove(thisAsteroid)
            -- Removes the asteroid from memory
            table.remove(asteroidsTable, i)
        end
    end
end

-- Variable allows to add pausing to the game
gameLoopTimer = timer.performWithDelay(1000, gameLoop, 0)

local function restoreShip()
    ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
    -- Fade in the ship
    transition.to(ship, {
        alpha = 1,
        time = 4000,
        onComplete = function ()
            ship.isBodyActive = true
            died = false
        end
    })
end

local function onCollision(event)
    if (event.phase == "began") then
        local obj1 = event.object1
        local obj2 = event.object2
        if (
            (obj1.myName == "laser" and obj2.myName == "asteroid") or
            (obj1.myName == "asteroid" and obj2.myName == "laser")
        ) then
            -- Remove both laser and asteroid
            display.remove(obj1)
            display.remove(obj2)
            for i = #asteroidsTable, 1, -1 do
                if (asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2) then
                    table.remove(asteroidsTable, i)
                    break
                end
            end
            -- Increase the score
            score = score + 100
            updateText()
        elseif (
            (obj1.myName == "ship" and obj2.myName == "asteroid") or
            (obj1.myName == "asteroid" and obj2.myName == "ship")
        ) then
            if(died == false)then
                died = true
                -- Update the lives
                lives = lives - 1
                updateText()
                -- livesText.text = stringLives .. lives
                if(lives == 0)then
                    -- Game over!
                    display.remove(ship)
                else
                    ship.alpha = 0
                    timer.performWithDelay(1000, restoreShip)
                end
            end
        end
    end
end

Runtime:addEventListener("collision", onCollision)
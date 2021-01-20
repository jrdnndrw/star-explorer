-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")

-- Hide the status bar
display.setStatusBar(display.HiddenStatusBar)

-- Seed the random number generator
math.randomseed(os.time())

-- Reserve channel 1 for background music
audio.reserveChannels(1)
-- Reduce the overall volume of the channel
audio.setVolume(0.5, {channel=1})

composer.gotoScene("menu")
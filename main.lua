local Party = require("mechanics.party")
local VortexScreen = require("screens.vortex")
local SummonScreen = require("screens.summon")

screen = "vortex"
local summonResult = nil

function love.load()
    love.window.setTitle("Summon System")
    love.window.setMode(800, 600)
end

function love.draw()
    if screen == "vortex" then
        VortexScreen.draw()
        Party.draw()
    elseif screen == "summon" then
        SummonScreen.draw()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if screen == "vortex" then
            VortexScreen.mousepressed(x, y, button)
        elseif screen == "summon" then
            SummonScreen.mousepressed()
        end
    end
end

function love.update(dt)
    if screen == "summon" then
        SummonScreen.update(dt, function()
            screen = "vortex"
        end)
    end
end

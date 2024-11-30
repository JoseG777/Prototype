local Party = require("mechanics.party")
local HomeScreen = require("screens.home")
local SummonScreen = require("screens.summon_screen")

local background

screen = "home"
summonResult = nil

function love.load()
    love.window.setTitle("Prototype")
    love.window.setMode(550, 800)
    background = love.graphics.newImage("assets/backgrounds/home.png")
    Party.loadAssets()
end

function love.draw()
    if screen == "home" then
        local bgWidth, bgHeight = background:getDimensions()
        local sx = 550 / bgWidth
        local sy = 800 / bgHeight
        love.graphics.draw(background, 0, 0, 0, sx, sy) 
        HomeScreen.draw()
        Party.draw()
    elseif screen == "summon" then
        SummonScreen.draw()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if screen == "home" then
            HomeScreen.mousepressed(x, y, button)
        elseif screen == "summon" then
            SummonScreen.mousepressed()
        end
    end
end

function love.update(dt)
    if screen == "home" then
        Party.update(dt)
    end
    if screen == "summon" then
        SummonScreen.update(dt, function()
            screen = "home"
        end)
    end
end

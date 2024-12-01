local Party = require("mechanics.party")
local HomeScreen = require("screens.home")
local SummonScreen = require("screens.summon_screen")
local Vortex = require("mechanics.vortex")
local BattleScreen = require("screens.battle_screen")

local background

screen = "battle" -- starting screen, change for testing
summonResult = nil

function love.load()
    love.window.setTitle("Prototype")
    love.window.setMode(550, 800)
    background = love.graphics.newImage("assets/backgrounds/home.png")
    math.randomseed(os.time())
    Party.loadAssets()
    Vortex.load()
    BattleScreen.load()
end

function love.draw()
    if screen == "home" then
        Party.isBattleMode = false

        local bgWidth, bgHeight = background:getDimensions()
        local sx = 550 / bgWidth
        local sy = 800 / bgHeight
        love.graphics.draw(background, 0, 0, 0, sx, sy)

        HomeScreen.draw()
        Vortex.draw()
        Party.draw() 
    elseif screen == "summon" then
        SummonScreen.draw()
    elseif screen == "battle" then
        Party.isBattleMode = true

        BattleScreen.draw()
        Party.draw() 
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if screen == "home" then
            if Vortex.isClicked(x, y) then
                screen = "battle"
            else
                HomeScreen.mousepressed(x, y, button)
            end
        elseif screen == "summon" then
            SummonScreen.mousepressed()
        elseif screen == "battle" then
            Party.mousepressed(x, y, button) 
        end
    end
end


function love.update(dt)
    if screen == "home" then
        Party.update(dt)
        Vortex.update(dt)
    elseif screen == "summon" then
        SummonScreen.update(dt, function()
            screen = "home"
        end)
    elseif screen == "battle" then
        Party.update(dt) 
        BattleScreen.update(dt)
    end
end

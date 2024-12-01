--[[ local Party = require("mechanics.party")
local HomeScreen = require("screens.home")
local SummonScreen = require("screens.summon_screen")
local Vortex = require("mechanics.vortex")
local BattleScreen = require("screens.battle_screen")

local background

screen = "home"
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
 ]]

 local lunajson = require("mechanics.lunajson")
 local Animation = require("mechanics.animation")
 local Combat = require("mechanics.combat")
 local Utils = require("utils")
 
 local reaper, magicKnight, combatState
 cachedAnimations = {}

 
 function love.load()
     love.window.setTitle("Battle Scene")
     love.window.setMode(550, 800)
 
     -- Load JSON for character and enemy
     local charactersJson = love.filesystem.read("characters.json")
     local enemiesJson = love.filesystem.read("enemies.json")
 
     local charactersData = lunajson.decode(charactersJson)
     local enemiesData = lunajson.decode(enemiesJson)
 
     -- Reaper (Enemy)
     local reaperData = enemiesData["Reaper"]
     reaper = {
         name = reaperData.name,
         idleAnimation = Animation.new(
             reaperData.idle.file,
             reaperData.idle.frameCount,
             reaperData.idle.frameDuration,
             3,
             reaperData.idle.rows
         ),
         position = {x = -50, y = 350},
         animation = nil
     }
     reaper.animation = reaper.idleAnimation
 
     -- Magic Knight (Character)
     local magicKnightData = charactersData["Magic Knight"]
     magicKnight = {
         name = magicKnightData.name,
         idleAnimation = Animation.new(
             magicKnightData.idle.file,
             magicKnightData.idle.frameCount,
             magicKnightData.idle.frameDuration,
             2.5
         ),
         position = {x = 375, y = 425},
         animation = nil
     }
     magicKnight.animation = magicKnight.idleAnimation
 
     -- Initialize combatState as nil
     combatState = nil
 end
 
 function love.update(dt)
     if combatState then
         combatState:update(dt)
     else
         reaper.animation:update(dt)
         magicKnight.animation:update(dt)
     end
 end
 
 function love.draw()
     love.graphics.clear(1, 1, 1)
 
     if combatState then
         combatState:draw()
     else
         reaper.animation:draw(reaper.position.x, reaper.position.y, false)
         magicKnight.animation:draw(magicKnight.position.x, magicKnight.position.y, true)
     end
 end
 
 function love.keypressed(key)
     if not combatState and key == "space" then
         combatState = Combat.performAttack(
             magicKnight,
             reaper,
             3,
             function()
                 combatState = nil
             end
         )
     end
 end
 
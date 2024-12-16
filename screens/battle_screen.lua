local Enemy = require("mechanics.enemy")
local Party = require("mechanics.party")

local BattleScreen = {}
local background
local possible_enemies = {"Orc", "Orc Rider", "Skeleton", "Greatsword Skeleton", "Werewolf", "Werebear"}


local function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end


function BattleScreen.startNewWave()
    Enemy.enemies = {nil,nil,nil,nil,nil,nil}
    Enemy.enemyInfo = {}
    Enemy.currEnemyAnimation = {}
    Enemy.currentCombatStates = {}
    Enemy.isAttacking = {}
    Enemy.enemyTargetSelected = {}
    Enemy.attackCounter = 0
    Enemy.calledPAOnce = false
    Party.attackedCount = 0

    local numEnemies = math.random(1, 6)

    local unpack = unpack or table.unpack
    local shuffledEnemies = {unpack(possible_enemies)}
    shuffle(shuffledEnemies)

    for i = 1, numEnemies do
        local enemyName = shuffledEnemies[i]
        Enemy.addNewEnemy(enemyName)
    end

    print("New wave started with", numEnemies, "enemies.")
end


function BattleScreen.load()
    background = love.graphics.newImage("assets/backgrounds/battle.png")
    BattleScreen.startNewWave() 
end


function BattleScreen.update(dt)
    if Enemy.defeated() then
        Party.attackFinished = {}
        print("CALLED")
        BattleScreen.startNewWave()
    else
        Enemy.update(dt)
    end
end


function BattleScreen.draw()
    local bgWidth, bgHeight = background:getDimensions()
    local sx = 550 / bgWidth
    local sy = 800 / bgHeight
    love.graphics.draw(background, 0, 0, 0, sx, sy)
    Enemy.draw() 
    Party.draw() 
end

return BattleScreen

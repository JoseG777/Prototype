local lunajson = require("mechanics.lunajson")
local Animation = require("mechanics.animation")
local Party = require("mechanics.party")
local Combat = require("mechanics.combat")
local Utils = require("utils")

local Enemy = {}
Enemy.currentCombatState = nil
Enemy.currentTarget = nil


function selectRandomTarget()
    local aliveTargets = {} 

    for _, target in pairs(Party.targetUnits) do
        if target.alive then 
            table.insert(aliveTargets, target)
        end
    end

    if #aliveTargets > 0 then
        return aliveTargets[math.random(#aliveTargets)]
    else
        return nil 
    end
end


function Enemy.new(name)
    local jsonData = love.filesystem.read("enemies.json")
    if not jsonData then
        error("Failed to read enemies.json")
    end

    local enemyData = lunajson.decode(jsonData)
    local enemyInfo = enemyData[name]

    if not enemyInfo then
        error("No data found for enemy: " .. name)
    end

    local enemy = {}
    enemy.name = name
    enemy.stats = enemyInfo.stats
    enemy.maxHP = enemyInfo.stats.HP
    enemy.position = enemyInfo.position or {x = 0, y = 0}
    enemy.scale = enemyInfo.scale or 1
    enemy.idleAnimation = Animation.new(
        enemyInfo.idle.file,
        enemyInfo.idle.frameCount,
        enemyInfo.idle.frameDuration,
        enemy.scale,
        enemyInfo.idle.rows
    )
    enemy.death = Animation.new(
        enemyInfo.death.file,
        enemyInfo.death.frameCount,
        enemyInfo.death.frameDuration,
        enemy.scale,
        enemyInfo.death.rows,
        false
    )
    enemy.skills = {}
    enemy.isEnemy = true
    for _, skill_info in pairs(enemyInfo.skills) do
        local attack = Animation.new(
            skill_info.file,
            skill_info.frameCount,
            skill_info.frameDuration,
            enemy.scale,
            skill_info.rows
        )
        local atk_info = {
            attack,
            skill_info
        }
        table.insert(enemy.skills, atk_info)
    end
    enemy.animation = enemy.skills[1][1]


    function enemy:update(dt)
        if enemy.stats.HP > 0 and Party.playerTurn then
            self.idleAnimation:update(dt)
            -- print("Player Turn:", Party.playerTurn)
        end
        if not Party.playerTurn and Enemy.currentCombatState then
            Enemy.currentCombatState:update(dt)
        end
    end

    Enemy.currentTarget = selectRandomTarget()

    Enemy.currentCombatState = Combat.performAttack(
        enemy,
        Enemy.currentTarget,
        enemy.skills[1][1],
        enemy.skills[1][2],
        function()
            Party.attackedCount = 5 
            Party.playerTurn = true
        end
    )
    

    function enemy:draw()
        if enemy.stats.HP > 0 and Party.playerTurn then
            -- local offsetX = (self.idleAnimation.frameWidth * self.scale) / 2 
            -- local offsetY = (self.idleAnimation.frameHeight * self.scale) / 2
            self.idleAnimation:draw(self.position.x, self.position.y, false)
            -- Enemy.currentTarget = selectRandomTarget()
            -- print(Enemy.currentTarget.stats.HP)
            local barWidth = 100 
            local barHeight = 10 
            local barX = self.position.x - barWidth / 2 
            local barY = self.position.y - 80 
    
            local hpPercent = math.max(0, self.stats.HP / enemy.maxHP)
    
            love.graphics.setColor(0.2, 0.2, 0.2) 
            love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
            love.graphics.setColor(0.8, 0.1, 0.1) 
            love.graphics.rectangle("fill", barX, barY, barWidth * hpPercent, barHeight)
    
            love.graphics.setColor(1, 1, 1) 
            love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
        -- end
        else
            Enemy.currentCombatState:draw()
        end
    end

    return enemy
end

return Enemy

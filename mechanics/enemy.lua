local lunajson = require("mechanics.lunajson")
local Animation = require("mechanics.animation")
local Party = require("mechanics.party")
local Combat = require("mechanics.combat")
local Utils = require("utils")

local Enemy = {}

Enemy.currentCombatState = nil

Enemy.currentTarget = nil
Enemy.enemies = {"Orc Rider", "Werewolf", "Werebear", "Orc", "Skeleton", "Greatsword Skeleton"}
Enemy.enemySkills = {}

Enemy.animations = {}
Enemy.currEnemyAnimation = {}
Enemy.currentCombatStates = {}
Enemy.isAttacking = {}
Enemy.enemyTargetSelected = {}

Enemy.enemyInfo = {}
Enemy.enemyTotalHP = {}
Enemy.attackCounter = 0 

Enemy.calledPAOnce = false

Enemy.positions = {
    {x = 100, y = 275}, -- Slot 1
    {x = 200, y = 275}, -- Slot 2
    {x = 100, y = 375}, -- Slot 3
    {x = 200, y = 375}, -- Slot 4
    {x = 100, y = 475}, -- Slot 5
    {x = 200, y = 475}  -- Slot 6
}


function Enemy.noCombat()
    for i = 1, 6 do
        if Enemy.currentCombatStates[Enemy.enemies[i]] then
            -- print("true")
            -- print(Enemy.enemies[i])
            return true
        end
    end
   --  print("false")
    return false
end


function Enemy.getIndex(enemy)
    for i = 1, 6 do
        if Enemy.enemies[i] and Enemy.enemies[i] == enemy then
            return i
        end
    end
end


function Enemy.selectRandomTarget()
    local aliveTargets = {} 

    for _, target in pairs(Party.targetUnits) do
        if target.stats.HP > 0 then 
            table.insert(aliveTargets, target)
        end
    end

    if #aliveTargets > 0 then
        return aliveTargets[math.random(#aliveTargets)]
    else
        return nil 
    end
end


function Enemy.loadAssetsFor(enemy)
    local enemyDataRaw = love.filesystem.read("enemies.json")
    if not enemyDataRaw then
        error("Failed to read enemies.json")
    end

    local enemyData = lunajson.decode(enemyDataRaw)
    if not enemyData then
        error("Failed to decode enemies.json")
    end

    local data = enemyData[enemy]
    if not data then
        print("enemy not found in JSON:", enemy)
        return
    end

    Enemy.animations[enemy] = {
        idle = Animation.new(
            data.idle.file,
            data.idle.frameCount,
            data.idle.frameDuration,
            2.5
        ),
        death = Animation.new(
            data.death.file,
            data.death.frameCount,
            data.death.frameDuration,
            2.5,
            false
        )
    }

    if data.skills then
        Enemy.enemySkills[enemy] = {}
        for _, atk_data in pairs(data.skills) do
            local attack = Animation.new(
                atk_data.file,
                atk_data.frameCount,
                atk_data.frameDuration,
                2.5
            )
            local atk_info = {
                attack,
                atk_data.name,
                atk_data.description,
                atk_data
            }
            table.insert(Enemy.enemySkills[enemy], atk_info)
        end
    end

    Enemy.currEnemyAnimation[enemy] = Enemy.animations[enemy].idle

    local position_index = Enemy.getIndex(enemy)
    local total_hp = data.stats.HP

    Enemy.enemyInfo[enemy] = {
        position = {x = Enemy.positions[position_index].x, y = Enemy.positions[position_index].y}, 
        stats = {HP = data.stats.HP, ATK = data.stats.ATK, DEF = data.stats.DEF, MAG = data.stats.MAG},
        deathTriggered = false}

    Enemy.enemyTotalHP[enemy] = {total_hp}
    Party.setEnemy(Enemy.enemyInfo[enemy])
end


function Enemy.triggerDeath(enemyName)
    local enemyInfo = Enemy.enemyInfo[enemyName]
    if not enemyInfo.deathTriggered then
        enemyInfo.deathTriggered = true
        Enemy.currEnemyAnimation[enemyName] = Enemy.animations[enemyName].death
        Enemy.currEnemyAnimation[enemyName]:reset() 
    end
end


function Enemy.loadAssets()
    for _, enemy in ipairs(Enemy.enemies) do
        Enemy.loadAssetsFor(enemy)
    end
end


function Enemy.performAttack(enemyName)
    -- for _, enemyName in ipairs(Enemy.enemies) do
        local enemyInfo = Enemy.enemyInfo[enemyName]
        if enemyInfo.stats.HP > 0 and not Enemy.enemyTargetSelected[enemyName] then
            local target = Enemy.selectRandomTarget()
            Enemy.enemyTargetSelected[enemyName] = true
            if target then
                -- print("we are here in pa "..enemyName)
                -- Utils.printTable(Enemy.enemySkills[enemyName][1])
                Enemy.currentCombatStates[enemyName] = Combat.performAttack(
                    {
                        name = enemyName,
                        position = enemyInfo.position,
                        animation = Enemy.enemySkills[enemyName],
                        idleAnimation = Enemy.animations[enemyName].idle,
                        stats = enemyInfo.stats,
                        isEnemy = true
                    },
                    target,
                    Enemy.enemySkills[enemyName][1][1], 
                    Enemy.enemySkills[enemyName][1][4], 
                    function()
                        Enemy.currentCombatStates[enemyName] = nil
                        Enemy.attackCounter = Enemy.attackCounter + 1
                        -- print(" called ")
                        Enemy.enemyTargetSelected[enemyName] = false
                        if Enemy.attackCounter >= #Enemy.enemies then
                            Enemy.attackCounter = 0 
                            Party.playerTurn = true 
                            Party.attackedCount = 0
                            Enemy.calledPAOnce = false
                        end
                    end
                )
                return 
            end
        end
    -- end
end


function Enemy.update(dt)
    -- print(Enemy.currentCombatStates["Orc Rider"])
    if not Party.playerTurn then
        if not Enemy.calledPAOnce then
            -- Enemy.performAttack()
            if Enemy.enemies[1] then
                Enemy.performAttack(Enemy.enemies[1])
            end
            if Enemy.enemies[2] then
                Enemy.performAttack(Enemy.enemies[2])
            end
            if Enemy.enemies[3] then
                Enemy.performAttack(Enemy.enemies[3])
            end
            if Enemy.enemies[4] then
                Enemy.performAttack(Enemy.enemies[4])
            end
            if Enemy.enemies[5] then
                Enemy.performAttack(Enemy.enemies[5])
            end
            if Enemy.enemies[6] then
                Enemy.performAttack(Enemy.enemies[6])
            end
            Enemy.calledPAOnce = true
        end
        print(Enemy.calledPAOnce)
        if Enemy.noCombat() then
            if Enemy.enemies[1] and Enemy.currentCombatStates[Enemy.enemies[1]] then
                Enemy.currentCombatStates[Enemy.enemies[1]]:update(dt)
            end
            if Enemy.enemies[2] and Enemy.currentCombatStates[Enemy.enemies[2]] then
                Enemy.currentCombatStates[Enemy.enemies[2]]:update(dt)
            end
            if Enemy.enemies[3] and Enemy.currentCombatStates[Enemy.enemies[3]] then
                Enemy.currentCombatStates[Enemy.enemies[3]]:update(dt)
            end
            if Enemy.enemies[4] and Enemy.currentCombatStates[Enemy.enemies[4]] then
                Enemy.currentCombatStates[Enemy.enemies[4]]:update(dt)
            end
            if Enemy.enemies[5] and Enemy.currentCombatStates[Enemy.enemies[5]] then
                Enemy.currentCombatStates[Enemy.enemies[5]]:update(dt)
            end
            if Enemy.enemies[6] and Enemy.currentCombatStates[Enemy.enemies[6]] then
                Enemy.currentCombatStates[Enemy.enemies[6]]:update(dt)
            end
        end
    end

    if Enemy.enemies[1] and Enemy.currEnemyAnimation[Enemy.enemies[1]] then
        Enemy.currEnemyAnimation[Enemy.enemies[1]]:update(dt)
    end
    if Enemy.enemies[2] and Enemy.currEnemyAnimation[Enemy.enemies[2]] then
        Enemy.currEnemyAnimation[Enemy.enemies[2]]:update(dt)
    end
    if Enemy.enemies[3] and Enemy.currEnemyAnimation[Enemy.enemies[3]] then
        Enemy.currEnemyAnimation[Enemy.enemies[3]]:update(dt)
    end
    if Enemy.enemies[4] and Enemy.currEnemyAnimation[Enemy.enemies[4]] then
        Enemy.currEnemyAnimation[Enemy.enemies[4]]:update(dt)
    end
    if Enemy.enemies[5] and Enemy.currEnemyAnimation[Enemy.enemies[5]] then
        Enemy.currEnemyAnimation[Enemy.enemies[5]]:update(dt)
    end
    if Enemy.enemies[6] and Enemy.currEnemyAnimation[Enemy.enemies[6]] then
        Enemy.currEnemyAnimation[Enemy.enemies[6]]:update(dt)
    end

    -- Enemy.currEnemyAnimation["Orc Rider"]:update(dt)

end


function Enemy.draw()
    for _, enemyName in ipairs(Enemy.enemies) do
        local enemyInfo = Enemy.enemyInfo[enemyName]
        local animation = Enemy.currEnemyAnimation[enemyName]
        local currHP = enemyInfo.stats.HP

        if not Enemy.currentCombatStates[enemyName] then
            if currHP > 0 and not Enemy.currentCombatStates[enemyName] then
                animation:draw(enemyInfo.position.x, enemyInfo.position.y, false)

                local barWidth = 100
                local barHeight = 10
                local barX = enemyInfo.position.x - barWidth / 2
                local barY = enemyInfo.position.y - 80

                if enemyName ~= "Orc Rider" then
                    barY = barY + 20
                end

                local hpPercent = math.max(0, currHP / Enemy.enemyTotalHP[enemyName][1])

                love.graphics.setColor(0.2, 0.2, 0.2)
                love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)

                love.graphics.setColor(0.8, 0.1, 0.1)
                love.graphics.rectangle("fill", barX, barY, barWidth * hpPercent, barHeight)

                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
            -- elseif currHP > 0 and Enemy.currentCombatStates[enemyName] then
            --    Enemy.currentCombatStates[enemyName]:draw()
            else
                local deathAnimation = Enemy.animations[enemyName].death
                deathAnimation:drawFrame(#deathAnimation.frames, enemyInfo.position.x, enemyInfo.position.y, false)
            end
        end
    end

    if Enemy.noCombat() then
        for i = 1, 6 do
            -- print("checking "..Enemy.enemies[i])
            -- print(Enemy.currentCombatStates[Enemy.enemies[i]])
            if Enemy.currentCombatStates[Enemy.enemies[i]] then
                -- print("drawing ".. Enemy.enemies[i])
                Enemy.currentCombatStates[Enemy.enemies[i]]:draw()
            end
        end
    end

end


--[[function Enemy.new(name)
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
            -- Enemy.currEnemyAnimation["Orc Rider"]:update(dt)
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
            Enemy.currentTarget = selectRandomTarget()
        end
    )
    

    function enemy:draw()
        local enemy = "Orc Rider" 
        local enemyInfo = Enemy.enemyInfo[enemy]
        local animation = Enemy.animations[enemy]
        local currHP = enemyInfo.stats.HP
        local maxHP = Enemy.enemyTotalHP[enemy][1]
    
        if currHP > 0 then
            animation.idle:draw(enemyInfo.position.x, enemyInfo.position.y, false)
    
            local barWidth = 100
            local barHeight = 10
            local barX = enemyInfo.position.x - barWidth / 2
            local barY = enemyInfo.position.y - 80
    
            local hpPercent = math.max(0, currHP / maxHP)
    
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
            love.graphics.setColor(0.8, 0.1, 0.1)
            love.graphics.rectangle("fill", barX, barY, barWidth * hpPercent, barHeight)
    
            love.graphics.setColor(1, 1, 1) 
            love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
        else
            Enemy.currentCombatState:draw()
        end
    end


    return enemy
end]]

return Enemy

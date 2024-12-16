local lunajson = require("mechanics.lunajson")
local Animation = require("mechanics.animation")
local Party = require("mechanics.party")
local Combat = require("mechanics.combat")
local Utils = require("utils")

local Enemy = {}

-- Enemy.currentCombatState = nil

-- Enemy.currentTarget = nil
Enemy.enemies = {nil, nil, nil, nil, nil, nil}
Enemy.aliveEnemies = {}
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

Enemy.drawEnemies = true

Enemy.positions = {
    {x = 100, y = 275}, -- Slot 1
    {x = 200, y = 275}, -- Slot 2
    {x = 100, y = 375}, -- Slot 3
    {x = 200, y = 375}, -- Slot 4
    {x = 100, y = 475}, -- Slot 5
    {x = 200, y = 475}  -- Slot 6
}

Enemy.predefinedRects = {
    {leftX = 75, upperY = 250}, -- Slot 1
    {leftX = 175, upperY = 250}, -- Slot 2
    {leftX = 75, upperY = 350}, -- Slot 3
    {leftX = 175, upperY = 350}, -- Slot 4
    {leftX = 75, upperY = 450}, -- Slot 5
    {leftX = 175, upperY = 450}, -- Slot 6
}


function Enemy.printDebugInfo()
    print("===== Enemy Debug Info =====")
    for enemyName, enemyInfo in pairs(Enemy.enemyInfo) do
        if enemyInfo then
            print("Enemy Name:", enemyName)
            if enemyInfo.position then
                print("  Position: x =", enemyInfo.position.x, "y =", enemyInfo.position.y)
            else
                print("  Position: None")
            end
            if enemyInfo.stats then
                print("  HP:", enemyInfo.stats.HP, "ATK:", enemyInfo.stats.ATK, "DEF:", enemyInfo.stats.DEF, "MAG:", enemyInfo.stats.MAG)
            else
                print("  Stats: None")
            end
            print("  Death Triggered:", enemyInfo.deathTriggered)
        else
            print("Enemy Name:", enemyName, "-> Missing Info!")
        end
    end
    print("===========================")
end


function Enemy.defeated()
    for _, enemyInfo in pairs(Enemy.enemyInfo) do
        if enemyInfo.stats.HP > 0 then
            Enemy.drawEnemies = true
            return false
        end
    end
    Enemy.drawEnemies = false
    return true
end


function Enemy.lastEnemy()
    local count = 0
    for _, enemyInfo in pairs(Enemy.enemyInfo) do
        if enemyInfo.stats.HP > 0 then
            count = count + 1
        end
    end
    return count == 1
end


function Enemy.setNewEnemy()
    for enemyName, enemyInfo in pairs(Enemy.enemyInfo) do
        if enemyInfo.stats.HP > 0 then
            Party.setEnemy(Enemy.enemyInfo[enemyName])
            return
        end
    end
end


function Enemy.noCombat()
    for i = 1, 6 do
        if Enemy.currentCombatStates[Enemy.enemies[i]] then
            return true
        end
    end
    return false
end


function Enemy.getIndex(enemy)
    for i = 1, 6 do
        if Enemy.enemies[i] and Enemy.enemies[i] == enemy then
            return i
        end
    end
    print("Enemy.getIndex: Unable to find index for", enemy)
    return nil
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

    print("we make it here")

    Enemy.enemyInfo[enemy] = {
        position = {x = Enemy.positions[position_index].x, y = Enemy.positions[position_index].y}, 
        stats = {HP = data.stats.HP, ATK = data.stats.ATK, DEF = data.stats.DEF, MAG = data.stats.MAG},
        deathTriggered = false}

    Enemy.enemyTotalHP[enemy] = {total_hp}
    Party.setEnemy(Enemy.enemyInfo[enemy])
end


--[[function Enemy.triggerDeath(enemyName)
    local enemyInfo = Enemy.enemyInfo[enemyName]
    if not enemyInfo.deathTriggered then
        enemyInfo.deathTriggered = true
        Enemy.currEnemyAnimation[enemyName] = Enemy.animations[enemyName].death
        Enemy.currEnemyAnimation[enemyName]:reset() 
    end
end]]


function Enemy.updateAliveEnemies()
    for i = #Enemy.aliveEnemies, 1, -1 do 
        local enemyName = Enemy.aliveEnemies[i]
        local enemyInfo = Enemy.enemyInfo[enemyName]

        if enemyInfo and enemyInfo.stats.HP <= 0 then
            table.remove(Enemy.aliveEnemies, i)
            print("Removed", enemyName, "from aliveEnemies")
        end
    end
end


function Enemy.loadAssets()
    for _, enemy in ipairs(Enemy.enemies) do
        Enemy.loadAssetsFor(enemy)
    end
end


function Enemy.addNewEnemy(enemy)
    local insert_index = nil
    for i = 1, 6 do
        if not Enemy.enemies[i] then
            Enemy.enemies[i] = enemy
            insert_index = i
            break
        end
    end
    table.insert(Enemy.aliveEnemies, enemy)
    Enemy.loadAssetsFor(enemy)
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
                        if Enemy.attackCounter >= #Enemy.aliveEnemies then
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
    -- print(Enemy.lastEnemy())
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
        -- print(Enemy.calledPAOnce)
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
    -- Enemy.printDebugInfo()
    Enemy.updateAliveEnemies()

    if not Enemy.drawEnemies then return end

    if not Party.currentEnemy then
        Enemy.setNewEnemy()
    end

    for _, enemyName in ipairs(Enemy.enemies) do
        local enemyInfo = Enemy.enemyInfo[enemyName]
        if not enemyInfo then
            print("Enemy info missing for:", enemyName)
            goto continue
        end
        local enemyInfo = Enemy.enemyInfo[enemyName]
        local animation = Enemy.currEnemyAnimation[enemyName]
        -- print(enemyInfo.stats.HP)
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
        ::continue::
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

    --[[for i, rect in ipairs(Enemy.predefinedRects) do
        love.graphics.setColor(0, 1, 0, 0.3) 
        love.graphics.rectangle(
            "fill", 
            rect.leftX, 
            rect.upperY, 
            50,
            50
        )
    end
    love.graphics.setColor(1, 1, 1, 1)]]

end


function Enemy.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- Iterate over predefined rects to check if clicked
    for i, box in ipairs(Enemy.predefinedRects or {}) do
        local curr_enemy = Enemy.enemies[i]

        if curr_enemy and Enemy.enemyInfo[curr_enemy] and Enemy.enemyInfo[curr_enemy].stats.HP > 0 then
            -- Check if click is inside the box
            if x >= box.leftX and x <= box.leftX + 50 and y >= box.upperY and y <= box.upperY + 50 then
                Party.setEnemy(Enemy.enemyInfo[curr_enemy])
                print(curr_enemy, "is alive and clicked!")
            end
        -- elseif curr_enemy then
        --    print(curr_enemy, "is dead.")
        end
    end
end


return Enemy
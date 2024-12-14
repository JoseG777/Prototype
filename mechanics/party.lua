local lunajson = require("mechanics.lunajson")
local Animation = require("mechanics.animation")
local Combat = require("mechanics.combat")
local Utils = require("utils")

local Party = {}

Party.members = {"Swordsman", "Archer","Priest", nil, nil, nil} -- max of 6 units
Party.memberStats = {}
-- Party.currMemberStats = {}
Party.memberSkills = {} -- max of 5 skills per unit
Party.animations = {}
Party.currUnitAnimation = {}
Party.selectedAttack = {} -- only one loaded attack for now
Party.selectedAttackData = {} 

Party.slots = { 
    {x = 137.5, y = 516}, -- Slot 1 {x = 412.5, y = 516}
    {x = 412.5, y = 516}, -- Slot 2 {x = 412.5, y = 598}
    {x = 137.5, y = 598}, -- Slot 3 {x = 412.5, y = 680}
    {x = 412.5, y = 598}, -- Slot 4 {x = 137.5, y = 516}
    {x = 137.5, y = 680}, -- Slot 5 {x = 137.5, y = 598}
    {x = 412.5, y = 680}  -- Slot 6 {x = 137.5, y = 680}
}
Party.predefinedRects = {
    {leftX = 375, upperY = 250}, -- Slot 1
    {leftX = 475, upperY = 250}, -- Slot 2
    {leftX = 375, upperY = 350}, -- Slot 3
    {leftX = 475, upperY = 350}, -- Slot 4
    {leftX = 375, upperY = 450}, -- Slot 5
    {leftX = 475, upperY = 450}, -- Slot 6
}
Party.unitPositions = {
    {x = 400, y = 275}, -- Slot 1
    {x = 500, y = 275}, -- Slot 2
    {x = 400, y = 375}, -- Slot 3
    {x = 500, y = 375}, -- Slot 4
    {x = 400, y = 475}, -- Slot 5
    {x = 500, y = 475}  -- Slot 6
}

Party.attackSelectionMode = false
Party.selectedUnit = nil
Party.isBattleMode = false 
Party.currentAnimation = nil
Party.currentEnemy = nil

Party.currentAttackers = {nil, nil, nil, nil, nil, nil}
Party.currentAttackerIndexes = {nil, nil, nil, nil, nil, nil}
Party.currentCombatStates = {nil, nil, nil, nil, nil, nil} 

Party.targetUnits = {}
Party.attackedCount = 5
Party.playerTurn = true

function Party.setEnemy(enemy)
    Party.currentEnemy = enemy
end


function Party.getIndex(unit)
    for i = 1, 6 do
        if Party.members[i] and Party.members[i] == unit then
            return i
        end
    end
end


function Party.isPlayerTurn()
    if Party.attackedCount >= 6 then
        Party.playerTurn = false
    end
end


function Party.loadAssetsFor(unit)
    local characterDataRaw = love.filesystem.read("characters.json")
    if not characterDataRaw then
        error("Failed to read characters.json")
    end

    local characterData = lunajson.decode(characterDataRaw)
    if not characterData then
        error("Failed to decode characters.json")
    end

    local data = characterData[unit]
    if not data then
        print("Unit not found in JSON:", unit)
        return
    end

    Party.animations[unit] = {
        idle = Animation.new(
            data.idle.file,
            data.idle.frameCount,
            data.idle.frameDuration,
            2.5
        )
    }

    if data.skills then
        Party.memberSkills[unit] = {}
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
            table.insert(Party.memberSkills[unit], atk_info)
        end
    end

    Party.memberStats[unit] = {
        HP = data.stats.HP,
        MP = data.stats.MP,
        ATK = data.stats.ATK,
        DEF = data.stats.DEF,
        MAG = data.stats.MAG
    }
    
    --[[Party.currMemberStats[unit] = {
        currHP = data.stats.HP,
        currMP = data.stats.MP
    }]]

    Party.currUnitAnimation[unit] = Party.animations[unit].idle
    Party.selectedAttack[unit] = nil

    local position_index = Party.getIndex(unit)
    local curr_HP = data.stats.HP
    local curr_MP = data.stats.MP
    local curr_DEF = data.stats.DEF

    Party.targetUnits[unit] = {position = {x = Party.unitPositions[position_index].x , y = Party.unitPositions[position_index].y}, stats = {HP = curr_HP, MP = curr_MP, DEF = curr_DEF}, alive = true}
    -- Utils.printTable(Party.targetUnits[unit])
end



function Party.addSummonedUnit(unit)
    Party.loadAssetsFor(unit)
    for i = 1, 6 do
        if not Party.members[i] then
            Party.members[i] = unit
            Party.currUnitAnimation[unit] = Party.animations[unit].idle
            Party.selectedAttack[unit] = nil
            return
        end
    end
end


function Party.selectAttack(skillIndex)
    if Party.selectedUnit and Party.memberSkills[Party.selectedUnit] then
        Party.members[Party.selectedUnit].selectedAttack = skillIndex
        Party.attackSelectionMode = false
    end
end


function Party.loadAssets()
    local characterDataRaw = love.filesystem.read("characters.json")
    if not characterDataRaw then
        error("Failed to read characters.json")
    end

    local characterData = lunajson.decode(characterDataRaw)
    if not characterData then
        error("Failed to decode characters.json")
    end

    for _, unit in ipairs(Party.members) do
        Party.loadAssetsFor(unit)
    end
end


function Party.noCombat()
    for i = 1, 6 do
        if Party.currentCombatStates[i] then
            return true
        end
    end
    return false
end


function Party.update(dt)
    if Party.members[1] and Party.currUnitAnimation[Party.members[1]] then
        Party.currUnitAnimation[Party.members[1]]:update(dt)
    end
    if Party.members[2] and Party.currUnitAnimation[Party.members[2]] then
        Party.currUnitAnimation[Party.members[2]]:update(dt)
    end
    if Party.members[3] and Party.currUnitAnimation[Party.members[3]] then
        Party.currUnitAnimation[Party.members[3]]:update(dt)
    end
    if Party.members[4] and Party.currUnitAnimation[Party.members[4]] then
        Party.currUnitAnimation[Party.members[4]]:update(dt)
    end
    if Party.members[5] and Party.currUnitAnimation[Party.members[5]] then
        Party.currUnitAnimation[Party.members[5]]:update(dt)
    end
    if Party.members[6] and Party.currUnitAnimation[Party.members[6]] then
        Party.currUnitAnimation[Party.members[6]]:update(dt)
    end
    
    if Party.noCombat() then
        -- Party.currentCombatState:update(dt)
        if Party.currentCombatStates[1] then
            Party.currentCombatStates[1]:update(dt)
        end
        if Party.currentCombatStates[2] then
            Party.currentCombatStates[2]:update(dt)
        end
        if Party.currentCombatStates[3] then
            Party.currentCombatStates[3]:update(dt)
        end
        if Party.currentCombatStates[4] then
            Party.currentCombatStates[4]:update(dt)
        end
        if Party.currentCombatStates[5] then
            Party.currentCombatStates[5]:update(dt)
        end
        if Party.currentCombatStates[6] then
            Party.currentCombatStates[6]:update(dt)
        end
    end
    
end


function Party.draw()
    for i = 1, 6 do
        if not Party.currentAttackerIndexes[i] then
            if Party.members[i] and Party.currUnitAnimation[Party.members[i]] then
                Party.currUnitAnimation[Party.members[i]]:draw(Party.unitPositions[i].x, Party.unitPositions[i].y, true)
            end
        end
    end

    if Party.noCombat() then
        for i = 1, 6 do
            if Party.currentCombatStates[i] then
                Party.currentCombatStates[i]:draw()
            end
        end
    end

    for i, rect in ipairs(Party.predefinedRects) do
        love.graphics.setColor(0, 1, 0, 0.3) 
        love.graphics.rectangle(
            "fill", 
            rect.leftX, 
            rect.upperY, 
            50,
            50
        )
    end
    love.graphics.setColor(1, 1, 1, 1)


    if Party.playerTurn then 
        if Party.isBattleMode and not Party.attackSelectionMode then
            for i, slot in ipairs(Party.slots) do
                if Party.members[i] then
                    local member = Party.members[i]

                    love.graphics.setColor(0, 0, 0, 1)
                    love.graphics.rectangle("fill", slot.x - 137.5, slot.y + 10, 275, 82)
                    love.graphics.setColor(1, 1, 1, 1)
                    
                    local formattedMemberInfo = string.format("%s\nHP: %d/%d\n MP: %d/%d", member, Party.targetUnits[member].stats.HP, Party.memberStats[member].HP, Party.targetUnits[member].stats.MP, Party.memberStats[member].MP)
                    love.graphics.printf(
                        formattedMemberInfo,
                        slot.x - 40,
                        slot.y + 30,
                        85,
                        "center"
                    )
                else
                    love.graphics.setColor(0, 0, 0, 1)
                    love.graphics.rectangle("fill", slot.x - 137.5, slot.y + 10, 275, 82)
                    love.graphics.setColor(1, 1, 1, 1) 
                    love.graphics.printf("Empty", slot.x - 137.5, slot.y + 35, 275, "center")  
                end
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle("line", slot.x - 137.5, slot.y + 10, 275, 82)
            end
        elseif Party.isBattleMode and Party.attackSelectionMode then
            local skills = Party.memberSkills[Party.selectedUnit]
            for i, slot in ipairs(Party.slots) do
                if i == 6 then
                    love.graphics.setColor(0, 0, 0, 1)
                    love.graphics.rectangle("fill", slot.x - 137.5, slot.y + 10, 275, 82)
                    love.graphics.setColor(1, 1, 1, 1) 
                    love.graphics.printf("Exit", slot.x - 137.5, slot.y + 35, 275, "center")
                else
                    love.graphics.setColor(0, 0, 0, 1)
                    love.graphics.rectangle("fill", slot.x - 137.5, slot.y + 10, 275, 82)
                    love.graphics.setColor(1, 1, 1, 1)
                    if skills and skills[i] then
                        local formattedAttackInfo = string.format("%s\n%s", skills[i][2], skills[i][3])
                        love.graphics.printf(
                            formattedAttackInfo, 
                            slot.x - 137.5, 
                            slot.y + 35, 
                            275, 
                            "center")
                    else
                        love.graphics.printf(
                            "Empty", 
                            slot.x - 137.5, 
                            slot.y + 35, 275, 
                            "center")
                    end
                end
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle("line", slot.x - 137.5, slot.y + 10, 275, 82)
            end      
        end
    end
end


function Party.mousepressed(x, y, button)
    if button ~= 1 then return end
    
    if Party.attackSelectionMode then

        local skills = Party.memberSkills[Party.selectedUnit]
        for i, slot in ipairs(Party.slots) do
            if i == 6 then -- Exit button
                if x >= slot.x - 137.5 and x <= slot.x + 137.5 and y >= slot.y + 10 and y <= slot.y + 92 then
                    Party.attackSelectionMode = false
                    Party.selectedUnit = nil
                    return
                end
            elseif skills and skills[i] then
                if x >= slot.x - 137.5 and x <= slot.x + 137.5 and y >= slot.y + 10 and y <= slot.y + 92 then
                    Party.selectedAttack[Party.selectedUnit] = skills[i][1]
                    Party.selectedAttackData[Party.selectedUnit] = skills[i][4]
                    Party.attackSelectionMode = false
                    Party.selectedUnit = nil
                    return
                end
            end
        end
        
    else

        for i, slot in ipairs(Party.slots) do
            if Party.members[i] and x >= slot.x - 137.5 and x <= slot.x + 137.5 and y >= slot.y + 10 and y <= slot.y + 92 then
                Party.attackSelectionMode = true
                Party.selectedUnit = Party.members[i]
                return
            end
        end 

        for i, box in ipairs(Party.predefinedRects) do
            local curr_member = Party.members[i]
            if curr_member and Party.selectedAttack[curr_member] and x >= box.leftX and x <= box.leftX + 50 and y >= box.upperY and y <= box.upperY + 50 then

                Party.currentAttackers[i] = name
                Party.currentAttackerIndexes[i] = true
                local attacker = {
                    name = curr_member,
                    position = {
                        x = Party.unitPositions[i].x,
                        y = Party.unitPositions[i].y
                    },
                    animation = Party.selectedAttack[curr_member],
                    idleAnimation = Party.animations[curr_member].idle,
                    stats = Party.memberStats[curr_member]
                }
        
                Party.currUnitAnimation[curr_member] = Party.selectedAttack[curr_member]
                
                Party.currentCombatStates[i] = Combat.performAttack(
                    attacker,
                    Party.currentEnemy,
                    Party.selectedAttack[curr_member],
                    Party.selectedAttackData[curr_member],
                    function()
                        Party.selectedAttack[curr_member] = nil
                        Party.currUnitAnimation[curr_member] = Party.animations[curr_member].idle
                        Party.currentAttackers[i] = nil
                        Party.currentAttackerIndexes[i] = nil
                        Party.selectedAttackData[curr_member] = nil
                        Party.attackedCount = Party.attackedCount + 1
                        Party.isPlayerTurn()
                    end
                )
                return
            end
        end


    end
end


return Party

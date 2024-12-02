local lunajson = require("mechanics.lunajson")
local Animation = require("mechanics.animation")
local Combat = require("mechanics.combat")
local Utils = require("utils")

local Party = {}

--[[
select attack
attack is ready
if attack is ready, on click of character perform attack
]]

Party.members = {"Archer", "Magic Knight", "Soldier", "Priest", "Lancer", "Wizard"} -- max of 6 units
Party.memberSkills = {} -- max of 5 skills per unit
Party.animations = {}
Party.selectedAttack = {
    ["Archer"] = nil,
    ["Magic Knight"] = nil,
    nil,
    nil,
    ["Lancer"] = nil,
    ["Wizard"] = nil
} -- only one loaded attack for now
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
    {x = 275, y = 150}, -- Slot 1
    {x = 375, y = 150}, -- Slot 2
    {x = 275, y = 250}, -- Slot 3
    {x = 375, y = 250}, -- Slot 4
    {x = 275, y = 350}, -- Slot 5
    {x = 375, y = 350}  -- Slot 6
}


Party.attackSelectionMode = false
Party.selectedUnit = nil
Party.isBattleMode = false 
Party.currentAnimation = nil
Party.currentEnemy = nil

function Party.setEnemy(enemy)
    Party.currentEnemy = enemy
end

function Party.addSummonedUnit(unit)
    if not Party.members[1] then
        Party.members[1] = unit
        return
    end
    if not Party.members[2] then
        Party.members[2] = unit
        return
    end
    if not Party.members[3] then
        Party.members[3] = unit
        return
    end
    if not Party.members[4] then
        Party.members[4] = unit
        return
    end
    if not Party.members[5] then
        Party.members[5] = unit
        return
    end
    if not Party.members[6] then
        Party.members[6] = unit
        return
    end
end

function Party.selectAttack(skillIndex)
    if Party.selectedUnit and Party.memberSkills[Party.selectedUnit] then
        Party.members[Party.selectedUnit].selectedAttack = skillIndex
        Party.attackSelectionMode = false
    end
end

function Party.loadAssets()
    local jsonData = love.filesystem.read("characters.json")
    if not jsonData then
        error("Failed to read assets/characters.json")
    end

    local characterData = lunajson.decode(jsonData)

    for name, data in pairs(characterData) do
        Party.animations[name] = {
            idle = Animation.new(
                data.idle.file,
                data.idle.frameCount,
                data.idle.frameDuration,
                2.5
            )
        }
    end

    for name, data in pairs(Party.members) do
        if name and characterData[data]["attack"] then
            for _, atk_data in pairs(characterData[data]["attack"]) do
                if not Party.memberSkills[data] then
                    Party.memberSkills[data] = {nil, nil, nil, nil, nil}
                end

                local attack = Animation.new(
                    atk_data.file,
                    atk_data.frameCount,
                    atk_data.frameDuration,
                    2.5
                )
                local attack_name = atk_data.name
                local attack_description = atk_data.description

                local atk_info = {attack, attack_name, attack_description}

                table.insert(Party.memberSkills[data], atk_info)
            end
        end
    end
end

function Party.update(dt)
    if Party.members[1] then
        Party.animations[Party.members[1]].idle:update(dt)
    end
    if Party.members[2] then
        Party.animations[Party.members[2]].idle:update(dt)
    end
    if Party.members[3] then
        Party.animations[Party.members[3]].idle:update(dt)
    end
    if Party.members[4] then
        Party.animations[Party.members[4]].idle:update(dt)
    end
    if Party.members[5] then
        Party.animations[Party.members[5]].idle:update(dt)
    end
    if Party.members[6] then
        Party.animations[Party.members[6]].idle:update(dt)
    end

    if Party.currentCombatState then
        Party.currentCombatState:update(dt)
    end
end

function Party.draw()
    if Party.currentCombatState then
        Party.currentCombatState:draw()
    end

    for i, position in ipairs(Party.unitPositions) do
        if Party.members[i] then
            local member = Party.members[i]
            Party.animations[member].idle:draw(position.x, position.y, true)
        end
    end

    --[[for i, rect in ipairs(Party.predefinedRects) do
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
    
    if Party.isBattleMode and not Party.attackSelectionMode then
        for i, slot in ipairs(Party.slots) do
            if Party.members[i] then
                local member = Party.members[i]
  
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.rectangle("fill", slot.x - 137.5, slot.y + 10, 275, 82)
                love.graphics.setColor(1, 1, 1, 1)

                love.graphics.printf(
                    member .. "\nHP: 100/100", -- temp place holder
                    slot.x - 40,
                    slot.y + 30,
                    80,
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
                    love.graphics.printf(skills[i][2], slot.x - 137.5, slot.y + 35, 275, "center")
                else
                    love.graphics.printf("Empty", slot.x - 137.5, slot.y + 35, 275, "center")
                end
            end
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("line", slot.x - 137.5, slot.y + 10, 275, 82)
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

        -- Party.selectedAttack
        for i, box in ipairs(Party.predefinedRects) do
            local curr_member = Party.members[i]
            if curr_member and Party.selectedAttack[curr_member] and x >= box.leftX and x <= box.leftX + 50 and y >= box.upperY and y <= box.upperY + 50 then
                --[[
                Party.unitPositions = {
                    {x = 275, y = 150}, -- Slot 1
                    {x = 375, y = 150}, -- Slot 2
                    {x = 275, y = 250}, -- Slot 3
                    {x = 375, y = 250}, -- Slot 4
                    {x = 275, y = 350}, -- Slot 5
                    {x = 375, y = 350}  -- Slot 6
                }
                ]]
                local attacker = {
                    name = curr_member,
                    position = {
                        x = Party.unitPositions[i].x, 
                        y = Party.unitPositions[i].y
                    },
                    animation = Party.selectedAttack[curr_member],
                    idleAnimation = Party.animations[curr_member].idle
                }
        
                Party.currentCombatState = Combat.performAttack(
                    attacker,
                    Party.currentEnemy, 
                    Party.selectedAttack[curr_member], 
                    function()
                        print("Attack animation completed")
                        Party.selectedAttack[curr_member] = nil 
                    end
                )
                return
            end
        end


    end
end


return Party

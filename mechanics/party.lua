local lunajson = require("mechanics.lunajson")
local Animation = require("mechanics.animation")
local Combat = require("mechanics.combat")
local Utils = require("utils")

local Party = {}

Party.members = {"Wizard", "Magic Knight", "Lancer", "Priest", nil, nil} -- max of 6 units
Party.memberSkills = {} -- max of 5 skills per unit
Party.animations = {}
Party.currUnitAnimation = {}
Party.selectedAttack = {} -- only one loaded attack for now
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
Party.currentAttacker = nil

function Party.setEnemy(enemy)
    Party.currentEnemy = enemy
end

function Party.loadAssetsFor(unit) -- need since assets are only loaded once
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

    if data.attack then
        Party.memberSkills[unit] = {}
        for _, atk_data in pairs(data.attack) do
            local attack = Animation.new(
                atk_data.file,
                atk_data.frameCount,
                atk_data.frameDuration,
                2.5
            )
            table.insert(Party.memberSkills[unit], {attack, atk_data.name, atk_data.description})
        end
    end
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
        local curr_name = characterData[data]["name"]
        Party.currUnitAnimation[curr_name] = Party.animations[curr_name].idle
        -- print(curr_name, Party.currUnitAnimation[curr_name])
        Party.selectedAttack[curr_name] = nil
    end
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
    
    if Party.currentCombatState then
        Party.currentCombatState:update(dt)
    end
    
end

function Party.draw()
    for i = 1, 6 do
        if Party.currentAttackerIndex ~= i then
            if Party.members[i] and Party.currUnitAnimation[Party.members[i]] then
                Party.currUnitAnimation[Party.members[i]]:draw(Party.unitPositions[i].x, Party.unitPositions[i].y, true)
            end
        end
    end

    if Party.currentCombatState then
        Party.currentCombatState:draw()
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

        for i, box in ipairs(Party.predefinedRects) do
            local curr_member = Party.members[i]
            if curr_member and Party.selectedAttack[curr_member] and x >= box.leftX and x <= box.leftX + 50 and y >= box.upperY and y <= box.upperY + 50 then
                Party.currentAttacker = name
                Party.currentAttackerIndex = i
                local attacker = {
                    name = curr_member,
                    position = {
                        x = Party.unitPositions[i].x,
                        y = Party.unitPositions[i].y
                    },
                    animation = Party.selectedAttack[curr_member],
                    idleAnimation = Party.animations[curr_member].idle
                }
        
                Party.currUnitAnimation[curr_member] = Party.selectedAttack[curr_member]
        
                Party.currentCombatState = Combat.performAttack( -- potential issue, maybe get rid of combat? put it all into one animation
                    attacker,
                    Party.currentEnemy,
                    Party.selectedAttack[curr_member],
                    function()
                        Party.selectedAttack[curr_member] = nil
                        Party.currUnitAnimation[curr_member] = Party.animations[curr_member].idle
                        Party.currentCombatState = nil
                        Party.currentAttacker = nil
                        Party.currentAttackerIndex = nil
                    end
                )
                return
            end
        end


    end
end


return Party

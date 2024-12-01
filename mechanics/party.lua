local lunajson = require("mechanics.lunajson")
local Animation = require("mechanics.animation")
local Utils = require("utils")

local Party = {}

Party.members = {"Archer", "Magic Knight", nil, nil, "Lancer", "Wizard"} -- max of 6 units
Party.memberSkills = {
    {nil, nil, nil, nil, nil}, 
    {nil, nil, nil, nil, nil},
    {nil, nil, nil, nil, nil},
    {nil, nil, nil, nil, nil},
    {nil, nil, nil, nil, nil},
    {nil, nil, nil, nil, nil}} -- max of 5 skills per unit
Party.animations = {}
Party.isBattleMode = false 
Party.slots = { 
    {x = 137.5, y = 516}, -- Slot 1 {x = 412.5, y = 516}
    {x = 412.5, y = 516}, -- Slot 2 {x = 412.5, y = 598}
    {x = 137.5, y = 598}, -- Slot 3 {x = 412.5, y = 680}
    {x = 412.5, y = 598}, -- Slot 4 {x = 137.5, y = 516}
    {x = 137.5, y = 680}, -- Slot 5 {x = 137.5, y = 598}
    {x = 412.5, y = 680}  -- Slot 6 {x = 137.5, y = 680}
}
Party.attackSelectionMode = false
Party.selectedUnit = nil

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
end

function Party.draw()
    -- {"Archer", "Magic Knight", nil, nil, "Lancer", "Wizard"}
    for i = 1, 6 do
        local isLeftSide = i % 2 == 1 
        local columnOffset = isLeftSide and -100 or 0 
        local rowIndex = math.ceil(i / 2) 
        local x = 375 + columnOffset
        local y = 150 + (rowIndex - 1) * 100 
    
        if Party.members[i] then
            local member = Party.members[i]
            Party.animations[member].idle:draw(x, y, true)
        end
    end
    

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


return Party

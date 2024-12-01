local lunajson = require("mechanics.lunajson")
local Animation = require("mechanics.animation")

local Party = {}

-- 550 / 2 = 275
-- 275 / 2 = 137.5
Party.members = {nil, nil, nil, nil, nil, nil} 
Party.animations = {}
Party.isBattleMode = false 
Party.slots = { 
    {x = 412.5, y = 500}, -- Slot 1
    {x = 412.5, y = 600}, -- Slot 2
    {x = 412.5, y = 700}, -- Slot 3
    {x = 137.5, y = 500}, -- Slot 4
    {x = 137.5, y = 600}, -- Slot 5
    {x = 137.5, y = 700}  -- Slot 6
}

function Party.addSummonedUnit(unit)
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

    Party.members = {"Archer", "Swordsman", "Priest", "Magic Knight", "Lancer", "Wizard"}
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
    for i = 1, 3 do
        local x = 375
        local y = 150 + (i - 1) * 100

        if Party.members[i + 3] then
            local memberLeft = Party.members[i + 3]
            Party.animations[memberLeft].idle:draw(x - 100, y, true)
        end

        if Party.members[i] then
            local memberRight = Party.members[i]
            Party.animations[memberRight].idle:draw(x, y, true)
        end
    end

    if Party.isBattleMode then
        for i, slot in ipairs(Party.slots) do
            if Party.members[i] then
                local member = Party.members[i]

                if i == 3 or i == 6 then
                    love.graphics.rectangle("line", slot.x - 137.5, slot.y + 10, 275, 62)
                else
                    love.graphics.rectangle("line", slot.x - 137.5, slot.y + 10, 275, 100)
                end
                love.graphics.printf(
                    member .. "\nHP: 100/100", -- temp place holder
                    slot.x - 40,
                    slot.y + 30,
                    80,
                    "center"
                )
            else
                love.graphics.rectangle("line", slot.x - 40, slot.y - 10, 80, 60)
                love.graphics.printf("Empty", slot.x - 40, slot.y + 30, 80, "center")
            end
        end
    end
end


return Party

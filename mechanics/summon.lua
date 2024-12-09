local Party = require('mechanics.party')
local Summon = {}

local unitPools = {
    ["3★"] = {"Soldier", "Knight"},
    ["4★"] = {"Wizard", "Magic Knight"},
    ["5★"] = {"Lancer", "Priest"}
}

local rarityOrder = {"3★", "4★", "5★"} 

function Summon.summonUnit()
    local roll = math.random(1, 200)
    local rarity

    if roll <= 125 then
        rarity = "3★"
    elseif roll <= 175 then
        rarity = "4★"
    else
        rarity = "5★"
    end

    local function getFilteredPool(rarity)
        local pool = {}
        for _, unit in ipairs(unitPools[rarity]) do
            local alreadyInParty = false
            for _, partyMember in ipairs(Party.members) do
                if partyMember == unit then
                    alreadyInParty = true
                    break
                end
            end
            if not alreadyInParty then
                table.insert(pool, unit)
            end
        end
        return pool
    end

    local rarityIndex = 1
    for i, r in ipairs(rarityOrder) do
        if r == rarity then
            rarityIndex = i
            break
        end
    end

    local pool = getFilteredPool(rarity)
    while #pool == 0 and rarityIndex < #rarityOrder do
        rarityIndex = rarityIndex + 1
        rarity = rarityOrder[rarityIndex]
        pool = getFilteredPool(rarity)
    end

    if #pool == 0 then
        print("No summonable units available.")
        return nil, rarity
    end

    local unit = pool[math.random(#pool)]
    return unit, rarity
end

return Summon

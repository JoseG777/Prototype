local Summon = {}

local unitPools = {
    ["3★"] = {"Swordsman", "Knight"},
    ["4★"] = {"Wizard", "Magic Knight"},
    ["5★"] = {"Lancer", "Priest"}
}

function Summon.summonUnit()
    local roll = math.random(1, 100)
    local rarity

    if roll <= 50 then
        rarity = "3★"
    elseif roll <= 85 then
        rarity = "4★"
    else
        rarity = "5★"
    end

    local pool = unitPools[rarity]
    local unit = pool[math.random(#pool)]

    return unit, rarity
end

return Summon

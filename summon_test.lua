-- simple summon function
local function summonUnit()
    -- Unit pools by rarity
    local unitPools = {
        ["3★"] = {"Swordsman", "Knight"},
        ["4★"] = {"Wizard", "Magic Knight"},
        ["5★"] = {"Lancer", "Priest"}
    }

    -- Summon probabilities
    local roll = math.random(1, 100)
    local rarity, unit

    -- Determine rarity based on probabilities
    if roll <= 50 then
        rarity = "3★"
    elseif roll <= 85 then
        rarity = "4★"
    else
        rarity = "5★"
    end

    -- Pick a random unit from the ★ pool
    local pool = unitPools[rarity]
    unit = pool[math.random(#pool)]

    return unit, rarity
end

-- Testing summon function
for i = 1, 10 do 
    local unit, rarity = summonUnit()
    print(string.format("Summon #%d: %s (%s)", i, unit, rarity))
end

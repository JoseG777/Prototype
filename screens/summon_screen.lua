local Stars = require("mechanics.stars")
local Party = require("mechanics.party")

local SummonScreen = {}
local stars, timer

function SummonScreen.enter(rarity)
    stars = Stars.generate(rarity)
    timer = 0
end

function SummonScreen.update(dt, onComplete)
    timer = Stars.update(dt, stars, timer)
    if timer > 3 then
        Party.replaceLast(summonResult.unit)
        onComplete()
    end
end

function SummonScreen.draw()
    love.graphics.clear(0, 0, 0)
    Stars.draw(stars)
    love.graphics.printf("Summoning...", 0, 50, 550, "center")

end

return SummonScreen

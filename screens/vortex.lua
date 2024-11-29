local Summon = require("mechanics.summon")
local SummonScreen = require("screens.summon_screen")

local VortexScreen = {}

function VortexScreen.draw()
    love.graphics.clear(0.1, 0.1, 0.3)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 50, 200, 150, 150)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Click the Vortex!", 50, 360, 150, "center")
end

function VortexScreen.mousepressed(x, y, button)
    if button == 1 and x >= 50 and x <= 200 and y >= 200 and y <= 350 then
        local unit, rarity = Summon.summonUnit()
        summonResult = {unit = unit, rarity = rarity}
        -- print(screen)
        screen = "summon"
        -- print(screen)
        SummonScreen.enter(rarity)
        -- print("Clicked")
    end
end

return VortexScreen

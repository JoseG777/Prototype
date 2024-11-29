local Summon = require("mechanics.summon")
local SummonScreen = require("screens.summon_screen")

local VortexScreen = {}
local buttons = {
    {label = "Home", x = 50, y = 730, width = 100, height = 50, enabled = false},
    {label = "Units", x = 160, y = 730, width = 100, height = 50, enabled = false},
    {label = "Inventory", x = 270, y = 730, width = 100, height = 50, enabled = false},
    {label = "Summon", x = 380, y = 730, width = 100, height = 50, enabled = true}
}

function VortexScreen.draw()
    love.graphics.clear(0.1, 0.1, 0.3)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 50, 200, 150, 150)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Click the Vortex!", 50, 360, 150, "center")

    for _, button in ipairs(buttons) do
        if button.enabled then
            love.graphics.setColor(0.8, 0.8, 0.8)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
        end
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(button.label, button.x, button.y + 15, button.width, "center")
    end

    love.graphics.setColor(1, 1, 1) 

end

function VortexScreen.mousepressed(x, y, button)
    if button == 1 and x >= 50 and x <= 200 and y >= 200 and y <= 350 then
        local unit, rarity = Summon.summonUnit()
        summonResult = {unit = unit, rarity = rarity}
        -- print(summonResult.unit, " ", summonResult.rarity)
        -- print(screen)
        screen = "summon"
        -- print(screen)
        SummonScreen.enter(rarity)
        -- print("Clicked")
    end
end

return VortexScreen

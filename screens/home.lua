local Summon = require("mechanics.summon")
local SummonScreen = require("screens.summon_screen")

local HomeScreen = {}

local buttons = {
    {label = "Home", x = 50, y = 730, width = 100, height = 50, enabled = false},
    {label = "Units", x = 160, y = 730, width = 100, height = 50, enabled = false},
    {label = "Inventory", x = 270, y = 730, width = 100, height = 50, enabled = false},
    {label = "Summon", x = 380, y = 730, width = 100, height = 50, enabled = true}
}

function HomeScreen.draw()
    -- love.graphics.clear(0.1, 0.1, 0.3)
    love.graphics.setColor(1, 1, 1)

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

function HomeScreen.mousepressed(x, y, button)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
                if btn.enabled then
                    if btn.label == "Summon" then
                        local unit, rarity = Summon.summonUnit()
                        summonResult = {unit = unit, rarity = rarity}
                        screen = "summon"
                        SummonScreen.enter(rarity)
                        btn.enabled = false
                    end
                end
            end
        end
    end
end

return HomeScreen

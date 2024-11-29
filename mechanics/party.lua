local Party = {}

Party.members = {"Swordsman", nil, "Archer"}

function Party.replaceLast(unit)
    Party.members[2] = unit
end

function Party.draw()
    love.graphics.printf("Your Party", 350, 100, 200, "center")
    for i = 1, 3 do
        if Party.members[i] then
            love.graphics.rectangle("fill", 375, 150 + (i - 1) * 100, 150, 80)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(Party.members[i], 375, 170 + (i - 1) * 100, 150, "center")
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.rectangle("line", 375, 150 + (i - 1) * 100, 150, 80)
            love.graphics.printf("Empty", 375, 170 + (i - 1) * 100, 150, "center")
        end
    end
end

return Party

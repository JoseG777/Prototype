local Party = {}

Party.members = {"Swordsman", nil, "Archer"}

function Party.replaceLast(unit)
    Party.members[2] = unit
end

function Party.draw()
    love.graphics.printf("Your Party", 550, 50, 200, "center")
    for i = 1, 3 do
        if Party.members[i] then
            love.graphics.rectangle("fill", 550, 100 + (i - 1) * 100, 150, 80)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(Party.members[i], 550, 120 + (i - 1) * 100, 150, "center")
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.rectangle("line", 550, 100 + (i - 1) * 100, 150, 80)
            love.graphics.printf("Empty", 550, 120 + (i - 1) * 100, 150, "center")
        end
    end
end

return Party

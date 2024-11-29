local lunajson = require("mechanics.lunajson")
local Animation = require("mechanics.animation")
local Party = {}

Party.members = {nil, nil, nil}
Party.animations = {}

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
                1.5
            )
        }
    end

    Party.members = {"Archer", nil, "Swordsman"}
end

function Party.update(dt)

    Party.animations["Swordsman"].idle:update(dt)
    Party.animations["Archer"].idle:update(dt)

end

function Party.draw()
    for i = 1, 3 do
        local x = 375
        local y = 220 + (i - 1) * 100

        if Party.members[i] then
            local member = Party.members[i]
            Party.animations[member].idle:draw(x, y, true)
        else
            love.graphics.rectangle("line", x, y, 150, 80)
            love.graphics.printf("Empty", x, y + 20, 150, "center")
        end
    end
end

function Party.replaceLast(unit)
    Party.members[2] = unit
end

return Party

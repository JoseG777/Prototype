local Stars = {}

function Stars.generate(rarity)
    local starCounts = {
        ["3★"] = {10, 35},
        ["4★"] = {60, 85},
        ["5★"] = {110, 185}
    }

    local range = starCounts[rarity]
    local numStars = math.random(range[1], range[2])

    local stars = {}
    for i = 1, numStars do
        table.insert(stars, {
            x = math.random(0, 550), 
            y = math.random(0, 800), 
            size = math.random(2, 4),
            alpha = 0
        })
    end
    return stars
end

function Stars.update(dt, stars, timer)
    timer = timer + dt
    local alpha = math.min(1, timer / 2)

    for i = 1, #stars do
        if i <= alpha * #stars then
            stars[i].alpha = math.min(1, stars[i].alpha + dt)
        end
    end

    return timer
end

function Stars.draw(stars)
    for _, star in ipairs(stars) do
        love.graphics.setColor(1, 1, 1, star.alpha)
        love.graphics.circle("fill", star.x, star.y, star.size)
    end
end

return Stars

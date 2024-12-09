local FloatingNumbers = {}

function FloatingNumbers.new(x, y, value)
    local number = {
        x = x, 
        y = y,
        value = value, 
        opacity = 1,
        lifetime = 1.5, 
        fadeSpeed = 1 / 1.5, 
        riseSpeed = 30 
    }
    table.insert(FloatingNumbers, number)
end

function FloatingNumbers.update(dt)
    for i = #FloatingNumbers, 1, -1 do
        local number = FloatingNumbers[i]
        number.y = number.y - number.riseSpeed * dt
        number.opacity = number.opacity - number.fadeSpeed * dt
        number.lifetime = number.lifetime - dt
        if number.lifetime <= 0 or number.opacity <= 0 then
            table.remove(FloatingNumbers, i) 
        end
    end
end

function FloatingNumbers.draw()
    for _, number in ipairs(FloatingNumbers) do
        love.graphics.setColor(1, 0, 0, number.opacity)
        love.graphics.printf(
            number.value,
            number.x - 20, 
            number.y,
            80,
            "center"
        )
    end
    love.graphics.setColor(1, 1, 1, 1) 
end

return FloatingNumbers

local Vortex = {}

local spriteSheet
local frames = {}
local currentFrame = 1
local frameWidth, frameHeight = 64, 64
local frameDuration = 0.1
local elapsedTime = 0

local scaleFactor = 4

function Vortex.load()
    spriteSheet = love.graphics.newImage("assets/environment/vortex.png") 

    local sheetWidth, sheetHeight = spriteSheet:getWidth(), spriteSheet:getHeight()

    for x = 0, 3 do
        table.insert(frames, love.graphics.newQuad(
            x * frameWidth, 0,
            frameWidth, frameHeight,
            sheetWidth, sheetHeight
        ))
    end

    for x = 0, 2 do
        table.insert(frames, love.graphics.newQuad(
            x * frameWidth, frameHeight,
            frameWidth, frameHeight,
            sheetWidth, sheetHeight
        ))
    end
end

function Vortex.update(dt)
    elapsedTime = elapsedTime + dt
    if elapsedTime >= frameDuration then
        elapsedTime = elapsedTime - frameDuration
        currentFrame = currentFrame + 1
        if currentFrame > #frames then
            currentFrame = 1
        end
    end
end

function Vortex.draw()
    local x, y = 150, 400
    love.graphics.draw(
        spriteSheet,
        frames[currentFrame],
        x, y, 
        0,
        scaleFactor, scaleFactor, 
        frameWidth / 2, frameHeight / 2 
    )
end

function Vortex.isClicked(x, y)
    local vortexX, vortexY = 100, 400
    local radius = 50 * scaleFactor 
    local dx, dy = x - vortexX, y - vortexY
    return dx * dx + dy * dy <= radius * radius
end

function Vortex.setScale(scale)
    scaleFactor = scale
end

return Vortex

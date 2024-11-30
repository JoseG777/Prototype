local BattleScreen = {}
local background

function BattleScreen.load()
    background = love.graphics.newImage("assets/backgrounds/battle.png")
end

function BattleScreen.draw()
    local bgWidth, bgHeight = background:getDimensions()
    local sx = 550 / bgWidth
    local sy = 800 / bgHeight
    love.graphics.draw(background, 0, 0, 0, sx, sy)
end

return BattleScreen

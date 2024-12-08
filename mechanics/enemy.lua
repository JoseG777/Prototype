local lunajson = require("mechanics.lunajson")
local Animation = require("mechanics.animation")

local Enemy = {}

function Enemy.new(name)
    local jsonData = love.filesystem.read("enemies.json")
    if not jsonData then
        error("Failed to read enemies.json")
    end

    local enemyData = lunajson.decode(jsonData)
    local enemyInfo = enemyData[name]

    if not enemyInfo then
        error("No data found for enemy: " .. name)
    end

    local enemy = {}
    enemy.name = name
    enemy.stats = enemyInfo.stats
    enemy.position = enemyInfo.position or {x = 0, y = 0}
    enemy.scale = enemyInfo.scale or 1
    enemy.animation = Animation.new(
        enemyInfo.idle.file,
        enemyInfo.idle.frameCount,
        enemyInfo.idle.frameDuration,
        enemy.scale,
        enemyInfo.idle.rows
    )

    function enemy:update(dt)
        self.animation:update(dt)
    end

    function enemy:draw()
        local offsetX = (self.animation.frameWidth * self.scale) / 2
        local offsetY = (self.animation.frameHeight * self.scale) / 2
        self.animation:draw(self.position.x - offsetX, self.position.y - offsetY, false)
    end

    return enemy
end

return Enemy

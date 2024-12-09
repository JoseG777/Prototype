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
    enemy.idle = Animation.new(
        enemyInfo.idle.file,
        enemyInfo.idle.frameCount,
        enemyInfo.idle.frameDuration,
        enemy.scale,
        enemyInfo.idle.rows
    )
    enemy.death = Animation.new(
        enemyInfo.death.file,
        enemyInfo.death.frameCount,
        enemyInfo.death.frameDuration,
        enemy.scale,
        enemyInfo.death.rows,
        false
    )

    function enemy:update(dt)
        if enemy.stats.HP > 0 then
            self.idle:update(dt)
        else
            self.death:update(dt)
        end
    end

    function enemy:draw()
        if enemy.stats.HP > 0 then
            local offsetX = (self.idle.frameWidth * self.scale) / 2 
            local offsetY = (self.idle.frameHeight * self.scale) / 2
            self.idle:draw(self.position.x - offsetX, self.position.y - offsetY, false)
            -- print("Idle: "..offsetX.." "..offsetY)
            -- print("Curr HP: ".. enemy.stats.HP)
        --[[else
            local offsetX = (self.death.frameWidth * self.scale) / 2 
            local offsetY = (self.death.frameHeight * self.scale) / 2 
            self.death:draw(self.position.x - offsetX, self.position.y - offsetY, false)
            print("Death: "..offsetX.." "..offsetY)
            print("Curr HP: ".. enemy.stats.HP)]]
        end
    end

    return enemy
end

return Enemy

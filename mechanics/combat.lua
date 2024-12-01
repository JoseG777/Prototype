local Combat = {}
local Animation = require("mechanics.animation")
local lunajson = require("mechanics.lunajson")

function Combat.performAttack(attacker, target, attackNumber, onComplete)
    local state = {
        phase = "moveToTarget",
        timer = 0
    }

    local attackerName = attacker.name

    local cacheKey = attackerName .. "_attack_" .. attackNumber
    local attackAnimation = cachedAnimations[cacheKey]

    if not attackAnimation then
        local jsonContent = love.filesystem.read("characters.json")
        local characterData = lunajson.decode(jsonContent)

        local attackData = characterData[attackerName]["attack"][tostring(attackNumber)]
        if not attackData then
            error("Attack data for attack " .. attackNumber .. " not found!")
        end

        attackAnimation = Animation.new(
            attackData.file,
            attackData.frameCount,
            attackData.frameDuration,
            2.5
        )
        cachedAnimations[cacheKey] = attackAnimation
    end

    local targetX, targetY = target.position.x + 75, target.position.y + 25
    local originalX, originalY = attacker.position.x, attacker.position.y

    function state:update(dt)
        if self.phase == "moveToTarget" then
            attacker.position.x = attacker.position.x + (targetX - attacker.position.x) * dt * 5
            attacker.position.y = attacker.position.y + (targetY - attacker.position.y) * dt * 5

            if math.abs(attacker.position.x - targetX) < 2 then
                attacker.position.x, attacker.position.y = targetX, targetY
                attacker.animation = attackAnimation
                self.phase = "playAttackAnimation"
                self.timer = 0
            end

        elseif self.phase == "playAttackAnimation" then
            attacker.animation:update(dt)
            self.timer = self.timer + dt

            if self.timer > attackAnimation:getDuration() then
                self.phase = "returnToOriginal"
                self.timer = 0
            end

        elseif self.phase == "returnToOriginal" then
            attacker.position.x = attacker.position.x + (originalX - attacker.position.x) * dt * 5
            attacker.position.y = attacker.position.y + (originalY - attacker.position.y) * dt * 5

            if math.abs(attacker.position.x - originalX) < 2 then
                attacker.position.x, attacker.position.y = originalX, originalY
                attacker.animation = attacker.idleAnimation
                self.phase = nil
                if onComplete then onComplete() end
            end
        end
    end

    function state:draw()
        attacker.animation:draw(attacker.position.x, attacker.position.y, true)
        target.animation:draw(target.position.x, target.position.y, false)
    end

    return state
end

return Combat

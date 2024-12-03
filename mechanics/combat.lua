local Animation = require("mechanics.animation")
local Combat = {}

function Combat.performAttack(attacker, target, attackAnimation, onComplete)
    if not attacker or not target or not attackAnimation then
        error("Missing parameters for performAttack")
        return
    end

    local state = {
        phase = "moveToTarget",
        timer = 0
    }

    local targetX, targetY = target.position.x - 50, target.position.y - 75 
    local originalX, originalY = attacker.position.x, attacker.position.y

    attackAnimation:reset()
    attackAnimation:setLoop(false) 

    function state:update(dt)
        if self.phase == "moveToTarget" then
            attacker.animation = attacker.idleAnimation
            attacker.position.x = attacker.position.x + (targetX - attacker.position.x) * dt * 5
            attacker.position.y = attacker.position.y + (targetY - attacker.position.y) * dt * 5

            if math.abs(attacker.position.x - targetX) < 2 and math.abs(attacker.position.y - targetY) < 2 then
                attacker.position.x, attacker.position.y = targetX, targetY
                self.phase = "playAttackAnimation"
                attacker.animation = attackAnimation
            end

        elseif self.phase == "playAttackAnimation" then
            attackAnimation:update(dt)

            if not attackAnimation.isPlaying then 
                 attacker.animation = attacker.idleAnimation
                self.phase = "returnToOriginal"
            end

        elseif self.phase == "returnToOriginal" then
            attacker.animation = attacker.idleAnimation
            attacker.position.x = attacker.position.x + (originalX - attacker.position.x) * dt * 5
            attacker.position.y = attacker.position.y + (originalY - attacker.position.y) * dt * 5

            if math.abs(attacker.position.x - originalX) < 2 and math.abs(attacker.position.y - originalY) < 2 then
                attacker.position.x, attacker.position.y = originalX, originalY
                self.phase = nil
                if onComplete then onComplete() end
            end
        end
    end

    function state:draw()
        attacker.animation:draw(attacker.position.x, attacker.position.y, true)
    end

    return state
end

return Combat

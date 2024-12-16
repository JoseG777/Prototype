local Utils = require("utils")
local FloatingNumbers = require("mechanics.damage_display")
local Combat = {}

function Combat.calculateDamage(attacker, target, atkData)
    local attackStat = 1
    if atkData.damageType == "hybrid" then
        attackStat = (attacker.stats.ATK + attacker.stats.MAG) / 2
    elseif atkData.damageType == "physical" then
        attackStat = attacker.stats.ATK
    else
        attackStat = attacker.stats.MAG
    end
    local defenseStat = target.stats.DEF
    local baseDamage = attackStat - defenseStat * 0.5
    local multiplier = math.random(85, 110) / 100
    local skillMultiplier = atkData.damageMultiplier or 1.0

    return math.floor(math.max(1, baseDamage * multiplier * skillMultiplier)) -- account for negatives
end


function Combat.performHeal(targetUnits, memberStats)
    local healAmount = 100
    for unitName, unit in pairs(targetUnits) do
        if unit.stats.HP > 0 then
            local maxHP = memberStats[unitName].HP 
            local newHP = math.min(unit.stats.HP + healAmount, maxHP)
            local healedAmount = newHP - unit.stats.HP
            unit.stats.HP = newHP
            FloatingNumbers.new(unit.position.x, unit.position.y - 30, "+" .. healedAmount)
        end
    end
end


function Combat.performAttack(attacker, target, attackAnimation, atkData, onComplete)
    if not attacker or not target or not attackAnimation or not atkData then
        error("Missing parameters for performAttack")
        return
    end

    local state = {
        phase = "moveToTarget",
        damageFramesHit = {},
    }

    local targetX, targetY = target.position.x, target.position.y
    local originalX, originalY = attacker.position.x, attacker.position.y
    local isEnemy = nil
    if attacker.isEnemy then
        targetX = targetX - 130
        isEnemy = false
    else
        targetX = targetX + 50
        isEnemy = true
    end

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
            local currentFrame = attackAnimation.currentFrame

            if atkData.damageFrames then
                for _, damageFrame in ipairs(atkData.damageFrames) do
                    if currentFrame == damageFrame and not self.damageFramesHit[damageFrame] then
                        local damage = Combat.calculateDamage(attacker, target, atkData)
                        target.stats.HP = math.max(0, target.stats.HP - damage) 
                        FloatingNumbers.new(target.position.x, target.position.y - 30, tostring(damage))
                        -- print(target.name .. " takes " .. damage .. " damage! HP left: " .. target.stats.HP)
                        self.damageFramesHit[damageFrame] = true
                    end
                end
            end

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
        if not isEnemy then
            -- Utils.printTable(attacker.animation[1][1])
            -- print(attacker.animation)
            attacker.animation:draw(attacker.position.x, attacker.position.y, isEnemy)
        else
            attacker.animation:draw(attacker.position.x, attacker.position.y, isEnemy)
        end
    end

    return state
end

return Combat

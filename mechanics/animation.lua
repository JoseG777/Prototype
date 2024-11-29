local Animation = {}

function Animation.new(filePath, frameCount, frameDuration, scaleFactor)
    local animation = {}

    animation.spriteSheet = love.graphics.newImage(filePath)
    animation.frames = {}
    animation.currentFrame = 1
    animation.elapsedTime = 0
    animation.frameDuration = frameDuration
    animation.scale = scaleFactor or 1

    local totalWidth = animation.spriteSheet:getWidth()
    local totalHeight = animation.spriteSheet:getHeight()
    animation.frameWidth = totalWidth / frameCount
    animation.frameHeight = totalHeight

    for i = 0, frameCount - 1 do
        table.insert(animation.frames, love.graphics.newQuad(
            i * animation.frameWidth, 0,
            animation.frameWidth, animation.frameHeight,
            totalWidth, totalHeight
        ))
    end

    function animation:update(dt)
        self.elapsedTime = self.elapsedTime + dt
        if self.elapsedTime >= self.frameDuration then
            self.currentFrame = (self.currentFrame % #self.frames) + 1
            self.elapsedTime = self.elapsedTime - self.frameDuration
        end
    end

    function animation:draw(x, y, flip)
        local flipScale = flip and -1 or 1
        local offsetX = self.frameWidth / 2
        local offsetY = self.frameHeight / 2

        love.graphics.draw(
            self.spriteSheet,
            self.frames[self.currentFrame],
            x + offsetX * self.scale, y + offsetY * self.scale,
            0,
            flipScale * self.scale, self.scale,
            offsetX, offsetY
        )
    end

    return animation
end

return Animation
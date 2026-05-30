local Hud = require("04_ui.hud")
local Levels = require("03_game.levels")
local ClassicMode = require("03_game.modes.classicMode")

local Breakout = {}
Breakout.__index = Breakout

local TAU = math.pi * 2
local STATE = {
    SERVE = "serve",
    PLAYING = "playing",
    LEVEL_CLEAR = "level_clear",
    WON = "won",
    LOST = "lost",
}

local function clamp(value, low, high)
    if value < low then
        return low
    end
    if value > high then
        return high
    end
    return value
end

local function circleRectIntersect(cx, cy, radius, rect)
    local closestX = clamp(cx, rect.x, rect.x + rect.w)
    local closestY = clamp(cy, rect.y, rect.y + rect.h)
    local dx = cx - closestX
    local dy = cy - closestY
    return dx * dx + dy * dy <= radius * radius
end

local function makeBricks(width, height, layout)
    local rows = #layout
    local cols = string.len(layout[1])
    local sidePadding = math.floor(width * 0.08)
    local topPadding = math.floor(height * 0.11)
    local gap = math.floor(width * 0.011)
    if gap < 4 then
        gap = 4
    end

    local brickW = (width - sidePadding * 2 - (cols - 1) * gap) / cols
    local brickH = math.floor(height * 0.022)
    if brickH < 18 then
        brickH = 18
    end

    local bricks = {}

    for row = 1, rows do
        local rowMask = layout[row]
        for col = 1, cols do
            local hp = tonumber(string.sub(rowMask, col, col)) or 0
            if hp > 0 then
                bricks[#bricks + 1] = {
                    x = sidePadding + (col - 1) * (brickW + gap),
                    y = topPadding + (row - 1) * (brickH + gap),
                    w = brickW,
                    h = brickH,
                    alive = true,
                    row = row,
                    hp = hp,
                    maxHp = hp,
                }
            end
        end
    end

    return bricks
end

local function brickColor(row, hp, maxHp)
    local ratio = 1
    if maxHp and maxHp > 0 and hp then
        ratio = 0.55 + 0.45 * (hp / maxHp)
    end

    if row == 1 then
        return 245 * ratio, 115 * ratio, 95 * ratio
    end
    if row == 2 then
        return 245 * ratio, 170 * ratio, 95 * ratio
    end
    if row == 3 then
        return 245 * ratio, 220 * ratio, 95 * ratio
    end
    if row == 4 then
        return 155 * ratio, 225 * ratio, 120 * ratio
    end
    if row == 5 then
        return 105 * ratio, 188 * ratio, 240 * ratio
    end
    return 160 * ratio, 145 * ratio, 245 * ratio
end

local function launchBall(ball, speed)
    local startVx = math.min(200, speed * 0.48)
    ball.vx = startVx
    ball.vy = -speed
end

local function isNaN(value)
    return value ~= value
end

local function makeTone(freq, duration, volume)
    local sampleRate = 44100
    local sampleCount = math.floor(duration * sampleRate)
    local soundData = love.sound.newSoundData(sampleCount, sampleRate, 16, 1)

    for i = 0, sampleCount - 1 do
        local t = i / sampleRate
        local envelope = 1 - (i / sampleCount)
        local value = math.sin(TAU * freq * t) * volume * envelope
        soundData:setSample(i, value)
    end

    return love.audio.newSource(soundData, "static")
end

local function isValidLayout(layout)
    if type(layout) ~= "table" or #layout == 0 then
        return false
    end

    local colCount = string.len(layout[1] or "")
    if colCount == 0 then
        return false
    end

    for row = 1, #layout do
        local line = layout[row]
        if type(line) ~= "string" or string.len(line) ~= colCount then
            return false
        end
    end

    return true
end

function Breakout.new(width, height)
    local self = setmetatable({}, Breakout)
    self.time = 0
    self.mode = ClassicMode.new()
    self.sounds = {
        brick = makeTone(820, 0.07, 0.35),
        brickHit = makeTone(680, 0.06, 0.28),
        paddle = makeTone(420, 0.05, 0.30),
        miss = makeTone(190, 0.18, 0.35),
        win = makeTone(1040, 0.22, 0.30),
    }
    self:reset(width, height)
    return self
end

function Breakout:loadLevel(level)
    local levelInfo = Levels[level]
    if not levelInfo then
        return
    end

    if not isValidLayout(levelInfo.layout) then
        return
    end

    self.level = level
    self.ballSpeed = levelInfo.ballSpeed or 380
    self.paddle.speed = levelInfo.paddleSpeed or 620
    self.theme = levelInfo.theme or self.theme
    self.bricks = makeBricks(self.width, self.height, levelInfo.layout)
    self.state = STATE.SERVE
    self.levelClearProgress = 0
    self:resetBallToPaddle()
end

function Breakout:advanceLevel()
    if self.level < self.maxLevel then
        self.mode:onLevelTransition(self)
        self.state = STATE.LEVEL_CLEAR
        self.levelClearTimer = 1.0
        self.levelClearDuration = 1.0
        self.levelClearProgress = 0
        self.ball.vx = 0
        self.ball.vy = 0
        self:playSound("win")
        self:addShake(8, 0.12)
        self:spawnScorePopup(self.width * 0.5, self.height * 0.48, "LEVEL " .. tostring(self.level) .. " CLEAR")
        return
    end

    self.state = STATE.WON
    self.ball.vx = 0
    self.ball.vy = 0
    self:playSound("win")
    self:addShake(10, 0.16)
end

function Breakout:reset(width, height)
    self.width = width or self.width or 1280
    self.height = height or self.height or 720

    self.score = 0
    self.lives = 3
    self.level = 1
    self.maxLevel = #Levels
    self.state = STATE.SERVE
    self.levelClearTimer = 0
    self.levelClearDuration = 1
    self.levelClearProgress = 0

    self.paddle = {
        w = 130,
        h = 18,
        x = (self.width - 130) * 0.5,
        y = self.height - 92,
        speed = 620,
    }

    self.ball = {
        r = 9,
        x = self.paddle.x + self.paddle.w * 0.5,
        y = self.paddle.y - 9,
        vx = 0,
        vy = 0,
    }

    self.ballSpeed = 380
    self.theme = {
        bgTop = {18, 24, 38},
        bgBottom = {26, 34, 52},
        ui = {230, 235, 248},
        accent = {140, 220, 255},
    }
    self.bricks = {}
    self.particles = {}
    self.popups = {}
    self.shakeTime = 0
    self.shakeDuration = 0
    self.shakeMagnitude = 0
    self.inputSnapshot = {
        moveAxis = 0,
        launchPressed = false,
        restartPressed = false,
        pausePressed = false,
    }

    self.mode:onReset(self)

    self:loadLevel(1)
end

function Breakout:resize(width, height)
    self:reset(width, height)
end

function Breakout:resetBallToPaddle()
    self.ball.x = self.paddle.x + self.paddle.w * 0.5
    self.ball.y = self.paddle.y - self.ball.r
    self.ball.vx = 0
    self.ball.vy = 0
end

function Breakout:setState(nextState)
    self.state = nextState
end

function Breakout:setInputSnapshot(snapshot)
    if snapshot then
        self.inputSnapshot = snapshot
    end
end

function Breakout:updatePaddle(dt)
    local direction = self.inputSnapshot.moveAxis or 0

    self.paddle.x = self.paddle.x + direction * self.paddle.speed * dt
    self.paddle.x = clamp(self.paddle.x, 0, self.width - self.paddle.w)
end

function Breakout:playSound(name)
    local source = self.sounds and self.sounds[name]
    if not source then
        return
    end
    source:stop()
    source:play()
end

function Breakout:addShake(magnitude, duration)
    if magnitude > self.shakeMagnitude then
        self.shakeMagnitude = magnitude
    end
    if duration > self.shakeTime then
        self.shakeTime = duration
        self.shakeDuration = duration
    end
end

function Breakout:spawnBrickParticles(x, y, r, g, b)
    for i = 1, 10 do
        local angle = (i / 10) * TAU
        local speed = 80 + i * 8
        self.particles[#self.particles + 1] = {
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed - 30,
            life = 0.26,
            maxLife = 0.26,
            size = 2 + (i % 3),
            r = r,
            g = g,
            b = b,
        }
    end
end

function Breakout:spawnScorePopup(x, y, text)
    self.popups[#self.popups + 1] = {
        x = x,
        y = y,
        vy = -36,
        life = 0.55,
        maxLife = 0.55,
        text = text,
    }
end

function Breakout:updateEffects(dt)
    self.time = self.time + dt
    self.mode:update(self, dt)

    if self.shakeTime > 0 then
        self.shakeTime = self.shakeTime - dt
        if self.shakeTime < 0 then
            self.shakeTime = 0
        end
    end

    local nextParticles = {}
    for i = 1, #self.particles do
        local p = self.particles[i]
        p.life = p.life - dt
        if p.life > 0 then
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.vy = p.vy + 260 * dt
            nextParticles[#nextParticles + 1] = p
        end
    end
    self.particles = nextParticles

    local nextPopups = {}
    for i = 1, #self.popups do
        local popup = self.popups[i]
        popup.life = popup.life - dt
        if popup.life > 0 then
            popup.y = popup.y + popup.vy * dt
            nextPopups[#nextPopups + 1] = popup
        end
    end
    self.popups = nextPopups
end

function Breakout:getShakeOffset()
    if self.shakeTime <= 0 or self.shakeDuration <= 0 then
        return 0, 0
    end

    local ratio = self.shakeTime / self.shakeDuration
    local strength = self.shakeMagnitude * ratio
    local ox = math.sin(self.time * 95) * strength
    local oy = math.cos(self.time * 123) * strength * 0.75
    return ox, oy
end

function Breakout:updateBall(dt)
    local ball = self.ball
    local prevX = ball.x
    local prevY = ball.y

    ball.x = ball.x + ball.vx * dt
    ball.y = ball.y + ball.vy * dt

    if ball.x - ball.r <= 0 then
        ball.x = ball.r
        ball.vx = math.abs(ball.vx)
    elseif ball.x + ball.r >= self.width then
        ball.x = self.width - ball.r
        ball.vx = -math.abs(ball.vx)
    end

    if ball.y - ball.r <= 0 then
        ball.y = ball.r
        ball.vy = math.abs(ball.vy)
    end

    if ball.y - ball.r > self.height then
        self.mode:onLifeLost(self)
        self.lives = self.lives - 1
        self:playSound("miss")
        self:addShake(8, 0.12)
        if self.lives <= 0 then
            self:setState(STATE.LOST)
        else
            self:setState(STATE.SERVE)
            self:resetBallToPaddle()
        end
        return
    end

    local paddle = self.paddle
    if ball.vy > 0 and circleRectIntersect(ball.x, ball.y, ball.r, paddle) then
        local hitOffset = ((ball.x - paddle.x) / paddle.w) * 2 - 1
        hitOffset = clamp(hitOffset, -0.95, 0.95)
        local speed = self.ballSpeed
        ball.vx = speed * hitOffset
        local vySquared = speed * speed - ball.vx * ball.vx
        if vySquared < 0 then
            vySquared = 0
        end
        ball.vy = -math.sqrt(vySquared)
        ball.y = paddle.y - ball.r
        self:playSound("paddle")
        self:addShake(3, 0.05)
    end

    if isNaN(ball.x) or isNaN(ball.y) or isNaN(ball.vx) or isNaN(ball.vy) then
        self:setState(STATE.SERVE)
        self:resetBallToPaddle()
        return
    end

    for i = 1, #self.bricks do
        local brick = self.bricks[i]
        if brick.alive and circleRectIntersect(ball.x, ball.y, ball.r, brick) then
            brick.hp = brick.hp - 1

            local r, g, b = brickColor(brick.row, brick.hp, brick.maxHp)

            if brick.hp <= 0 then
                brick.alive = false
                local gained = self.mode:awardBrickPoints(self, 100)
                self.score = self.score + gained
                self:playSound("brick")
                self:spawnBrickParticles(brick.x + brick.w * 0.5, brick.y + brick.h * 0.5, r, g, b)
                self:spawnScorePopup(brick.x + brick.w * 0.5, brick.y, "+" .. tostring(gained))
                self:addShake(4, 0.06)
            else
                local gained = self.mode:awardBrickPoints(self, 25)
                self.score = self.score + gained
                self:playSound("brickHit")
                self:spawnScorePopup(brick.x + brick.w * 0.5, brick.y, "+" .. tostring(gained))
                self:addShake(2, 0.04)
            end

            if prevY + ball.r <= brick.y then
                ball.vy = -math.abs(ball.vy)
            elseif prevY - ball.r >= brick.y + brick.h then
                ball.vy = math.abs(ball.vy)
            elseif prevX + ball.r <= brick.x then
                ball.vx = -math.abs(ball.vx)
            elseif prevX - ball.r >= brick.x + brick.w then
                ball.vx = math.abs(ball.vx)
            else
                ball.vy = -ball.vy
            end

            break
        end
    end

    local aliveCount = 0
    for i = 1, #self.bricks do
        if self.bricks[i].alive then
            aliveCount = aliveCount + 1
        end
    end

    if aliveCount == 0 then
        self:advanceLevel()
        return
    end
end

function Breakout:update(dt)
    self:updateEffects(dt)
    self:updatePaddle(dt)

    if self.inputSnapshot.restartPressed then
        self:reset(self.width, self.height)
        return
    end

    if self.state == STATE.LEVEL_CLEAR then
        self.levelClearTimer = self.levelClearTimer - dt
        self.levelClearProgress = 1 - (self.levelClearTimer / self.levelClearDuration)
        if self.levelClearProgress < 0 then
            self.levelClearProgress = 0
        elseif self.levelClearProgress > 1 then
            self.levelClearProgress = 1
        end
        if self.levelClearTimer <= 0 then
            self:loadLevel(self.level + 1)
        end
        return
    end

    if self.state == STATE.SERVE then
        if self.inputSnapshot.launchPressed then
            launchBall(self.ball, self.ballSpeed)
            self:setState(STATE.PLAYING)
            return
        end
        self:resetBallToPaddle()
        return
    end

    if self.state ~= STATE.PLAYING then
        return
    end

    self:updateBall(dt)
end

function Breakout:drawEffects()
    local gr = love.graphics

    for i = 1, #self.particles do
        local p = self.particles[i]
        local alpha = p.life / p.maxLife
        gr.setColor(p.r / 255, p.g / 255, p.b / 255, alpha)
        gr.rectangle("fill", p.x, p.y, p.size, p.size)
    end

    for i = 1, #self.popups do
        local popup = self.popups[i]
        local alpha = popup.life / popup.maxLife
        gr.setColor(1, 1, 1, alpha)
        gr.printf(popup.text, popup.x - 30, popup.y, 60, "center")
    end
end

function Breakout:drawBackground()
    local gr = love.graphics
    local theme = self.theme
    local bgTop = theme.bgTop
    local bgBottom = theme.bgBottom

    gr.setColor(bgTop[1] / 255, bgTop[2] / 255, bgTop[3] / 255)
    gr.rectangle("fill", 0, 0, self.width, self.height)

    gr.setColor(bgBottom[1] / 255, bgBottom[2] / 255, bgBottom[3] / 255, 0.75)
    gr.rectangle("fill", 0, self.height * 0.62, self.width, self.height * 0.38)
end

function Breakout:drawBricks()
    local gr = love.graphics

    for i = 1, #self.bricks do
        local brick = self.bricks[i]
        if brick.alive then
            local r, g, b = brickColor(brick.row, brick.hp, brick.maxHp)
            gr.setColor(r / 255, g / 255, b / 255)
            gr.rectangle("fill", brick.x, brick.y, brick.w, brick.h, 4, 4)

            gr.setColor(1, 1, 1, 0.11 + 0.09 * (brick.hp / brick.maxHp))
            gr.rectangle("line", brick.x, brick.y, brick.w, brick.h, 4, 4)

            if brick.hp > 1 then
                gr.setColor(1, 1, 1, 0.45)
                gr.printf(tostring(brick.hp), brick.x, brick.y + 3, brick.w, "center")
            end
        end
    end
end

function Breakout:drawPaddleAndBall()
    local gr = love.graphics

    gr.setColor(220 / 255, 229 / 255, 248 / 255)
    gr.rectangle("fill", self.paddle.x, self.paddle.y, self.paddle.w, self.paddle.h, 4, 4)

    gr.setColor(1, 1, 1)
    gr.circle("fill", self.ball.x, self.ball.y, self.ball.r)
end

function Breakout:draw()
    local gr = love.graphics
    self:drawBackground()

    local offsetX, offsetY = self:getShakeOffset()
    gr.push()
    gr.translate(offsetX, offsetY)
    self:drawBricks()
    self:drawPaddleAndBall()
    self:drawEffects()
    gr.pop()

    Hud.draw(self)
end

return Breakout

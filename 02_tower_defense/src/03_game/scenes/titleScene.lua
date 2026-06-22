-- ============================================================================
-- titleScene.lua — 타이틀 화면
-- ============================================================================
local TitleScene = {}
TitleScene.__index = TitleScene

function TitleScene.new(baseWidth, baseHeight)
    local self = setmetatable({}, TitleScene)
    self.baseWidth = baseWidth
    self.baseHeight = baseHeight
    self.blinkTimer = 0
    self.showText = true
    return self
end

function TitleScene:onEnter() end

function TitleScene:update(dt)
    self.blinkTimer = self.blinkTimer + dt
    if self.blinkTimer >= 0.7 then
        self.blinkTimer = 0
        self.showText = not self.showText
    end
end

function TitleScene:setInputSnapshot(snapshot)
    if snapshot.tapped then
        self:_startGame()
    end
end

function TitleScene:_startGame()
    local LevelSelectScene = require("03_game.scenes.levelSelectScene")
    self._stack:replace(LevelSelectScene.new(self.baseWidth, self.baseHeight))
end

function TitleScene:draw()
    local gr = love.graphics
    local cx = self.baseWidth / 2
    local cy = self.baseHeight / 2

    -- 배경
    gr.setColor(0.05, 0.08, 0.15, 1)
    gr.rectangle("fill", 0, 0, self.baseWidth, self.baseHeight)

    -- 타이틀
    gr.setColor(1, 0.8, 0.2, 1)
    local font = gr.getFont()
    local title = "TOWER DEFENSE"
    local tw = font:getWidth(title)
    gr.print(title, cx - tw / 2, cy - 60)

    -- 부제
    gr.setColor(0.7, 0.7, 0.7, 1)
    local subtitle = "Xeno Tactic Style"
    local sw = font:getWidth(subtitle)
    gr.print(subtitle, cx - sw / 2, cy - 30)

    -- 시작 안내
    if self.showText then
        gr.setColor(1, 1, 1, 1)
        local startText = "TAP TO START"
        local stw = font:getWidth(startText)
        gr.print(startText, cx - stw / 2, cy + 60)
    end

    gr.setColor(1, 1, 1, 1)
end

function TitleScene:resize(width, height) end

return TitleScene

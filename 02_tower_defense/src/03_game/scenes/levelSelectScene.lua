-- ============================================================================
-- levelSelectScene.lua — 레벨 선택 화면
-- ============================================================================
local Levels = require("03_game.levels")

local LevelSelectScene = {}
LevelSelectScene.__index = LevelSelectScene

function LevelSelectScene.new(baseWidth, baseHeight)
    local self = setmetatable({}, LevelSelectScene)
    self.baseWidth = baseWidth
    self.baseHeight = baseHeight
    self.buttons = {}
    self:_buildButtons()
    return self
end

function LevelSelectScene:_buildButtons()
    local count = Levels.getCount()
    local btnW = 200
    local btnH = 60
    local gap = 20
    local startY = self.baseHeight / 2 - (count * (btnH + gap)) / 2

    for i = 1, count do
        local level = Levels.getLevel(i)
        self.buttons[i] = {
            x = self.baseWidth / 2 - btnW / 2,
            y = startY + (i - 1) * (btnH + gap),
            w = btnW,
            h = btnH,
            label = "Level " .. i .. ": " .. level.name,
            levelIndex = i,
        }
    end
end

function LevelSelectScene:onEnter() end

function LevelSelectScene:update(dt) end

function LevelSelectScene:setInputSnapshot(snapshot)
    if snapshot.tapped then
        for _, btn in ipairs(self.buttons) do
            if snapshot.tapX >= btn.x and snapshot.tapX <= btn.x + btn.w
               and snapshot.tapY >= btn.y and snapshot.tapY <= btn.y + btn.h then
                self:_selectLevel(btn.levelIndex)
                return
            end
        end
    end
end

function LevelSelectScene:_selectLevel(index)
    local GameplayScene = require("03_game.scenes.gameplayScene")
    self._stack:replace(GameplayScene.new(self.baseWidth, self.baseHeight, index))
end

function LevelSelectScene:draw()
    local gr = love.graphics

    -- 배경
    gr.setColor(0.05, 0.05, 0.1, 1)
    gr.rectangle("fill", 0, 0, self.baseWidth, self.baseHeight)

    -- 타이틀
    gr.setColor(1, 1, 1, 1)
    local title = "SELECT LEVEL"
    local font = gr.getFont()
    local tw = font:getWidth(title)
    gr.print(title, self.baseWidth / 2 - tw / 2, 80)

    -- 버튼
    for _, btn in ipairs(self.buttons) do
        gr.setColor(0.2, 0.3, 0.5, 1)
        gr.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 8, 8)
        gr.setColor(0.4, 0.6, 0.9, 1)
        gr.rectangle("line", btn.x, btn.y, btn.w, btn.h, 8, 8)
        gr.setColor(1, 1, 1, 1)
        local lw = font:getWidth(btn.label)
        gr.print(btn.label, btn.x + btn.w / 2 - lw / 2, btn.y + btn.h / 2 - 7)
    end

    gr.setColor(1, 1, 1, 1)
end

function LevelSelectScene:resize(width, height) end

return LevelSelectScene

local BreakoutScene = require("03_game.scenes.breakoutScene")
local Levels = require("03_game.levels")
local ProgressStore = require("03_game.progressStore")

local LevelSelectScene = {}
LevelSelectScene.__index = LevelSelectScene

local GRID_COLUMNS = 2
local VISIBLE_ROWS = 3

local MODE_LABELS = {
    classic = "Classic",
    combo_rush = "Combo Rush",
}

local LOCKED_TEXT = "LOCKED"

local function clamp(value, low, high)
    if value < low then
        return low
    end
    if value > high then
        return high
    end
    return value
end

local function ceilDiv(value, divisor)
    return math.floor((value + divisor - 1) / divisor)
end

local function levelRow(index)
    return math.floor((index - 1) / GRID_COLUMNS) + 1
end

local function levelCol(index)
    return ((index - 1) % GRID_COLUMNS) + 1
end

local function moveSelection(selected, deltaRow, deltaCol, total)
    local row = levelRow(selected) + deltaRow
    local col = levelCol(selected) + deltaCol
    local rowCount = ceilDiv(total, GRID_COLUMNS)

    row = clamp(row, 1, rowCount)
    col = clamp(col, 1, GRID_COLUMNS)

    local nextIndex = (row - 1) * GRID_COLUMNS + col
    if nextIndex > total then
        nextIndex = total
    end
    return nextIndex
end

local function getVisibleStartRow(selected, visibleStartRow, total)
    local row = levelRow(selected)
    local maxStartRow = math.max(1, ceilDiv(total, GRID_COLUMNS) - VISIBLE_ROWS + 1)
    local nextStart = visibleStartRow or 1

    if row < nextStart then
        nextStart = row
    elseif row >= nextStart + VISIBLE_ROWS then
        nextStart = row - VISIBLE_ROWS + 1
    end

    return clamp(nextStart, 1, maxStartRow)
end

local function countSolid(layout)
    local total = 0
    for row = 1, #layout do
        local line = layout[row]
        for col = 1, string.len(line) do
            if string.sub(line, col, col) ~= "0" then
                total = total + 1
            end
        end
    end
    return total
end

local function hpTint(ch)
    if ch == "1" then
        return 0.56, 0.85, 1.0
    end
    if ch == "2" then
        return 0.98, 0.78, 0.42
    end
    if ch == "3" then
        return 1.0, 0.48, 0.42
    end
    return 0.28, 0.34, 0.42
end

local function resolveLevelSet(modeId)
    local levelSet = Levels[modeId]
    if type(levelSet) ~= "table" or #levelSet == 0 then
        return Levels.classic, "classic"
    end
    return levelSet, modeId
end

local function drawMiniMap(gr, layout, x, y, w, h)
    local rows = #layout
    local cols = string.len(layout[1] or "")
    if rows == 0 or cols == 0 then
        return
    end

    local gap = 2
    local cellW = math.max(3, math.floor((w - gap * (cols - 1)) / cols))
    local cellH = math.max(3, math.floor((h - gap * (rows - 1)) / rows))
    local gridW = cellW * cols + gap * (cols - 1)
    local gridH = cellH * rows + gap * (rows - 1)
    local startX = x + math.floor((w - gridW) * 0.5)
    local startY = y + math.floor((h - gridH) * 0.5)

    for row = 1, rows do
        local line = layout[row]
        for col = 1, cols do
            local ch = string.sub(line, col, col)
            local r, g, b = hpTint(ch)
            gr.setColor(r, g, b, ch == "0" and 0.24 or 0.96)
            gr.rectangle("fill", startX + (col - 1) * (cellW + gap), startY + (row - 1) * (cellH + gap), cellW, cellH, 3, 3)
        end
    end
end

function LevelSelectScene.new(width, height, options)
    local self = setmetatable({}, LevelSelectScene)
    self.width = width
    self.height = height
    self.options = options or {}
    self.levelSet, self.modeId = resolveLevelSet(self.options.modeId)
    self.selected = clamp(self.options.selectedLevel or 1, 1, #self.levelSet)
    self.visibleStartRow = 1
    self.progressStore = self.options.progressStore or ProgressStore.new()
    self.startGameFactory = self.options.startGameFactory or function(w, h, modeId, startLevel)
        return BreakoutScene.new(w, h, {
            modeId = modeId,
            startLevel = startLevel,
            progressStore = self.progressStore,
        })
    end
    self.previousSceneFactory = self.options.previousSceneFactory or function(w, h, modeId)
        return require("03_game.scenes.modeSelectScene").new(w, h, {
            selectedIndex = modeId == "combo_rush" and 2 or 1,
        })
    end
    self.progressSnapshot = self.progressStore:getSnapshot(self.modeId, #self.levelSet)
    self.visibleStartRow = getVisibleStartRow(self.selected, self.visibleStartRow, #self.levelSet)
    return self
end

function LevelSelectScene:refreshProgress()
    self.progressSnapshot = self.progressStore:getSnapshot(self.modeId, #self.levelSet)
end

function LevelSelectScene:isUnlocked(level)
    return level <= (self.progressSnapshot.unlockedLevel or 1)
end

function LevelSelectScene:resize(width, height)
    self.width = width
    self.height = height
end

function LevelSelectScene:startSelected(level)
    if not self._stack then
        return
    end
    self:refreshProgress()
    if not self:isUnlocked(level) then
        self:setSelected(level)
        return
    end
    self._stack:replace(self.startGameFactory(self.width, self.height, self.modeId, level))
end

function LevelSelectScene:setSelected(level)
    self.selected = clamp(level, 1, #self.levelSet)
    self.visibleStartRow = getVisibleStartRow(self.selected, self.visibleStartRow, #self.levelSet)
end

function LevelSelectScene:keypressed(key)
    if key == "backspace" then
        if self._stack then
            self._stack:replace(self.previousSceneFactory(self.width, self.height, self.modeId))
        end
        return
    end

    local numeric = tonumber(key)
    if numeric and numeric >= 1 and numeric <= #self.levelSet then
        self:startSelected(numeric)
        return
    end

    if key == "left" or key == "a" then
        self:setSelected(moveSelection(self.selected, 0, -1, #self.levelSet))
        return
    end

    if key == "right" or key == "d" then
        self:setSelected(moveSelection(self.selected, 0, 1, #self.levelSet))
        return
    end

    if key == "up" or key == "w" then
        self:setSelected(moveSelection(self.selected, -1, 0, #self.levelSet))
        return
    end

    if key == "down" or key == "s" then
        self:setSelected(moveSelection(self.selected, 1, 0, #self.levelSet))
        return
    end

    if key == "return" or key == "space" then
        self:startSelected(self.selected)
    end
end

function LevelSelectScene:draw()
    local gr = love.graphics
    local total = #self.levelSet
    local unlockedLevel = self.progressSnapshot.unlockedLevel or 1
    local rowCount = ceilDiv(total, GRID_COLUMNS)
    local cardGapX = 18
    local cardGapY = 20
    local sidePad = 28
    local top = math.floor(self.height * 0.20)
    local cardW = math.floor((self.width - sidePad * 2 - cardGapX) / GRID_COLUMNS)
    local cardH = math.floor((self.height * 0.62 - cardGapY * (VISIBLE_ROWS - 1)) / VISIBLE_ROWS)
    local visibleStartRow = getVisibleStartRow(self.selected, self.visibleStartRow, total)

    self.visibleStartRow = visibleStartRow

    gr.setColor(0.06, 0.08, 0.13, 1)
    gr.rectangle("fill", 0, 0, self.width, self.height)

    gr.setColor(0.88, 0.93, 0.98, 1)
    gr.printf("SELECT LEVEL", 0, self.height * 0.08, self.width, "center")

    gr.setColor(0.65, 0.78, 0.92, 1)
    gr.printf((MODE_LABELS[self.modeId] or self.modeId) .. " ROUTE", 0, self.height * 0.125, self.width, "center")

    gr.setColor(0.78, 0.84, 0.91, 1)
    gr.printf("Unlocked " .. tostring(unlockedLevel) .. "/" .. tostring(total), 0, self.height * 0.16, self.width, "center")

    for row = visibleStartRow, math.min(rowCount, visibleStartRow + VISIBLE_ROWS - 1) do
        for col = 1, GRID_COLUMNS do
            local index = (row - 1) * GRID_COLUMNS + col
            if index <= total then
                local entry = self.levelSet[index]
                local progress = self.progressSnapshot.levels[index] or {cleared = false, bestScore = 0}
                local x = sidePad + (col - 1) * (cardW + cardGapX)
                local y = top + (row - visibleStartRow) * (cardH + cardGapY)
                local active = self.selected == index
                local minimapH = math.floor(cardH * 0.47)
                local solid = countSolid(entry.layout)
                local unlocked = self:isUnlocked(index)

                if active then
                    gr.setColor(0.95, 0.9, 0.72, 1)
                elseif not unlocked then
                    gr.setColor(0.12, 0.14, 0.18, 1)
                else
                    gr.setColor(0.16, 0.21, 0.30, 1)
                end
                gr.rectangle("fill", x, y, cardW, cardH, 16, 16)

                if active then
                    gr.setColor(0.12, 0.15, 0.24, 1)
                else
                    gr.setColor(0.74, 0.80, 0.88, 0.16)
                end
                gr.rectangle("line", x, y, cardW, cardH, 16, 16)

                if active then
                    gr.setColor(0.12, 0.15, 0.24, 1)
                elseif not unlocked then
                    gr.setColor(0.70, 0.73, 0.80, 0.85)
                else
                    gr.setColor(0.88, 0.93, 0.98, 1)
                end
                gr.printf("L" .. tostring(index), x, y + 14, cardW, "center")

                drawMiniMap(gr, entry.layout, x + 14, y + 44, cardW - 28, minimapH)

                if active then
                    gr.setColor(0.18, 0.20, 0.28, 1)
                elseif not unlocked then
                    gr.setColor(0.66, 0.68, 0.74, 1)
                else
                    gr.setColor(0.68, 0.74, 0.82, 1)
                end
                if not unlocked then
                    gr.printf(LOCKED_TEXT, x, y + minimapH + 50, cardW, "center")
                elseif progress.cleared then
                    gr.printf("CLEAR", x, y + minimapH + 50, cardW, "center")
                else
                    gr.printf("OPEN", x, y + minimapH + 50, cardW, "center")
                end
                gr.printf("Best " .. tostring(progress.bestScore or 0), x, y + minimapH + 74, cardW, "center")
                gr.printf(solid .. " bricks  B " .. tostring(entry.ballSpeed), x, y + minimapH + 98, cardW, "center")
            end
        end
    end

    if rowCount > VISIBLE_ROWS then
        local trackX = self.width - 16
        local trackY = top
        local trackH = VISIBLE_ROWS * cardH + (VISIBLE_ROWS - 1) * cardGapY
        local thumbH = math.max(24, math.floor(trackH * (VISIBLE_ROWS / rowCount)))
        local travel = trackH - thumbH
        local ratio = 0

        if rowCount > VISIBLE_ROWS then
            ratio = (visibleStartRow - 1) / (rowCount - VISIBLE_ROWS)
        end

        gr.setColor(0.22, 0.28, 0.38, 0.85)
        gr.rectangle("fill", trackX, trackY, 6, trackH, 3, 3)
        gr.setColor(0.95, 0.9, 0.72, 0.92)
        gr.rectangle("fill", trackX, trackY + travel * ratio, 6, thumbH, 3, 3)
    end

    gr.setColor(0.9, 0.9, 0.9, 1)
    gr.printf("ARROWS/WASD + ENTER  |  NUMBER TO JUMP  |  BACKSPACE BACK", 0, self.height * 0.90, self.width, "center")
end

return LevelSelectScene
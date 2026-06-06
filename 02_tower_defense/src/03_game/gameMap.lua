-- ============================================================================
-- gameMap.lua — 오픈 그리드 맵 (미로 빌딩 TD)
-- ============================================================================
--
-- ◆ 역할
--   오픈 필드 그리드를 관리한다.
--   플레이어가 벽/타워를 배치하면 적 경로가 동적으로 변경된다.
--   배치 전 경로 차단 여부를 pathfinder로 검증한다.
--
-- ◆ 셀 타입
--   0 = 빈 공간 (통행 가능, 건설 가능)
--   1 = 벽 (통행 불가, 데미지 없음)
--   2 = 타워 (통행 불가, 공격)
--   3 = 진입점 (적 스폰)
--   4 = 출구점 (적 목표)

local Pathfinder = require("03_game.pathfinder")

local GameMap = {}
GameMap.__index = GameMap

-- 셀 상수
local CELL_EMPTY = 0
local CELL_WALL = 1
local CELL_TOWER = 2
local CELL_ENTRY = 3
local CELL_EXIT = 4

function GameMap.new(config)
    local self = setmetatable({}, GameMap)
    self.cols = config.cols or 9
    self.rows = config.rows or 16
    self.cellSize = config.cellSize or 60
    self.entryCol = config.entryCol or math.ceil(self.cols / 2)
    self.entryRow = config.entryRow or 1
    self.exitCol = config.exitCol or math.ceil(self.cols / 2)
    self.exitRow = config.exitRow or self.rows
    self.grid = {}
    self.currentPath = nil
    self:_initGrid()
    self:_recalcPath()
    return self
end

function GameMap:_initGrid()
    for row = 1, self.rows do
        self.grid[row] = {}
        for col = 1, self.cols do
            self.grid[row][col] = CELL_EMPTY
        end
    end
    self.grid[self.entryRow][self.entryCol] = CELL_ENTRY
    self.grid[self.exitRow][self.exitCol] = CELL_EXIT
end

function GameMap:_makePathGrid()
    local tempGrid = {}
    for row = 1, self.rows do
        tempGrid[row] = {}
        for col = 1, self.cols do
            local cell = self.grid[row][col]
            if cell == CELL_EMPTY or cell == CELL_ENTRY or cell == CELL_EXIT then
                tempGrid[row][col] = 0
            else
                tempGrid[row][col] = 1
            end
        end
    end
    return tempGrid
end

function GameMap:_recalcPath()
    local tempGrid = self:_makePathGrid()
    self.currentPath = Pathfinder.findPath(
        tempGrid, self.cols, self.rows,
        self.entryCol, self.entryRow,
        self.exitCol, self.exitRow
    )
end

--- 벽 또는 타워 배치 가능 여부 (경로 차단하지 않는지 확인)
function GameMap:canPlace(col, row)
    if col < 1 or col > self.cols or row < 1 or row > self.rows then
        return false
    end
    local cell = self.grid[row][col]
    if cell ~= CELL_EMPTY then
        return false
    end

    local tempGrid = self:_makePathGrid()
    return Pathfinder.canBlock(
        tempGrid, self.cols, self.rows,
        col, row,
        self.entryCol, self.entryRow,
        self.exitCol, self.exitRow
    )
end

function GameMap:placeWall(col, row)
    if not self:canPlace(col, row) then return false end
    self.grid[row][col] = CELL_WALL
    self:_recalcPath()
    return true
end

function GameMap:placeTower(col, row)
    if not self:canPlace(col, row) then return false end
    self.grid[row][col] = CELL_TOWER
    self:_recalcPath()
    return true
end

function GameMap:remove(col, row)
    if col < 1 or col > self.cols or row < 1 or row > self.rows then
        return false
    end
    local cell = self.grid[row][col]
    if cell == CELL_WALL or cell == CELL_TOWER then
        self.grid[row][col] = CELL_EMPTY
        self:_recalcPath()
        return true
    end
    return false
end

function GameMap:getPath()
    return self.currentPath
end

function GameMap:getPathPixels()
    if not self.currentPath then return nil end
    local pixels = {}
    for i, node in ipairs(self.currentPath) do
        local x, y = self:cellToPixel(node.col, node.row)
        pixels[i] = {x = x, y = y}
    end
    return pixels
end

function GameMap:cellToPixel(col, row)
    local x = (col - 1) * self.cellSize + self.cellSize * 0.5
    local y = (row - 1) * self.cellSize + self.cellSize * 0.5
    return x, y
end

function GameMap:pixelToCell(px, py)
    local col = math.floor(px / self.cellSize) + 1
    local row = math.floor(py / self.cellSize) + 1
    return col, row
end

function GameMap:getCellType(col, row)
    if col < 1 or col > self.cols or row < 1 or row > self.rows then
        return nil
    end
    return self.grid[row][col]
end

function GameMap:draw()
    local gr = love.graphics
    for row = 1, self.rows do
        for col = 1, self.cols do
            local x = (col - 1) * self.cellSize
            local y = (row - 1) * self.cellSize
            local cell = self.grid[row][col]

            if cell == CELL_WALL then
                gr.setColor(0.35, 0.35, 0.4, 1)
            elseif cell == CELL_TOWER then
                gr.setColor(0.2, 0.2, 0.35, 1)
            elseif cell == CELL_ENTRY then
                gr.setColor(0.1, 0.5, 0.1, 1)
            elseif cell == CELL_EXIT then
                gr.setColor(0.5, 0.1, 0.1, 1)
            else
                gr.setColor(0.12, 0.14, 0.12, 1)
            end
            gr.rectangle("fill", x, y, self.cellSize, self.cellSize)

            -- 그리드 라인
            gr.setColor(0.25, 0.25, 0.25, 0.4)
            gr.rectangle("line", x, y, self.cellSize, self.cellSize)
        end
    end

    -- 현재 경로 표시
    if self.currentPath and #self.currentPath > 1 then
        gr.setColor(0.9, 0.8, 0.2, 0.25)
        gr.setLineWidth(2)
        for i = 1, #self.currentPath - 1 do
            local a = self.currentPath[i]
            local b = self.currentPath[i + 1]
            local ax, ay = self:cellToPixel(a.col, a.row)
            local bx, by = self:cellToPixel(b.col, b.row)
            gr.line(ax, ay, bx, by)
        end
        gr.setLineWidth(1)
    end

    gr.setColor(1, 1, 1, 1)
end

-- 상수 노출
GameMap.CELL_EMPTY = CELL_EMPTY
GameMap.CELL_WALL = CELL_WALL
GameMap.CELL_TOWER = CELL_TOWER
GameMap.CELL_ENTRY = CELL_ENTRY
GameMap.CELL_EXIT = CELL_EXIT

return GameMap

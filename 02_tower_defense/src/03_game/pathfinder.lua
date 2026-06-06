-- ============================================================================
-- pathfinder.lua — BFS 최단경로 탐색 (그리드 기반)
-- ============================================================================
--
-- ◆ 역할
--   오픈 그리드에서 시작점→끝점의 최단 경로를 BFS로 계산한다.
--   타워/벽 배치 시 경로 차단 여부를 미리 검증할 수 있다.
--
-- ◆ 반환값
--   경로가 존재하면 {col, row} 배열, 없으면 nil

local Pathfinder = {}

local DIRS = {
    {0, -1}, {0, 1}, {-1, 0}, {1, 0},  -- 상하좌우
}

--- BFS 최단경로 탐색
-- @param grid 2D 배열 (grid[row][col]), 0=통행가능, 그 외=차단
-- @param cols number 열 수
-- @param rows number 행 수
-- @param startCol, startRow 시작 셀
-- @param endCol, endRow 도착 셀
-- @return path table of {col, row} or nil
function Pathfinder.findPath(grid, cols, rows, startCol, startRow, endCol, endRow)
    if startCol == endCol and startRow == endRow then
        return {{col = startCol, row = startRow}}
    end

    -- 방문 배열
    local visited = {}
    for r = 1, rows do
        visited[r] = {}
    end

    -- BFS 큐 (간단한 ring buffer)
    local queue = {}
    local head, tail = 1, 0

    local function enqueue(col, row, parent)
        tail = tail + 1
        queue[tail] = {col = col, row = row, parent = parent}
    end

    local function dequeue()
        if head > tail then return nil end
        local item = queue[head]
        head = head + 1
        return item
    end

    enqueue(startCol, startRow, nil)
    visited[startRow][startCol] = true

    while head <= tail do
        local node = dequeue()
        if not node then break end

        for _, dir in ipairs(DIRS) do
            local nc = node.col + dir[1]
            local nr = node.row + dir[2]

            if nc >= 1 and nc <= cols and nr >= 1 and nr <= rows then
                if not visited[nr][nc] and grid[nr][nc] == 0 then
                    if nc == endCol and nr == endRow then
                        -- 경로 역추적
                        local path = {{col = nc, row = nr}}
                        local cur = node
                        while cur do
                            path[#path + 1] = {col = cur.col, row = cur.row}
                            cur = cur.parent
                        end
                        -- 역순 정렬
                        local reversed = {}
                        for i = #path, 1, -1 do
                            reversed[#reversed + 1] = path[i]
                        end
                        return reversed
                    end

                    visited[nr][nc] = true
                    enqueue(nc, nr, node)
                end
            end
        end
    end

    return nil  -- 경로 없음
end

--- 특정 셀을 차단했을 때 경로가 여전히 존재하는지 검증
-- @param grid 원본 그리드
-- @param cols, rows 크기
-- @param blockCol, blockRow 차단할 셀
-- @param startCol, startRow 시작
-- @param endCol, endRow 도착
-- @return boolean 경로 존재 여부
function Pathfinder.canBlock(grid, cols, rows, blockCol, blockRow, startCol, startRow, endCol, endRow)
    -- 시작/끝 지점은 차단 불가
    if (blockCol == startCol and blockRow == startRow) or
       (blockCol == endCol and blockRow == endRow) then
        return false
    end

    -- 임시로 차단
    local original = grid[blockRow][blockCol]
    grid[blockRow][blockCol] = 1

    local path = Pathfinder.findPath(grid, cols, rows, startCol, startRow, endCol, endRow)

    -- 복원
    grid[blockRow][blockCol] = original

    return path ~= nil
end

return Pathfinder

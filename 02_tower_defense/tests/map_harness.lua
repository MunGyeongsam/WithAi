-- ============================================================================
-- map_harness.lua — GameMap (미로 빌딩) 단위 테스트
-- ============================================================================
package.path = "../src/?.lua;" .. package.path

love = love or {}
love.graphics = love.graphics or {}

local GameMap = require("03_game.gameMap")

local function test_init()
    local map = GameMap.new({cols = 5, rows = 5, cellSize = 60, entryCol = 3, entryRow = 1, exitCol = 3, exitRow = 5})
    assert(map.cols == 5)
    assert(map.rows == 5)
    assert(map.grid[1][3] == GameMap.CELL_ENTRY)
    assert(map.grid[5][3] == GameMap.CELL_EXIT)
    assert(map.currentPath ~= nil, "initial path should exist")
    print("[PASS] test_init")
end

local function test_place_wall()
    local map = GameMap.new({cols = 5, rows = 5, cellSize = 60, entryCol = 3, entryRow = 1, exitCol = 3, exitRow = 5})
    assert(map:placeWall(1, 2) == true)
    assert(map.grid[2][1] == GameMap.CELL_WALL)
    assert(map.currentPath ~= nil, "path should still exist")
    print("[PASS] test_place_wall")
end

local function test_cannot_place_on_entry()
    local map = GameMap.new({cols = 5, rows = 5, cellSize = 60, entryCol = 3, entryRow = 1, exitCol = 3, exitRow = 5})
    assert(map:canPlace(3, 1) == false, "cannot place on entry")
    assert(map:canPlace(3, 5) == false, "cannot place on exit")
    print("[PASS] test_cannot_place_on_entry")
end

local function test_reject_placement_failures()
    local map = GameMap.new({cols = 5, rows = 5, cellSize = 60, entryCol = 3, entryRow = 1, exitCol = 3, exitRow = 5})
    assert(map:placeWall(1, 2) == true)
    assert(map:placeTower(1, 2) == false, "occupied cell should reject tower")
    assert(map:getCellType(1, 2) == GameMap.CELL_WALL)
    assert(map:placeWall(0, 2) == false)
    assert(map:placeTower(6, 2) == false)
    assert(map:placeWall(3, 1) == false, "entry should reject wall")
    assert(map:placeTower(3, 5) == false, "exit should reject tower")
    print("[PASS] test_reject_placement_failures")
end

local function test_cannot_block_path()
    -- 좁은 3x3 맵에서 유일한 경로를 차단 시도
    local map = GameMap.new({cols = 3, rows = 3, cellSize = 60, entryCol = 2, entryRow = 1, exitCol = 2, exitRow = 3})
    -- 좌/우를 벽으로 → (2,2)가 유일한 통로
    map:placeWall(1, 2)
    map:placeWall(3, 2)
    -- (2,2)를 차단하면 경로 없음 → canPlace가 false여야 함
    assert(map:canPlace(2, 2) == false, "should not block only path")
    local pathBefore = map:getPath()
    assert(map:placeWall(2, 2) == false, "wall placement should reject blocked path")
    assert(map:placeTower(2, 2) == false, "tower placement should reject blocked path")
    assert(map:getCellType(2, 2) == GameMap.CELL_EMPTY)
    assert(map:getPath() == pathBefore, "failed placement should preserve current path")
    print("[PASS] test_cannot_block_path")
end

local function test_place_tower()
    local map = GameMap.new({cols = 5, rows = 5, cellSize = 60, entryCol = 3, entryRow = 1, exitCol = 3, exitRow = 5})
    assert(map:placeTower(1, 1) == true)
    assert(map.grid[1][1] == GameMap.CELL_TOWER)
    print("[PASS] test_place_tower")
end

local function test_remove()
    local map = GameMap.new({cols = 5, rows = 5, cellSize = 60, entryCol = 3, entryRow = 1, exitCol = 3, exitRow = 5})
    map:placeWall(1, 1)
    assert(map:remove(1, 1) == true)
    assert(map.grid[1][1] == GameMap.CELL_EMPTY)
    print("[PASS] test_remove")
end

local function test_remove_failure_contract()
    local map = GameMap.new({cols = 5, rows = 5, cellSize = 60, entryCol = 3, entryRow = 1, exitCol = 3, exitRow = 5})
    assert(map:placeTower(1, 1) == true)
    assert(map:remove(1, 1) == true)
    assert(map:getCellType(1, 1) == GameMap.CELL_EMPTY)
    assert(map:remove(1, 1) == false, "empty cell should not remove")
    assert(map:remove(3, 1) == false, "entry should not remove")
    assert(map:remove(3, 5) == false, "exit should not remove")
    assert(map:remove(0, 1) == false, "out-of-range cell should not remove")
    print("[PASS] test_remove_failure_contract")
end

local function test_path_update_on_place()
    local map = GameMap.new({cols = 5, rows = 5, cellSize = 60, entryCol = 3, entryRow = 1, exitCol = 3, exitRow = 5})
    local pathBefore = #map.currentPath
    -- 벽 배치 → 경로 길어짐
    map:placeWall(3, 2)
    local pathAfter = #map.currentPath
    assert(pathAfter > pathBefore, "path should get longer after wall placement")
    print("[PASS] test_path_update_on_place")
end

test_init()
test_place_wall()
test_cannot_place_on_entry()
test_reject_placement_failures()
test_cannot_block_path()
test_place_tower()
test_remove()
test_remove_failure_contract()
test_path_update_on_place()
print("\n=== All map_harness tests passed ===")

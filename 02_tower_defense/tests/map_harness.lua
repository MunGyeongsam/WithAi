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

local function test_cannot_block_path()
    -- 좁은 3x3 맵에서 유일한 경로를 차단 시도
    local map = GameMap.new({cols = 3, rows = 3, cellSize = 60, entryCol = 2, entryRow = 1, exitCol = 2, exitRow = 3})
    -- 좌/우를 벽으로 → (2,2)가 유일한 통로
    map:placeWall(1, 2)
    map:placeWall(3, 2)
    -- (2,2)를 차단하면 경로 없음 → canPlace가 false여야 함
    assert(map:canPlace(2, 2) == false, "should not block only path")
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
test_cannot_block_path()
test_place_tower()
test_remove()
test_path_update_on_place()
print("\n=== All map_harness tests passed ===")

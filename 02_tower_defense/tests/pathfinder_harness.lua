-- ============================================================================
-- pathfinder_harness.lua — BFS Pathfinder 단위 테스트
-- ============================================================================
package.path = "../src/?.lua;" .. package.path

local Pathfinder = require("03_game.pathfinder")

local function test_direct_path()
    -- 3x3 빈 그리드, (1,1) → (3,3)
    local grid = {
        {0, 0, 0},
        {0, 0, 0},
        {0, 0, 0},
    }
    local path = Pathfinder.findPath(grid, 3, 3, 1, 1, 3, 3)
    assert(path ~= nil, "path should exist")
    assert(path[1].col == 1 and path[1].row == 1, "start")
    assert(path[#path].col == 3 and path[#path].row == 3, "end")
    -- BFS 최단: 맨해튼 거리 4 → 5 노드
    assert(#path == 5, "shortest path length should be 5, got " .. #path)
    print("[PASS] test_direct_path")
end

local function test_blocked_path()
    -- 벽으로 완전 차단
    local grid = {
        {0, 1, 0},
        {0, 1, 0},
        {0, 1, 0},
    }
    local path = Pathfinder.findPath(grid, 3, 3, 1, 1, 3, 1)
    assert(path == nil, "path should be blocked")
    print("[PASS] test_blocked_path")
end

local function test_maze_path()
    -- 미로: 벽 사이를 우회
    local grid = {
        {0, 0, 0, 0, 0},
        {1, 1, 1, 1, 0},
        {0, 0, 0, 0, 0},
        {0, 1, 1, 1, 1},
        {0, 0, 0, 0, 0},
    }
    local path = Pathfinder.findPath(grid, 5, 5, 1, 1, 5, 5)
    assert(path ~= nil, "path should exist through maze")
    assert(path[1].col == 1 and path[1].row == 1)
    assert(path[#path].col == 5 and path[#path].row == 5)
    print("[PASS] test_maze_path")
end

local function test_same_start_end()
    local grid = {{0}}
    local path = Pathfinder.findPath(grid, 1, 1, 1, 1, 1, 1)
    assert(path ~= nil)
    assert(#path == 1)
    print("[PASS] test_same_start_end")
end

local function test_canBlock_true()
    local grid = {
        {0, 0, 0},
        {0, 0, 0},
        {0, 0, 0},
    }
    -- 차단해도 우회 가능한 셀
    local ok = Pathfinder.canBlock(grid, 3, 3, 2, 2, 1, 1, 3, 3)
    assert(ok == true, "blocking center should still allow path")
    print("[PASS] test_canBlock_true")
end

local function test_canBlock_false()
    -- 좁은 통로를 차단
    local grid = {
        {0, 0, 0},
        {1, 0, 1},
        {0, 0, 0},
    }
    -- (2,2)를 차단하면 경로 없음
    local ok = Pathfinder.canBlock(grid, 3, 3, 2, 2, 1, 1, 3, 3)
    assert(ok == false, "blocking bottleneck should prevent path")
    print("[PASS] test_canBlock_false")
end

local function test_canBlock_entry_exit()
    local grid = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
    assert(Pathfinder.canBlock(grid, 3, 3, 1, 1, 1, 1, 3, 3) == false, "cannot block entry")
    assert(Pathfinder.canBlock(grid, 3, 3, 3, 3, 1, 1, 3, 3) == false, "cannot block exit")
    print("[PASS] test_canBlock_entry_exit")
end

test_direct_path()
test_blocked_path()
test_maze_path()
test_same_start_end()
test_canBlock_true()
test_canBlock_false()
test_canBlock_entry_exit()
print("\n=== All pathfinder_harness tests passed ===")

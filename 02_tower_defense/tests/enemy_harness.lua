-- ============================================================================
-- enemy_harness.lua — Enemy 단위 테스트 (지상 + 공중)
-- ============================================================================
package.path = "../src/?.lua;" .. package.path

love = love or {}
love.graphics = love.graphics or {}

local Enemy = require("03_game.enemy")

local function test_ground_create()
    local waypoints = {{x = 0, y = 0}, {x = 100, y = 0}, {x = 100, y = 100}}
    local e = Enemy.new("normal", waypoints, {x = 0, y = 0}, {x = 100, y = 100})
    assert(e ~= nil)
    assert(e.flying == false)
    assert(e.x == 0 and e.y == 0)
    assert(e.hp == 40)
    print("[PASS] test_ground_create")
end

local function test_flyer_create()
    local entry = {x = 0, y = 0}
    local exit = {x = 200, y = 200}
    local e = Enemy.new("flyer", nil, entry, exit)
    assert(e ~= nil)
    assert(e.flying == true)
    -- 공중: 직선 경로
    assert(#e.waypoints == 2)
    assert(e.waypoints[1].x == 0)
    assert(e.waypoints[2].x == 200)
    print("[PASS] test_flyer_create")
end

local function test_movement()
    local waypoints = {{x = 0, y = 0}, {x = 55, y = 0}}
    local e = Enemy.new("normal", waypoints, {x = 0, y = 0}, {x = 55, y = 0})
    -- speed=55, dt=1.0
    e:update(1.0)
    assert(math.abs(e.x - 55) < 1, "should reach near waypoint, got " .. e.x)
    print("[PASS] test_movement")
end

local function test_reach_end()
    local waypoints = {{x = 0, y = 0}, {x = 10, y = 0}}
    local e = Enemy.new("fast", waypoints, {x = 0, y = 0}, {x = 10, y = 0})
    e:update(1.0)
    assert(e.reachedEnd == true)
    print("[PASS] test_reach_end")
end

local function test_damage()
    local waypoints = {{x = 0, y = 0}, {x = 100, y = 0}}
    local e = Enemy.new("normal", waypoints, {x = 0, y = 0}, {x = 100, y = 0})
    e:takeDamage(30)
    assert(e.hp == 10)
    e:takeDamage(15)
    assert(e.hp == 0)
    assert(e.dead == true)
    print("[PASS] test_damage")
end

local function test_slow()
    local waypoints = {{x = 0, y = 0}, {x = 1000, y = 0}}
    local e = Enemy.new("normal", waypoints, {x = 0, y = 0}, {x = 1000, y = 0})
    e:applySlow(0.5, 2.0)
    e:update(1.0)
    -- speed should be 55 * 0.5 = 27.5, moved ~27.5
    assert(e.x > 25 and e.x < 30, "slowed movement, got " .. e.x)
    print("[PASS] test_slow")
end

local function test_path_update()
    local waypoints = {{x = 0, y = 0}, {x = 50, y = 0}, {x = 100, y = 0}}
    local e = Enemy.new("normal", waypoints, {x = 0, y = 0}, {x = 100, y = 0})
    e:update(0.5)  -- move a bit

    local newWaypoints = {{x = 0, y = 0}, {x = 0, y = 50}, {x = 100, y = 50}, {x = 100, y = 0}}
    e:updatePath(newWaypoints)
    assert(e.waypoints == newWaypoints)
    print("[PASS] test_path_update")
end

local function test_flyer_ignores_path_update()
    local e = Enemy.new("flyer", nil, {x = 0, y = 0}, {x = 200, y = 200})
    local origPath = e.waypoints
    e:updatePath({{x = 50, y = 50}, {x = 100, y = 100}})
    assert(e.waypoints == origPath, "flyer should ignore path update")
    print("[PASS] test_flyer_ignores_path_update")
end

test_ground_create()
test_flyer_create()
test_movement()
test_reach_end()
test_damage()
test_slow()
test_path_update()
test_flyer_ignores_path_update()
print("\n=== All enemy_harness tests passed ===")

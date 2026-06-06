-- ============================================================================
-- tower_harness.lua — Tower 단위 테스트 (Xeno Tactic 스타일)
-- ============================================================================
package.path = "../src/?.lua;" .. package.path

love = love or {}
love.graphics = love.graphics or {}

local Tower = require("03_game.tower")

local function test_create_all_types()
    for _, ttype in ipairs(Tower.getTypes()) do
        local t = Tower.new(ttype, 100, 100)
        assert(t ~= nil, ttype .. " should create")
        assert(t.type == ttype)
        assert(t.level == 1)
    end
    print("[PASS] test_create_all_types")
end

local function test_invalid_type()
    assert(Tower.new("invalid", 0, 0) == nil)
    print("[PASS] test_invalid_type")
end

local function test_gun_upgrade()
    local t = Tower.new("gun", 100, 100)
    assert(t:canUpgrade() == true)
    assert(t:getUpgradeCost() == 40)
    assert(t:upgrade() == true)
    assert(t.level == 2)
    assert(t.damage == 14)
    -- 3 upgrades total
    t:upgrade()
    t:upgrade()
    assert(t.level == 4)
    assert(t:canUpgrade() == false)
    print("[PASS] test_gun_upgrade")
end

local function test_antiair_targeting()
    local aa = Tower.new("antiair", 100, 100)
    local groundEnemy = {x = 110, y = 110, dead = false, progress = 0.5, flying = false}
    local airEnemy = {x = 110, y = 110, dead = false, progress = 0.5, flying = true}

    -- AA should only target flying
    aa.cooldown = 0
    local proj = aa:update(1.0, {groundEnemy, airEnemy})
    assert(proj ~= nil, "should fire at air target")
    assert(proj.target == airEnemy, "target should be flying enemy")
    print("[PASS] test_antiair_targeting")
end

local function test_gun_no_air()
    local gun = Tower.new("gun", 100, 100)
    local airEnemy = {x = 110, y = 110, dead = false, progress = 0.5, flying = true}

    gun.cooldown = 0
    local proj = gun:update(1.0, {airEnemy})
    assert(proj == nil, "gun should not target flying")
    print("[PASS] test_gun_no_air")
end

local function test_slow_tower()
    local t = Tower.new("slow", 100, 100)
    assert(t.slow == 0.4)
    assert(t.splash == 60)
    t:upgrade()
    assert(t.slow == 0.5)
    assert(t.splash == 70)
    print("[PASS] test_slow_tower")
end

local function test_sell_value()
    local t = Tower.new("gun", 100, 100)
    -- cost=30, sell=60% → 18
    assert(t:getSellValue() == 18)
    t:upgrade()
    -- 30 + 40 = 70, sell=42
    assert(t:getSellValue() == 42)
    print("[PASS] test_sell_value")
end

test_create_all_types()
test_invalid_type()
test_gun_upgrade()
test_antiair_targeting()
test_gun_no_air()
test_slow_tower()
test_sell_value()
print("\n=== All tower_harness tests passed ===")

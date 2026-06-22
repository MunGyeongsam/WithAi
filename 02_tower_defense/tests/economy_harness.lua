-- ============================================================================
-- economy_harness.lua — Economy 단위 테스트
-- ============================================================================
package.path = "../src/?.lua;" .. package.path

local Economy = require("03_game.economy")

local function test_initial()
    local eco = Economy.new(200, 20)
    assert(eco:getGold() == 200)
    assert(eco:getLives() == 20)
    assert(eco:isGameOver() == false)
    print("[PASS] test_initial")
end

local function test_spend()
    local eco = Economy.new(100, 10)
    assert(eco:canAfford(50) == true)
    assert(eco:spend(50) == true)
    assert(eco:getGold() == 50)
    assert(eco:spend(60) == false, "should not overspend")
    assert(eco:getGold() == 50)
    print("[PASS] test_spend")
end

local function test_earn()
    local eco = Economy.new(100, 10)
    eco:earn(50)
    assert(eco:getGold() == 150)
    print("[PASS] test_earn")
end

local function test_lives()
    local eco = Economy.new(100, 3)
    eco:loseLife(1)
    assert(eco:getLives() == 2)
    eco:loseLife(5)
    assert(eco:getLives() == 0)
    assert(eco:isGameOver() == true)
    print("[PASS] test_lives")
end

test_initial()
test_spend()
test_earn()
test_lives()
print("\n=== All economy_harness tests passed ===")

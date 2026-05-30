package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local Combo = require("03_game.combo")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local function assertNear(actual, expected, epsilon, message)
    local diff = math.abs(actual - expected)
    if diff > epsilon then
        error((message or "assertNear failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local combo = Combo.new(1.8, 0.25, 4, 2.5)

local gained1, mult1, count1 = Combo.registerHit(combo, 100)
assertEq(gained1, 100, "first hit points")
assertNear(mult1, 1.0, 0.0001, "first hit multiplier")
assertEq(count1, 1, "first hit count")

Combo.tick(combo, 0.5)
local gained2, mult2, count2 = Combo.registerHit(combo, 100)
assertEq(gained2, 100, "second hit points")
assertNear(mult2, 1.0, 0.0001, "second hit multiplier")
assertEq(count2, 2, "second hit count")

Combo.registerHit(combo, 100)
local gained4, mult4, count4 = Combo.registerHit(combo, 100)
assertEq(count4, 4, "fourth hit count")
assertNear(mult4, 1.0, 0.0001, "fourth hit multiplier")
assertEq(gained4, 100, "fourth hit points")

local gained5, mult5, count5 = Combo.registerHit(combo, 100)
assertEq(count5, 5, "fifth hit count")
assertNear(mult5, 1.25, 0.0001, "fifth hit multiplier")
assertEq(gained5, 125, "fifth hit points")

Combo.tick(combo, 3.0)
assertEq(combo.count, 0, "combo reset after timer")
assertNear(combo.multiplier, 1.0, 0.0001, "multiplier reset")

print("combo_harness: all checks passed")

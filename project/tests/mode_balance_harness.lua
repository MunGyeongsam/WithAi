package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local ModeBalance = require("03_game.modes.modeBalance")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local classic = ModeBalance.get("classic")
assertEq(classic.comboConfig.windowSeconds, 1.8, "classic combo window")
assertEq(classic.touchControl.response, 11, "classic touch response")
assertEq(classic.riskLane.enabled, false, "classic risk lane disabled")

local rush = ModeBalance.get("combo_rush")
assertEq(rush.levelClearBonusByLevel[1], 220, "rush level1 bonus")
assertEq(rush.ballSpeedScaleByLevel[3], 1.12, "rush level3 ball scale")
assertEq(rush.touchControl.maxSpeed, 1120, "rush touch max speed")
assertEq(rush.riskLane.enabled, true, "rush risk lane enabled")
assertEq(rush.riskLane.tokenCap, 4, "rush token cap")

local fallback = ModeBalance.get("unknown")
assertEq(fallback.comboConfig.hitsPerStep, 4, "fallback to classic")

print("mode_balance_harness: all checks passed")

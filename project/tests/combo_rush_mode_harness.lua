package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local ComboRushMode = require("03_game.modes.comboRushMode")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local mode = ComboRushMode.new()
local game = {
    score = 0,
}

mode:onReset(game)
assertEq(game.score, 0, "score reset")
assertEq(game.combo.count, 0, "combo count reset")

local gained = mode:awardBrickPoints(game, 100)
assertEq(gained, 100, "first hit points")

mode:awardBrickPoints(game, 100)
mode:awardBrickPoints(game, 100)
local boosted = mode:awardBrickPoints(game, 100)
if boosted <= 100 then
    error("combo rush multiplier should boost points")
end

mode:update(game, 2.0)
assertEq(game.combo.count, 0, "timeout reset")

game.score = 500
mode:onLevelTransition(game)
assertEq(game.score, 750, "level clear bonus")
assertEq(game.combo.count, 0, "level transition combo reset")

print("combo_rush_mode_harness: all checks passed")

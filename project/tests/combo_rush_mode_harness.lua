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
    level = 1,
    ballSpeed = 0,
    paddle = {speed = 0},
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
game.level = 2
mode:onLevelTransition(game)
assertEq(game.score, 820, "level clear bonus by level")
assertEq(game.combo.count, 0, "level transition combo reset")

mode:applyLevelRules(game, {ballSpeed = 600, paddleSpeed = 700})
assertEq(game.ballSpeed, 648, "ball speed scaled by level")
assertEq(game.paddle.speed, 672, "paddle speed scaled by level")

print("combo_rush_mode_harness: all checks passed")

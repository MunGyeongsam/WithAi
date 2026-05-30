package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local TouchFollow = require("03_game.input.touchFollow")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local function assertApprox(actual, expected, epsilon, message)
    if math.abs(actual - expected) > epsilon then
        error((message or "assertApprox failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local config = {
    response = 10,
    maxSpeed = 100,
    snapDistance = 5,
}

local x = TouchFollow.step(10, 13, 1 / 60, config, 0, 200)
assertEq(x, 13, "snap zone goes target")

x = TouchFollow.step(10, 110, 1.0, config, 0, 200)
assertEq(x, 110, "large dt clamps to target without overshoot")

x = TouchFollow.step(10, 110, 0.1, config, 0, 200)
assertApprox(x, 20, 0.0001, "limited speed step")

x = TouchFollow.step(195, 300, 0.5, config, 0, 200)
assertEq(x, 200, "respects max bound")

x = TouchFollow.step(5, -20, 0.5, config, 0, 200)
assertEq(x, 0, "respects min bound")

print("touch_follow_harness: all checks passed")

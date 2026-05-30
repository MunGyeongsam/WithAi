package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local TouchInput = require("03_game.input.touchInput")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local touches = {}
local positions = {}

local input = TouchInput.new({
    getTouches = function()
        return touches
    end,
    getPosition = function(id)
        return positions[id], 0
    end,
})

local s = input:update()
assertEq(s.moveAxis, 0, "idle axis")
assertEq(s.paddleTargetNorm, nil, "idle target")
assertEq(s.launchPressed, false, "idle launch")

touches = { 11 }
positions[11] = 0.1
s = input:update()
assertEq(s.moveAxis, -1, "left zone")
assertEq(s.paddleTargetNorm, 0.1, "left target")
assertEq(s.launchPressed, true, "touch edge press")

s = input:update()
assertEq(s.launchPressed, false, "touch hold no repeat")

positions[11] = 0.9
s = input:update()
assertEq(s.moveAxis, 1, "right zone")
assertEq(s.paddleTargetNorm, 0.9, "right target")

touches = {}
s = input:update()
assertEq(s.moveAxis, 0, "release axis")
assertEq(s.paddleTargetNorm, nil, "release target")
assertEq(s.launchPressed, false, "release launch")

print("touch_input_harness: all checks passed")

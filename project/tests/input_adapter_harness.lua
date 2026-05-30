package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local InputAdapter = require("03_game.input.inputAdapter")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local keys = {}
local adapter = InputAdapter.new({
    isDown = function(key)
        return keys[key] or false
    end,
})

local s = adapter:update()
assertEq(s.moveAxis, 0, "idle axis")
assertEq(s.launchPressed, false, "idle launch")

keys.left = true
s = adapter:update()
assertEq(s.moveAxis, -1, "left axis")
assertEq(s.launchPressed, false, "left no launch")

keys.space = true
s = adapter:update()
assertEq(s.launchPressed, true, "space edge press")

s = adapter:update()
assertEq(s.launchPressed, false, "space hold not repeated")

keys.space = false
s = adapter:update()
assertEq(s.launchPressed, false, "space release")

keys.r = true
s = adapter:update()
assertEq(s.restartPressed, true, "restart edge press")

s = adapter:update()
assertEq(s.restartPressed, false, "restart hold not repeated")

keys.right = true
keys.left = false
keys.r = false
s = adapter:update()
assertEq(s.moveAxis, 1, "right axis")

print("input_adapter_harness: all checks passed")

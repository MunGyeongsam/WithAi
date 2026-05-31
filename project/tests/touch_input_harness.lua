package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local TouchInput = require("03_game.input.touchInput")

local function assertEq(actual, expected, message)
    if type(actual) == "number" and type(expected) == "number" then
        if math.abs(actual - expected) <= 1e-9 then
            return
        end
    end
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local touches = {}
local positions = {}
local positionsY = {}

local input = TouchInput.new({
    getTouches = function()
        return touches
    end,
    getPosition = function(id)
        return positions[id], positionsY[id]
    end,
    getWidth = function()
        return 1
    end,
    getHeight = function()
        return 1
    end,
})

local s = input:update()
assertEq(s.moveAxis, 0, "idle axis")
assertEq(s.paddleTargetNorm, nil, "idle target")
assertEq(s.paddleDeltaNorm, 0, "idle delta")
assertEq(s.launchPressed, false, "idle launch")

touches = { 11 }
positions[11] = 0.1
positionsY[11] = 0.9
s = input:update()
assertEq(s.moveAxis, 0, "lane touch has no direct axis")
assertEq(s.paddleTargetNorm, 0.1, "lane touch sets absolute target")
assertEq(s.paddleDeltaNorm, 0, "lane touch keeps delta zero")
assertEq(s.serveAimNorm, 0.1, "lane touch sets serve aim")
assertEq(s.launchPressed, false, "touch down does not launch immediately")

s = input:update()
assertEq(s.launchPressed, false, "touch hold no repeat")

positions[11] = 0.9
s = input:update()
assertEq(s.paddleTargetNorm, 0.9, "drag updates absolute target")
assertEq(s.paddleDeltaNorm, 0, "drag keeps delta zero")
assertEq(s.serveAimNorm, 0.9, "drag updates serve aim")

touches = {}
s = input:update()
assertEq(s.moveAxis, 0, "release axis")
assertEq(s.paddleTargetNorm, nil, "release target")
assertEq(s.serveAimNorm, nil, "release aim")
assertEq(s.launchPressed, false, "release launch")

local pixelInput = TouchInput.new({
    getTouches = function()
        return touches
    end,
    getPosition = function(id)
        return positions[id], positionsY[id]
    end,
    getWidth = function()
        return 1000
    end,
    getHeight = function()
        return 2000
    end,
})

touches = { 11 }
positions[11] = 100
positionsY[11] = 1900
s = pixelInput:update()
assertEq(s.paddleTargetNorm, 0.1, "pixel initial touch target normalized")
assertEq(s.paddleDeltaNorm, 0, "pixel initial touch delta")

positions[11] = 900
s = pixelInput:update()
assertEq(s.paddleTargetNorm, 0.9, "pixel right target normalized as target")
assertEq(s.paddleDeltaNorm, 0, "pixel drag delta remains zero")

touches = {}
s = pixelInput:update()
assertEq(s.launchPressed, false, "drag release does not launch")

touches = { 11 }
positions[11] = 500
positionsY[11] = 1900
s = pixelInput:update()
assertEq(s.launchPressed, false, "tap down does not launch")

touches = {}
s = pixelInput:update()
assertEq(s.launchPressed, true, "tap release launches")

touches = { 12 }
positions[12] = 500
positionsY[12] = 1200
s = pixelInput:update()
assertEq(s.paddleTargetNorm, nil, "touch outside lane has no target")
assertEq(s.paddleDeltaNorm, 0, "touch outside lane ignored")

touches = {}
s = pixelInput:update()
assertEq(s.launchPressed, false, "outside lane release does not launch")

print("touch_input_harness: all checks passed")

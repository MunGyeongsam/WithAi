package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local InputAdapter = require("03_game.input.inputAdapter")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local keys = {}
local mouseState = {
    moveAxis = 0,
    paddleTargetNorm = nil,
    serveAimNorm = nil,
    launchPressed = false,
}
local touchState = {
    moveAxis = 0,
    paddleTargetNorm = nil,
    launchPressed = false,
}
local adapter = InputAdapter.new({
    isDown = function(key)
        return keys[key] or false
    end,
    mouseSource = {
        update = function()
            return {
                moveAxis = mouseState.moveAxis,
                paddleTargetNorm = mouseState.paddleTargetNorm,
                serveAimNorm = mouseState.serveAimNorm,
                launchPressed = mouseState.launchPressed,
                restartPressed = false,
                pausePressed = false,
            }
        end,
    },
    touchSource = {
        update = function()
            return {
                moveAxis = touchState.moveAxis,
                paddleTargetNorm = touchState.paddleTargetNorm,
                launchPressed = touchState.launchPressed,
                restartPressed = false,
                pausePressed = false,
            }
        end,
    },
})

local s = adapter:update()
assertEq(s.moveAxis, 0, "idle axis")
assertEq(s.launchPressed, false, "idle launch")
assertEq(s.serveAimNorm, nil, "idle aim")

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

keys["return"] = true
s = adapter:update()
assertEq(s.launchPressed, true, "return edge press")

s = adapter:update()
assertEq(s.launchPressed, false, "return hold not repeated")

keys["return"] = false
s = adapter:update()
assertEq(s.launchPressed, false, "return release")

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

keys.right = false
mouseState.moveAxis = -1
mouseState.paddleTargetNorm = 0.3
mouseState.serveAimNorm = 0.3
touchState.moveAxis = -1
touchState.paddleTargetNorm = 0.2
touchState.launchPressed = false
s = adapter:update()
assertEq(s.moveAxis, -1, "pointer axis fallback")
assertEq(s.paddleTargetNorm, nil, "axis active clears target")
assertEq(s.serveAimNorm, 0.3, "mouse aim forwarded")

mouseState.moveAxis = 0
touchState.moveAxis = 0
s = adapter:update()
assertEq(s.moveAxis, 0, "touch neutral axis")
assertEq(s.paddleTargetNorm, 0.2, "touch drag target fallback")

mouseState.paddleTargetNorm = nil
s = adapter:update()
assertEq(s.paddleTargetNorm, 0.2, "touch target remains active")

mouseState.launchPressed = true
s = adapter:update()
assertEq(s.launchPressed, true, "mouse launch press")

mouseState.launchPressed = false
s = adapter:update()
assertEq(s.launchPressed, false, "mouse launch release")

touchState.launchPressed = true
s = adapter:update()
assertEq(s.launchPressed, true, "touch launch press")

touchState.launchPressed = false
s = adapter:update()
assertEq(s.launchPressed, false, "touch launch release")

keys.left = true
keys.right = true
mouseState.moveAxis = -1
mouseState.paddleTargetNorm = 0.8
mouseState.serveAimNorm = 0.8
touchState.moveAxis = -1
touchState.paddleTargetNorm = 0.8
s = adapter:update()
assertEq(s.moveAxis, 0, "keyboard conflict keeps neutral axis")
assertEq(s.paddleTargetNorm, nil, "keyboard conflict blocks touch target fallback")
assertEq(s.serveAimNorm, 0.8, "keyboard conflict keeps mouse aim")

keys.left = false
keys.right = false
mouseState.moveAxis = -1
mouseState.paddleTargetNorm = 0.8
touchState.moveAxis = -1
touchState.paddleTargetNorm = 0.8
s = adapter:update()
assertEq(s.moveAxis, -1, "touch fallback resumes after keyboard release")
assertEq(s.paddleTargetNorm, nil, "touch axis active keeps target nil")

mouseState.moveAxis = 0
touchState.moveAxis = 0
s = adapter:update()
assertEq(s.paddleTargetNorm, 0.8, "touch target resumes after axis neutral")

print("input_adapter_harness: all checks passed")

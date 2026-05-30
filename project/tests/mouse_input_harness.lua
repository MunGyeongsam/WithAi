package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local MouseInput = require("03_game.input.mouseInput")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local mouseX = 0
local mouseDown = false

local input = MouseInput.new({
    getPosition = function()
        return mouseX, 0
    end,
    isDown = function(button)
        if button ~= 1 then
            return false
        end
        return mouseDown
    end,
    getWidth = function()
        return 100
    end,
})

local s = input:update()
assertEq(s.moveAxis, 0, "mouse does not move axis")
assertEq(s.paddleTargetNorm, nil, "mouse does not set paddle target")
assertEq(s.serveAimNorm, 0, "left aim norm")
assertEq(s.launchPressed, false, "left idle launch")

mouseX = 50
s = input:update()
assertEq(s.moveAxis, 0, "center axis remains neutral")
assertEq(s.serveAimNorm, 0.5, "center aim norm")

mouseDown = true
s = input:update()
assertEq(s.launchPressed, true, "mouse launch edge")

s = input:update()
assertEq(s.launchPressed, false, "mouse hold no repeat")

mouseDown = false
mouseX = 130
s = input:update()
assertEq(s.serveAimNorm, 1, "clamped high norm")
assertEq(s.moveAxis, 0, "right zone still neutral axis")

mouseX = -20
s = input:update()
assertEq(s.serveAimNorm, 0, "clamped low norm")
assertEq(s.moveAxis, 0, "left zone still neutral axis")

print("mouse_input_harness: all checks passed")
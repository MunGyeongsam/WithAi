package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local MouseInput = require("03_game.input.mouseInput")

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

local mouseX = 0
local mouseY = 0
local mouseDown = false

local input = MouseInput.new({
    getPosition = function()
        return mouseX, mouseY
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
    getHeight = function()
        return 100
    end,
})

local s = input:update()
assertEq(s.moveAxis, 0, "mouse does not move axis")
assertEq(s.paddleTargetNorm, nil, "mouse does not set paddle target")
assertEq(s.paddleDeltaNorm, 0, "mouse idle delta")
assertEq(s.serveAimNorm, 0, "left aim norm")
assertEq(s.launchPressed, false, "left idle launch")

mouseX = 50
s = input:update()
assertEq(s.moveAxis, 0, "center axis remains neutral")
assertEq(s.serveAimNorm, 0.5, "center aim norm")

mouseDown = true
mouseY = 90
s = input:update()
assertEq(s.launchPressed, false, "mouse down does not launch")
assertEq(s.paddleTargetNorm, 0.5, "initial lane target follows cursor")
assertEq(s.paddleDeltaNorm, 0, "initial lane delta is not used")

mouseX = 80
s = input:update()
assertEq(s.paddleTargetNorm, 0.8, "mouse drag updates absolute target")
assertEq(s.paddleDeltaNorm, 0, "mouse drag keeps delta zero")

mouseDown = false
s = input:update()
assertEq(s.launchPressed, false, "mouse drag release does not launch")

mouseX = 60
mouseY = 90
mouseDown = true
s = input:update()
assertEq(s.launchPressed, false, "tap down no launch")
mouseDown = false
s = input:update()
assertEq(s.launchPressed, true, "tap release launches")

mouseX = 130
s = input:update()
assertEq(s.serveAimNorm, 1, "clamped high norm")
assertEq(s.moveAxis, 0, "right zone still neutral axis")
assertEq(s.paddleTargetNorm, nil, "outside lane no absolute target")
assertEq(s.paddleDeltaNorm, 0, "outside lane no delta")

mouseX = -20
mouseY = 40
s = input:update()
assertEq(s.serveAimNorm, 0, "clamped low norm")
assertEq(s.moveAxis, 0, "left zone still neutral axis")

print("mouse_input_harness: all checks passed")
package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local SceneStack = require("01_core.sceneStack")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local events = {}

local function makeScene(name)
    return {
        onEnter = function()
            events[#events + 1] = name .. ":enter"
        end,
        onExit = function()
            events[#events + 1] = name .. ":exit"
        end,
        update = function(_, dt)
            events[#events + 1] = name .. ":update:" .. tostring(dt)
        end,
        draw = function()
            events[#events + 1] = name .. ":draw"
        end,
        keypressed = function(_, key)
            events[#events + 1] = name .. ":key:" .. key
        end,
        setInputSnapshot = function(_, snapshot)
            events[#events + 1] = name .. ":input:" .. tostring(snapshot.moveAxis)
        end,
        resize = function(_, w, h)
            events[#events + 1] = name .. ":resize:" .. tostring(w) .. "x" .. tostring(h)
        end,
    }
end

local stack = SceneStack.new()
local a = makeScene("A")
local b = makeScene("B")
local c = makeScene("C")

stack:push(a)
assertEq(stack:top(), a, "top after push A")
assertEq(a._stack, stack, "scene receives stack reference")

stack:setInputSnapshot({moveAxis = 1})
stack:update(0.1)
stack:draw()
stack:keypressed("space", "space")
stack:resize(540, 1200)

stack:push(b)
assertEq(stack:top(), b, "top after push B")

local popped = stack:pop()
assertEq(popped, b, "pop returns B")
assertEq(stack:top(), a, "top back to A")

stack:replace(c)
assertEq(stack:top(), c, "top after replace C")

stack:push(a)
stack:draw()
stack:resize(360, 800)

assertEq(events[1], "A:enter", "A entered first")
assertEq(events[2], "A:input:1", "A input forwarded")
assertEq(events[3], "A:update:0.1", "A update forwarded")
assertEq(events[4], "A:draw", "A draw forwarded")
assertEq(events[5], "A:key:space", "A key forwarded")
assertEq(events[6], "A:resize:540x1200", "A resize forwarded")
assertEq(events[7], "B:enter", "B entered")
assertEq(events[8], "B:exit", "B exited on pop")
assertEq(events[9], "A:exit", "A exited on replace")
assertEq(events[10], "C:enter", "C entered on replace")
assertEq(events[11], "A:enter", "A entered after push on C")
assertEq(events[12], "C:draw", "layer draw includes base scene")
assertEq(events[13], "A:draw", "layer draw includes top scene")
assertEq(events[14], "C:resize:360x800", "layer resize includes base scene")
assertEq(events[15], "A:resize:360x800", "layer resize includes top scene")

print("scene_stack_harness: all checks passed")

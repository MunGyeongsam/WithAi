local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*/)") or ""
package.path = scriptDirectory .. "../../src/?.lua;" .. package.path

local SceneStack = require("01_core.sceneStack")

local function createScene(name, trace)
    return {
        onEnter = function()
            trace[#trace + 1] = name .. ":enter"
        end,
        onExit = function()
            trace[#trace + 1] = name .. ":exit"
        end,
        update = function(_, dt)
            trace[#trace + 1] = name .. ":update:" .. tostring(dt)
        end,
        draw = function()
            trace[#trace + 1] = name .. ":draw"
        end,
        setInputSnapshot = function(_, snapshot)
            trace[#trace + 1] = name .. ":input:" .. snapshot.id
        end,
        resize = function(_, width, height)
            trace[#trace + 1] = name .. ":resize:" .. width .. "x" .. height
        end,
    }
end

local function clearTrace(trace)
    for i = #trace, 1, -1 do
        trace[i] = nil
    end
end

local function test_push_pop_replace_lifecycle()
    local stack = SceneStack.new()
    local trace = {}
    local first = createScene("first", trace)
    local second = createScene("second", trace)

    stack:push(first)
    stack:replace(second)

    assert(first._stack == stack)
    assert(second._stack == stack)
    assert(stack:top() == second)
    assert(table.concat(trace, ",") == "first:enter,first:exit,second:enter")

    assert(stack:pop() == second)
    assert(stack:top() == nil)
    assert(trace[#trace] == "second:exit")
    print("[PASS] test_push_pop_replace_lifecycle")
    return true
end

local function test_updates_and_inputs_only_top_scene()
    local stack = SceneStack.new()
    local trace = {}

    stack:push(createScene("first", trace))
    stack:push(createScene("second", trace))
    clearTrace(trace)
    stack:update(1 / 60)
    stack:setInputSnapshot({id = "tap"})

    assert(#trace == 2)
    assert(trace[1] == "second:update:0.016666666666667")
    assert(trace[2] == "second:input:tap")
    print("[PASS] test_updates_and_inputs_only_top_scene")
    return true
end

local function test_pop_restores_previous_scene()
    local stack = SceneStack.new()
    local trace = {}
    local first = createScene("first", trace)
    local second = createScene("second", trace)

    stack:push(first)
    stack:push(second)
    clearTrace(trace)

    assert(stack:pop() == second)
    assert(stack:top() == first)
    assert(trace[#trace] == "second:exit")

    stack:update(1)
    assert(trace[#trace] == "first:update:1")
    print("[PASS] test_pop_restores_previous_scene")
    return true
end

local function test_draws_and_resizes_entire_stack()
    local stack = SceneStack.new()
    local trace = {}

    stack:push(createScene("first", trace))
    stack:push(createScene("second", trace))
    clearTrace(trace)
    stack:draw()
    stack:resize(540, 960)

    assert(table.concat(trace, ",") ==
        "first:draw,second:draw,first:resize:540x960,second:resize:540x960")
    print("[PASS] test_draws_and_resizes_entire_stack")
    return true
end

test_push_pop_replace_lifecycle()
test_updates_and_inputs_only_top_scene()
test_pop_restores_previous_scene()
test_draws_and_resizes_entire_stack()
print("\n=== All scene_stack_harness tests passed ===")

local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*/)") or ""
package.path = scriptDirectory .. "../../src/?.lua;" .. package.path

local FixedTimestep = require("01_core.fixedTimestep")

local function near(actual, expected, epsilon)
    return math.abs(actual - expected) <= epsilon
end

local function test_clamps_frame_dt()
    local fixed = FixedTimestep.new()
    local callbacks = 0

    fixed:update(1, function(dt)
        assert(near(dt, 1 / 60, 0.000001))
        callbacks = callbacks + 1
    end)

    assert(callbacks == 8)
    assert(fixed.stepCount == 8)
    assert(near(fixed.totalTime, 8 / 60, 0.000001))
    assert(near(fixed.accumulator, 0.25 - 8 / 60, 0.000001))
    assert(fixed:getAlpha() > 1)
    assert(fixed:getRenderAlpha() == 1)
    print("[PASS] test_clamps_frame_dt")
    return true
end

local function test_consumes_configured_steps()
    local fixed = FixedTimestep.new(0.1, 4)
    local callbacks = 0

    fixed:update(0.25, function(dt)
        assert(dt == 0.1)
        callbacks = callbacks + 1
    end)

    assert(callbacks == 2)
    assert(fixed.stepCount == 2)
    assert(near(fixed.totalTime, 0.2, 0.000001))
    assert(near(fixed.accumulator, 0.05, 0.000001))
    assert(near(fixed:getAlpha(), 0.5, 0.000001))
    assert(near(fixed:getRenderAlpha(), 0.5, 0.000001))
    print("[PASS] test_consumes_configured_steps")
    return true
end

local function test_preserves_backlog_at_iteration_limit()
    local fixed = FixedTimestep.new(0.05, 2)

    fixed:update(0.25, function() end)

    assert(fixed.stepCount == 2)
    assert(near(fixed.accumulator, 0.15, 0.000001))
    assert(near(fixed:getAlpha(), 3, 0.000001))
    assert(fixed:getRenderAlpha() == 1)
    print("[PASS] test_preserves_backlog_at_iteration_limit")
    return true
end

local function test_carries_accumulator_into_next_frame()
    local fixed = FixedTimestep.new(0.1, 2)
    local callbacks = 0

    fixed:update(0.25, function()
        callbacks = callbacks + 1
    end)
    assert(callbacks == 2)
    assert(near(fixed.accumulator, 0.05, 0.000001))

    fixed:update(0.06, function()
        callbacks = callbacks + 1
    end)

    assert(callbacks == 3)
    assert(fixed.stepCount == 3)
    assert(near(fixed.accumulator, 0.01, 0.000001))
    print("[PASS] test_carries_accumulator_into_next_frame")
    return true
end

test_clamps_frame_dt()
test_consumes_configured_steps()
test_preserves_backlog_at_iteration_limit()
test_carries_accumulator_into_next_frame()
print("\n=== All fixed_timestep_harness tests passed ===")

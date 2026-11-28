local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*/)") or ""
package.path = scriptDirectory .. "../../src/?.lua;" .. package.path

local InputAdapter = require("03_game.input.inputAdapter")

local function withTimeSource()
    local now = 0
    _G.love = {
        timer = {
            getTime = function()
                return now
            end,
        },
    }
    return function(value)
        now = value
    end
end

local function test_mouse_tap_is_consumed_once()
    withTimeSource()
    local input = InputAdapter.new()

    input:mousepressed(120, 240, 1)
    local first = input:update()
    local firstTapped = first.tapped
    local firstX = first.tapX
    local firstY = first.tapY
    local second = input:update()

    assert(first == second)
    assert(firstTapped == true)
    assert(firstX == 120)
    assert(firstY == 240)
    assert(second.tapped == false)
    assert(second.tapX == nil)
    assert(second.tapY == nil)
    print("[PASS] test_mouse_tap_is_consumed_once")
    return true
end

local function test_touch_tap_is_consumed_once()
    withTimeSource()
    local input = InputAdapter.new()

    input:touchpressed("touch-1", 40, 80)
    local first = input:update()

    assert(first.tapped == true)
    assert(first.tapX == 40)
    assert(first.tapY == 80)

    local second = input:update()
    assert(second.tapped == false)
    assert(second.tapX == nil)
    assert(second.tapY == nil)
    print("[PASS] test_touch_tap_is_consumed_once")
    return true
end

local function test_hold_uses_current_timer_and_release_clears_it()
    local setTime = withTimeSource()
    local input = InputAdapter.new()

    setTime(10)
    input:touchpressed("touch-1", 25, 50)
    setTime(10.5)
    local boundary = input:update()
    assert(boundary.holding == false)

    setTime(10.51)
    local held = input:update()
    assert(held.holding == true)
    assert(held.holdX == 25)
    assert(held.holdY == 50)

    input:touchreleased("touch-1", 25, 50)
    assert(input:update().holding == false)
    print("[PASS] test_hold_uses_current_timer_and_release_clears_it")
    return true
end

local function test_non_left_mouse_press_is_ignored()
    withTimeSource()
    local input = InputAdapter.new()

    input:mousepressed(10, 20, 2)
    local snapshot = input:update()

    assert(snapshot.tapped == false)
    assert(snapshot.holding == false)
    print("[PASS] test_non_left_mouse_press_is_ignored")
    return true
end

test_mouse_tap_is_consumed_once()
test_touch_tap_is_consumed_once()
test_hold_uses_current_timer_and_release_clears_it()
test_non_left_mouse_press_is_ignored()
print("\n=== All input_adapter_harness tests passed ===")

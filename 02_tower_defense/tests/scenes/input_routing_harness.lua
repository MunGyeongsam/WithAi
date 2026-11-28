local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*/)") or ""
package.path = scriptDirectory .. "../../src/?.lua;" .. package.path

local InputAdapter = require("03_game.input.inputAdapter")
local SceneStack = require("01_core.sceneStack")

local function installLoveStub()
    _G.love = {
        timer = {
            getTime = function()
                return 0
            end,
        },
    }
end

local function createScene(trace, name)
    return {
        setInputSnapshot = function(_, snapshot)
            trace[#trace + 1] = {
                scene = name,
                snapshot = snapshot,
                tapped = snapshot.tapped,
                tapX = snapshot.tapX,
                tapY = snapshot.tapY,
            }
        end,
    }
end

local function test_snapshot_routes_to_top_scene()
    installLoveStub()
    local input = InputAdapter.new()
    local stack = SceneStack.new()
    local trace = {}

    stack:push(createScene(trace, "lower"))
    stack:push(createScene(trace, "top"))
    input:mousepressed(120, 240, 1)
    stack:setInputSnapshot(input:update())

    assert(#trace == 1)
    assert(trace[1].scene == "top")
    assert(trace[1].snapshot == input.snapshot)
    assert(trace[1].tapped == true)
    assert(trace[1].tapX == 120)
    assert(trace[1].tapY == 240)
    print("[PASS] test_snapshot_routes_to_top_scene")
    return true
end

local function test_adapter_consumes_tap_once_across_routing()
    installLoveStub()
    local input = InputAdapter.new()
    local stack = SceneStack.new()
    local trace = {}

    stack:push(createScene(trace, "top"))
    input:touchpressed("touch-1", 30, 60)
    stack:setInputSnapshot(input:update())
    stack:setInputSnapshot(input:update())

    assert(#trace == 2)
    assert(trace[1].tapped == true)
    assert(trace[1].snapshot == trace[2].snapshot)
    assert(trace[2].tapped == false)
    assert(trace[2].tapX == nil)
    assert(trace[2].tapY == nil)
    print("[PASS] test_adapter_consumes_tap_once_across_routing")
    return true
end

test_snapshot_routes_to_top_scene()
test_adapter_consumes_tap_once_across_routing()
print("\n=== All input_routing_harness tests passed ===")

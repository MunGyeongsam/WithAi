local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*/)") or ""
package.path = scriptDirectory .. "../../src/?.lua;" .. package.path

local VirtualResolution = require("01_core.virtualResolution")

local function test_letterbox_geometry_and_round_trip()
    local virtual = VirtualResolution.new(540, 960)

    virtual:resize(1080, 1920)
    assert(virtual.scale == 2)
    assert(virtual.offsetX == 0)
    assert(virtual.offsetY == 0)

    local x, y = virtual:toVirtual(500, 900)
    assert(x == 250)
    assert(y == 450)

    virtual:resize(1080, 1080)
    assert(virtual.scale == 1.125)
    assert(virtual.offsetX == 236)
    assert(virtual.offsetY == 0)

    x, y = virtual:toVirtual(371.5, 540)
    assert(math.abs(x - 120.44444444444) < 0.000001)
    assert(y == 480)
    print("[PASS] test_letterbox_geometry_and_round_trip")
    return true
end

local function test_non_positive_scale_falls_back_to_one()
    local virtual = VirtualResolution.new(540, 960)

    virtual:resize(0, 0)

    assert(virtual.scale == 1)
    assert(virtual.offsetX == -270)
    assert(virtual.offsetY == -480)
    print("[PASS] test_non_positive_scale_falls_back_to_one")
    return true
end

local function test_begin_and_end_draw_apply_transform()
    local calls = {}
    _G.love = {
        graphics = {
            push = function()
                calls[#calls + 1] = "push"
            end,
            translate = function(x, y)
                calls[#calls + 1] = "translate:" .. x .. "," .. y
            end,
            scale = function(scaleX, scaleY)
                calls[#calls + 1] = "scale:" .. scaleX .. "," .. scaleY
            end,
            pop = function()
                calls[#calls + 1] = "pop"
            end,
        },
    }
    local virtual = VirtualResolution.new(540, 960)
    virtual:resize(1080, 1920)

    virtual:beginDraw()
    virtual:endDraw()

    assert(table.concat(calls, ",") == "push,translate:0,0,scale:2,2,pop")
    print("[PASS] test_begin_and_end_draw_apply_transform")
    return true
end

test_letterbox_geometry_and_round_trip()
test_non_positive_scale_falls_back_to_one()
test_begin_and_end_draw_apply_transform()
print("\n=== All virtual_resolution_harness tests passed ===")

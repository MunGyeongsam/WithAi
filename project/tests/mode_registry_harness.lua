package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local ModeRegistry = require("03_game.modes.modeRegistry")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local id, mode = ModeRegistry.create("classic")
assertEq(id, "classic", "classic id")
if not mode then
    error("classic mode should be created")
end

id, mode = ModeRegistry.create("combo_rush")
assertEq(id, "combo_rush", "combo rush id")
if not mode then
    error("combo rush mode should be created")
end

id, mode = ModeRegistry.create("invalid")
assertEq(id, "classic", "invalid id fallback")
if not mode then
    error("fallback mode should be created")
end

print("mode_registry_harness: all checks passed")

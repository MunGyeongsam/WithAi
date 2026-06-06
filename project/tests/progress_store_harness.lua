package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local ProgressStore = require("03_game.progressStore")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local writes = {}
local fakeFilesystem = {
    getInfo = function(path)
        if writes[path] then
            return {type = "file"}
        end
        return nil
    end,
    read = function(path)
        return writes[path]
    end,
    write = function(path, contents)
        writes[path] = contents
        return true
    end,
}

local store = ProgressStore.new({filesystem = fakeFilesystem, path = "progress.lua"})
local initial = store:getSnapshot("classic", 5)
assertEq(initial.unlockedLevel, 1, "default unlocked level")
assertEq(initial.levels[1].bestScore, 0, "default best score")

store:recordLevelResult("classic", 1, 5, 4200, true, 2)
local afterClear = store:getSnapshot("classic", 5)
assertEq(afterClear.unlockedLevel, 2, "clear unlocks next level")
assertEq(afterClear.levels[1].cleared, true, "clear recorded")
assertEq(afterClear.levels[1].bestScore, 4200, "best score recorded")

store:recordLevelResult("classic", 1, 5, 1200, false, 1)
local afterLower = store:getSnapshot("classic", 5)
assertEq(afterLower.levels[1].bestScore, 4200, "lower score does not overwrite best")

local reloaded = ProgressStore.new({filesystem = fakeFilesystem, path = "progress.lua"})
local restored = reloaded:getSnapshot("classic", 5)
assertEq(restored.unlockedLevel, 2, "saved unlock level reloads")
assertEq(restored.levels[1].cleared, true, "saved clear reloads")
assertEq(restored.levels[1].bestScore, 4200, "saved best score reloads")

print("progress_store_harness: all checks passed")
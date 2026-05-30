package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local LevelSelectScene = require("03_game.scenes.levelSelectScene")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local fakeStore = {
    getSnapshot = function(_, modeId, totalLevels)
        local levels = {}
        for i = 1, totalLevels do
            levels[i] = {
                cleared = i <= 2,
                bestScore = i * 1000,
            }
        end
        return {
            unlockedLevel = 3,
            levels = levels,
        }
    end,
}

local startedMode
local startedLevel
local scene = LevelSelectScene.new(540, 1200, {
    modeId = "classic",
    progressStore = fakeStore,
    startGameFactory = function(_, _, modeId, startLevel)
        startedMode = modeId
        startedLevel = startLevel
        return {
            draw = function() end,
            keypressed = function() end,
        }
    end,
})

scene._stack = {
    replace = function(_, nextScene)
        scene._replaced = nextScene
    end,
}

assertEq(scene.progressSnapshot.unlockedLevel, 3, "level select reads unlocked level")
assertEq(scene:isUnlocked(3), true, "third level unlocked")
assertEq(scene:isUnlocked(4), false, "fourth level locked")

scene:startSelected(4)
assertEq(startedLevel, nil, "locked level should not start")

scene:startSelected(3)
assertEq(startedMode, "classic", "start preserves mode")
assertEq(startedLevel, 3, "unlocked level starts")

print("level_select_progress_harness: all checks passed")
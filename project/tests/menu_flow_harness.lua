package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local SceneStack = require("01_core.sceneStack")
local TitleScene = require("03_game.scenes.titleScene")
local ModeSelectScene = require("03_game.scenes.modeSelectScene")
local LevelSelectScene = require("03_game.scenes.levelSelectScene")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local selectedMode
local selectedLevel
local makeModeScene
local makeLevelScene
local fakeProgressStore = {
    getSnapshot = function(_, _, totalLevels)
        local levels = {}
        for i = 1, totalLevels do
            levels[i] = {
                cleared = false,
                bestScore = 0,
            }
        end
        return {
            unlockedLevel = totalLevels,
            levels = levels,
        }
    end,
}

makeLevelScene = function(modeId)
    selectedMode = modeId
    return LevelSelectScene.new(540, 1200, {
        modeId = modeId,
        progressStore = fakeProgressStore,
        previousSceneFactory = function()
            return makeModeScene()
        end,
        startGameFactory = function(_, _, nextModeId, startLevel)
            selectedMode = nextModeId
            selectedLevel = startLevel
            return {
                keypressed = function() end,
                draw = function() end,
            }
        end,
    })
end

makeModeScene = function()
    return ModeSelectScene.new(540, 1200, {
        nextSceneFactory = function(_, _, modeId)
            return makeLevelScene(modeId)
        end,
    })
end

local stack1 = SceneStack.new()
local title = TitleScene.new(540, 1200, {
    nextSceneFactory = function()
        return makeModeScene()
    end,
})

stack1:push(title)
assertEq(stack1:top(), title, "title pushed")
stack1:keypressed("space", "space")
if getmetatable(stack1:top()) ~= ModeSelectScene then
    error("title should transition to mode select scene")
end
stack1:keypressed("backspace", "backspace")
if getmetatable(stack1:top()) ~= TitleScene then
    error("mode select should go back to title scene")
end

local stack2 = SceneStack.new()
stack2:push(makeModeScene())
stack2:keypressed("down", "down")
stack2:keypressed("return", "return")
if getmetatable(stack2:top()) ~= LevelSelectScene then
    error("mode select should transition to level select")
end
stack2:keypressed("backspace", "backspace")
if getmetatable(stack2:top()) ~= ModeSelectScene then
    error("level select should go back to mode select scene")
end

local stack3 = SceneStack.new()
stack3:push(makeModeScene())
stack3:keypressed("down", "down")
stack3:keypressed("return", "return")
if getmetatable(stack3:top()) ~= LevelSelectScene then
    error("mode select should transition to level select on start path")
end
stack3:keypressed("down", "down")
stack3:keypressed("left", "left")
stack3:keypressed("return", "return")
assertEq(selectedMode, "combo_rush", "level select keeps selected mode")
assertEq(selectedLevel, 3, "level select starts chosen level")

print("menu_flow_harness: all checks passed")
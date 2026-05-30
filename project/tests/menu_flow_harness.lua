package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local SceneStack = require("01_core.sceneStack")
local TitleScene = require("03_game.scenes.titleScene")
local ModeSelectScene = require("03_game.scenes.modeSelectScene")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local stack = SceneStack.new()

local selectedMode
local modeScene = ModeSelectScene.new(540, 1200, {
    startGameFactory = function(_, _, modeId)
        selectedMode = modeId
        return {
            keypressed = function() end,
            draw = function() end,
        }
    end,
})

local title = TitleScene.new(540, 1200, {
    nextSceneFactory = function()
        return modeScene
    end,
})

stack:push(title)
assertEq(stack:top(), title, "title pushed")

stack:keypressed("space", "space")
assertEq(stack:top(), modeScene, "title transitions to mode select")

stack:keypressed("down", "down")
stack:keypressed("return", "return")
assertEq(selectedMode, "combo_rush", "mode select starts selected mode")

print("menu_flow_harness: all checks passed")
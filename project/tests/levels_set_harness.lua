package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local Levels = require("03_game.levels")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

if type(Levels.classic) ~= "table" or #Levels.classic == 0 then
    error("classic level set must exist")
end

if type(Levels.combo_rush) ~= "table" or #Levels.combo_rush == 0 then
    error("combo_rush level set must exist")
end

assertEq(#Levels.classic, 3, "classic level count")
assertEq(#Levels.combo_rush, 3, "combo_rush level count")

local classicFirst = Levels.classic[1]
local rushFirst = Levels.combo_rush[1]

if classicFirst.layout[1] == rushFirst.layout[1] then
    error("mode level layouts should differ")
end

local function countChar(layout, ch)
    local total = 0
    for row = 1, #layout do
        local line = layout[row]
        for col = 1, string.len(line) do
            if string.sub(line, col, col) == ch then
                total = total + 1
            end
        end
    end
    return total
end

local rush2 = Levels.combo_rush[2]
local rush3 = Levels.combo_rush[3]

if rush3.ballSpeed <= rush2.ballSpeed then
    error("combo_rush level3 should be faster than level2")
end

if countChar(rush3.layout, "3") <= countChar(rush2.layout, "3") then
    error("combo_rush level3 should have denser high-hp bricks")
end

print("levels_set_harness: all checks passed")

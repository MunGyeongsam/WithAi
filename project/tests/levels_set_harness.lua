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

assertEq(#Levels.classic, 5, "classic level count")
assertEq(#Levels.combo_rush, 5, "combo_rush level count")

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
local rush4 = Levels.combo_rush[4]
local rush5 = Levels.combo_rush[5]

if type(rush2.specialBricks) ~= "table" then
    error("combo_rush level2 must define specialBricks")
end

local function hasSpecialKind(specialBricks, kind)
    for _, spec in pairs(specialBricks) do
        if spec.kind == kind then
            return true
        end
    end
    return false
end

if not hasSpecialKind(rush2.specialBricks, "keyhole") then
    error("combo_rush level2 should contain keyhole brick")
end

if not hasSpecialKind(rush2.specialBricks, "lock") then
    error("combo_rush level2 should contain lock brick")
end

if not hasSpecialKind(rush2.specialBricks, "risk_core") then
    error("combo_rush level2 should contain risk_core brick")
end

local lockGroups = {}
local keyholeGroups = {}
for _, spec in pairs(rush2.specialBricks) do
    if spec.kind == "lock" then
        if type(spec.group) ~= "string" or spec.group == "" then
            error("lock brick must define non-empty group")
        end
        lockGroups[spec.group] = true
    elseif spec.kind == "keyhole" then
        if type(spec.unlockGroup) ~= "string" or spec.unlockGroup == "" then
            error("keyhole brick must define unlockGroup")
        end
        keyholeGroups[spec.unlockGroup] = true
    end
end

local lockGroupCount = 0
for _ in pairs(lockGroups) do
    lockGroupCount = lockGroupCount + 1
end

if lockGroupCount < 2 then
    error("combo_rush level2 should have at least two lock groups")
end

for groupName in pairs(keyholeGroups) do
    if not lockGroups[groupName] then
        error("keyhole unlockGroup must match an existing lock group")
    end
end

if rush3.ballSpeed <= rush2.ballSpeed then
    error("combo_rush level3 should be faster than level2")
end

if countChar(rush3.layout, "3") <= countChar(rush2.layout, "3") then
    error("combo_rush level3 should have denser high-hp bricks")
end

if type(rush4.specialBricks) ~= "table" then
    error("combo_rush level4 must define specialBricks")
end

if not hasSpecialKind(rush4.specialBricks, "keyhole") then
    error("combo_rush level4 should contain keyhole brick")
end

if not hasSpecialKind(rush4.specialBricks, "risk_core") then
    error("combo_rush level4 should contain risk_core brick")
end

if rush5.ballSpeed <= rush4.ballSpeed then
    error("combo_rush level5 should be faster than level4")
end

if countChar(Levels.classic[5].layout, "3") <= countChar(Levels.classic[4].layout, "3") then
    error("classic level5 should be denser than level4")
end

print("levels_set_harness: all checks passed")

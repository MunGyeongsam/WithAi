package.path = package.path .. ";project/src/?.lua;project/src/?/init.lua;project/src/?/?.lua"

local RiskLane = require("03_game.riskLane")

local function assertEq(actual, expected, message)
    if actual ~= expected then
        error((message or "assertEq failed") .. " | expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    end
end

local lane = RiskLane.new(1000, {
    enabled = true,
    zoneHeightRatio = 0.3,
    tokenCap = 4,
    tokenGain = 1,
    consumePerHit = 1,
    bonusMultiplierPerToken = 0.5,
})

assertEq(lane:getZoneBottom(), 300, "zone bottom")
assertEq(lane:isRiskY(280), true, "risk y true")
assertEq(lane:isRiskY(340), false, "risk y false")

local gain = lane:onBrickBreak(250)
assertEq(gain, 1, "token gain")
assertEq(lane.tokens, 1, "token count")

local scored, mult, consumed = lane:scoreWithBonus(100)
assertEq(scored, 150, "bonus score")
assertEq(mult, 1.5, "bonus multiplier")
assertEq(consumed, 1, "consumed token")
assertEq(lane.tokens, 0, "tokens consumed")

lane:onBrickBreak(250)
lane:onBrickBreak(250)
lane:onBrickBreak(250)
lane:onBrickBreak(250)
lane:onBrickBreak(250)
assertEq(lane.tokens, 4, "token cap")

lane:resetTokens()
assertEq(lane.tokens, 0, "reset tokens")

local disabled = RiskLane.new(1000, {
    enabled = false,
    zoneHeightRatio = 0.3,
    tokenCap = 4,
    tokenGain = 1,
    consumePerHit = 1,
    bonusMultiplierPerToken = 0.5,
})

assertEq(disabled:isRiskY(100), false, "disabled lane no risk zone")
local scored2, mult2, consumed2 = disabled:scoreWithBonus(120)
assertEq(scored2, 120, "disabled lane base score")
assertEq(mult2, 1, "disabled lane multiplier")
assertEq(consumed2, 0, "disabled lane no consume")

-- Simulate real game order per brick break:
-- 1) scoreWithBonus(base)
-- 2) onBrickBreak(y)
local function runBreakSequence(targetLane, yList, basePoints)
    local total = 0
    local boostedHits = 0

    for i = 1, #yList do
        local gained, mult, consumed = targetLane:scoreWithBonus(basePoints)
        total = total + gained
        if mult > 1 and consumed > 0 then
            boostedHits = boostedHits + 1
        end
        targetLane:onBrickBreak(yList[i])
    end

    return total, boostedHits
end

lane:resetTokens()
local total1, boosted1 = runBreakSequence(lane, {
    250, 350, 250, 350, 350, 250, 350, 350,
}, 100)

assertEq(total1, 950, "mixed sequence score profile")
assertEq(boosted1, 3, "mixed sequence boosted hit count")
assertEq(lane.tokens, 0, "mixed sequence remaining tokens")

lane:resetTokens()
local total2, boosted2 = runBreakSequence(lane, {
    250, 250, 250, 250, 250, 250,
}, 100)

assertEq(total2, 850, "dense risk sequence score profile")
assertEq(boosted2, 5, "dense risk sequence boosted hit count")
assertEq(lane.tokens, 1, "dense risk sequence token carry")

local tuned = RiskLane.new(1000, {
    enabled = true,
    zoneHeightRatio = 0.3,
    tokenCap = 4,
    tokenGain = 2,
    consumePerHit = 2,
    bonusMultiplierPerToken = 0.5,
})

local tunedScoreA = tuned:scoreWithBonus(99)
assertEq(tunedScoreA, 99, "tuned first hit no bonus")
tuned:onBrickBreak(250)
local tunedScoreB, tunedMultB, tunedConsumedB = tuned:scoreWithBonus(99)
assertEq(tunedScoreB, 198, "tuned second hit doubled by two-token consume")
assertEq(tunedMultB, 2.0, "tuned multiplier")
assertEq(tunedConsumedB, 2, "tuned consumed tokens")

print("risk_lane_harness: all checks passed")

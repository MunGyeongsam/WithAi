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

print("risk_lane_harness: all checks passed")

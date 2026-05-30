local ModeBalance = {}

ModeBalance.byId = {
    classic = {
        comboConfig = {
            windowSeconds = 1.8,
            stepMultiplier = 0.25,
            hitsPerStep = 4,
            maxMultiplier = 2.5,
        },
        levelClearBonusByLevel = {},
        ballSpeedScaleByLevel = {},
        paddleSpeedScaleByLevel = {},
        touchControl = {
            response = 11,
            maxSpeed = 880,
            snapDistance = 8,
        },
        riskLane = {
            enabled = false,
            zoneHeightRatio = 0.28,
            tokenCap = 0,
            tokenGain = 0,
            consumePerHit = 0,
            bonusMultiplierPerToken = 0,
        },
    },
    combo_rush = {
        comboConfig = {
            windowSeconds = 1.1,
            stepMultiplier = 0.35,
            hitsPerStep = 3,
            maxMultiplier = 3.2,
        },
        levelClearBonusByLevel = {
            [1] = 220,
            [2] = 320,
            [3] = 450,
        },
        ballSpeedScaleByLevel = {
            [1] = 1.04,
            [2] = 1.08,
            [3] = 1.12,
        },
        paddleSpeedScaleByLevel = {
            [1] = 0.98,
            [2] = 0.96,
            [3] = 0.94,
        },
        touchControl = {
            response = 15,
            maxSpeed = 1120,
            snapDistance = 6,
        },
        riskLane = {
            enabled = true,
            zoneHeightRatio = 0.30,
            tokenCap = 4,
            tokenGain = 1,
            consumePerHit = 1,
            bonusMultiplierPerToken = 0.5,
        },
    },
}

function ModeBalance.get(modeId)
    return ModeBalance.byId[modeId] or ModeBalance.byId.classic
end

return ModeBalance

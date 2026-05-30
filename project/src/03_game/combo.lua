local Combo = {}

function Combo.new(windowSeconds, stepMultiplier, hitsPerStep, maxMultiplier)
    return {
        windowSeconds = windowSeconds or 1.8,
        stepMultiplier = stepMultiplier or 0.25,
        hitsPerStep = hitsPerStep or 4,
        maxMultiplier = maxMultiplier or 2.5,
        timer = 0,
        count = 0,
        multiplier = 1,
    }
end

function Combo.reset(state)
    state.timer = 0
    state.count = 0
    state.multiplier = 1
end

function Combo.tick(state, dt)
    if state.timer <= 0 then
        return
    end

    state.timer = state.timer - dt
    if state.timer <= 0 then
        Combo.reset(state)
    end
end

function Combo.registerHit(state, basePoints)
    if state.timer > 0 and state.count > 0 then
        state.count = state.count + 1
    else
        state.count = 1
    end

    state.timer = state.windowSeconds

    local steps = math.floor((state.count - 1) / state.hitsPerStep)
    local nextMultiplier = 1 + steps * state.stepMultiplier
    if nextMultiplier > state.maxMultiplier then
        nextMultiplier = state.maxMultiplier
    end
    state.multiplier = nextMultiplier

    local gained = math.floor(basePoints * state.multiplier + 0.5)
    return gained, state.multiplier, state.count
end

return Combo

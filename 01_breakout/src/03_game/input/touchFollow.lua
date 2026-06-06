local TouchFollow = {}

local function clamp(value, low, high)
    if value < low then
        return low
    end
    if value > high then
        return high
    end
    return value
end

function TouchFollow.step(currentX, targetX, dt, config, minX, maxX)
    local cfg = config or {}
    local response = cfg.response or 12
    local maxSpeed = cfg.maxSpeed or 900
    local snapDistance = cfg.snapDistance or 6

    if dt <= 0 then
        return clamp(currentX, minX, maxX)
    end

    local delta = targetX - currentX
    if math.abs(delta) <= snapDistance then
        return clamp(targetX, minX, maxX)
    end

    local velocity = delta * response
    velocity = clamp(velocity, -maxSpeed, maxSpeed)

    local nextX = currentX + velocity * dt

    if (delta > 0 and nextX > targetX) or (delta < 0 and nextX < targetX) then
        nextX = targetX
    end

    return clamp(nextX, minX, maxX)
end

return TouchFollow

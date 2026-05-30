local RiskLane = {}
RiskLane.__index = RiskLane

local function clamp(value, low, high)
    if value < low then
        return low
    end
    if value > high then
        return high
    end
    return value
end

function RiskLane.new(height, config)
    local self = setmetatable({}, RiskLane)
    local cfg = config or {}

    self.enabled = cfg.enabled == true
    self.height = height or 0
    self.zoneHeightRatio = cfg.zoneHeightRatio or 0.28
    self.tokenCap = cfg.tokenCap or 4
    self.tokenGain = cfg.tokenGain or 1
    self.consumePerHit = cfg.consumePerHit or 1
    self.bonusMultiplierPerToken = cfg.bonusMultiplierPerToken or 0.5
    self.tokens = 0

    return self
end

function RiskLane:updateHeight(height)
    self.height = height or self.height
end

function RiskLane:getZoneBottom()
    return self.height * self.zoneHeightRatio
end

function RiskLane:isRiskY(y)
    if not self.enabled then
        return false
    end
    return y <= self:getZoneBottom()
end

function RiskLane:resetTokens()
    self.tokens = 0
end

function RiskLane:onBrickBreak(y)
    if not self:isRiskY(y) then
        return 0
    end

    local before = self.tokens
    self.tokens = clamp(self.tokens + self.tokenGain, 0, self.tokenCap)
    return self.tokens - before
end

function RiskLane:scoreWithBonus(basePoints)
    if (not self.enabled) or self.tokens <= 0 then
        return basePoints, 1, 0
    end

    local consume = math.min(self.consumePerHit, self.tokens)
    local multiplier = 1 + consume * self.bonusMultiplierPerToken
    local gained = math.floor(basePoints * multiplier + 0.5)
    self.tokens = self.tokens - consume

    return gained, multiplier, consume
end

return RiskLane

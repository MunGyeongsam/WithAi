-- ============================================================================
-- fixedTimestep.lua — 고정 타임스텝 업데이트 관리
-- ============================================================================
local FixedTimestep = {}
FixedTimestep.__index = FixedTimestep

local DEFAULT_FIXED_DT = 1 / 60
local MAX_ITERATIONS = 8

function FixedTimestep.new(fixedDt, maxIterations)
    local self = setmetatable({}, FixedTimestep)
    self.fixedDt = fixedDt or DEFAULT_FIXED_DT
    self.maxIterations = maxIterations or MAX_ITERATIONS
    self.accumulator = 0
    self.totalTime = 0
    self.stepCount = 0
    return self
end

function FixedTimestep:update(dt, callback)
    if dt > 0.25 then
        dt = 0.25
    end

    self.accumulator = self.accumulator + dt
    local iterations = 0

    while self.accumulator >= self.fixedDt and iterations < self.maxIterations do
        callback(self.fixedDt)
        self.accumulator = self.accumulator - self.fixedDt
        self.totalTime = self.totalTime + self.fixedDt
        self.stepCount = self.stepCount + 1
        iterations = iterations + 1
    end
end

function FixedTimestep:getAlpha()
    return self.accumulator / self.fixedDt
end

return FixedTimestep

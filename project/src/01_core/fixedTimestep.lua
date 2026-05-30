-- ============================================================================
-- fixedTimestep.lua — 고정 타임스텝 업데이트 관리
-- ============================================================================
--
-- ◆ 역할
--   variable dt를 accumulator에 누적하고,
--   고정된 간격(FIXED_DT)으로 게임 로직을 업데이트한다.
--
-- ◆ 장점
--   - 충돌 정확도 향상 (터널링 방지)
--   - 결정론적 게임플레이 (같은 입력 → 같은 결과)
--   - 리플레이/네트워크 동기화 용이
--
-- ◆ 사용법
--   local fixedStep = require("01_core.fixedTimestep")
--   local stepper = fixedStep.new(1/60)
--   
--   function love.update(dt)
--       stepper:update(dt, function(fixedDt)
--           -- 고정 dt로 게임 로직 업데이트
--           game:update(fixedDt)
--       end)
--   end

local FixedTimestep = {}
FixedTimestep.__index = FixedTimestep

-- ◆ 상수
local DEFAULT_FIXED_DT = 1 / 60  -- 60Hz 물리
local MAX_ITERATIONS = 8         -- spiral of death 방지

-- ============================================================================
-- 생성
-- ============================================================================

--- 고정 타임스텝 매니저 생성
-- @param fixedDt number 고정 업데이트 간격 (기본: 1/60)
-- @param maxIterations number 최대 반복 횟수 (기본: 8)
-- @return FixedTimestep
function FixedTimestep.new(fixedDt, maxIterations)
    local self = setmetatable({}, FixedTimestep)
    self.fixedDt = fixedDt or DEFAULT_FIXED_DT
    self.maxIterations = maxIterations or MAX_ITERATIONS
    self.accumulator = 0
    self.totalTime = 0
    self.stepCount = 0
    return self
end

-- ============================================================================
-- 업데이트
-- ============================================================================

--- 가변 dt를 받아 고정 스텝으로 callback 실행
-- @param dt number 프레임 delta time
-- @param callback function(fixedDt) 고정 dt로 호출될 함수
function FixedTimestep:update(dt, callback)
    -- 너무 큰 dt는 clamp (긴 프레임 스파이크 방지)
    if dt > 0.25 then
        dt = 0.25
    end

    self.accumulator = self.accumulator + dt
    local iterations = 0

    while self.accumulator >= self.fixedDt do
        if iterations >= self.maxIterations then
            -- spiral of death: 따라잡기 포기하고 accumulator 버림
            self.accumulator = 0
            break
        end

        callback(self.fixedDt)
        self.accumulator = self.accumulator - self.fixedDt
        self.totalTime = self.totalTime + self.fixedDt
        self.stepCount = self.stepCount + 1
        iterations = iterations + 1
    end
end

--- 남은 accumulator 비율 (보간용)
-- @return number 0.0 ~ 1.0 사이 값
function FixedTimestep:getAlpha()
    return self.accumulator / self.fixedDt
end

--- 통계 정보
-- @return table {totalTime, stepCount, accumulator, fixedDt}
function FixedTimestep:getStats()
    return {
        totalTime = self.totalTime,
        stepCount = self.stepCount,
        accumulator = self.accumulator,
        fixedDt = self.fixedDt,
    }
end

--- accumulator 리셋 (씬 전환 등에 사용)
function FixedTimestep:reset()
    self.accumulator = 0
end

return FixedTimestep

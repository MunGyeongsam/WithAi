-- ============================================================================
-- inputAdapter.lua — 터치/마우스 입력 통합 어댑터 (타워 디펜스용)
-- ============================================================================
local InputAdapter = {}
InputAdapter.__index = InputAdapter

function InputAdapter.new()
    local self = setmetatable({}, InputAdapter)
    self.snapshot = {
        tapX = nil,        -- 탭/클릭 위치
        tapY = nil,
        tapped = false,    -- 이번 프레임에 탭 발생
        holdX = nil,       -- 길게 누르기 위치
        holdY = nil,
        holding = false,
    }
    self._pendingTap = nil
    self._touchStart = nil
    self._touchStartTime = 0
    return self
end

function InputAdapter:update()
    -- 이전 프레임 상태 초기화
    self.snapshot.tapped = false
    self.snapshot.tapX = nil
    self.snapshot.tapY = nil
    self.snapshot.holding = false
    self.snapshot.holdX = nil
    self.snapshot.holdY = nil

    -- 펜딩 탭 처리
    if self._pendingTap then
        self.snapshot.tapped = true
        self.snapshot.tapX = self._pendingTap.x
        self.snapshot.tapY = self._pendingTap.y
        self._pendingTap = nil
    end

    -- 길게 누르기 감지 (터치가 0.5초 이상 유지)
    if self._touchStart then
        local elapsed = love.timer.getTime() - self._touchStartTime
        if elapsed > 0.5 then
            self.snapshot.holding = true
            self.snapshot.holdX = self._touchStart.x
            self.snapshot.holdY = self._touchStart.y
        end
    end

    return self.snapshot
end

function InputAdapter:mousepressed(x, y, button)
    if button == 1 then
        self._pendingTap = {x = x, y = y}
        self._touchStart = {x = x, y = y}
        self._touchStartTime = love.timer.getTime()
    end
end

function InputAdapter:mousereleased(x, y, button)
    if button == 1 then
        self._touchStart = nil
    end
end

function InputAdapter:touchpressed(id, x, y)
    self._pendingTap = {x = x, y = y}
    self._touchStart = {x = x, y = y}
    self._touchStartTime = love.timer.getTime()
end

function InputAdapter:touchreleased(id, x, y)
    self._touchStart = nil
end

return InputAdapter

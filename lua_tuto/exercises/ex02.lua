-- 연습 2-2: 전역 오염 수정
local function createBullet(x, y)
    local speed = 500
    local dx = 0
    local dy = -1
    local bullet = {x = x, y = y, speed = speed, dx = dx, dy = dy}
    return bullet
end

-- 연습 2-3: 다중 할당 & 교환
local a, b, c = 10, 20, 30
a, c = c, a   -- temp 없이 교환
print(a, b, c)   -- 30  20  10

-- 연습 2-4: 진위 판별
-- A: 출력됨 (0은 참!)
-- B: 출력됨 (빈 문자열도 참!)
-- C: 출력 안 됨 (nil은 거짓)
-- D: 출력 안 됨 (false는 거짓)
-- E: 출력됨 (0.0도 참!)
-- F: 출력됨 ("false" 문자열은 참!)

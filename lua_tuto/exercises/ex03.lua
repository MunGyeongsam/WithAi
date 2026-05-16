-- 연습 3-1: switch를 테이블 디스패치로
local enemyType = "bat"

local speedTable = {
    slime = 50,
    bat = 150,
    boss = 30,
}
local speed = speedTable[enemyType] or 100   -- default = 100
print(speed)   -- 150


-- 연습 3-2: continue 대체 (3의 배수만 출력)
for i = 1, 20 do
    if i % 3 == 0 then
        print(i)   -- 3, 6, 9, 12, 15, 18
    end
end


-- 연습 3-3: and/or 함정
local a = true and false or "fallback"  -- false는 falsy → "fallback"
local b = true and 0 or "fallback"      -- 0은 truthy → 0
local c = nil and "yes" or "no"         -- nil은 falsy → "no"
print(a, b, c)   -- fallback  0  no


-- 연습 3-4: C의 for를 Lua로
-- C: for (int i = 0; i < 10; i++)
-- 끝값이 포함되므로 9로 설정
for i = 0, 9 do
    print(i)   -- 0, 1, 2, ..., 9
end

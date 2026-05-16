# 02. 타입 & 변수 & 스코프

## Lua의 8가지 타입

```lua
print(type(nil))           -- "nil"
print(type(true))          -- "boolean"
print(type(42))            -- "number"
print(type("hello"))       -- "string"
print(type(print))         -- "function"
print(type({}))            -- "table"
print(type(io.stdin))      -- "userdata"
print(type(coroutine.create(function() end)))  -- "thread"
```

### C/C# 비교

```
Lua            C                  C#
─────────────────────────────────────────────
nil            NULL               null
boolean        int (0/1)          bool
number         double             double (Lua는 정수/실수 구분 없음 ⚠️)
string         char*              string
function       함수 포인터        delegate / Func<>
table          struct + array     Dictionary + List + object
userdata       void*              IntPtr / object
thread         -                  Thread (코루틴용, OS 스레드 아님 ⚠️)
```

## number 타입 — 정수가 없다

Lua 5.1에는 **정수 타입이 없다**. 모든 숫자는 배정밀도 부동소수점(double).

```lua
local a = 42        -- 내부적으로 42.0
local b = 42.0      -- 같은 값
print(a == b)       -- true

-- 정수 나눗셈이 없다 ⚠️
print(7 / 2)        -- 3.5  (C에서는 3)

-- 정수 나눗셈을 원하면
print(math.floor(7 / 2))  -- 3

-- 비트 연산이 없다 ⚠️ (Lua 5.1)
-- C의 &, |, ^, ~, <<, >> 사용 불가
-- 필요하면 bit 라이브러리 사용 (LuaJIT에 내장)
```

## nil — 존재하지 않음

```lua
local x           -- 초기화 안 하면 nil
print(x)          -- nil

-- nil은 "존재하지 않는다"는 의미
-- C의 NULL, C#의 null과 비슷하지만 더 적극적으로 사용

-- 테이블에서 nil 대입 = 키 삭제
local t = {a = 1, b = 2}
t.b = nil          -- b 키가 테이블에서 사라짐
```

## boolean — 진짜와 거짓

```lua
-- false와 nil만 거짓, 나머지는 전부 참 ⚠️
if 0 then print("0은 참!") end        -- 출력됨! (C에서 0은 거짓)
if "" then print("빈 문자열도 참!") end  -- 출력됨! (C#에서도 참이긴 하지만)
if nil then print("안 나옴") end       -- 출력 안 됨
if false then print("안 나옴") end     -- 출력 안 됨
```

> **⚠️ C 개발자 주의**: `0`이 참이다! `if (count)` 패턴을 Lua에서 쓰면 안 된다.

## 변수 선언

### local vs 전역

```lua
-- 전역 변수 (local 없이 선언)
x = 10              -- 전역! 어디서든 접근 가능

-- 지역 변수
local y = 20        -- 이 스코프에서만 유효

-- ⚠️ Lua에서는 local을 빼먹으면 자동으로 전역이 된다!
-- C#에서는 class 밖에 변수를 둘 수 없지만, Lua는 가능
-- C에서 전역 변수를 쓰는 것과 같은 위험
```

```lua
-- 나쁜 코드 (전역 오염)
function updateEnemy()
    speed = 100      -- 실수로 전역! 다른 함수에서 speed를 덮어쓸 수 있음
    x = x + speed    -- x도 전역
end

-- 좋은 코드
function updateEnemy(enemy)
    local speed = 100
    enemy.x = enemy.x + speed
end
```

> **규칙: 항상 `local`을 붙여라.** 전역이 필요한 경우는 거의 없다.

### 다중 할당

```lua
-- Lua는 다중 할당을 지원한다 (C/C#에는 없음)
local a, b, c = 1, 2, 3

-- 값이 부족하면 nil로 채움
local x, y = 1       -- x=1, y=nil

-- 값이 넘치면 버림
local x, y = 1, 2, 3 -- x=1, y=2, 3은 버려짐

-- 변수 교환 (temp 필요 없음!)
a, b = b, a           -- C에서는 temp 변수 필요
```

## 스코프 규칙

```lua
-- 블록 스코프 (C/C#과 유사)
do
    local x = 10
    print(x)           -- 10
end
print(x)               -- nil (블록 밖)

-- if 블록
if true then
    local msg = "hello"
    print(msg)         -- "hello"
end
print(msg)             -- nil

-- for 루프
for i = 1, 5 do
    local temp = i * 2
end
print(i)               -- nil (C#의 for 루프 변수와 동일)
print(temp)            -- nil
```

### 클로저와 upvalue

```lua
-- 함수가 외부 local 변수를 캡처한다 (C#의 클로저와 동일)
function makeCounter()
    local count = 0          -- upvalue
    return function()
        count = count + 1    -- 캡처된 변수에 접근
        return count
    end
end

local counter = makeCounter()
print(counter())   -- 1
print(counter())   -- 2
print(counter())   -- 3

-- C# 비교:
-- Func<int> MakeCounter() {
--     int count = 0;
--     return () => ++count;
-- }
```

## 타입 변환

```lua
-- 자동 변환 (coercion)
print("10" + 5)        -- 15 (문자열이 숫자로 자동 변환)
print("10" .. 5)       -- "105" (숫자가 문자열로 자동 변환)

-- ⚠️ 자동 변환에 의존하지 마라! 명시적 변환 사용
local n = tonumber("42")   -- 문자열 → 숫자
local s = tostring(42)     -- 숫자 → 문자열

-- 변환 실패 시 nil 반환 (에러가 아님 ⚠️)
local x = tonumber("abc")  -- nil (C#의 int.TryParse와 유사)
```

## 변수 네이밍 규칙

```lua
-- 유효한 이름: 문자 또는 _로 시작, 영숫자와 _ 포함
local playerSpeed = 100    -- camelCase (Lua 관례)
local MAX_ENEMIES = 50     -- 상수는 UPPER_SNAKE_CASE
local _private = true      -- _ 접두사 = private 관례

-- 예약어 (변수명으로 사용 불가)
-- and, break, do, else, elseif, end, false, for, function,
-- if, in, local, nil, not, or, repeat, return, then, true,
-- until, while
```

---

## 연습문제

### 연습 2-1: 타입 확인
아래 각 값의 `type()`을 예측한 뒤 실행해서 확인하라.

```lua
print(type(42))
print(type(42.0))
print(type("42"))
print(type(nil))
print(type(true))
print(type(print))
print(type({}))
print(type(type))
```

### 연습 2-2: 전역 오염 찾기
아래 코드에서 의도치 않은 전역 변수를 찾아 `local`로 수정하라.

```lua
function createBullet(x, y)
    speed = 500
    dx = 0
    dy = -1
    bullet = {x = x, y = y, speed = speed, dx = dx, dy = dy}
    return bullet
end
```

### 연습 2-3: 다중 할당
`a, b, c`에 `10, 20, 30`을 다중 할당하고, `a`와 `c`의 값을 temp 변수 없이 교환하라.

### 연습 2-4: 진위 판별
아래 각 조건이 `true`인지 `false`인지 예측하라 (C 개발자는 틀리기 쉬움).

```lua
if 0 then print("A") end
if "" then print("B") end
if nil then print("C") end
if false then print("D") end
if 0.0 then print("E") end
if "false" then print("F") end
```

---

[← 이전: 01. Intro](01_intro.md) | [다음: 03. 제어문 & 연산자 →](03_control_flow.md)

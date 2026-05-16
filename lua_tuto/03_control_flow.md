# 03. 제어문 & 연산자

## if / elseif / else

```lua
local hp = 30

if hp <= 0 then
    print("Dead")
elseif hp < 30 then
    print("Danger")
else
    print("OK")
end

-- ⚠️ "else if"가 아니라 "elseif" (붙여 쓴다)
-- ⚠️ 중괄호 {} 없음 → then ... end 구조
```

```
-- C/C# 비교:
-- if (hp <= 0) {           →  if hp <= 0 then
--     ...                       ...
-- } else if (hp < 30) {    →  elseif hp < 30 then
--     ...                       ...
-- } else {                 →  else
--     ...                       ...
-- }                         →  end
```

## switch 없음

```lua
-- Lua에는 switch/case가 없다 ⚠️
-- 대안 1: if-elseif 체인
local state = "idle"

if state == "idle" then
    -- ...
elseif state == "attack" then
    -- ...
elseif state == "dead" then
    -- ...
end

-- 대안 2: 테이블 디스패치 (더 Lua다운 방식)
local handlers = {
    idle = function() print("waiting...") end,
    attack = function() print("attacking!") end,
    dead = function() print("x_x") end,
}

local handler = handlers[state]
if handler then handler() end

-- C# 비교: Dictionary<string, Action> + TryGetValue
```

## while 루프

```lua
local i = 0
while i < 10 do
    print(i)
    i = i + 1     -- ⚠️ i++ 없음, i += 1도 없음
end
```

## repeat-until (do-while)

```lua
-- C의 do-while과 동일 (최소 1회 실행)
local input
repeat
    input = getInput()
until input == "quit"

-- 특이점: until 조건에서 repeat 블록 내부 local 변수에 접근 가능
repeat
    local line = readLine()
until line == ""   -- line은 repeat 블록의 local이지만 접근 가능
```

## for 루프 — 숫자형

```lua
-- for 변수 = 시작, 끝, 증감
for i = 1, 10 do        -- 1부터 10까지 (10 포함! ⚠️)
    print(i)
end

for i = 10, 1, -1 do    -- 10부터 1까지 역순
    print(i)
end

for i = 0, 1, 0.1 do    -- 0.0, 0.1, 0.2, ..., 1.0
    print(i)
end

-- ⚠️ C와 다른 점:
-- 1. 끝 값이 포함된다 (C는 < 조건이 일반적)
-- 2. 루프 변수 i는 루프 내부에서만 유효 (local 자동)
-- 3. 루프 변수를 루프 안에서 수정해도 반복 횟수에 영향 없음
```

## for 루프 — 제네릭 (이터레이터)

```lua
-- ipairs: 배열 부분 순회 (1, 2, 3, ... 연속 정수 키)
local fruits = {"apple", "banana", "cherry"}
for i, v in ipairs(fruits) do
    print(i, v)    -- 1 apple, 2 banana, 3 cherry
end

-- pairs: 전체 테이블 순회 (순서 보장 안 됨 ⚠️)
local player = {name = "Hero", hp = 100, mp = 50}
for k, v in pairs(player) do
    print(k, v)    -- 순서가 매번 다를 수 있음
end

-- C# 비교:
-- ipairs ≈ for (int i = 0; i < list.Count; i++)
-- pairs  ≈ foreach (var kvp in dictionary)
```

## break (continue 없음)

```lua
for i = 1, 100 do
    if i > 10 then
        break          -- 루프 탈출
    end
    print(i)
end

-- ⚠️ Lua 5.1에는 continue가 없다!
-- 대안: 조건을 뒤집어서 처리
for i = 1, 100 do
    if i % 2 == 0 then    -- continue 대신 if로 감싸기
        print(i)
    end
end

-- 대안 2: goto (Lua 5.2+, LuaJIT에서 사용 가능)
for i = 1, 100 do
    if i % 2 ~= 0 then goto continue end
    print(i)
    ::continue::
end
```

## 비교 연산자

```lua
-- 같음 / 다름
print(1 == 1)      -- true
print(1 ~= 2)      -- true    ⚠️ != 가 아니라 ~=

-- 크기 비교
print(1 < 2)       -- true
print(1 <= 2)      -- true
print(1 > 2)       -- false
print(1 >= 2)      -- false

-- ⚠️ 타입이 다르면 항상 ~= (자동 변환 안 함)
print(1 == "1")    -- false (C#의 Equals와 유사)
print(nil == false) -- false (둘 다 falsy지만 같지 않다!)
```

## 논리 연산자

```lua
-- and, or, not (기호가 아니라 영단어!)
-- C의 &&, ||, ! 에 해당

print(true and false)   -- false
print(true or false)    -- true
print(not true)         -- false
```

### and/or의 특수 동작 — 값을 반환한다

```lua
-- and: 첫 번째 falsy 값 반환, 없으면 마지막 값
print(1 and 2)          -- 2
print(nil and 2)        -- nil
print(false and 2)      -- false

-- or: 첫 번째 truthy 값 반환, 없으면 마지막 값
print(1 or 2)           -- 1
print(nil or 2)         -- 2
print(false or "hi")    -- "hi"
```

### 삼항 연산자 대체 패턴

```lua
-- Lua에는 ? : 삼항 연산자가 없다
-- 대안: and/or 패턴
local max = (a > b) and a or b

-- ⚠️ 주의: 중간 값이 false/nil이면 깨진다!
local x = true and false or "default"  -- "default" (false를 원했는데!)

-- 안전한 대안: if-else
local x
if condition then x = valueA else x = valueB end
```

## 산술 연산자

```lua
print(10 + 3)     -- 13
print(10 - 3)     -- 7
print(10 * 3)     -- 30
print(10 / 3)     -- 3.3333... (항상 실수 나눗셈 ⚠️)
print(10 % 3)     -- 1 (나머지)
print(10 ^ 2)     -- 100 (거듭제곱, C에서는 pow())

-- ⚠️ 없는 연산자들:
-- ++, --, +=, -=, *=, /= 전부 없음!
-- i = i + 1 로 써야 한다

-- ⚠️ 비트 연산자 없음 (Lua 5.1)
-- LuaJIT에서는 bit.band(), bit.bor() 등 사용
```

## 문자열 연결

```lua
-- + 가 아니라 .. (점 두 개)
local name = "Player" .. " " .. "One"   -- "Player One"

-- ⚠️ + 를 쓰면 숫자로 변환 시도
print("10" + "20")    -- 30 (숫자로 변환됨!)
print("hello" + 1)    -- 에러!
```

## 길이 연산자

```lua
local s = "hello"
print(#s)              -- 5 (문자열 길이)

local t = {10, 20, 30}
print(#t)              -- 3 (배열 길이)

-- ⚠️ # 연산자의 함정은 06_tables에서 자세히 다룸
```

## 연산자 우선순위 (높은 것 → 낮은 것)

```
^                          거듭제곱 (우결합!)
not  #  - (단항)           단항 연산자
*  /  %                    곱셈류
+  -                       덧셈류
..                         문자열 연결 (우결합!)
<  >  <=  >=  ~=  ==       비교
and                        논리 AND
or                         논리 OR
```

---

## 연습문제

### 연습 3-1: switch 대체
아래 C# 코드를 Lua 테이블 디스패치로 변환하라.

```csharp
switch (enemyType) {
    case "slime": speed = 50; break;
    case "bat": speed = 150; break;
    case "boss": speed = 30; break;
    default: speed = 100; break;
}
```

### 연습 3-2: continue 대체
1부터 20까지의 숫자 중, 3의 배수만 출력하는 코드를 작성하라.
(Lua 5.1에는 continue가 없음을 기억하라)

### 연습 3-3: and/or 함정
아래 코드의 출력을 예측하라. 왜 그런 결과가 나오는지 설명하라.

```lua
local a = true and false or "fallback"
local b = true and 0 or "fallback"
local c = nil and "yes" or "no"
print(a, b, c)
```

### 연습 3-4: 숫자 for 차이
C의 `for (int i = 0; i < 10; i++)`를 Lua로 변환하라.
시작값과 끝값에 주의할 것.

---

[← 이전: 02. 타입 & 변수](02_types_and_variables.md) | [다음: 04. 문자열 →](04_strings.md)

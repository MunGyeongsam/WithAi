# 06. 테이블 기초

> Lua에서 가장 중요한 자료구조. 배열, 딕셔너리, 객체, 모듈 — 전부 테이블이다.

## 테이블 = 만능 자료구조

```lua
-- C 비교: struct + array + hashmap 을 하나로 합친 것
-- C# 비교: Dictionary<object, object> + List를 합친 것

-- 빈 테이블
local t = {}

-- 배열처럼 (순서 있는 연속 정수 키)
local fruits = {"apple", "banana", "cherry"}
-- 내부적으로: {[1] = "apple", [2] = "banana", [3] = "cherry"}

-- 딕셔너리처럼 (키-값 쌍)
local player = {
    name = "Hero",
    hp = 100,
    mp = 50,
}

-- 혼합 (비추천, 하지만 가능)
local mixed = {
    "first",              -- [1] = "first"
    "second",             -- [2] = "second"
    name = "mixed table", -- ["name"] = "mixed table"
}
```

## 1-based 인덱스 ⚠️

```lua
local arr = {"a", "b", "c"}

print(arr[1])    -- "a" (첫 번째 요소)
print(arr[0])    -- nil (0번 인덱스는 비어있음!)

-- C/C# 개발자의 가장 흔한 실수:
-- for (int i = 0; i < arr.Length; i++) 패턴을 쓰면 안 된다!

-- Lua 방식:
for i = 1, #arr do
    print(arr[i])
end
```

## 요소 접근

```lua
local player = {name = "Hero", hp = 100}

-- 점 표기법 (키가 유효한 식별자일 때)
print(player.name)         -- "Hero"
print(player.hp)           -- 100

-- 괄호 표기법 (모든 키에 사용 가능)
print(player["name"])      -- "Hero"
print(player["hp"])        -- 100

-- 동적 키 접근 (괄호만 가능)
local key = "hp"
print(player[key])         -- 100
-- player.key 라고 쓰면 "key"라는 문자열 키를 찾는다! ⚠️

-- 없는 키 → nil (에러 아님 ⚠️)
print(player.mp)           -- nil
print(player.weapon)       -- nil

-- 중첩 접근
local game = {
    player = {
        pos = {x = 10, y = 20}
    }
}
print(game.player.pos.x)       -- 10
-- ⚠️ 중간 테이블이 nil이면 에러!
-- print(game.enemy.pos.x)     -- 에러: game.enemy가 nil
```

## 요소 추가 / 수정 / 삭제

```lua
local t = {}

-- 추가
t.name = "Hero"          -- 키-값 추가
t["hp"] = 100            -- 같은 방식
t[1] = "first"           -- 정수 키

-- 수정
t.hp = 80                -- 기존 값 덮어쓰기

-- 삭제 (nil 대입)
t.name = nil             -- 키가 테이블에서 사라짐

-- ⚠️ C#의 Dictionary.Remove()와 다르게, nil 대입 = 삭제
```

## 배열 연산

```lua
local enemies = {"Slime", "Bat", "Goblin"}

-- 길이
print(#enemies)    -- 3

-- 끝에 추가
enemies[#enemies + 1] = "Dragon"     -- 가장 빠른 방법
-- 또는
table.insert(enemies, "Skeleton")    -- 끝에 추가

-- 특정 위치에 삽입
table.insert(enemies, 2, "Ghost")    -- 2번 위치에 삽입, 나머지 밀림

-- 제거
table.remove(enemies, 3)    -- 3번 위치 제거, 나머지 당겨짐
table.remove(enemies)       -- 마지막 요소 제거 (가장 빠름)

-- ⚠️ 중간 삭제 시 뒤의 요소들이 이동 → 큰 배열에서 느림
-- 게임에서 엔티티 제거 시 주의 (뒤에서부터 제거하거나 swap-remove 사용)
```

### Swap-Remove 패턴 (게임 최적화)

```lua
-- 순서가 중요하지 않을 때, O(1) 삭제
local function swapRemove(t, i)
    t[i] = t[#t]     -- 마지막 요소를 삭제 위치로
    t[#t] = nil       -- 마지막 제거
end

local bullets = {"b1", "b2", "b3", "b4"}
swapRemove(bullets, 2)    -- "b4"가 2번 위치로
-- bullets = {"b1", "b4", "b3"}
```

## 테이블 순회

```lua
local inventory = {"sword", "shield", "potion", "potion"}

-- 1. 숫자 for (배열, 가장 빠름)
for i = 1, #inventory do
    print(i, inventory[i])
end

-- 2. ipairs (배열, 읽기 쉬움)
for i, item in ipairs(inventory) do
    print(i, item)
end

-- 3. pairs (딕셔너리, 순서 보장 없음 ⚠️)
local stats = {str = 10, dex = 15, int = 8}
for key, value in pairs(stats) do
    print(key, value)    -- 순서가 매번 다를 수 있음
end
```

### ipairs vs pairs 차이

```lua
local t = {10, 20, nil, 40, name = "test"}

-- ipairs: 연속 정수 키만, nil에서 멈춤
for i, v in ipairs(t) do
    print(i, v)    -- 1 10, 2 20 (nil에서 중단! ⚠️)
end

-- pairs: 모든 키-값, 순서 불확정
for k, v in pairs(t) do
    print(k, v)    -- 1 10, 2 20, 4 40, "name" "test" (순서 랜덤)
end
```

## # 연산자의 함정 ⚠️

```lua
-- # 은 배열 부분의 길이를 반환하지만...
-- nil "구멍"이 있으면 결과가 불확실하다!

local t = {1, 2, nil, 4}
print(#t)    -- 4? 2? → 구현에 따라 다름! ⚠️

-- 안전 규칙:
-- 1. 배열에 nil 구멍을 만들지 마라
-- 2. nil 구멍이 가능하면 별도 count 변수를 관리하라

-- 딕셔너리 크기는 # 로 구할 수 없다
local dict = {a = 1, b = 2, c = 3}
print(#dict)   -- 0 (배열 부분이 없으므로!)

-- 딕셔너리 크기를 구하려면 직접 세야 한다
local count = 0
for _ in pairs(dict) do count = count + 1 end
print(count)   -- 3
```

## 테이블 정렬

```lua
local scores = {50, 20, 80, 10, 40}

-- 오름차순
table.sort(scores)
-- scores = {10, 20, 40, 50, 80}

-- 내림차순 (비교 함수 전달)
table.sort(scores, function(a, b)
    return a > b
end)
-- scores = {80, 50, 40, 20, 10}

-- 구조체 배열 정렬
local enemies = {
    {name = "Slime", hp = 50},
    {name = "Dragon", hp = 500},
    {name = "Bat", hp = 30},
}

table.sort(enemies, function(a, b)
    return a.hp < b.hp    -- HP 오름차순
end)
```

## 테이블 생성자 문법

```lua
-- 기본
local t = {1, 2, 3}

-- 명시적 키
local t = {
    [1] = "a",
    [2] = "b",
    ["name"] = "Hero",
}

-- 계산된 키
local key = "hp"
local t = {
    [key] = 100,              -- t.hp = 100
    [key .. "_max"] = 100,    -- t.hp_max = 100
    [math.random(10)] = true, -- 랜덤 키
}

-- 마지막 쉼표 허용 (trailing comma)
local t = {
    "a",
    "b",
    "c",    -- OK! C89에서는 에러지만 Lua는 허용
}
```

---

## 연습문제

### 연습 6-1: 인벤토리 시스템
문자열 배열로 인벤토리를 만들고, 아래 기능을 구현하라:
- `addItem(inventory, item)`: 끝에 아이템 추가
- `removeItem(inventory, index)`: 특정 위치 아이템 제거
- `findItem(inventory, item)`: 아이템 이름으로 인덱스 검색 (없으면 nil)
- `printInventory(inventory)`: 전체 목록 출력

### 연습 6-2: 점수 테이블 정렬
플레이어 이름과 점수 쌍의 배열을 만들고, 점수 내림차순으로 정렬하라.

```lua
local leaderboard = {
    {name = "Alice", score = 1500},
    {name = "Bob", score = 2300},
    {name = "Charlie", score = 800},
}
-- 정렬 후: Bob(2300), Alice(1500), Charlie(800)
```

### 연습 6-3: # 함정 이해
아래 코드의 출력을 예측하고, 왜 그런 결과가 나오는지 설명하라.

```lua
local a = {1, 2, 3}
local b = {1, nil, 3}
local c = {x = 1, y = 2, z = 3}
print(#a, #b, #c)
```

### 연습 6-4: Swap-Remove 구현
`swapRemove(t, i)` 함수를 구현하고, 100개 요소 배열에서 50번 인덱스를 제거하는 데 `table.remove`와 `swapRemove`의 동작 차이를 설명하라.

---

[← 이전: 05. 함수](05_functions.md) | [다음: 07. 테이블 심화 →](07_tables_advanced.md)

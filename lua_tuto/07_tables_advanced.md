# 07. 테이블 심화

## 참조 의미론 (Reference Semantics)

```lua
-- 테이블은 참조로 전달된다 (C#의 class, C의 포인터와 동일)
local a = {hp = 100}
local b = a              -- b는 같은 테이블을 가리킴

b.hp = 50
print(a.hp)              -- 50 ⚠️ (a도 바뀜!)

-- == 비교는 참조 비교
local t1 = {1, 2, 3}
local t2 = {1, 2, 3}
print(t1 == t2)          -- false (내용이 같아도 다른 객체)

local t3 = t1
print(t1 == t3)          -- true (같은 참조)
```

## 얕은 복사 (Shallow Copy)

```lua
-- 테이블을 독립적으로 복사하려면 직접 구현해야 한다
local function shallowCopy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = v
    end
    return copy
end

local a = {hp = 100, pos = {x = 0, y = 0}}
local b = shallowCopy(a)

b.hp = 50
print(a.hp)          -- 100 (독립적!)

-- ⚠️ 얕은 복사의 한계: 중첩 테이블은 여전히 공유
b.pos.x = 10
print(a.pos.x)       -- 10 (중첩 테이블은 참조 공유! ⚠️)
```

## 깊은 복사 (Deep Copy)

```lua
local function deepCopy(orig)
    if type(orig) ~= "table" then
        return orig
    end
    local copy = {}
    for k, v in pairs(orig) do
        copy[deepCopy(k)] = deepCopy(v)   -- 키와 값 모두 재귀 복사
    end
    return copy
end

local a = {hp = 100, pos = {x = 0, y = 0}}
local b = deepCopy(a)

b.pos.x = 10
print(a.pos.x)       -- 0 (완전 독립)

-- ⚠️ 순환 참조가 있으면 무한 루프! 실전에서는 visited 테이블 추가 필요
```

## pairs / ipairs 실제 구현 관점

좋은 질문이다. `pairs`와 `ipairs`를 내부 형태로 보면 generic `for`가 명확해진다.

- 실제 표준 라이브러리는 C로 구현되어 있다
- 아래 코드는 Lua 5.1.5 기준 "동작 의미"를 보여주는 축약 구현이다

### 1) pairs는 `next`를 그대로 넘긴다

```lua
-- 개념적으로 pairs(t)는 아래와 거의 같다
local function pairs_like(t)
    return next, t, nil
end

local player = {name = "Hero", hp = 100, mp = 50}
for k, v in pairs_like(player) do
    print(k, v)
end
```

generic `for`는 내부적으로 이런 흐름으로 돈다.

```lua
local iter, state, ctrl = pairs_like(player)  -- iter=next, state=player, ctrl=nil
while true do
    local k, v = iter(state, ctrl)             -- next(player, ctrl)
    ctrl = k
    if ctrl == nil then break end
    print(k, v)
end
```

핵심: `pairs`는 "테이블 전체 키"를 `next`로 순회한다. 순서는 보장되지 않는다.

### 2) ipairs는 숫자 인덱스 1부터 연속 순회

```lua
-- Lua 5.1의 의미를 보존한 축약 구현
local function ipairsIter(t, i)
    i = i + 1
    local v = t[i]
    if v ~= nil then
        return i, v
    end
    -- nil이면 반복 종료
end

local function ipairs_like(t)
    return ipairsIter, t, 0
end

local arr = {"a", "b", "c"}
for i, v in ipairs_like(arr) do
    print(i, v)   -- 1 a, 2 b, 3 c
end
```

핵심: `ipairs`는 `1,2,3...`으로 진행하다가 `nil`을 만나면 즉시 멈춘다.

```lua
local t = {10, 20, nil, 40}
for i, v in ipairs_like(t) do
    print(i, v)   -- 1 10, 2 20 까지만 출력
end
```

### 3) 왜 이게 중요한가?

- `pairs`: 딕셔너리/셋/혼합 테이블 순회용
- `ipairs`: 연속 배열 순회용
- 중간 `nil`이 가능한 데이터(삭제가 섞인 배열)는 `ipairs`에서 일부가 누락될 수 있다

게임 코드에서는 의도에 따라 아래처럼 고른다.

```lua
-- 연속 배열 보장: ipairs
for i, enemy in ipairs(enemies) do
    enemy:update(dt)
end

-- 키 중심 데이터: pairs
for tag, enabled in pairs(tags) do
    if enabled then
        -- ...
    end
end
```

### 4) Lua 5.1.5 기준 주의점

- `pairs` 순서는 실행마다 달라질 수 있다 (정렬이 필요하면 키를 모아 sort)
- `ipairs`는 연속 정수 인덱스 구간만 본다
- `#t`와 `ipairs`는 "중간 nil" 테이블에서 직관과 다르게 동작할 수 있다

## 테이블을 스택/큐로 사용

```lua
-- 스택 (LIFO)
local stack = {}

-- push
stack[#stack + 1] = "a"
stack[#stack + 1] = "b"
stack[#stack + 1] = "c"

-- pop
local top = stack[#stack]     -- "c"
stack[#stack] = nil           -- 제거

-- 또는 table.remove 사용
local top = table.remove(stack)  -- 마지막 요소 제거 및 반환

-- 큐 (FIFO) — 단순 구현
local queue = {}

-- enqueue (끝에 추가)
queue[#queue + 1] = "a"
queue[#queue + 1] = "b"

-- dequeue (앞에서 제거 — O(n) 주의! ⚠️)
local front = table.remove(queue, 1)

-- 게임에서 큐가 필요하면 이중 인덱스 큐를 쓴다 (성능)
local Queue = {}
function Queue.new()
    return {first = 1, last = 0, data = {}}
end
function Queue.push(q, val)
    q.last = q.last + 1
    q.data[q.last] = val
end
function Queue.pop(q)
    if q.first > q.last then return nil end
    local val = q.data[q.first]
    q.data[q.first] = nil
    q.first = q.first + 1
    return val
end
```

## 오브젝트 풀 패턴

```lua
-- 게임에서 가장 중요한 테이블 패턴
-- 총알/파티클 등 자주 생성·삭제되는 객체를 재사용

local BulletPool = {
    pool = {},       -- 사용 가능한 총알
    active = {},     -- 현재 활성 총알
}

function BulletPool.get()
    local bullet
    local n = #BulletPool.pool
    if n > 0 then
        bullet = BulletPool.pool[n]
        BulletPool.pool[n] = nil           -- 풀에서 제거
    else
        bullet = {x = 0, y = 0, vx = 0, vy = 0, active = false}  -- 새로 생성
    end
    bullet.active = true
    BulletPool.active[#BulletPool.active + 1] = bullet
    return bullet
end

function BulletPool.release(bullet)
    bullet.active = false
    bullet.x = 0
    bullet.y = 0
    BulletPool.pool[#BulletPool.pool + 1] = bullet  -- 풀에 반환
end

-- 사용
local b = BulletPool.get()
b.x = 100
b.y = 200
b.vx = 5
-- ... 사용 후
BulletPool.release(b)

-- C# 비교: UnityEngine.Pool.ObjectPool<T>
-- C 비교: 고정 크기 배열 + free list
```

## 테이블을 Set(집합)으로 사용

```lua
-- 값을 키로 사용하고, 값은 true로 설정
local tags = {
    ["enemy"] = true,
    ["flying"] = true,
    ["boss"] = true,
}

-- 포함 여부 확인: O(1)
if tags["enemy"] then
    print("This is an enemy")
end

-- 추가
tags["fire"] = true

-- 제거
tags["flying"] = nil

-- 합집합
local function union(a, b)
    local result = {}
    for k in pairs(a) do result[k] = true end
    for k in pairs(b) do result[k] = true end
    return result
end

-- 교집합
local function intersection(a, b)
    local result = {}
    for k in pairs(a) do
        if b[k] then result[k] = true end
    end
    return result
end
```

## 약한 테이블 (Weak Tables)

`setmetatable`의 기본 동작과 `__index/__newindex`는 [08. 메타테이블](08_metatables.md)에서 먼저 확인하면 이해가 훨씬 쉽다.

```lua
-- 약한 참조: GC가 다른 곳에서 참조가 없으면 수거 가능
-- 캐시, 옵저버 패턴에 유용

-- 값이 약한 참조
local cache = setmetatable({}, {__mode = "v"})

cache["texture1"] = createTexture()   -- 다른 곳에서 참조가 없으면 GC 대상

-- 키가 약한 참조
local metadata = setmetatable({}, {__mode = "k"})

local entity = {}
metadata[entity] = {createdAt = os.time()}
entity = nil   -- entity가 GC되면 metadata 항목도 자동 제거

-- __mode 값:
-- "k" : 키가 약한 참조
-- "v" : 값이 약한 참조
-- "kv": 키와 값 모두 약한 참조

-- C# 비교: WeakReference<T>, ConditionalWeakTable
```

## 안전한 중첩 접근 패턴

```lua
-- 중첩 테이블 접근 시 중간이 nil이면 에러
local game = {player = {pos = {x = 10}}}

-- 위험한 접근
-- print(game.enemy.pos.x)   -- 에러! game.enemy가 nil

-- 안전한 접근 방법 1: and 체인
local x = game.enemy and game.enemy.pos and game.enemy.pos.x
print(x)   -- nil (에러 없음)

-- 안전한 접근 방법 2: 헬퍼 함수
local function safeGet(t, ...)
    for i = 1, select("#", ...) do
        local key = select(i, ...)
        if type(t) ~= "table" then return nil end
        t = t[key]
    end
    return t
end

print(safeGet(game, "enemy", "pos", "x"))    -- nil
print(safeGet(game, "player", "pos", "x"))   -- 10
```

## 테이블 직렬화 (간단 버전)

```lua
-- 테이블을 문자열로 변환 (저장/디버깅용)
local function serialize(t, indent)
    indent = indent or 0
    local pad = string.rep("  ", indent)
    local parts = {}
    
    parts[#parts + 1] = "{\n"
    for k, v in pairs(t) do
        local keyStr
        if type(k) == "number" then
            keyStr = string.format("[%d]", k)
        else
            keyStr = tostring(k)
        end
        
        if type(v) == "table" then
            parts[#parts + 1] = string.format("%s  %s = %s", pad, keyStr, serialize(v, indent + 1))
        else
            parts[#parts + 1] = string.format("%s  %s = %s,\n", pad, keyStr, tostring(v))
        end
    end
    parts[#parts + 1] = pad .. "}\n"
    
    return table.concat(parts)
end

local data = {name = "Hero", stats = {str = 10, dex = 15}}
print(serialize(data))
```

---

## 연습문제

### 연습 7-1: 깊은 복사 + 순환 참조
`deepCopy` 함수를 순환 참조를 처리할 수 있도록 확장하라.

```lua
local a = {value = 1}
a.self = a   -- 순환 참조
local b = deepCopy(a)
print(b.self == b)   -- true (복사된 테이블 내에서도 자기 참조 유지)
```

### 연습 7-2: 오브젝트 풀
파티클 풀을 구현하라. 각 파티클은 `{x, y, vx, vy, life, maxLife}` 필드를 가진다.
`get()`, `release(p)`, `updateAll(dt)` (life가 0 이하면 자동 release) 함수를 만들어라.

### 연습 7-3: Set 연산
문자열 Set 두 개의 합집합, 교집합, 차집합을 구현하고 테스트하라.

```lua
local a = toSet({"fire", "ice", "wind"})
local b = toSet({"ice", "earth", "wind"})
-- union: fire, ice, wind, earth
-- intersection: ice, wind
-- difference (a-b): fire
```

### 연습 7-4: 안전한 접근
`safeSet(t, value, ...)` 함수를 구현하라. 중간 경로의 테이블이 없으면 자동으로 생성해야 한다.

```lua
local t = {}
safeSet(t, 100, "player", "stats", "hp")
print(t.player.stats.hp)   -- 100
```

---

[← 이전: 06. 테이블 기초](06_tables_basics.md) | [다음: 08. 메타테이블 →](08_metatables.md)

## 모범 답안

### 7-1
```lua
local function deepCopy(src, seen)
    if type(src) ~= "table" then return src end
    seen = seen or {}
    if seen[src] then return seen[src] end
    local dst = {}
    seen[src] = dst
    for k, v in pairs(src) do
        dst[deepCopy(k, seen)] = deepCopy(v, seen)
    end
    return setmetatable(dst, getmetatable(src))
end
```

### 7-2
핵심 구현:
- `get()`: `pool[#pool]` 재사용 또는 새 생성
- `release(p)`: 상태 초기화 후 `pool[#pool+1] = p`
- `updateAll(dt)`: `active`를 역순 순회하며 `life <= 0`이면 release

### 7-3
```lua
local function toSet(arr)
    local s = {}
    for i = 1, #arr do s[arr[i]] = true end
    return s
end

local function union(a, b)
    local r = {}
    for k in pairs(a) do r[k] = true end
    for k in pairs(b) do r[k] = true end
    return r
end
```
교집합/차집합도 같은 방식으로 키 존재 여부로 계산하면 된다.

### 7-4
```lua
local function safeSet(t, value, ...)
    local keys = {...}
    local cur = t
    for i = 1, #keys - 1 do
        local k = keys[i]
        if type(cur[k]) ~= "table" then cur[k] = {} end
        cur = cur[k]
    end
    cur[keys[#keys]] = value
end
```

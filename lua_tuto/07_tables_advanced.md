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

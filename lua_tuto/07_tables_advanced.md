# 07. 테이블 심화

이 단원에서는 테이블을 단순히 데이터를 담는 상자처럼 사용하는 것을 넘어, 복사하고 순회하고 재사용하는 방법을 배운다. 내용이 많으므로 아래 순서로 읽으면 된다.

1. **먼저 읽기:** 참조, 얕은 복사, 깊은 복사
2. **그다음 읽기:** `pairs`와 `ipairs`, 스택과 큐
3. **필요할 때 읽기:** 오브젝트 풀, Set, 약한 테이블, 직렬화
4. **선택 심화:** 반복자와 `generic for`의 내부 동작

06장에서 배열과 딕셔너리, `pairs`와 `ipairs`를 처음 배웠다면 이 문서의 예제를 따라갈 수 있다. `for`가 낯설다면 먼저 [03. 제어 흐름](03_control_flow.md)의 반복자 설명을 읽어 보자.

## 먼저 알아둘 용어

어려운 용어는 특별한 종류의 데이터가 아니라, 이미 배운 테이블의 동작을 설명하는 이름이다.

| 용어 | 쉬운 뜻 |
| --- | --- |
| 참조 | 테이블 자체가 아니라 테이블을 찾아가는 연결 정보 |
| 얕은 복사 | 겉의 테이블만 새로 만들고, 안쪽 테이블은 함께 사용하는 복사 |
| 깊은 복사 | 안쪽에 들어 있는 테이블까지 새로 만드는 복사 |
| 반복자 | 값을 한 번에 하나씩 꺼내 주는 함수 |
| 클로저 | 함수가 만들어질 때 주변의 지역 변수를 기억하는 함수 |
| 순회 | 테이블의 항목을 처음부터 끝까지 하나씩 확인하는 것 |
| `O(1)` | 데이터 개수와 관계없이 거의 일정한 시간에 처리되는 방식 |
| `O(n)` | 데이터 개수가 늘어날수록 처리량도 함께 늘어나는 방식 |
| 가비지 컬렉터(GC) | 더 이상 사용하지 않는 데이터를 자동으로 정리하는 기능 |
| 메타테이블 | 테이블의 기본 동작을 바꾸거나 확장하는 설정 테이블 |
| 직렬화 | 데이터를 저장하거나 전송할 수 있는 문자열 형태로 바꾸는 작업 |

> 용어를 모두 외울 필요는 없다. 예제를 실행하면서 “어떤 값이 공유되고, 언제 새로 만들어지는가?”를 확인하는 것이 이 단원의 핵심이다.

## 테이블은 복사되지 않고 함께 가리킬 수 있다

### 참조란?

Lua에서 테이블 변수를 다른 변수에 대입하면 테이블 내용이 복사되지 않는다. 두 변수가 **같은 테이블을 가리키는 연결 정보**를 함께 갖게 된다. 이 연결 정보를 참조라고 부른다.

```lua
-- 테이블 자체가 복사되는 것이 아니라, 같은 테이블을 함께 가리킨다
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

## 얕은 복사: 겉만 새로 만들기

테이블을 새로 만들고 바로 들어 있는 값만 옮기는 방법이다. 숫자나 문자열은 독립적으로 복사되지만, 안쪽 테이블은 여전히 같은 것을 가리킨다.

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

## 깊은 복사: 안쪽 테이블까지 새로 만들기

중첩된 테이블을 만날 때마다 다시 복사하는 방법이다. 그래서 복사한 결과를 수정해도 원본의 안쪽 테이블이 함께 바뀌지 않는다.

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

> **키를 deepCopy할 필요가 있는가?**  
> 위 코드에서 `copy[deepCopy(k)]`는 이론적 완전성을 위한 것이다.  
> 실전에서는 키가 거의 문자열/숫자(값 타입)이므로 복사해도 그대로 반환된다.  
> 테이블을 키로 쓰는 경우(메타데이터 맵 등), 키를 복사하면 오히려 lookup이 깨진다.  
> → 실무에서는 `copy[k] = deepCopy(v)` (키는 그대로, 값만 재귀)가 안전하다.

## `pairs`와 `ipairs`가 움직이는 방식

앞에서 배운 것처럼 `pairs`는 키와 값을, `ipairs`는 1부터 이어지는 숫자 인덱스를 순서대로 확인한다. 대부분의 코드는 이 정도만 알아도 충분하다.

아래의 **반복자 내부 구현 관점**은 `generic for`가 어떻게 동작하는지 궁금할 때 읽는 선택 심화 내용이다. 처음 읽는다면 다음 [스택과 큐](#테이블을-스택큐로-사용)로 넘어가도 된다.

### 선택 심화: 반복자와 `generic for`의 내부 구현

`pairs`와 `ipairs`를 내부 형태로 보면 generic `for`가 명확해진다.

- 실제 표준 라이브러리는 C로 구현되어 있다
- 아래 코드는 Lua 5.1.5 기준 "동작 의미"를 보여주는 축약 구현이다

### 1) `next` — 테이블 순회의 기본 단위

`next(t, key)`는 Lua 내장 함수로, 테이블에서 주어진 키의 **다음 키-값 쌍**을 반환한다.

```lua
local t = {a = 1, b = 2, c = 3}

local k, v = next(t, nil)    -- nil을 넘기면 "첫 번째" 항목 반환
print(k, v)                   -- (예: "a", 1 — 순서 불확정)

k, v = next(t, k)            -- 그 키의 "다음" 항목
print(k, v)                   -- (예: "b", 2)

k, v = next(t, k)            -- 마지막
print(k, v)                   -- (예: "c", 3)

k, v = next(t, k)            -- 더 없으면 nil 반환 → 순회 종료
print(k, v)                   -- nil  nil
```

> ⚠️ "다음"의 순서는 내부 해시 구조에 따르므로 예측할 수 없다.  
> 순회 중 새 키를 추가하면 동작이 정의되지 않는다.

### 2) pairs는 `next`를 그대로 넘긴다

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

### 반복자와 클로저: 상태를 어디에 둘 것인가

반복자는 값을 하나씩 꺼내 주는 함수다. 제네릭 `for`의 반복자와 클로저는 서로 다른 기능이 아니라, **현재 위치를 어디에 기억해 두는가**가 다른 두 가지 작성 방식이다.

| 방식 | 현재 위치의 보관 장소 | 대표 예 | 특징 |
| --- | --- | --- | --- |
| 상태를 바깥에서 받는 반복자 | `state`와 `ctrl` | `pairs`, `ipairs` | 현재 위치를 호출자가 전달함 |
| 클로저 반복자 | 함수가 기억한 지역 변수 | `range`, `string.gmatch` | 현재 위치를 함수 안에 숨겨 사용하기 간단함 |

`ipairs`는 첫 번째 방식이다. 반복 함수는 현재 인덱스를 내부에 저장하지 않고, 제네릭 `for`가 전달한 이전 제어값 `i`로 다음 위치를 계산한다.

```lua
local function ipairsIter(t, i)
    i = i + 1
    local value = t[i]
    if value ~= nil then
        return i, value
    end
end

-- for i, value in ipairs_like(arr) do ... end
-- 는 매 반복마다 ipairsIter(arr, 이전_i)를 호출한다.
```

반대로 클로저 반복자는 생성할 때 현재 위치를 지역 변수에 숨긴다. 제네릭 `for`는 반복자에 `state`, `ctrl` 인자를 전달하지만, 이 함수는 그 인자를 받지 않고 캡처한 `index`를 사용한다.

```lua
local function rangeIterator(first, last)
    local index = first - 1

    return function()
        index = index + 1
        if index <= last then
            return index
        end
        -- 첫 번째 반환값이 nil이면 generic for가 종료한다.
    end
end

for number in rangeIterator(3, 5) do
    print(number)    -- 3, 4, 5
end
```

제네릭 `for` 관점에서 위 호출은 아래와 같다. 반복 표현식이 함수 하나만 반환하면 나머지 두 값은 `nil`이다.

```lua
local iter, state, ctrl = rangeIterator(3, 5)  -- state=nil, ctrl=nil
while true do
    local number = iter(state, ctrl)            -- 클로저는 전달된 인자를 무시
    ctrl = number
    if ctrl == nil then
        break
    end
    print(number)
end
```

### 언제 어떤 방식을 쓰는가

| 상황 | 권장 방식 | 이유 |
| --- | --- | --- |
| 테이블의 모든 키를 순회 | `pairs` / `next` 방식 | 테이블과 이전 키를 `state`, `ctrl`로 자연스럽게 전달 |
| 연속 배열을 인덱스와 함께 순회 | `ipairs` 또는 숫자 `for` | 인덱스가 제어 변수 역할을 함 |
| 범위, 필터, 지연 생성 값을 순회 | 클로저 반복자 | 위치와 조건을 호출자에게 노출하지 않음 |
| 동시에 여러 번 순회 | 매번 새 클로저 생성 또는 독립 `state` 사용 | 각 순회가 서로 다른 현재 위치를 가져야 함 |

클로저가 상태를 공유하는지 확인하려면 반복자 하나를 두 곳에서 번갈아 호출해 보면 된다.

```lua
local iter = rangeIterator(1, 3)
print(iter())    -- 1
print(iter())    -- 2: 두 호출자는 같은 index를 공유한다

local left = rangeIterator(1, 3)
local right = rangeIterator(1, 3)
print(left())    -- 1
print(right())   -- 1: 생성할 때마다 독립적인 index를 캡처한다
```

### 종료와 반환값의 주의점

- 제네릭 `for`는 반복자 **첫 번째 반환값**이 `nil`이면 끝난다. 따라서 `for value in iter do` 형태에서는 순회 대상 값으로 `nil`을 전달할 수 없다.
- `for key, value in iter do`에서는 `key`가 첫 번째 반환값이다. `pairs`가 키를 먼저 반환하는 이유도 종료 여부를 판단하기 위해서다.
- 클로저 반복자는 한 번 끝나면 내부 위치가 마지막 이후에 남는다. 같은 범위를 처음부터 다시 돌려야 하면 `rangeIterator(...)`를 다시 호출해 새 클로저를 만들어야 한다.
- `pairs` 또는 `next`로 순회하는 동안 새 키를 추가하거나 삭제하면 동작이 예측하기 어렵다. 변경 목록을 따로 기록한 뒤 순회 후 적용하는 편이 안전하다.

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

오브젝트 풀은 총알이나 파티클을 매번 새로 만들고 버리는 대신, 다 쓴 객체를 보관했다가 다시 사용하는 방법이다. `active`는 현재 사용하는 객체 목록이고 `pool`은 재사용을 기다리는 객체 목록이다.

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
    bullet.activeIndex = #BulletPool.active + 1
    BulletPool.active[#BulletPool.active + 1] = bullet
    return bullet
end

function BulletPool.release(bullet)
    local index = bullet.activeIndex
    local last = BulletPool.active[#BulletPool.active]
    if index and BulletPool.active[index] == bullet then
        BulletPool.active[index] = last
        BulletPool.active[index].activeIndex = index
        BulletPool.active[#BulletPool.active] = nil
    end
    bullet.active = false
    bullet.activeIndex = nil
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

`release`할 때는 재사용 목록에 넣는 것뿐 아니라 활성 목록에서도 빼야 한다. 위 예제는 순서가 중요하지 않다는 전제에서 마지막 객체를 빈자리로 옮긴다. 순서를 유지해야 한다면 `table.remove(BulletPool.active, index)`를 사용할 수 있지만, 뒤의 항목을 이동시키므로 더 느릴 수 있다.

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

약한 테이블은 일반 테이블과 달리 특정 키나 값을 강하게 붙잡아 두지 않는다. 다른 곳에서 사용하지 않는 객체를 가비지 컬렉터가 정리할 수 있게 하는 고급 기능이다. 따라서 캐시된 값이 언제든 사라질 수 있다는 점을 받아들일 수 있을 때만 사용한다.

```lua
-- 약한 참조: GC가 다른 곳에서 참조가 없으면 수거 가능
-- 캐시, 옵저버 패턴에 유용

-- 값이 약한 참조
local cache = setmetatable({}, {__mode = "v"})

local texture = {}                    -- 실제 프로젝트에서는 이미지나 텍스처 객체
cache["texture1"] = texture           -- 다른 곳에서 참조가 없으면 GC 대상

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

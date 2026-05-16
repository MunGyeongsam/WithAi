# 05. 함수

## 함수 정의

```lua
-- 기본 형태
local function add(a, b)
    return a + b
end

-- 위와 동일 (함수는 값이다)
local add = function(a, b)
    return a + b
end

-- 전역 함수 (모듈이 아닌 이상 피하라)
function globalFunc()
    -- ...
end
```

> **⚠️ 순서 주의**: `local function`으로 선언해야 같은 파일 내에서 순서에 덜 민감하다.  
> `local f = function()` 형태는 선언 전에 호출하면 nil 에러.

## 다중 반환값

```lua
-- Lua는 여러 값을 반환할 수 있다 (C#의 out/tuple보다 깔끔)
local function findEnemy()
    return "Slime", 100, 50     -- name, hp, mp
end

local name, hp, mp = findEnemy()
print(name, hp, mp)    -- Slime  100  50

-- 필요 없는 값은 버린다
local name = findEnemy()    -- hp, mp 버려짐

-- 관례: 불필요한 값은 _ 로 받는다
local _, _, mp = findEnemy()
```

### 다중 반환의 함정

```lua
-- 다중 반환은 마지막 인자일 때만 전체 확장
local function two() return 1, 2 end

print(two(), "end")       -- 1  end (두 번째 반환값 잘림! ⚠️)
print("start", two())    -- start  1  2 (마지막이라 확장됨)

-- 괄호로 감싸면 첫 번째 값만 남음
print((two()))            -- 1
```

## 가변 인자 (Varargs)

```lua
-- ... 으로 가변 인자 받기
local function sum(...)
    local args = {...}         -- 테이블로 변환
    local total = 0
    for i = 1, #args do
        total = total + args[i]
    end
    return total
end

print(sum(1, 2, 3))       -- 6
print(sum(10, 20))         -- 30

-- select로 가변인자 다루기
local function info(...)
    print("인자 수:", select("#", ...))   -- 개수
    print("3번째:", select(3, ...))       -- 3번째부터 끝까지
end

-- C 비교: va_list, va_arg
-- C# 비교: params 키워드
```

## 함수는 일급 객체 (First-Class)

```lua
-- 함수를 변수에 담을 수 있다
local greet = function(name)
    return "Hello, " .. name
end

-- 함수를 인자로 전달할 수 있다
local function apply(func, value)
    return func(value)
end
print(apply(greet, "Lua"))    -- "Hello, Lua"

-- 함수를 반환할 수 있다
local function multiplier(factor)
    return function(x)
        return x * factor
    end
end
local double = multiplier(2)
local triple = multiplier(3)
print(double(5))    -- 10
print(triple(5))    -- 15

-- C# 비교: Func<T>, Action, delegate와 유사
-- C 비교: 함수 포인터와 유사하지만 훨씬 유연
```

## 클로저 (Closure)

```lua
-- 함수가 외부 지역 변수를 "기억"한다
local function makeTimer()
    local elapsed = 0           -- upvalue (캡처되는 변수)
    
    return {
        update = function(dt)
            elapsed = elapsed + dt
        end,
        getTime = function()
            return elapsed
        end,
        reset = function()
            elapsed = 0
        end,
    }
end

local timer = makeTimer()
timer.update(0.016)
timer.update(0.016)
print(timer.getTime())    -- 0.032

-- C# 비교:
-- class Timer { float elapsed; void Update(float dt) { elapsed += dt; } }
-- Lua는 클래스 없이 클로저로 같은 것을 구현
```

### 클로저 활용 — 게임 패턴

```lua
-- 쿨다운 시스템
local function makeCooldown(duration)
    local remaining = 0
    
    return {
        use = function()
            if remaining <= 0 then
                remaining = duration
                return true     -- 사용 성공
            end
            return false        -- 쿨다운 중
        end,
        update = function(dt)
            if remaining > 0 then
                remaining = remaining - dt
            end
        end,
        isReady = function()
            return remaining <= 0
        end,
    }
end

local fireball = makeCooldown(2.0)   -- 2초 쿨다운
fireball.use()       -- true
fireball.use()       -- false (쿨다운 중)
fireball.update(2.0)
fireball.use()       -- true
```

## 메서드 호출 — : (콜론) 문법

```lua
-- 테이블에 함수를 넣으면 "메서드"처럼 사용
local player = {
    name = "Hero",
    hp = 100,
}

-- . (점)으로 정의 — self를 명시적으로 받음
function player.takeDamage(self, amount)
    self.hp = self.hp - amount
end

-- : (콜론)으로 정의 — self가 자동으로 첫 번째 인자
function player:heal(amount)
    self.hp = self.hp + amount
end

-- 호출할 때도 마찬가지
player.takeDamage(player, 10)  -- . 으로 호출: self 직접 전달
player:heal(10)                -- : 으로 호출: self 자동 전달

-- ⚠️ . 과 : 를 섞어 쓰면 버그 원인!
-- player.heal(10)  -- self에 10이 들어감! amount는 nil!
```

```
-- 정리:
-- function obj.method(self, ...)  ≡  function obj:method(...)
-- obj.method(obj, ...)            ≡  obj:method(...)
```

## 콜백 패턴

```lua
-- 이벤트 시스템 (게임에서 매우 흔함)
local EventSystem = {}
local listeners = {}

function EventSystem.on(event, callback)
    listeners[event] = listeners[event] or {}
    listeners[event][#listeners[event] + 1] = callback
end

function EventSystem.emit(event, ...)
    local cbs = listeners[event]
    if cbs then
        for i = 1, #cbs do
            cbs[i](...)
        end
    end
end

-- 사용
EventSystem.on("enemyDied", function(enemy)
    print(enemy.name .. " defeated!")
end)

EventSystem.on("enemyDied", function(enemy)
    score = score + enemy.points
end)

EventSystem.emit("enemyDied", {name = "Slime", points = 10})
```

## 꼬리 호출 최적화 (Tail Call)

```lua
-- Lua는 꼬리 호출(tail call)을 최적화한다 → 스택 오버플로 없음
local function factorial(n, acc)
    acc = acc or 1
    if n <= 1 then return acc end
    return factorial(n - 1, n * acc)   -- 꼬리 호출 (return 바로 뒤)
end

print(factorial(1000000))   -- 스택 오버플로 없이 동작

-- ⚠️ 아래는 꼬리 호출이 아님
local function notTail(n)
    if n <= 1 then return 1 end
    return n * notTail(n - 1)   -- 곱셈이 남아있으므로 꼬리 호출 아님
end
```

---

## 연습문제

### 연습 5-1: 다중 반환
플레이어 위치와 방향을 반환하는 함수를 작성하라.

```lua
-- getPlayerInfo() → x, y, angle
-- 호출 예: local x, y, angle = getPlayerInfo()
```

### 연습 5-2: 고차 함수
숫자 테이블과 함수를 받아, 각 요소에 함수를 적용한 새 테이블을 반환하는 `map` 함수를 작성하라.

```lua
local numbers = {1, 2, 3, 4, 5}
local doubled = map(numbers, function(x) return x * 2 end)
-- doubled = {2, 4, 6, 8, 10}
```

### 연습 5-3: 클로저 활용
`makeHealthBar(maxHp)`를 호출하면 `damage(amount)`, `heal(amount)`, `getPercent()` 메서드를 가진 테이블을 반환하는 함수를 작성하라. HP는 0 미만 또는 maxHp 초과가 되지 않아야 한다.

### 연습 5-4: 콜론 문법
아래 코드의 버그를 찾아 수정하라.

```lua
local enemy = {hp = 100, name = "Goblin"}

function enemy:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        print(self.name .. " is dead!")
    end
end

enemy.takeDamage(30)   -- 여기서 에러 발생. 왜?
```

---

[← 이전: 04. 문자열](04_strings.md) | [다음: 06. 테이블 기초 →](06_tables_basics.md)

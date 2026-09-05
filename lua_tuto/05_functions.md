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

> **⚠️ 순서 주의**: 두 형태 모두 선언 이전 줄에서 호출하면 nil 에러가 난다.  
> 차이점은 **함수 본문 안에서 자기 이름을 참조(재귀)**할 수 있느냐이다.
>
> ```lua
> -- OK: local function은 본문에서 자기 자신 참조 가능
> local function f(n)
>     if n <= 1 then return 1 end
>     return n * f(n - 1)        -- f가 이미 로컬에 존재
> end
>
> -- ERROR: local f = function() 은 대입 완료 전이라 f가 nil
> local g = function(n)
>     if n <= 1 then return 1 end
>     return n * g(n - 1)        -- g는 아직 nil!
> end
> ```
>
> `local function f() end`는 내부적으로 `local f; f = function() end`로 변환되어  
> 함수 본문이 만들어질 때 이미 `f` 변수가 스코프에 존재하기 때문이다.

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

"함수는 일급 객체다"는 함수가 단지 호출하는 문법이 아니라, 숫자나 문자열처럼 **값으로 다뤄진다**는 뜻이다. 따라서 함수는 다음과 같이 사용할 수 있다.

- 변수나 테이블에 저장한다.
- 다른 함수의 인자로 전달한다.
- 다른 함수의 반환값으로 받는다.
- 필요한 시점에 나중에 호출한다.

함수 이름 뒤의 괄호 유무가 특히 중요하다. `greet`는 함수 **값 자체**를 가리키고, `greet("Lua")`는 함수를 **즉시 호출한 결과값**이다.

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

-- 테이블에도 저장할 수 있다
local commands = {
    attack = function()
        return "attack"
    end,
}
print(commands.attack())    -- "attack"
```

### 다른 언어와 비교

| 언어 | 함수를 값으로 다루는 방법 | Lua와의 차이 |
| --- | --- | --- |
| Lua | 함수 자체를 변수, 테이블, 인자, 반환값으로 사용 | 별도 선언 없이 자연스럽게 사용 |
| C | 함수 포인터 `int (*op)(int, int)` 사용 | 함수 타입을 명시해야 하며, 지역 상태를 자동으로 기억하지 않음 |
| C++ | 함수 포인터, 람다, 함수 객체, `std::function` 사용 | 람다의 캡처 방식과 객체 수명을 명시적으로 고려해야 함 |
| C# | `delegate`, `Action`, `Func<T>`, 람다 사용 | 엄밀히는 메서드 자체보다 호출 가능한 delegate 값을 전달함 |

Lua의 `local operation = greet`는 C#의 다음 코드와 비슷하다.

```csharp
Func<string, string> operation = greet;
Console.WriteLine(operation("Lua"));
```

C에서는 함수 포인터 타입을 직접 선언해야 한다.

```c
char *greet(const char *name);
char *(*operation)(const char *) = greet;
```

Lua는 함수가 값인 데서 한 걸음 더 나아가, 반환된 함수가 바깥 지역 변수를 기억하는 **클로저**를 기본 지원한다. 위의 `multiplier`에서 `double`은 호출이 끝난 뒤에도 `factor` 값 `2`를 기억한다. 다음 절의 클로저는 이 성질을 이용해 상태를 함수 안에 안전하게 보관하는 방법을 다룬다.

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

## 모범 답안

### 5-1
```lua
local player = {x = 100, y = 200, angle = 1.57}

local function getPlayerInfo()
    return player.x, player.y, player.angle
end
```

### 5-2
```lua
local function map(t, fn)
    local out = {}
    for i = 1, #t do
        out[i] = fn(t[i])
    end
    return out
end
```

### 5-3
```lua
local function makeHealthBar(maxHp)
    local hp = maxHp
    return {
        damage = function(amount)
            hp = math.max(0, hp - amount)
            return hp
        end,
        heal = function(amount)
            hp = math.min(maxHp, hp + amount)
            return hp
        end,
        getPercent = function()
            return hp / maxHp
        end,
    }
end
```

### 5-4
```lua
enemy:takeDamage(30)
```
`:` 문법은 첫 인자로 `self`를 자동 전달하므로 `enemy.takeDamage(30)`은 `self`가 잘못 들어가 에러가 난다.

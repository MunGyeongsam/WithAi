# 08. 메타테이블

> C++의 vtable, C#의 operator overloading과 같은 역할.  
> Lua의 강력한 메타프로그래밍 메커니즘.

## 메타테이블이란?

모든 테이블에 **메타테이블**을 붙일 수 있다. 메타테이블은 특수한 키(메타메서드)를 통해 테이블의 동작을 커스터마이즈한다.

```lua
local t = {}
local mt = {}

setmetatable(t, mt)           -- t의 메타테이블을 mt로 설정
print(getmetatable(t) == mt)  -- true
```

## __index — 없는 키 접근 시 동작

가장 중요한 메타메서드. Lua OOP의 핵심.

```lua
-- __index가 테이블일 때: 해당 테이블에서 키를 찾음
local defaults = {hp = 100, speed = 5, color = "white"}
local enemy = setmetatable({name = "Slime"}, {__index = defaults})

print(enemy.name)     -- "Slime" (자기 테이블에 있음)
print(enemy.hp)       -- 100 (없으므로 defaults에서 찾음)
print(enemy.speed)    -- 5

-- enemy 자체에는 hp가 없다!
for k, v in pairs(enemy) do
    print(k, v)       -- name  Slime (이것만 출력)
end

-- C# 비교: 클래스의 기본값 / 부모 클래스 필드
-- C 비교: 구조체의 기본값을 별도 테이블로 관리
```

```lua
-- __index가 함수일 때: 더 유연한 제어
local smartTable = setmetatable({}, {
    __index = function(self, key)
        print("접근: " .. tostring(key))
        return "default_" .. key
    end
})

print(smartTable.anything)   -- "접근: anything" 출력 후 "default_anything" 반환
```

### __index 체인 (프로토타입 체인)

```lua
-- JavaScript의 프로토타입 체인과 동일한 원리
local grandparent = {species = "Monster"}
local parent = setmetatable({family = "Slime"}, {__index = grandparent})
local child = setmetatable({name = "Blue Slime"}, {__index = parent})

print(child.name)       -- "Blue Slime" (자기 자신)
print(child.family)     -- "Slime" (parent에서 찾음)
print(child.species)    -- "Monster" (grandparent에서 찾음)

-- 검색 순서: child → parent → grandparent → nil
```

## __newindex — 없는 키에 값 설정 시 동작

```lua
-- 읽기 전용 테이블 만들기
local function readOnly(t)
    return setmetatable({}, {
        __index = t,
        __newindex = function(self, key, value)
            error("read-only table: cannot set '" .. tostring(key) .. "'")
        end
    })
end

local config = readOnly({maxHp = 100, speed = 5})
print(config.maxHp)       -- 100
-- config.maxHp = 200     -- 에러: read-only table
```

```lua
-- 변경 감시 (프로퍼티 시스템)
local function observable(t, onChange)
    return setmetatable({}, {
        __index = t,
        __newindex = function(self, key, value)
            local old = t[key]
            t[key] = value
            onChange(key, old, value)
        end
    })
end

local player = observable({hp = 100}, function(key, old, new)
    print(string.format("%s changed: %s → %s", key, tostring(old), tostring(new)))
end)

player.hp = 80   -- "hp changed: 100 → 80"
```

## 산술 메타메서드

```lua
-- C++의 operator overloading, C#의 operator 키워드와 유사

local Vec2 = {}
Vec2.__index = Vec2

function Vec2.new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vec2)
end

-- 덧셈
function Vec2.__add(a, b)
    return Vec2.new(a.x + b.x, a.y + b.y)
end

-- 뺄셈
function Vec2.__sub(a, b)
    return Vec2.new(a.x - b.x, a.y - b.y)
end

-- 스칼라 곱 (숫자 * 벡터 또는 벡터 * 숫자)
function Vec2.__mul(a, b)
    if type(a) == "number" then
        return Vec2.new(a * b.x, a * b.y)
    elseif type(b) == "number" then
        return Vec2.new(a.x * b, a.y * b)
    end
    return Vec2.new(a.x * b.x, a.y * b.y)
end

-- 부정 (단항 마이너스)
function Vec2.__unm(a)
    return Vec2.new(-a.x, -a.y)
end

-- 동등 비교
function Vec2.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

-- 문자열 변환
function Vec2.__tostring(v)
    return string.format("(%g, %g)", v.x, v.y)
end

-- 사용
local a = Vec2.new(3, 4)
local b = Vec2.new(1, 2)
local c = a + b              -- Vec2(4, 6)
local d = a * 2              -- Vec2(6, 8)
local e = -a                 -- Vec2(-3, -4)
print(tostring(c))           -- "(4, 6)"
print(a == Vec2.new(3, 4))   -- true
```

## 전체 메타메서드 목록

```
산술:
  __add(a, b)      +
  __sub(a, b)      -
  __mul(a, b)      *
  __div(a, b)      /
  __mod(a, b)      %
  __pow(a, b)      ^
  __unm(a)         단항 -

비교:
  __eq(a, b)       ==  (양쪽 메타테이블이 같아야 호출)
  __lt(a, b)       <
  __le(a, b)       <=

기타:
  __index          없는 키 읽기
  __newindex       없는 키 쓰기
  __call(t, ...)   t()로 호출 시
  __tostring(t)    tostring(t) 시
  __len(t)         #t 시 (Lua 5.1에서는 테이블에 미작동 ⚠️)
  __concat(a, b)   .. 연산
  __gc             GC 수거 시 (userdata만, Lua 5.1)
  __metatable      getmetatable 결과 변경 / 메타테이블 보호
```

## __call — 함수처럼 호출

```lua
-- 테이블을 함수처럼 호출할 수 있게 만든다
local Dice = setmetatable({}, {
    __call = function(self, sides)
        return math.random(1, sides or 6)
    end
})

print(Dice(6))     -- 1~6 랜덤
print(Dice(20))    -- 1~20 랜덤
print(Dice())      -- 1~6 랜덤 (기본값)

-- 게임 활용: 팩토리 패턴
local Enemy = {}
Enemy.__index = Enemy

setmetatable(Enemy, {
    __call = function(cls, name, hp)
        return cls.new(name, hp)
    end
})

function Enemy.new(name, hp)
    return setmetatable({name = name, hp = hp}, Enemy)
end

-- 두 가지 생성 방식 모두 가능
local e1 = Enemy.new("Slime", 50)
local e2 = Enemy("Goblin", 80)     -- __call 덕분
```

## rawget / rawset — 메타메서드 우회

```lua
-- 메타메서드를 거치지 않고 직접 접근
local t = setmetatable({}, {
    __index = function() return "meta" end,
    __newindex = function() error("no!") end,
})

print(t.anything)          -- "meta" (__index 호출)
print(rawget(t, "anything"))  -- nil (메타메서드 무시)

-- rawset은 __newindex를 무시
rawset(t, "key", "value")    -- 에러 없이 직접 설정
print(rawget(t, "key"))      -- "value"
```

---

## 연습문제

### 연습 8-1: Vec2 확장
위의 Vec2에 다음을 추가하라:
- `length()`: 벡터 길이 반환
- `normalized()`: 단위 벡터 반환
- `dot(other)`: 내적
- `__tostring`: `"Vec2(x, y)"` 형식

### 연습 8-2: 읽기 전용 + 기본값
`createConfig(defaults)` 함수를 만들어라. 반환된 테이블은:
- 없는 키 접근 시 defaults에서 값을 가져온다
- 값 설정 시도 시 경고 메시지를 출력하지만 설정은 허용한다

### 연습 8-3: 프록시 테이블
접근 횟수를 추적하는 프록시 테이블을 만들어라.

```lua
local data = {hp = 100, mp = 50}
local proxy = createProxy(data)
print(proxy.hp)           -- 100
print(proxy.hp)           -- 100
print(proxy.mp)           -- 50
print(proxy:getAccessCount("hp"))   -- 2
print(proxy:getAccessCount("mp"))   -- 1
```

### 연습 8-4: __index 체인 이해
아래 코드의 출력을 예측하라.

```lua
local A = {x = 1}
local B = setmetatable({y = 2}, {__index = A})
local C = setmetatable({z = 3}, {__index = B})

print(C.z, C.y, C.x)     -- ?
B.x = 10
print(C.x)                -- ?
A.x = 20
print(C.x)                -- ?
```

---

[← 이전: 07. 테이블 심화](07_tables_advanced.md) | [다음: 09. OOP 패턴 →](09_oop_patterns.md)

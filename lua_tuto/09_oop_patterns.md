# 09. OOP 패턴

> Lua에는 `class` 키워드가 없다. 테이블 + 메타테이블로 OOP를 구현한다.

## C#/C++ 클래스 vs Lua 테이블

```
C#:                              Lua:
class Enemy {                    local Enemy = {}
    int hp;                      Enemy.__index = Enemy
    string name;
                                 function Enemy.new(name, hp)
    Enemy(string n, int h) {         return setmetatable({
        name = n;                        name = name,
        hp = h;                          hp = hp,
    }                                }, Enemy)
                                 end
    void TakeDamage(int d) {
        hp -= d;                 function Enemy:takeDamage(d)
    }                                self.hp = self.hp - d
}                                end
```

## 기본 클래스 패턴

```lua
local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(name, hp)
    local self = setmetatable({}, Enemy)
    self.name = name
    self.hp = hp or 100
    self.maxHp = self.hp
    return self
end

function Enemy:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self.hp = 0
        self:onDeath()
    end
end

function Enemy:heal(amount)
    self.hp = math.min(self.hp + amount, self.maxHp)
end

function Enemy:isAlive()
    return self.hp > 0
end

function Enemy:onDeath()
    print(self.name .. " has been defeated!")
end

function Enemy:toString()
    return string.format("%s [HP: %d/%d]", self.name, self.hp, self.maxHp)
end

-- 사용
local slime = Enemy.new("Slime", 50)
slime:takeDamage(20)
print(slime:toString())    -- "Slime [HP: 30/50]"
print(slime:isAlive())     -- true
slime:takeDamage(50)       -- "Slime has been defeated!"
```

### 동작 원리

```
slime:takeDamage(20) 호출 시:
1. slime 테이블에서 "takeDamage" 키를 찾음 → 없음
2. slime의 메타테이블(Enemy)에서 __index를 확인 → Enemy 테이블
3. Enemy["takeDamage"]를 찾음 → 함수 발견!
4. slime:takeDamage(20) → Enemy.takeDamage(slime, 20) 으로 호출
   (: 문법이 self를 자동 전달)
```

## 상속

```lua
-- 부모 클래스
local Entity = {}
Entity.__index = Entity

function Entity.new(x, y)
    return setmetatable({
        x = x or 0,
        y = y or 0,
        active = true,
    }, Entity)
end

function Entity:getPos()
    return self.x, self.y
end

function Entity:destroy()
    self.active = false
end

-- 자식 클래스
local Enemy = setmetatable({}, {__index = Entity})   -- Enemy가 Entity를 상속
Enemy.__index = Enemy

function Enemy.new(name, hp, x, y)
    local self = Entity.new(x, y)       -- 부모 생성자 호출
    setmetatable(self, Enemy)            -- 메타테이블을 Enemy로 변경
    self.name = name
    self.hp = hp
    return self
end

function Enemy:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self:destroy()   -- Entity의 메서드 호출
    end
end

-- 손자 클래스
local Boss = setmetatable({}, {__index = Enemy})
Boss.__index = Boss

function Boss.new(name, hp, phase, x, y)
    local self = Enemy.new(name, hp, x, y)
    setmetatable(self, Boss)
    self.phase = phase or 1
    self.maxPhase = 3
    return self
end

function Boss:takeDamage(amount)
    -- 오버라이드
    self.hp = self.hp - amount
    if self.hp <= 0 and self.phase < self.maxPhase then
        self.phase = self.phase + 1
        self.hp = 100    -- 다음 페이즈
        print(self.name .. " enters Phase " .. self.phase .. "!")
    elseif self.hp <= 0 then
        self:destroy()
    end
end

-- 사용
local boss = Boss.new("Dragon", 100, 1, 0, 0)
boss:takeDamage(120)    -- "Dragon enters Phase 2!"
print(boss.hp)          -- 100
local bx, by = boss:getPos()   -- Entity의 메서드 사용 가능
```

### 상속 체인

```
boss:getPos() 검색 순서:
boss 인스턴스 → Boss → Enemy → Entity → nil

boss:takeDamage() 검색 순서:
boss 인스턴스 → Boss (여기서 발견! Enemy 버전은 호출 안 됨)
```

## instanceof 구현

```lua
local function isinstance(obj, class)
    local mt = getmetatable(obj)
    while mt do
        if mt == class then return true end
        local parent = getmetatable(mt)
        if parent then
            mt = parent.__index
        else
            mt = nil
        end
    end
    return false
end

local boss = Boss.new("Dragon", 100, 1, 0, 0)
print(isinstance(boss, Boss))     -- true
print(isinstance(boss, Enemy))    -- true
print(isinstance(boss, Entity))   -- true
```

## 믹스인 (다중 상속 대안)

```lua
-- Lua는 단일 __index만 가지므로 다중 상속이 어렵다
-- 대안: 믹스인 (기능을 복사해서 섞기)

local Movable = {}
function Movable:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end
function Movable:setVelocity(vx, vy)
    self.vx = vx
    self.vy = vy
end

local Damageable = {}
function Damageable:takeDamage(amount)
    self.hp = self.hp - amount
end
function Damageable:isAlive()
    return self.hp > 0
end

-- 믹스인 적용 함수
local function mixin(target, ...)
    for i = 1, select("#", ...) do
        local source = select(i, ...)
        for k, v in pairs(source) do
            target[k] = v
        end
    end
end

-- 사용
local Player = {}
Player.__index = Player
mixin(Player, Movable, Damageable)   -- 두 믹스인의 메서드를 복사

function Player.new(name)
    return setmetatable({
        name = name, x = 0, y = 0, vx = 0, vy = 0, hp = 100,
    }, Player)
end

local p = Player.new("Hero")
p:move(5, 3)           -- Movable에서 온 메서드
p:takeDamage(10)       -- Damageable에서 온 메서드
print(p:isAlive())     -- true
```

## 간단한 클래스 헬퍼

```lua
-- 매번 메타테이블 설정하기 번거로우면 헬퍼 함수를 만들어 둔다
local function class(parent)
    local cls = {}
    cls.__index = cls
    
    if parent then
        setmetatable(cls, {__index = parent})
    end
    
    -- new를 호출하면 인스턴스 생성
    cls.new = function(...)
        local self = setmetatable({}, cls)
        if cls.init then
            cls.init(self, ...)
        end
        return self
    end
    
    return cls
end

-- 사용이 깔끔해진다
local Animal = class()
function Animal:init(name, sound)
    self.name = name
    self.sound = sound
end
function Animal:speak()
    print(self.name .. " says " .. self.sound)
end

local Dog = class(Animal)
function Dog:init(name)
    Animal.init(self, name, "Woof!")  -- super 호출
    self.tricks = {}
end
function Dog:learnTrick(trick)
    self.tricks[#self.tricks + 1] = trick
end

local buddy = Dog.new("Buddy")
buddy:speak()              -- "Buddy says Woof!"
buddy:learnTrick("sit")
```

## 게임에서의 OOP 사용 주의점

```lua
-- ⚠️ Lua에서 OOP를 과도하게 쓰면:
-- 1. 메타테이블 체인이 깊어져 __index 검색 비용 증가
-- 2. 인스턴스마다 테이블 생성 → GC 부담
-- 3. 디버깅이 어려워짐 (누가 어떤 메서드를 오버라이드했는지)

-- 게임에서 권장하는 패턴:
-- 1. 상속보다 컴포지션 (ECS 패턴 — 19장에서 다룸)
-- 2. 상속 깊이 최대 2~3단계
-- 3. 핫패스(매 프레임 호출)에서는 메서드 호출 대신 직접 필드 접근
-- 4. 대량 객체(총알, 파티클)는 OOP 대신 풀 + 배열 방식

-- 핫패스 최적화 예:
-- 느림: entity:getX()  (메타테이블 검색 + 함수 호출)
-- 빠름: entity.x       (직접 필드 접근)
```

---

## 연습문제

### 연습 9-1: 무기 클래스 계층
아래 클래스 계층을 구현하라:
- `Weapon`: name, damage, cooldown 필드. `attack()` 메서드 (데미지 반환)
- `Sword(Weapon)`: 근접 무기. range 필드 추가
- `Staff(Weapon)`: 마법 무기. manaCost 필드 추가. attack() 시 마나 체크

### 연습 9-2: 믹스인 활용
`Serializable` 믹스인을 만들어라. `serialize()` 메서드가 테이블의 모든 값 필드를 `"key=value"` 형식의 문자열로 반환해야 한다.  
이 믹스인을 `Player` 클래스에 적용하라.

### 연습 9-3: class 헬퍼 확장
위의 `class()` 헬퍼에 `super` 기능을 추가하라. 자식 클래스에서 `self:super("methodName", args...)` 형태로 부모 메서드를 호출할 수 있어야 한다.

### 연습 9-4: OOP vs 데이터 비교
같은 기능(적 100마리 생성, 이동, 데미지)을:
1. OOP 방식 (클래스 인스턴스 배열)
2. 데이터 방식 (배열 of 테이블, 함수는 외부)
로 구현하고, 코드 구조의 차이를 비교하라.

---

[← 이전: 08. 메타테이블](08_metatables.md) | [다음: 10. 모듈 시스템 →](10_modules.md)

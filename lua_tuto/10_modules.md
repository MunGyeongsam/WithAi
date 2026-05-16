# 10. 모듈 시스템

## require — Lua의 import

```lua
-- C#의 using, C의 #include에 해당
-- 하지만 동작 방식이 다르다!

local myModule = require("myModule")

-- require의 동작:
-- 1. package.loaded["myModule"]에 이미 있으면 캐시된 값 반환
-- 2. 없으면 package.path에서 파일 검색
-- 3. 파일을 실행하고, 반환값을 package.loaded에 캐시
-- 4. 반환값을 리턴

-- ⚠️ 핵심: require는 파일당 1회만 실행한다! (싱글톤과 유사)
```

## 모듈 작성 패턴

### 패턴 1: 테이블 반환 (표준)

```lua
-- utils.lua
local M = {}

function M.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function M.lerp(a, b, t)
    return a + (b - a) * t
end

-- private 함수 (M에 넣지 않으면 외부 접근 불가)
local function internalHelper()
    -- 모듈 내부에서만 사용
end

return M
```

```lua
-- 사용하는 쪽
local utils = require("utils")
print(utils.clamp(150, 0, 100))   -- 100
print(utils.lerp(0, 10, 0.5))     -- 5
```

### 패턴 2: 상태를 가진 모듈

```lua
-- camera.lua
local M = {}

local x, y = 0, 0        -- private 상태
local zoom = 1.0

function M.init(startX, startY)
    x = startX or 0
    y = startY or 0
    zoom = 1.0
end

function M.update(dt)
    -- 카메라 업데이트 로직
end

function M.getPos()
    return x, y
end

function M.setZoom(z)
    zoom = z
end

function M.apply()
    love.graphics.translate(-x, -y)
    love.graphics.scale(zoom)
end

return M
```

### 패턴 3: 클래스 모듈

```lua
-- enemy.lua
local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(name, hp)
    return setmetatable({
        name = name,
        hp = hp or 100,
    }, Enemy)
end

function Enemy:takeDamage(amount)
    self.hp = self.hp - amount
end

return Enemy
```

```lua
-- 사용하는 쪽
local Enemy = require("enemy")
local slime = Enemy.new("Slime", 50)
```

## require 경로 규칙

```lua
-- . (점)으로 디렉토리 구분 (/ 아님!)
local player = require("game.entities.player")
-- 검색: game/entities/player.lua

-- package.path에서 검색 패턴 확인
print(package.path)
-- 보통: "./?.lua;./?/init.lua;/usr/share/lua/5.1/?.lua"

-- ? 가 모듈 이름으로 대체됨
-- require("game.entities.player") →
--   ./game/entities/player.lua
--   ./game/entities/player/init.lua
--   ...

-- LÖVE2D에서는 src/ 가 루트
-- require("03_game.systems.moveSystem")
-- → src/03_game/systems/moveSystem.lua
```

## require 캐싱과 순환 의존

```lua
-- ⚠️ require는 캐시된다! 같은 모듈을 여러 번 require해도 1번만 실행
local a = require("myModule")
local b = require("myModule")
print(a == b)    -- true (같은 테이블!)

-- 캐시 강제 리셋 (디버깅 시에만 사용)
package.loaded["myModule"] = nil
local fresh = require("myModule")   -- 다시 실행
```

```lua
-- ⚠️ 순환 의존 주의!
-- a.lua
local b = require("b")    -- b를 로드
local M = {}
function M.hello() return "A" end
return M

-- b.lua
local a = require("a")    -- a를 로드... 하지만 a는 아직 로드 중!
local M = {}
function M.hello() return a.hello() end  -- a가 불완전할 수 있음 ⚠️
return M

-- 해결책:
-- 1. 의존 방향을 단방향으로 유지 (레이어 규칙)
-- 2. 지연 로딩: 함수 내부에서 require
-- 3. 콜백/이벤트로 역방향 통신
```

## 지연 로딩 패턴

```lua
-- 순환 의존이나 선택적 로딩이 필요할 때
local M = {}
local otherModule   -- 아직 nil

function M.init()
    otherModule = require("otherModule")   -- 필요한 시점에 로드
end

function M.doSomething()
    if otherModule then
        otherModule.help()
    end
end

return M
```

## LÖVE2D 프로젝트 구조 예시

```
my_game/
├── main.lua              -- 진입점
├── conf.lua              -- LÖVE 설정
├── lib/
│   ├── vec2.lua          -- 벡터 유틸
│   └── timer.lua         -- 타이머 유틸
├── entities/
│   ├── player.lua        -- 플레이어 클래스
│   ├── enemy.lua         -- 적 클래스
│   └── bullet.lua        -- 총알 클래스
├── systems/
│   ├── collision.lua     -- 충돌 시스템
│   └── spawner.lua       -- 스포너 시스템
└── scenes/
    ├── menu.lua          -- 메뉴 화면
    └── game.lua          -- 게임 화면
```

```lua
-- main.lua
local scene = require("scenes.menu")

function love.load()
    scene.init()
end

function love.update(dt)
    scene.update(dt)
end

function love.draw()
    scene.draw()
end
```

## package.path 커스터마이즈

```lua
-- conf.lua 또는 main.lua 최상단에서 경로 추가
-- LÖVE2D에서 커스텀 require 경로가 필요할 때

-- conf.lua
function love.conf(t)
    t.identity = "mygame"
    t.window.title = "My Game"
end

-- main.lua
-- 서브폴더를 자동으로 검색하도록 경로 추가
package.path = package.path .. ";lib/?.lua;lib/?/init.lua"
```

## 모듈 설계 원칙

```lua
-- 1. 모듈은 테이블 하나를 반환한다
-- 2. 모듈 내부 상태는 local 변수로 숨긴다
-- 3. public API만 반환 테이블에 넣는다
-- 4. require 순서에 의존하지 않게 설계한다 (init 패턴 사용)
-- 5. 모듈 간 의존은 단방향 (상위 → 하위)

-- ✅ 좋은 모듈
local M = {}
local state = {}   -- private

function M.init() end
function M.update(dt) end
function M.getState() return state end

return M

-- ❌ 나쁜 모듈
someGlobal = {}    -- 전역 오염
function doSomething() end   -- 전역 함수
-- return 없음 → require 시 true 반환
```

---

## 연습문제

### 연습 10-1: 유틸리티 모듈
`mathUtils.lua` 모듈을 만들어라. 다음 함수를 포함:
- `clamp(value, min, max)`
- `lerp(a, b, t)`
- `distance(x1, y1, x2, y2)`
- `normalize(x, y)` — 정규화된 벡터 (x, y) 반환

### 연습 10-2: 상태 모듈
`scoreManager.lua` 모듈을 만들어라:
- `init()`: 점수 0으로 초기화
- `add(points)`: 점수 추가, 최고 점수 자동 갱신
- `getScore()`: 현재 점수
- `getHighScore()`: 최고 점수
- `reset()`: 현재 점수만 0으로

### 연습 10-3: 의존성 방향
아래 모듈 구조에서 순환 의존이 있는지 찾고, 있다면 해결 방안을 제시하라.

```
player.lua → require("weapon")
weapon.lua → require("effects")
effects.lua → require("player")   -- ⚠️
```

### 연습 10-4: 프로젝트 구조 설계
간단한 슈팅 게임의 모듈 구조를 설계하라 (파일 목록 + require 관계도).
플레이어, 적, 총알, 충돌, 점수, 화면(메뉴/게임/게임오버)이 필요하다.

---

[← 이전: 09. OOP 패턴](09_oop_patterns.md) | [다음: 11. LÖVE2D 생명주기 →](11_love2d_lifecycle.md)

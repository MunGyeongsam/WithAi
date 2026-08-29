# 03. 그리기 기초

## 좌표계

```
(0,0) ──────────────── X+ →
  │
  │         (400,300) 화면 중앙
  │
  Y+ ↓
            (800,600) 오른쪽 아래
```

Y축이 **아래로 증가**한다. 수학 좌표계와 반대.

```lua
local w = love.graphics.getWidth()    -- 기본 800
local h = love.graphics.getHeight()   -- 기본 600
```

## 색상

LÖVE 11.x에서 색상은 **0~1 범위** (0~255가 아님).

```lua
function love.draw()
    love.graphics.setColor(1, 0, 0)         -- 빨강
    love.graphics.setColor(0, 1, 0, 0.5)    -- 반투명 초록 (r, g, b, a)
    love.graphics.setColor(1, 1, 1)         -- 흰색 (기본)

    -- 색상은 이후 모든 그리기에 적용된다
    -- 그리기 끝나면 흰색으로 복원하는 것이 좋다
    love.graphics.setColor(1, 1, 1)
end
```

### 배경색

```lua
function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2)   -- 어두운 남색
end
```

## 기본 도형

### 원

```lua
function love.draw()
    -- circle(mode, x, y, radius)
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.circle("fill", 400, 300, 50)     -- 채워진 원
    love.graphics.circle("line", 400, 300, 80)     -- 원 테두리
    love.graphics.circle("fill", 200, 200, 30, 6)  -- 6각형 (세그먼트 수)
end
```

### 사각형

```lua
function love.draw()
    -- rectangle(mode, x, y, width, height)
    love.graphics.setColor(0.3, 0.3, 1)
    love.graphics.rectangle("fill", 100, 100, 200, 150)

    -- 둥근 모서리
    love.graphics.rectangle("fill", 400, 100, 200, 150, 10, 10)
end
```

### 선

```lua
function love.draw()
    love.graphics.setColor(1, 1, 0)
    love.graphics.line(0, 0, 800, 600)               -- 대각선
    love.graphics.line(0, 0, 400, 0, 400, 300)        -- 꺾인 선

    -- 선 두께
    love.graphics.setLineWidth(3)
    love.graphics.line(100, 500, 700, 500)
    love.graphics.setLineWidth(1)   -- 복원
end
```

### 다각형

```lua
function love.draw()
    love.graphics.setColor(0.5, 1, 0.5)
    -- polygon(mode, x1, y1, x2, y2, x3, y3, ...)
    love.graphics.polygon("fill", 400, 100, 450, 200, 350, 200)   -- 삼각형
end
```

### 점

```lua
function love.draw()
    love.graphics.setPointSize(5)
    love.graphics.points(100, 100, 200, 150, 300, 200)
end
```

## 좌표 변환 (Transform)

### translate — 원점 이동

```lua
function love.draw()
    love.graphics.push()              -- 현재 변환 상태 저장
    love.graphics.translate(400, 300) -- 원점을 화면 중앙으로

    -- 이제 (0,0)이 화면 중앙
    love.graphics.circle("fill", 0, 0, 50)
    love.graphics.pop()               -- 변환 상태 복원
end
```

### rotate — 회전

```lua
function love.draw()
    love.graphics.push()
    love.graphics.translate(400, 300)
    love.graphics.rotate(math.rad(45))    -- 45도 회전 (라디안)

    love.graphics.rectangle("fill", -50, -50, 100, 100)
    love.graphics.pop()
end
```

### scale — 확대/축소

```lua
function love.draw()
    love.graphics.push()
    love.graphics.translate(400, 300)
    love.graphics.scale(2, 0.5)     -- X 2배, Y 0.5배

    love.graphics.circle("fill", 0, 0, 50)   -- 타원이 됨
    love.graphics.pop()
end
```

### push/pop 중첩

```lua
function love.draw()
    love.graphics.push()
    love.graphics.translate(200, 200)
    love.graphics.circle("fill", 0, 0, 30)   -- (200,200)에 원

        love.graphics.push()
        love.graphics.translate(100, 0)
        love.graphics.circle("fill", 0, 0, 20)   -- (300,200)에 원
        love.graphics.pop()

    love.graphics.circle("fill", 0, 50, 15)  -- (200,250)에 원
    love.graphics.pop()
end
```

> **규칙**: `push()`와 `pop()`은 반드시 짝을 맞춘다. 안 맞으면 에러.

## 그리기 순서

LÖVE2D에는 Z-order가 없다. **코드 순서 = 그리기 순서** (나중에 그린 것이 위).

```lua
function love.draw()
    -- 배경 (맨 먼저)
    love.graphics.setColor(0.2, 0.5, 0.2)
    love.graphics.rectangle("fill", 0, 400, 800, 200)

    -- 캐릭터 (배경 위)
    love.graphics.setColor(1, 0.8, 0.6)
    love.graphics.circle("fill", 400, 380, 30)

    -- UI (맨 위)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: 100", 10, 10)
end
```

## 실습: 간단한 장면

```lua
-- main.lua
local time

function love.load()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.15)
    time = 0
end

function love.update(dt)
    time = time + dt
end

function love.draw()
    -- 별 (점)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setPointSize(2)
    for i = 1, 50 do
        local x = (i * 97) % 800
        local y = (i * 53) % 400
        love.graphics.points(x, y)
    end

    -- 달 (원)
    love.graphics.setColor(1, 1, 0.8)
    love.graphics.circle("fill", 650, 80, 40)

    -- 땅 (사각형)
    love.graphics.setColor(0.15, 0.4, 0.15)
    love.graphics.rectangle("fill", 0, 450, 800, 150)

    -- 나무 (삼각형 + 사각형)
    love.graphics.setColor(0.4, 0.25, 0.1)
    love.graphics.rectangle("fill", 195, 380, 10, 70)
    love.graphics.setColor(0.1, 0.6, 0.2)
    love.graphics.polygon("fill", 200, 300, 240, 380, 160, 380)

    -- 움직이는 원
    local pulse = math.sin(time * 2) * 0.3 + 0.7
    love.graphics.setColor(0.3, pulse, 1)
    love.graphics.circle("fill", 400, 400, 15)

    love.graphics.setColor(1, 1, 1)
end
```

## 다음 챕터

키보드와 마우스 입력을 받아 화면의 객체를 조작한다.

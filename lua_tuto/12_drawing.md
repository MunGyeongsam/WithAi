# 12. 그리기

## 좌표계

```lua
-- LÖVE2D 기본 좌표계 (스크린 좌표)
-- (0,0) ────────── X+ →
--   |
--   |
--   Y+ ↓
--
-- ⚠️ Y축이 아래로 증가! (OpenGL/DirectX와 동일, 수학 좌표계와 반대)
-- Unity의 2D도 Y-up이지만, LÖVE2D는 Y-down이 기본

-- 화면 크기
local w = love.graphics.getWidth()    -- 기본 800
local h = love.graphics.getHeight()   -- 기본 600
```

## 기본 도형

```lua
function love.draw()
    -- 색상 설정 (0~1 범위, LÖVE 11.x)
    love.graphics.setColor(1, 0, 0)         -- 빨강
    love.graphics.setColor(1, 0, 0, 0.5)    -- 반투명 빨강
    
    -- 원
    love.graphics.circle("fill", 400, 300, 50)      -- 채워진 원
    love.graphics.circle("line", 400, 300, 50)      -- 원 테두리
    love.graphics.circle("fill", 400, 300, 50, 6)   -- 6각형 (세그먼트 수)
    
    -- 사각형
    love.graphics.rectangle("fill", 100, 100, 200, 150)     -- 채워진 (x, y, w, h)
    love.graphics.rectangle("line", 100, 100, 200, 150)     -- 테두리
    love.graphics.rectangle("fill", 100, 100, 200, 150, 10) -- 둥근 모서리 (rx)
    
    -- 선
    love.graphics.line(0, 0, 800, 600)               -- 대각선
    love.graphics.line(0, 0, 400, 0, 400, 300)       -- 연결된 선분들
    
    -- 점
    love.graphics.points(100, 100, 200, 200, 300, 300)  -- 점 여러 개
    
    -- 다각형
    love.graphics.polygon("fill", 400, 100, 450, 200, 350, 200)  -- 삼각형
    
    -- 타원 (없음! 스케일로 구현)
    love.graphics.push()
    love.graphics.translate(400, 300)
    love.graphics.scale(2, 1)          -- X축 2배 → 타원
    love.graphics.circle("fill", 0, 0, 50)
    love.graphics.pop()
    
    -- 색상 리셋
    love.graphics.setColor(1, 1, 1)
end
```

## 색상

```lua
-- LÖVE 11.x: 0~1 범위 (OpenGL 표준)
love.graphics.setColor(1, 0, 0)        -- 빨강
love.graphics.setColor(0.5, 0.5, 0.5)  -- 회색

-- 0~255 범위를 쓰고 싶으면 변환
local function rgb(r, g, b, a)
    return r/255, g/255, b/255, (a or 255)/255
end
love.graphics.setColor(rgb(255, 128, 0))   -- 주황

-- 흔히 쓰는 색상
local COLORS = {
    white  = {1, 1, 1},
    black  = {0, 0, 0},
    red    = {1, 0, 0},
    green  = {0, 1, 0},
    blue   = {0, 0, 1},
    yellow = {1, 1, 0},
    cyan   = {0, 1, 1},
}

-- ⚠️ setColor는 이후 모든 draw에 영향! 
-- 함수 끝에서 (1,1,1)로 리셋하는 습관
```

## 텍스트

```lua
function love.draw()
    -- 기본 텍스트
    love.graphics.print("Hello!", 10, 10)
    
    -- 포맷된 텍스트
    love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 10, 30)
    
    -- 텍스트 크기 및 회전
    love.graphics.print("Rotated", 400, 300, math.rad(45))  -- 45도 회전
    love.graphics.print("Scaled", 400, 300, 0, 2, 2)        -- 2배 크기
    
    -- printf — 정렬 지원
    love.graphics.printf("Center Text", 0, 300, 800, "center")   -- 800px 내 가운데
    love.graphics.printf("Right Text", 0, 320, 800, "right")
    
    -- 폰트 변경
    local font = love.graphics.newFont(24)           -- 기본 폰트 24pt
    love.graphics.setFont(font)
    love.graphics.print("Big Text", 10, 50)
    
    -- 폰트는 love.load에서 생성하라! (매 프레임 생성하면 메모리 낭비 ⚠️)
end

-- love.load에서 폰트 생성
local titleFont, bodyFont

function love.load()
    titleFont = love.graphics.newFont(32)
    bodyFont = love.graphics.newFont(16)
end

function love.draw()
    love.graphics.setFont(titleFont)
    love.graphics.print("GAME TITLE", 10, 10)
    
    love.graphics.setFont(bodyFont)
    love.graphics.print("Press Start", 10, 50)
end
```

## 좌표 변환 (Transform)

```lua
-- LÖVE2D의 변환 = OpenGL 변환 행렬과 동일
-- Unity의 Transform과 비슷하지만, 직접 스택을 관리해야 한다

function love.draw()
    -- push/pop으로 변환 상태 저장/복원
    love.graphics.push()
    
    love.graphics.translate(400, 300)   -- 원점 이동
    love.graphics.rotate(math.rad(45))  -- 회전 (라디안)
    love.graphics.scale(2, 2)           -- 확대
    
    -- (0,0)이 화면 (400,300)에 위치
    love.graphics.rectangle("fill", -25, -25, 50, 50)   -- 중심 기준 사각형
    
    love.graphics.pop()    -- 변환 복원
    
    -- pop 후에는 원래 좌표계
    love.graphics.circle("fill", 0, 0, 10)   -- 좌상단
end
```

### 변환 순서 주의

```lua
-- 변환은 역순으로 적용된다!
-- 코드: translate → rotate → scale
-- 실제 적용: scale → rotate → translate

-- 중심 회전 패턴 (가장 흔한 패턴)
local function drawRotated(drawable, x, y, angle, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)        -- 3. 최종 위치로 이동
    love.graphics.rotate(angle)          -- 2. 회전
    love.graphics.scale(sx or 1, sy or 1)  -- 1. 스케일
    -- 원점 중심으로 그리기
    love.graphics.rectangle("fill", -25, -25, 50, 50)
    love.graphics.pop()
end
```

## 선 스타일

```lua
-- 선 두께
love.graphics.setLineWidth(3)
love.graphics.line(0, 0, 800, 600)

-- 선 스타일
love.graphics.setLineStyle("smooth")    -- 안티앨리어싱 (기본)
love.graphics.setLineStyle("rough")     -- 픽셀 정확

-- 선 조인
love.graphics.setLineJoin("miter")      -- 뾰족 (기본)
love.graphics.setLineJoin("bevel")      -- 깎인
love.graphics.setLineJoin("none")       -- 없음
```

## 블렌드 모드

```lua
-- 기본: alpha 블렌딩
love.graphics.setBlendMode("alpha")

-- 가산 (발광 효과, 파티클에 유용)
love.graphics.setBlendMode("add")
love.graphics.setColor(1, 0.5, 0, 0.5)
love.graphics.circle("fill", 400, 300, 50)

-- 곱하기
love.graphics.setBlendMode("multiply")

-- 리셋
love.graphics.setBlendMode("alpha")

-- 게임에서 흔한 조합:
-- 총알, 폭발, 마법: add
-- 그림자, 어둠: multiply
-- 일반 스프라이트: alpha
```

## Canvas (오프스크린 렌더링)

```lua
-- C#의 RenderTexture, OpenGL의 FBO와 동일
local canvas

function love.load()
    canvas = love.graphics.newCanvas(800, 600)
end

function love.draw()
    -- 캔버스에 그리기
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)    -- 투명으로 초기화
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", 400, 300, 100)
    
    love.graphics.setCanvas()    -- 기본 화면으로 복원
    
    -- 캔버스를 화면에 그리기
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0)
end

-- 캔버스 활용:
-- 블룸/블러 등 포스트 프로세싱
-- 미니맵
-- 미리 그려놓기 (성능 최적화)
```

## 벡터 아트 패턴 (Zero-Art)

```lua
-- 이미지 없이 코드만으로 비주얼을 만드는 패턴

-- 별 모양
local function drawStar(x, y, outerR, innerR, points)
    local vertices = {}
    for i = 0, points * 2 - 1 do
        local angle = (i / (points * 2)) * math.pi * 2 - math.pi / 2
        local r = (i % 2 == 0) and outerR or innerR
        vertices[#vertices + 1] = x + math.cos(angle) * r
        vertices[#vertices + 1] = y + math.sin(angle) * r
    end
    love.graphics.polygon("fill", vertices)
end

-- 글로우 효과 (가산 블렌딩 + 여러 겹)
local function drawGlow(x, y, radius, r, g, b)
    love.graphics.setBlendMode("add")
    for i = 3, 1, -1 do
        local alpha = 0.1 / i
        love.graphics.setColor(r, g, b, alpha)
        love.graphics.circle("fill", x, y, radius * i)
    end
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(r, g, b, 1)
    love.graphics.circle("fill", x, y, radius * 0.3)
end
```

---

## 연습문제

### 연습 12-1: 도형 그리기
화면에 다음을 그려라:
- 빨간 채운 원 (중앙)
- 녹색 사각형 테두리 (좌상단)
- 노란 삼각형 (우하단)
- 흰색 격자선 (50px 간격)

### 연습 12-2: 회전하는 사각형
화면 중앙에서 시간에 따라 회전하는 사각형을 그려라.
`love.timer.getTime()` 또는 누적 `dt`를 각도로 사용할 것.

### 연습 12-3: 간단한 파티클
클릭한 위치에서 원형 파티클이 생성되어 위로 올라가며 서서히 사라지는 효과를 구현하라.
(가산 블렌딩 사용)

### 연습 12-4: 벡터 캐릭터
코드만으로 (이미지 없이) 간단한 우주선 모양을 그려라.
삼각형 + 사각형 조합으로, 색상과 글로우 효과를 추가할 것.

---

[← 이전: 11. LÖVE2D 생명주기](11_love2d_lifecycle.md) | [다음: 13. 입력 처리 →](13_input.md)

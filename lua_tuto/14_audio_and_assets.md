# 14. 오디오 & 리소스

## 오디오

### Source 생성

```lua
-- LÖVE2D에서 소리 = Source 객체
-- 두 가지 타입:
-- "static" : 메모리에 전체 로드 (짧은 효과음)
-- "stream" : 스트리밍 재생 (긴 BGM)

local sfxShoot
local bgm

function love.load()
    -- 효과음 (static — 짧고, 여러 번 동시 재생 가능)
    sfxShoot = love.audio.newSource("sfx/shoot.wav", "static")
    
    -- 배경음악 (stream — 메모리 절약)
    bgm = love.audio.newSource("music/bgm.ogg", "stream")
    bgm:setLooping(true)
    bgm:play()
end
```

### 재생 제어

```lua
-- 재생
sfxShoot:play()

-- 정지
bgm:stop()

-- 일시정지 / 재개
bgm:pause()
bgm:play()     -- pause 후 play = 재개

-- 볼륨 (0.0 ~ 1.0)
bgm:setVolume(0.5)
sfxShoot:setVolume(0.8)

-- 전체 볼륨
love.audio.setVolume(0.7)

-- 피치 (재생 속도)
sfxShoot:setPitch(1.5)    -- 1.5배속 (더 높은 음)

-- 루핑
bgm:setLooping(true)

-- 재생 중인지 확인
if bgm:isPlaying() then
    print("BGM is playing")
end
```

### 동시 재생 (같은 효과음 여러 번)

```lua
-- ⚠️ Source 하나를 play() 하면 이전 재생이 중단됨!
-- 동시 재생을 원하면 clone() 사용

function playSound(source)
    local clone = source:clone()
    clone:play()
    -- clone은 재생 후 GC에 의해 정리됨
end

-- 또는 미리 여러 개 만들어두기 (풀링)
local shootSounds = {}
local shootIndex = 1
local SHOOT_POOL_SIZE = 8

function love.load()
    local base = love.audio.newSource("sfx/shoot.wav", "static")
    for i = 1, SHOOT_POOL_SIZE do
        shootSounds[i] = base:clone()
    end
end

function playShoot()
    shootSounds[shootIndex]:stop()
    shootSounds[shootIndex]:play()
    shootIndex = shootIndex % SHOOT_POOL_SIZE + 1
end
```

### 절차적 오디오 (코드로 소리 만들기)

```lua
-- SoundData로 직접 파형 생성
local function generateTone(frequency, duration, volume)
    local sampleRate = 44100
    local samples = math.floor(sampleRate * duration)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)
    
    for i = 0, samples - 1 do
        local t = i / sampleRate
        -- 사인파
        local value = math.sin(2 * math.pi * frequency * t) * volume
        -- 페이드아웃
        local fade = 1 - (i / samples)
        data:setSample(i, value * fade)
    end
    
    return love.audio.newSource(data, "static")
end

local beep = generateTone(440, 0.2, 0.5)   -- A4음, 0.2초
beep:play()
```

## 이미지

```lua
local playerImg, tileImg

function love.load()
    -- 이미지 로딩
    playerImg = love.graphics.newImage("sprites/player.png")
    
    -- 필터 설정 (픽셀아트면 "nearest")
    playerImg:setFilter("nearest", "nearest")   -- 픽셀아트
    -- playerImg:setFilter("linear", "linear")  -- 부드러운 스케일링
end

function love.draw()
    -- 기본 그리기
    love.graphics.draw(playerImg, 100, 200)
    
    -- 전체 파라미터
    love.graphics.draw(
        playerImg,
        x, y,           -- 위치
        angle,           -- 회전 (라디안)
        sx, sy,          -- 스케일
        ox, oy           -- 원점 오프셋 (회전/스케일 기준점)
    )
    
    -- 중심 기준으로 그리기
    local w = playerImg:getWidth()
    local h = playerImg:getHeight()
    love.graphics.draw(playerImg, x, y, angle, 1, 1, w/2, h/2)
end
```

### 스프라이트 시트 (Quad)

```lua
local sheet, quads
local frameW, frameH = 32, 32

function love.load()
    sheet = love.graphics.newImage("sprites/character.png")
    sheet:setFilter("nearest", "nearest")
    
    local sheetW = sheet:getWidth()
    local sheetH = sheet:getHeight()
    
    -- Quad 생성 (스프라이트 시트에서 영역 잘라내기)
    quads = {}
    for y = 0, sheetH - frameH, frameH do
        for x = 0, sheetW - frameW, frameW do
            quads[#quads + 1] = love.graphics.newQuad(
                x, y, frameW, frameH, sheetW, sheetH
            )
        end
    end
end

function love.draw()
    -- 특정 프레임 그리기
    local frame = quads[currentFrame]
    love.graphics.draw(sheet, frame, player.x, player.y)
end
```

### 간단한 애니메이션

```lua
local anim = {
    frames = {},        -- Quad 배열
    frameTime = 0.1,    -- 프레임당 시간
    currentFrame = 1,
    elapsed = 0,
}

function anim:update(dt)
    self.elapsed = self.elapsed + dt
    if self.elapsed >= self.frameTime then
        self.elapsed = self.elapsed - self.frameTime
        self.currentFrame = self.currentFrame % #self.frames + 1
    end
end

function anim:draw(image, x, y)
    love.graphics.draw(image, self.frames[self.currentFrame], x, y)
end
```

## 폰트

```lua
function love.load()
    -- 기본 폰트
    local default = love.graphics.newFont(14)
    
    -- TTF 폰트
    local custom = love.graphics.newFont("fonts/pixel.ttf", 16)
    
    -- BMFont (비트맵 폰트)
    local bitmap = love.graphics.newFont("fonts/bitmap.fnt")
    
    -- 이미지 폰트
    local imgFont = love.graphics.newImageFont(
        "fonts/font.png",
        " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    )
    
    love.graphics.setFont(custom)
end
```

## 파일 시스템

```lua
-- LÖVE2D는 자체 파일 시스템을 사용 (보안 샌드박스)
-- 읽기: 게임 폴더 + save 폴더
-- 쓰기: save 폴더만 가능

-- save 폴더 위치 (conf.lua의 t.identity에 따라 결정)
-- macOS: ~/Library/Application Support/LOVE/<identity>/
-- Windows: %APPDATA%/LOVE/<identity>/

-- 파일 쓰기
love.filesystem.write("save.dat", "score=100\nlevel=5")

-- 파일 읽기
if love.filesystem.getInfo("save.dat") then
    local content = love.filesystem.read("save.dat")
    print(content)
end

-- 디렉토리 생성
love.filesystem.createDirectory("saves")

-- 파일 목록
local files = love.filesystem.getDirectoryItems("sprites")
for _, file in ipairs(files) do
    print(file)
end
```

### 간단한 저장/로드

```lua
-- 저장
local function saveGame(data)
    local parts = {}
    for k, v in pairs(data) do
        parts[#parts + 1] = k .. "=" .. tostring(v)
    end
    love.filesystem.write("save.dat", table.concat(parts, "\n"))
end

-- 로드
local function loadGame()
    if not love.filesystem.getInfo("save.dat") then
        return nil
    end
    local content = love.filesystem.read("save.dat")
    local data = {}
    for line in content:gmatch("[^\n]+") do
        local key, value = line:match("(%w+)=(.+)")
        if key then
            data[key] = tonumber(value) or value
        end
    end
    return data
end

-- 사용
saveGame({score = 1500, level = 3, name = "Hero"})
local data = loadGame()
if data then
    print(data.score, data.level)
end
```

---

## 연습문제

### 연습 14-1: 효과음 시스템
`SoundManager` 모듈을 만들어라:
- `load(name, path, type)`: 사운드 등록
- `play(name)`: 재생 (같은 소리 중복 재생 가능)
- `setVolume(name, vol)`: 개별 볼륨
- `setMasterVolume(vol)`: 마스터 볼륨

### 연습 14-2: 절차적 효과음
코드로 아래 효과음을 생성하라:
1. "피격음": 짧고 날카로운 노이즈 (0.05초)
2. "코인 획득": 올라가는 피치의 사인파 (0.15초)
3. "폭발": 긴 노이즈 + 페이드아웃 (0.5초)

### 연습 14-3: 스프라이트 애니메이션
가상의 4프레임 걷기 애니메이션을 구현하라 (이미지 없이 색 사각형 4개로 대체).
- 이동 중일 때만 애니메이션 재생
- 정지 시 첫 프레임 고정

### 연습 14-4: 저장/로드 시스템
`saveManager.lua` 모듈을 만들어라:
- 테이블을 JSON-like 형식으로 직렬화하여 저장
- 파일에서 읽어 테이블로 복원
- 저장 파일이 없으면 기본값 반환

---

[← 이전: 13. 입력 처리](13_input.md) | [다음: 15. 게임 루프 & 상태머신 →](15_game_loop_pattern.md)

## 모범 답안

### 14-1
`SoundManager.sounds[name] = {src=Source, volume=1}` 구조로 관리하고, `play`는 `clone()` 후 재생하면 중복 재생이 가능하다.

### 14-2
`love.sound.newSoundData`로 샘플을 채운 뒤 `love.audio.newSource(data)`로 재생한다.
- 피격음: 짧은 white-noise
- 코인음: 시간에 따라 주파수 증가하는 sine
- 폭발음: noise * (1 - t)

### 14-3
프레임 인덱스 `frame = floor(animTime * fps) % 4 + 1`, 이동 중일 때만 `animTime` 증가.

### 14-4
`love.filesystem.write/read` 기반으로 직렬화/역직렬화 함수를 만들고, 파일이 없으면 `defaults`를 반환한다.

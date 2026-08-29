# 09. 사운드 & 음악

## Source 타입

| 타입 | 생성 | 메모리 | 용도 |
|------|------|--------|------|
| `"static"` | 전체 로드 | 높음 | 짧은 효과음 (타격, 점프) |
| `"stream"` | 스트리밍 | 낮음 | 긴 BGM |

```lua
local sfx_hit, bgm

function love.load()
    sfx_hit = love.audio.newSource("assets/hit.wav", "static")
    bgm     = love.audio.newSource("assets/bgm.ogg", "stream")
end
```

지원 형식: OGG Vorbis, WAV, MP3, FLAC.
**OGG 권장** (작은 용량, 좋은 품질, 라이센스 자유).

## 재생 / 정지 / 볼륨

```lua
function love.load()
    sfx_hit = love.audio.newSource("assets/hit.wav", "static")
    bgm     = love.audio.newSource("assets/bgm.ogg", "stream")

    bgm:setLooping(true)
    bgm:setVolume(0.5)     -- 0.0 ~ 1.0
    bgm:play()
end

function love.keypressed(key)
    if key == "space" then
        sfx_hit:stop()     -- 이전 재생 중이면 정지 후
        sfx_hit:play()     -- 처음부터 재생
    end

    if key == "m" then
        if bgm:isPlaying() then
            bgm:pause()
        else
            bgm:play()
        end
    end
end
```

## 동시 재생 (같은 효과음 여러 번)

`Source:play()`는 같은 Source를 동시에 재생하지 않는다. 이전 재생을 멈추고 처음부터 시작한다.

동시 재생이 필요하면 `Source:clone()`을 사용한다.

```lua
local sfx_hit

function love.load()
    sfx_hit = love.audio.newSource("assets/hit.wav", "static")
end

local function playSfx(source)
    local s = source:clone()
    s:play()
end

function love.keypressed(key)
    if key == "space" then
        playSfx(sfx_hit)   -- 여러 번 빠르게 눌러도 겹쳐서 재생
    end
end
```

## 피치 / 볼륨 랜덤화

같은 효과음이 반복되면 단조롭다. 약간의 랜덤으로 자연스럽게.

```lua
local function playSfxRandom(source, vol_min, vol_max, pitch_min, pitch_max)
    local s = source:clone()
    s:setVolume(vol_min + math.random() * (vol_max - vol_min))
    s:setPitch(pitch_min + math.random() * (pitch_max - pitch_min))
    s:play()
end

-- 사용: 볼륨 0.8~1.0, 피치 0.9~1.1
playSfxRandom(sfx_hit, 0.8, 1.0, 0.9, 1.1)
```

## 오디오 매니저 패턴

```lua
-- audio_manager.lua
local M = {}

local sources = {}
local master_volume = 1.0
local sfx_volume = 1.0
local bgm_volume = 0.5
local current_bgm

function M.load(name, path, source_type)
    sources[name] = love.audio.newSource(path, source_type or "static")
end

function M.playSfx(name)
    local src = sources[name]
    if not src then return end
    local s = src:clone()
    s:setVolume(sfx_volume * master_volume)
    s:play()
end

function M.playBgm(name)
    if current_bgm then current_bgm:stop() end
    local src = sources[name]
    if not src then return end
    current_bgm = src
    current_bgm:setLooping(true)
    current_bgm:setVolume(bgm_volume * master_volume)
    current_bgm:play()
end

function M.stopBgm()
    if current_bgm then
        current_bgm:stop()
        current_bgm = nil
    end
end

function M.setMasterVolume(v)
    master_volume = v
    if current_bgm then
        current_bgm:setVolume(bgm_volume * master_volume)
    end
end

return M
```

```lua
-- main.lua
local audio = require("audio_manager")

function love.load()
    audio.load("hit", "assets/hit.wav", "static")
    audio.load("bgm_menu", "assets/menu.ogg", "stream")
    audio.playBgm("bgm_menu")
end

function love.keypressed(key)
    if key == "space" then audio.playSfx("hit") end
end
```

## 위치 기반 사운드 (2D 패닝)

```lua
-- 간단한 좌우 패닝
local function playAtPosition(source, src_x, listener_x, screen_w)
    local s = source:clone()
    local pan = (src_x - listener_x) / (screen_w / 2)
    pan = math.max(-1, math.min(1, pan))

    -- 볼륨으로 간이 패닝
    local vol_l = math.max(0, 1 - pan)
    local vol_r = math.max(0, 1 + pan)
    local avg = (vol_l + vol_r) / 2
    s:setVolume(avg)
    s:play()
end
```

## 오디오 파일이 없을 때

개발 중 사운드 파일이 없으면 안전하게 건너뛰도록 한다.

```lua
local function safeSfxLoad(path)
    local ok, src = pcall(love.audio.newSource, path, "static")
    if ok then
        return src
    else
        print("[WARN] Audio not found: " .. path)
        return nil
    end
end

local function safeSfxPlay(src)
    if src then src:clone():play() end
end
```

## 실습: 간단한 드럼 머신

```lua
-- main.lua (사운드 파일 없이 동작 — 화면 표시만)
local pads = {}
local pad_count = 8
local active = {}
local step = 1
local bpm = 120
local timer = 0

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.12)
    for i = 1, pad_count do
        active[i] = false
    end
end

function love.update(dt)
    local beat_duration = 60 / bpm / 2
    timer = timer + dt
    if timer >= beat_duration then
        timer = timer - beat_duration
        step = (step % pad_count) + 1
    end
end

function love.draw()
    local pad_size = 60
    local gap = 15
    local start_x = (800 - (pad_size + gap) * pad_count + gap) / 2

    for i = 1, pad_count do
        local x = start_x + (i - 1) * (pad_size + gap)
        local y = 270

        -- 현재 스텝 하이라이트
        if i == step then
            love.graphics.setColor(1, 1, 0, 0.3)
            love.graphics.rectangle("fill", x - 3, y - 3, pad_size + 6, pad_size + 6, 6)
        end

        -- 패드
        if active[i] then
            love.graphics.setColor(0.3, 0.8, 1)
        else
            love.graphics.setColor(0.25, 0.25, 0.3)
        end
        love.graphics.rectangle("fill", x, y, pad_size, pad_size, 4)

        -- 번호
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(tostring(i), x, y + 20, pad_size, "center")
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(string.format("BPM: %d", bpm), 0, 380, 800, "center")
    love.graphics.printf("1~8: toggle pad  /  UP/DOWN: BPM", 0, 420, 800, "center")
end

function love.keypressed(key)
    local n = tonumber(key)
    if n and n >= 1 and n <= pad_count then
        active[n] = not active[n]
    end
    if key == "up"   then bpm = math.min(240, bpm + 10) end
    if key == "down" then bpm = math.max(40,  bpm - 10) end
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

여러 화면(메뉴, 게임, 게임오버)을 전환하는 씬 관리 시스템을 배운다.

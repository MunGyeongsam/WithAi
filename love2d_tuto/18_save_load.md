# 18. 저장 & 불러오기

## love.filesystem

LÖVE2D는 자체 파일시스템 API를 제공한다.
쓰기는 **save directory**에만 가능 (보안상 게임 폴더 직접 쓰기 불가).

```
Save directory 위치:
- Windows: %APPDATA%/LOVE/<identity>/
- macOS:   ~/Library/Application Support/LOVE/<identity>/
- Linux:   ~/.local/share/love/<identity>/

<identity>는 conf.lua의 t.identity 값이다.
```

## 기본 읽기/쓰기

```lua
-- 텍스트 쓰기
love.filesystem.write("save.txt", "Hello, World!")

-- 텍스트 읽기
local content = love.filesystem.read("save.txt")
print(content)   -- "Hello, World!"

-- 파일 존재 확인
if love.filesystem.getInfo("save.txt") then
    print("파일 있음")
end
```

## 테이블 직렬화 (JSON 없이)

Lua 테이블을 문자열로 변환하여 저장한다.

### 간단한 직렬화

```lua
-- serialize.lua
local M = {}

function M.serialize(t)
    local parts = {}
    parts[#parts + 1] = "return {"
    for k, v in pairs(t) do
        local key
        if type(k) == "number" then
            key = "[" .. k .. "]"
        else
            key = '["' .. tostring(k) .. '"]'
        end

        local value
        if type(v) == "number" then
            value = tostring(v)
        elseif type(v) == "string" then
            value = string.format("%q", v)
        elseif type(v) == "boolean" then
            value = tostring(v)
        elseif type(v) == "table" then
            value = M.serialize(v):gsub("^return ", "")
        else
            value = '"<unsupported>"'
        end

        parts[#parts + 1] = "  " .. key .. " = " .. value .. ","
    end
    parts[#parts + 1] = "}"
    return table.concat(parts, "\n")
end

function M.deserialize(str)
    local fn = loadstring(str)
    if fn then
        setfenv(fn, {})   -- 보안: 빈 환경에서 실행
        return fn()
    end
    return nil
end

return M
```

### 사용

```lua
local ser = require("serialize")

local save_data = {
    score = 1500,
    level = 3,
    player_name = "Hero",
    unlocked = {true, true, false, false},
}

-- 저장
local str = ser.serialize(save_data)
love.filesystem.write("save.lua", str)

-- 불러오기
local content = love.filesystem.read("save.lua")
if content then
    local loaded = ser.deserialize(content)
    print(loaded.score)   -- 1500
end
```

## JSON 방식 (간이 구현)

```lua
-- json_simple.lua (숫자, 문자열, 불리언, 배열, 객체만 지원)
local M = {}

function M.encode(val)
    local t = type(val)
    if t == "number" then
        return tostring(val)
    elseif t == "string" then
        return string.format("%q", val)
    elseif t == "boolean" then
        return val and "true" or "false"
    elseif t == "nil" then
        return "null"
    elseif t == "table" then
        -- 배열인지 확인
        local is_array = #val > 0
        local parts = {}
        if is_array then
            for i = 1, #val do
                parts[i] = M.encode(val[i])
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            for k, v in pairs(val) do
                parts[#parts + 1] = string.format("%q", k) .. ":" .. M.encode(v)
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    end
    return "null"
end

return M
```

## 안전한 세이브/로드 패턴

```lua
-- save_manager.lua
local ser = require("serialize")
local M = {}

local SAVE_FILE = "gamedata.sav"
local BACKUP_FILE = "gamedata.bak"

function M.save(data)
    local str = ser.serialize(data)
    -- 백업 생성
    if love.filesystem.getInfo(SAVE_FILE) then
        local old = love.filesystem.read(SAVE_FILE)
        if old then love.filesystem.write(BACKUP_FILE, old) end
    end
    local ok, err = love.filesystem.write(SAVE_FILE, str)
    return ok, err
end

function M.load()
    local content = love.filesystem.read(SAVE_FILE)
    if content then
        local data = ser.deserialize(content)
        if data then return data end
    end
    -- 메인 파일 손상 시 백업 시도
    content = love.filesystem.read(BACKUP_FILE)
    if content then
        return ser.deserialize(content)
    end
    return nil
end

function M.exists()
    return love.filesystem.getInfo(SAVE_FILE) ~= nil
end

function M.delete()
    love.filesystem.remove(SAVE_FILE)
    love.filesystem.remove(BACKUP_FILE)
end

return M
```

## 설정 저장 (볼륨, 키바인딩 등)

```lua
local default_settings = {
    master_volume = 1.0,
    sfx_volume = 0.8,
    bgm_volume = 0.5,
    fullscreen = false,
}

local function loadSettings()
    local content = love.filesystem.read("settings.lua")
    if content then
        local loaded = ser.deserialize(content)
        if loaded then
            -- 누락된 키는 기본값으로 채움
            for k, v in pairs(default_settings) do
                if loaded[k] == nil then loaded[k] = v end
            end
            return loaded
        end
    end
    return default_settings
end
```

## 실습: 하이스코어 시스템

```lua
-- main.lua
local ser = require("serialize")
local scores = {}
local current_score = 0
local input_name = ""
local state = "playing"  -- "playing" | "enter_name" | "leaderboard"

function love.load()
    scores = loadScores()
end

local function loadScores()
    local content = love.filesystem.read("highscores.lua")
    if content then
        local fn = loadstring(content)
        if fn then
            setfenv(fn, {})
            local data = fn()
            if data then return data end
        end
    end
    return {}
end

local function saveScores()
    local str = ser.serialize(scores)
    love.filesystem.write("highscores.lua", str)
end

local function addScore(name, score)
    scores[#scores + 1] = {name = name, score = score}
    table.sort(scores, function(a, b) return a.score > b.score end)
    -- 상위 10개만 유지
    while #scores > 10 do scores[#scores] = nil end
    saveScores()
end

function love.update(dt)
    if state == "playing" then
        current_score = current_score + dt * 10
    end
end

function love.draw()
    if state == "playing" then
        love.graphics.printf("Playing... Score: " .. math.floor(current_score), 0, 280, 800, "center")
        love.graphics.printf("Press ENTER to finish", 0, 320, 800, "center")
    elseif state == "enter_name" then
        love.graphics.printf("Score: " .. math.floor(current_score), 0, 200, 800, "center")
        love.graphics.printf("Enter name: " .. input_name .. "_", 0, 280, 800, "center")
        love.graphics.printf("Press ENTER to submit", 0, 320, 800, "center")
    elseif state == "leaderboard" then
        love.graphics.printf("=== HIGH SCORES ===", 0, 50, 800, "center")
        for i, entry in ipairs(scores) do
            local text = string.format("%d. %s — %d", i, entry.name, entry.score)
            love.graphics.printf(text, 0, 80 + i * 30, 800, "center")
        end
        love.graphics.printf("Press R to play again", 0, 500, 800, "center")
    end
end

function love.keypressed(key)
    if state == "playing" then
        if key == "return" then
            state = "enter_name"
            input_name = ""
        end
    elseif state == "enter_name" then
        if key == "return" and #input_name > 0 then
            addScore(input_name, math.floor(current_score))
            state = "leaderboard"
        elseif key == "backspace" then
            input_name = input_name:sub(1, -2)
        end
    elseif state == "leaderboard" then
        if key == "r" then
            state = "playing"
            current_score = 0
        end
    end
    if key == "escape" then love.event.quit() end
end

function love.textinput(text)
    if state == "enter_name" and #input_name < 12 then
        input_name = input_name .. text
    end
end
```

## 다음 챕터

터치 입력과 모바일 대응 방법을 배운다.

# 15. 게임 루프 & 상태머신

## 씬 관리 (상태머신)

게임은 여러 "상태"(씬)로 나뉜다: 메뉴, 게임플레이, 게임오버, 설정 등.

```
Unity 비교: SceneManager.LoadScene()
하지만 LÖVE2D에는 씬 매니저가 없으므로 직접 구현한다.
```

### 패턴 1: 단순 상태 변수

```lua
local state = "menu"

function love.update(dt)
    if state == "menu" then
        updateMenu(dt)
    elseif state == "playing" then
        updateGame(dt)
    elseif state == "gameover" then
        updateGameOver(dt)
    end
end

function love.draw()
    if state == "menu" then
        drawMenu()
    elseif state == "playing" then
        drawGame()
    elseif state == "gameover" then
        drawGameOver()
    end
end

-- ⚠️ 문제: 상태가 늘어나면 if-elseif 체인이 거대해진다
```

### 패턴 2: 씬 테이블 (추천)

```lua
-- 각 씬을 모듈로 분리
-- scenes/menu.lua
local Menu = {}

function Menu.enter()
    -- 씬 진입 시 초기화
end

function Menu.update(dt)
    -- ...
end

function Menu.draw()
    love.graphics.printf("PRESS ENTER TO START", 0, 300, 800, "center")
end

function Menu.keypressed(key)
    if key == "return" then
        switchScene("game")
    end
end

function Menu.exit()
    -- 씬 퇴장 시 정리
end

return Menu
```

```lua
-- main.lua
local scenes = {
    menu = require("scenes.menu"),
    game = require("scenes.game"),
    gameover = require("scenes.gameover"),
}

local currentScene

function switchScene(name)
    if currentScene and currentScene.exit then
        currentScene.exit()
    end
    currentScene = scenes[name]
    if currentScene.enter then
        currentScene.enter()
    end
end

function love.load()
    switchScene("menu")
end

function love.update(dt)
    if currentScene.update then
        currentScene.update(dt)
    end
end

function love.draw()
    if currentScene.draw then
        currentScene.draw()
    end
end

function love.keypressed(key, ...)
    if currentScene.keypressed then
        currentScene.keypressed(key, ...)
    end
end
```

### 패턴 3: 씬 스택 (오버레이 지원)

```lua
-- 일시정지 화면처럼 이전 씬 위에 겹치는 경우
local SceneStack = {}
local stack = {}

function SceneStack.push(scene)
    -- 현재 씬 일시정지
    local top = stack[#stack]
    if top and top.pause then top.pause() end
    
    stack[#stack + 1] = scene
    if scene.enter then scene.enter() end
end

function SceneStack.pop()
    local top = stack[#stack]
    if top then
        if top.exit then top.exit() end
        stack[#stack] = nil
        
        -- 이전 씬 재개
        local newTop = stack[#stack]
        if newTop and newTop.resume then newTop.resume() end
    end
end

function SceneStack.replace(scene)
    SceneStack.pop()
    SceneStack.push(scene)
end

function SceneStack.update(dt)
    local top = stack[#stack]
    if top and top.update then top.update(dt) end
end

function SceneStack.draw()
    -- 모든 씬을 아래서부터 그림 (투명 오버레이 지원)
    for i = 1, #stack do
        if stack[i].draw then stack[i].draw() end
    end
end

function SceneStack.keypressed(key, ...)
    local top = stack[#stack]
    if top and top.keypressed then top.keypressed(key, ...) end
end

-- 사용
SceneStack.push(menuScene)        -- 메뉴 표시
SceneStack.replace(gameScene)     -- 게임으로 전환
SceneStack.push(pauseScene)       -- 일시정지 (게임 위에 겹침)
SceneStack.pop()                  -- 일시정지 해제 (게임으로 복귀)
```

## 게임 루프 패턴

### 스포너 (타이머 기반)

```lua
local SpawnManager = {
    timer = 0,
    interval = 2.0,      -- 2초마다 스폰
    minInterval = 0.3,    -- 최소 간격
    elapsed = 0,          -- 총 경과 시간
}

function SpawnManager.update(dt)
    SpawnManager.elapsed = SpawnManager.elapsed + dt
    SpawnManager.timer = SpawnManager.timer + dt
    
    -- 시간에 따라 간격 감소 (난이도 상승)
    local currentInterval = math.max(
        SpawnManager.minInterval,
        SpawnManager.interval - SpawnManager.elapsed * 0.01
    )
    
    if SpawnManager.timer >= currentInterval then
        SpawnManager.timer = SpawnManager.timer - currentInterval
        spawnEnemy()
    end
end
```

### 웨이브 시스템

```lua
local WaveManager = {
    wave = 0,
    enemiesInWave = 0,
    enemiesKilled = 0,
    state = "waiting",      -- "waiting", "spawning", "clearing"
    timer = 0,
    waveDelay = 3.0,        -- 웨이브 간 대기
}

local waveData = {
    {count = 5,  types = {"slime"}},
    {count = 8,  types = {"slime", "bat"}},
    {count = 12, types = {"slime", "bat", "goblin"}},
}

function WaveManager.update(dt)
    local M = WaveManager
    
    if M.state == "waiting" then
        M.timer = M.timer + dt
        if M.timer >= M.waveDelay then
            M.timer = 0
            M.wave = M.wave + 1
            M.state = "spawning"
            M.enemiesKilled = 0
            
            local data = waveData[math.min(M.wave, #waveData)]
            M.enemiesInWave = data.count
            spawnWave(data)
        end
        
    elseif M.state == "spawning" then
        -- 모든 적이 스폰되면
        M.state = "clearing"
        
    elseif M.state == "clearing" then
        if M.enemiesKilled >= M.enemiesInWave then
            M.state = "waiting"
            M.timer = 0
        end
    end
end

function WaveManager.onEnemyKilled()
    WaveManager.enemiesKilled = WaveManager.enemiesKilled + 1
end
```

### 타이머 유틸리티

```lua
local Timer = {}

local timers = {}

function Timer.after(delay, callback)
    timers[#timers + 1] = {
        delay = delay,
        elapsed = 0,
        callback = callback,
        type = "once",
    }
end

function Timer.every(interval, callback)
    timers[#timers + 1] = {
        delay = interval,
        elapsed = 0,
        callback = callback,
        type = "repeat",
    }
end

function Timer.update(dt)
    for i = #timers, 1, -1 do
        local t = timers[i]
        t.elapsed = t.elapsed + dt
        
        if t.elapsed >= t.delay then
            t.callback()
            
            if t.type == "once" then
                table.remove(timers, i)
            else
                t.elapsed = t.elapsed - t.delay
            end
        end
    end
end

-- 사용
Timer.after(2.0, function()
    print("2초 후 실행!")
end)

Timer.every(1.0, function()
    print("매 1초마다 실행!")
end)
```

## 상태 전이 다이어그램 예시

```
[Menu] --Enter--> [Playing] --Death--> [GameOver]
                     |                     |
                     |--Esc--> [Pause]     |--Enter--> [Menu]
                     |           |
                     |<--Esc-----|
```

---

## 연습문제

### 연습 15-1: 씬 매니저
패턴 2(씬 테이블)를 사용하여 3개의 씬을 구현하라:
- Menu: "Press Enter" 표시, Enter로 Game 전환
- Game: 숫자 카운터 증가, HP가 0이 되면 GameOver 전환
- GameOver: 최종 점수 표시, R로 Menu 전환

### 연습 15-2: 웨이브 시스템
5웨이브 슈팅 게임을 구현하라:
- 각 웨이브마다 적 수 증가
- 모든 적 처치 시 다음 웨이브
- 웨이브 간 3초 쿨다운
- 5웨이브 완료 시 승리 메시지

### 연습 15-3: 타이머 모듈
위의 Timer 유틸리티에 다음을 추가하라:
- `Timer.cancel(id)`: 특정 타이머 취소 (after/every가 id 반환)
- `Timer.tween(duration, obj, target)`: 값을 서서히 변경
  예: `Timer.tween(1.0, player, {x = 500, y = 300})`

### 연습 15-4: 씬 스택 + 일시정지
씬 스택 패턴을 사용하여:
- Game 씬 위에 Pause 씬을 push
- Pause 씬은 반투명 검은 배경 + "PAUSED" 텍스트
- Game 씬의 배경이 보여야 함 (스택 전체 draw)

---

[← 이전: 14. 오디오 & 리소스](14_audio_and_assets.md) | [다음: 16. 엔티티 관리 →](16_entity_management.md)

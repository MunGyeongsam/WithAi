# 18. 코루틴 활용

> C#의 `IEnumerator` / `yield return` / `async-await`와 같은 역할.  
> 게임에서 순차적 연출, 보스 패턴, 대화 시스템에 필수.

## 코루틴 기본

```lua
-- 코루틴 = 중단·재개 가능한 함수
local function myCoroutine()
    print("Step 1")
    coroutine.yield()       -- 여기서 중단
    print("Step 2")
    coroutine.yield()       -- 여기서 중단
    print("Step 3")         -- 마지막 (자동 종료)
end

local co = coroutine.create(myCoroutine)

coroutine.resume(co)   -- "Step 1" 출력 후 중단
coroutine.resume(co)   -- "Step 2" 출력 후 중단
coroutine.resume(co)   -- "Step 3" 출력 후 종료

print(coroutine.status(co))  -- "dead"
```

```
-- C# 비교:
-- IEnumerator MyCoroutine() {
--     Debug.Log("Step 1");
--     yield return null;        ← coroutine.yield()
--     Debug.Log("Step 2");
--     yield return null;
--     Debug.Log("Step 3");
-- }
-- StartCoroutine(MyCoroutine());
```

## 값 주고받기

```lua
-- yield로 값 반환, resume으로 값 전달
local function producer()
    local i = 0
    while true do
        i = i + 1
        local input = coroutine.yield(i)  -- i를 반환하고, 재개 시 input 받음
        print("Received: " .. tostring(input))
    end
end

local co = coroutine.create(producer)
local ok, value = coroutine.resume(co)          -- ok=true, value=1
local ok, value = coroutine.resume(co, "hello") -- "Received: hello", value=2
local ok, value = coroutine.resume(co, "world") -- "Received: world", value=3
```

## 게임용 코루틴 래퍼

```lua
-- 매 프레임 resume하는 코루틴 매니저
local CoroutineManager = {}
local routines = {}

function CoroutineManager.start(func)
    local co = coroutine.create(func)
    routines[#routines + 1] = co
    return co
end

function CoroutineManager.update(dt)
    for i = #routines, 1, -1 do
        local co = routines[i]
        if coroutine.status(co) == "dead" then
            table.remove(routines, i)
        else
            local ok, err = coroutine.resume(co, dt)
            if not ok then
                print("Coroutine error: " .. tostring(err))
                table.remove(routines, i)
            end
        end
    end
end

-- 유틸리티 함수들
local function wait(seconds)
    local elapsed = 0
    while elapsed < seconds do
        elapsed = elapsed + coroutine.yield()   -- dt를 받음
    end
end

local function waitFrames(count)
    for i = 1, count do
        coroutine.yield()
    end
end

local function waitUntil(condition)
    while not condition() do
        coroutine.yield()
    end
end
```

## 보스 패턴 (가장 강력한 활용)

```lua
local function bossPattern(boss)
    -- Phase 1: 탄막
    for i = 1, 3 do
        boss:fireSpiral(12)       -- 나선형 12발
        wait(1.0)
    end
    
    -- Phase 2: 돌진
    boss:telegraphAttack(1.5)     -- 1.5초 예고
    wait(1.5)
    boss:dashToPlayer()
    wait(0.5)
    
    -- Phase 3: 원형 폭발
    boss:chargeUp(2.0)
    wait(2.0)
    boss:circleExplosion(36)      -- 원형 36발
    wait(1.0)
end

-- 보스 AI 코루틴
local function bossAI(boss)
    while boss.hp > 0 do
        bossPattern(boss)      -- 패턴 반복
        
        if boss.hp < boss.maxHp * 0.5 then
            -- 체력 50% 이하: 발광 패턴 추가
            boss:enrage()
            wait(0.5)
        end
    end
    
    -- 사망 연출
    boss:playDeathAnimation()
    wait(2.0)
    switchScene("victory")
end

-- C# 비교:
-- IEnumerator BossAI() {
--     while (boss.hp > 0) {
--         yield return StartCoroutine(BossPattern());
--         if (boss.hp < boss.maxHp * 0.5f)
--             yield return StartCoroutine(Enrage());
--     }
--     yield return StartCoroutine(DeathAnimation());
-- }
```

## 연출 시퀀스

```lua
-- 게임 시작 연출
local function introSequence()
    -- 화면 페이드인
    fadeIn(1.0)
    wait(1.0)
    
    -- 텍스트 타이핑 효과
    showText("Stage 1: The Beginning")
    wait(2.0)
    
    -- 플레이어 등장
    local player = spawnPlayer(-50, 300)
    
    -- 플레이어 슬라이드 인
    local startX = -50
    local endX = 100
    local duration = 1.0
    local elapsed = 0
    
    while elapsed < duration do
        local dt = coroutine.yield()
        elapsed = elapsed + dt
        local t = math.min(elapsed / duration, 1)
        -- 이징: ease-out cubic
        t = 1 - (1 - t) ^ 3
        player.x = startX + (endX - startX) * t
    end
    
    wait(0.5)
    hideText()
    
    -- 게임 시작
    gameState = "playing"
end

CoroutineManager.start(introSequence)
```

## 트윈 (코루틴 기반)

```lua
-- 값을 점진적으로 변경
local function tween(obj, target, duration, easingFunc)
    local start = {}
    for k, v in pairs(target) do
        start[k] = obj[k]
    end
    
    local elapsed = 0
    while elapsed < duration do
        local dt = coroutine.yield()
        elapsed = elapsed + dt
        local t = math.min(elapsed / duration, 1)
        
        -- 이징 적용
        if easingFunc then
            t = easingFunc(t)
        end
        
        for k, targetValue in pairs(target) do
            obj[k] = start[k] + (targetValue - start[k]) * t
        end
    end
    
    -- 최종값 보정
    for k, v in pairs(target) do
        obj[k] = v
    end
end

-- 이징 함수들
local Easing = {}

function Easing.linear(t) return t end

function Easing.easeInQuad(t) return t * t end

function Easing.easeOutQuad(t) return t * (2 - t) end

function Easing.easeInOutQuad(t)
    if t < 0.5 then return 2 * t * t end
    return -1 + (4 - 2 * t) * t
end

function Easing.easeOutBounce(t)
    if t < 1/2.75 then
        return 7.5625 * t * t
    elseif t < 2/2.75 then
        t = t - 1.5/2.75
        return 7.5625 * t * t + 0.75
    elseif t < 2.5/2.75 then
        t = t - 2.25/2.75
        return 7.5625 * t * t + 0.9375
    else
        t = t - 2.625/2.75
        return 7.5625 * t * t + 0.984375
    end
end

-- 사용
CoroutineManager.start(function()
    -- 오브젝트를 (500, 200)으로 1초간 이동 (ease-out)
    tween(myObject, {x = 500, y = 200}, 1.0, Easing.easeOutQuad)
    
    -- 0.5초 대기
    wait(0.5)
    
    -- 투명하게 1초간 페이드아웃
    tween(myObject, {alpha = 0}, 1.0, Easing.linear)
end)
```

## 대화 시스템

```lua
local DialogueBox = {
    text = "",
    visible = false,
    charIndex = 0,
    speed = 30,     -- 초당 글자 수
}

local function showDialogue(lines)
    DialogueBox.visible = true
    
    for _, line in ipairs(lines) do
        DialogueBox.text = line
        DialogueBox.charIndex = 0
        
        -- 타이핑 효과
        local totalChars = #line
        while DialogueBox.charIndex < totalChars do
            local dt = coroutine.yield()
            DialogueBox.charIndex = DialogueBox.charIndex + DialogueBox.speed * dt
        end
        DialogueBox.charIndex = totalChars
        
        -- 플레이어 입력 대기
        waitUntil(function()
            return love.keyboard.isDown("space")
        end)
        wait(0.1)   -- 디바운스
    end
    
    DialogueBox.visible = false
end

-- 사용
CoroutineManager.start(function()
    showDialogue({
        "Welcome, brave warrior.",
        "The dungeon awaits you.",
        "Good luck!",
    })
end)

-- 그리기
function DialogueBox.draw()
    if not DialogueBox.visible then return end
    
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 50, 400, 700, 150, 10)
    
    love.graphics.setColor(1, 1, 1)
    local displayText = string.sub(DialogueBox.text, 1, math.floor(DialogueBox.charIndex))
    love.graphics.printf(displayText, 70, 420, 660)
end
```

## 코루틴 vs 상태머신 비교

```lua
-- 같은 보스 패턴을 상태머신으로 구현하면:
-- (코루틴 대비 코드량 2~3배, 가독성 하락)

local BossFSM = {
    state = "spiral",
    timer = 0,
    shotCount = 0,
}

function BossFSM.update(dt)
    BossFSM.timer = BossFSM.timer + dt
    
    if BossFSM.state == "spiral" then
        if BossFSM.timer >= 1.0 then
            boss:fireSpiral(12)
            BossFSM.shotCount = BossFSM.shotCount + 1
            BossFSM.timer = 0
            if BossFSM.shotCount >= 3 then
                BossFSM.state = "telegraph"
                BossFSM.timer = 0
                BossFSM.shotCount = 0
            end
        end
    elseif BossFSM.state == "telegraph" then
        -- ... 계속 ...
    end
end

-- 코루틴 버전이 순차적으로 읽히는 반면,
-- 상태머신은 각 상태가 분리되어 흐름 파악이 어렵다.
-- → 순차적 패턴에는 코루틴, 병렬 상태에는 상태머신
```

---

## 연습문제

### 연습 18-1: 기본 코루틴
아래 동작을 코루틴으로 구현하라:
1. "3..." 출력 후 1초 대기
2. "2..." 출력 후 1초 대기
3. "1..." 출력 후 1초 대기
4. "GO!" 출력

### 연습 18-2: 보스 패턴
3가지 공격 패턴을 가진 보스를 코루틴으로 구현하라:
- 패턴 A: 전방 5연발 (0.2초 간격)
- 패턴 B: 원형 8방향 (1초 차지 → 발사)
- 패턴 C: 플레이어 추적 돌진 (1초 텔레그래프 → 돌진 → 0.5초 경직)
- 랜덤 순서로 패턴 반복

### 연습 18-3: 트윈 시스템
위의 트윈을 활용하여:
- 적이 죽을 때 커지면서 사라지는 연출 (scale up + fade out)
- 점수 텍스트가 위로 떠오르며 사라지는 연출
- 보스 등장 시 화면 쉐이크 효과

### 연습 18-4: 대화 시스템 확장
위의 대화 시스템에 추가하라:
- 말하는 캐릭터 이름 표시
- 텍스트 속도 조절 (특수 태그: `{slow}`, `{fast}`)
- Space로 타이핑 스킵 (즉시 전체 표시)

---

[← 이전: 17. 충돌 처리](17_collision.md) | [다음: 19. ECS 패턴 입문 →](19_ecs_intro.md)

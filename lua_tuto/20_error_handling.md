# 20. 에러 처리

## Lua의 에러 모델

```lua
-- Lua에는 try-catch가 없다 ⚠️
-- 대신 pcall (protected call) / xpcall 을 사용

-- 에러 발생
error("something went wrong")           -- 문자열 메시지
error("bad value: " .. tostring(x))     -- 포맷된 메시지
error({code = 404, msg = "not found"})  -- 테이블도 가능

-- assert (조건이 false/nil이면 에러)
local file = assert(io.open("data.txt", "r"), "파일 열기 실패")
local n = assert(tonumber(input), "숫자가 아닙니다: " .. tostring(input))
```

## pcall — Protected Call

```lua
-- C#의 try-catch와 유사
-- 에러가 발생해도 프로그램이 중단되지 않는다

local ok, result = pcall(function()
    -- 위험한 코드
    return riskyOperation()
end)

if ok then
    print("성공: " .. tostring(result))
else
    print("에러: " .. tostring(result))   -- result에 에러 메시지
end

-- 인자 전달
local ok, result = pcall(riskyFunction, arg1, arg2)

-- C# 비교:
-- try {
--     var result = RiskyOperation();
-- } catch (Exception e) {
--     Console.WriteLine("에러: " + e.Message);
-- }
```

## xpcall — 스택 트레이스 포함

```lua
-- pcall + 에러 핸들러 함수
local function errorHandler(err)
    -- 스택 트레이스 추가
    return debug.traceback(err, 2)
end

local ok, result = xpcall(function()
    error("boom!")
end, errorHandler)

if not ok then
    print(result)
    -- 출력:
    -- boom!
    -- stack traceback:
    --     main.lua:3: in function <main.lua:2>
    --     ...
end
```

## 게임에서의 에러 처리 패턴

### 안전한 모듈 로딩

```lua
local function safeRequire(moduleName)
    local ok, module = pcall(require, moduleName)
    if ok then
        return module
    else
        print("[WARN] Failed to load module: " .. moduleName)
        print("  " .. tostring(module))
        return nil
    end
end

-- 선택적 모듈 로딩
local debugUI = safeRequire("debug_ui")    -- 없어도 게임 동작
local analytics = safeRequire("analytics") -- 선택적 기능
```

### 안전한 콜백 실행

```lua
-- 이벤트 핸들러가 에러를 내도 다른 핸들러는 계속 실행
local function safeCall(func, ...)
    local ok, err = pcall(func, ...)
    if not ok then
        print("[ERROR] " .. tostring(err))
    end
    return ok
end

function EventSystem.emit(event, ...)
    local handlers = listeners[event]
    if handlers then
        for i = 1, #handlers do
            safeCall(handlers[i], ...)    -- 하나가 실패해도 나머지 실행
        end
    end
end
```

### 세이브 데이터 검증

```lua
local function loadSaveData(path)
    -- 파일 존재 확인
    if not love.filesystem.getInfo(path) then
        return nil, "파일 없음"
    end
    
    -- 파일 읽기
    local content, err = love.filesystem.read(path)
    if not content then
        return nil, "읽기 실패: " .. tostring(err)
    end
    
    -- 파싱 (pcall로 보호)
    local ok, data = pcall(function()
        return deserialize(content)
    end)
    
    if not ok then
        return nil, "파싱 실패: " .. tostring(data)
    end
    
    -- 데이터 검증
    if type(data) ~= "table" then
        return nil, "잘못된 데이터 형식"
    end
    
    if not data.version then
        return nil, "버전 정보 없음"
    end
    
    return data
end

-- 사용
local data, err = loadSaveData("save.dat")
if data then
    applyLoadedData(data)
else
    print("[WARN] 세이브 로드 실패: " .. err)
    useDefaultData()
end
```

## 방어적 프로그래밍 패턴

### nil 안전 접근

```lua
-- 나쁜 예: nil이면 크래시
local hp = entity.health.current    -- entity.health가 nil이면 에러!

-- 좋은 예: nil 체크
local hp = entity.health and entity.health.current or 0

-- 더 좋은 예: 함수로 추상화
local function safeGet(t, ...)
    for i = 1, select("#", ...) do
        if type(t) ~= "table" then return nil end
        t = t[select(i, ...)]
    end
    return t
end

local hp = safeGet(entity, "health", "current") or 0
```

### 기본값 패턴

```lua
-- 함수 인자 기본값
local function createEnemy(config)
    config = config or {}
    
    local enemy = {
        x = config.x or 0,
        y = config.y or 0,
        hp = config.hp or 100,
        speed = config.speed or 50,
        name = config.name or "Unknown",
    }
    
    return enemy
end

-- nil을 넘겨도 안전
local e = createEnemy()
local e = createEnemy({x = 100})
local e = createEnemy({x = 100, hp = 200})
```

### 타입 검증 (시스템 경계)

```lua
-- 외부 입력이나 모듈 경계에서만 타입 검사
-- 내부 핫패스에서는 하지 않는다 (성능)

local function setDamage(entity, amount)
    -- 시스템 경계: 타입 검증
    assert(type(entity) == "table", "entity must be a table")
    assert(type(amount) == "number", "amount must be a number")
    assert(amount >= 0, "amount must be non-negative")
    
    entity.hp = entity.hp - amount
end
```

## debug 라이브러리

```lua
-- 디버깅 시에만 사용. 프로덕션에서는 비활성화!

-- 스택 트레이스
print(debug.traceback("여기서 호출됨"))

-- 현재 실행 위치
local info = debug.getinfo(1, "Sl")
print(info.source, info.currentline)

-- 지역 변수 조사
local name, value = debug.getlocal(1, 1)  -- 첫 번째 지역 변수
print(name, value)

-- upvalue 조사
local name, value = debug.getupvalue(someFunction, 1)

-- ⚠️ debug 라이브러리는 성능 비용이 크다
-- 프로덕션에서는 사용하지 않는다
```

## LÖVE2D 에러 화면 커스터마이즈

```lua
-- love.errhand를 오버라이드하면 에러 화면을 커스터마이즈할 수 있다
function love.errorhandler(msg)
    -- 에러 로그 저장
    local trace = debug.traceback(tostring(msg), 2)
    pcall(love.filesystem.write, "error.log", trace)
    
    -- 기본 에러 화면 사용
    return love.errhand(msg)
end
```

---

## 연습문제

### 연습 20-1: 안전한 JSON 파서
문자열을 Lua 테이블로 변환하는 간단한 파서를 작성하라. (key=value 형식)
pcall로 감싸서 잘못된 입력에도 크래시하지 않게 만들어라.

```lua
local data, err = safeParse("name=Hero,hp=100,level=5")
-- data = {name = "Hero", hp = 100, level = 5}

local data, err = safeParse("invalid!!!")
-- data = nil, err = "파싱 에러: ..."
```

### 연습 20-2: 에러 로거
에러 발생 시 자동으로 파일에 기록하는 모듈을 만들어라:
- 에러 메시지 + 스택 트레이스 + 타임스탬프
- 파일: `error.log`
- 최대 100개 에러까지만 기록 (무한 증가 방지)

### 연습 20-3: 방어적 ECS
19장의 ECS에 에러 처리를 추가하라:
- 없는 엔티티에 컴포넌트 추가 시도 → 경고 로그
- 없는 컴포넌트 접근 → nil 반환 (에러 아님)
- 시스템 실행 중 에러 → 해당 시스템만 스킵, 나머지 계속 실행

### 연습 20-4: 에러 복구
게임 루프에서 에러가 발생했을 때:
1. 에러를 로그에 기록
2. 현재 씬을 안전 모드로 전환 (빈 화면 + 에러 메시지)
3. 키 입력으로 메인 메뉴로 복구
이 시스템을 구현하라.

---

[← 이전: 19. ECS 패턴](19_ecs_intro.md) | [다음: 21. 성능 최적화 →](21_performance.md)

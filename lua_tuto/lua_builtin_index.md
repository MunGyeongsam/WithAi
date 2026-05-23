# Lua 5.1 기본 함수와 표준 라이브러리 색인

> 대상: Lua 5.1.5 (LÖVE2D 11.x의 LuaJIT 환경 기준)
> 
> 목적: "이름을 아는데 어디에 있는지" 빠르게 찾는 인덱스.

---

## 우선순위 색인 (자주 쓰임 + 중요도)

기준:
- 사용 빈도: 매우 높음 / 높음 / 보통 / 낮음
- 중요도: 필수 / 중요 / 보조

| 순위 | 함수/모듈 | 사용 빈도 | 중요도 | 왜 먼저 익히나 |
|---|---|---|---|---|
| 1 | type, tostring, tonumber | 매우 높음 | 필수 | 값 검증/출력/변환의 기본 |
| 2 | pairs, ipairs, next | 매우 높음 | 필수 | 테이블 순회는 Lua 핵심 |
| 3 | require, package.loaded | 매우 높음 | 필수 | 모듈 구조와 재사용의 시작점 |
| 4 | table.insert, table.remove, table.sort, table.concat | 매우 높음 | 필수 | 배열 관리와 문자열 결합 실무 빈도 높음 |
| 5 | string.format, string.match, string.gmatch, string.gsub, string.sub | 매우 높음 | 필수 | 로그/파싱/UI 문자열 처리 핵심 |
| 6 | math.min, math.max, math.floor, math.ceil, math.sqrt, math.random | 매우 높음 | 필수 | 이동/충돌/랜덤 등 게임 로직 기본 연산 |
| 7 | pcall, xpcall, error, assert | 높음 | 중요 | 런타임 안정성과 에러 복구 |
| 8 | setmetatable, getmetatable, rawget, rawset | 높음 | 중요 | OOP/메타프로그래밍/성능 제어 |
| 9 | coroutine.create, coroutine.resume, coroutine.yield | 보통 | 중요 | 컷신/패턴/시퀀스 제어 |
| 10 | collectgarbage | 보통 | 중요 | GC 튜닝/디버깅 |
| 11 | io.open, io.read, io.write / os.time, os.date | 보통 | 보조 | 일반 Lua 스크립트에서는 중요, LÖVE에서는 대체 가능 |
| 12 | debug.traceback, debug.getinfo | 낮음 | 보조 | 디버그 전용. 배포 코드 직접 사용은 최소화 |

LÖVE2D 메모:
- 파일 I/O는 io/os보다 love.filesystem 우선.
- 핫패스에서는 string 연산과 debug 호출을 최소화.

---

## 핵심 함수 상세 설명과 예시

아래는 우선순위 상위 항목부터 정리한 상세 레퍼런스다.

### 1) type, tostring, tonumber

- type(v): 값의 런타임 타입 문자열을 반환한다.
- tostring(v): 값을 사람이 읽기 쉬운 문자열로 변환한다.
- tonumber(v, base): 문자열을 숫자로 변환한다. base를 주면 진법 변환도 가능하다.

```lua
local v = "42"
print(type(v))            -- string
print(tonumber(v) + 8)    -- 50
print(tostring(true))     -- true
print(tonumber("FF", 16)) -- 255
```

### 2) pairs, ipairs, next

- ipairs(t): 1부터 연속된 배열 파트를 순회한다.
- pairs(t): 키-값 전체를 순회한다.
- next(t, key): 다음 키를 수동으로 얻는다.

```lua
local t = {"a", "b", hp = 100}

for i, v in ipairs(t) do
	print(i, v)           -- 1 a / 2 b
end

for k, v in pairs(t) do
	print(k, v)           -- 순서는 보장되지 않음
end

local k, v = next(t, nil)
print(k, v)               -- 첫 키-값 (순서 비보장)
```

### 3) require, package.loaded

- require(name): 모듈을 1회 로드하고 캐시된 값을 반환한다.
- package.loaded[name]: 모듈 캐시 테이블.

```lua
local utils = require("utils")
local sameUtils = require("utils")
print(utils == sameUtils) -- true

package.loaded["utils"] = nil
local reloaded = require("utils")
print(utils == reloaded)  -- false (재로드)
```

### 4) table.insert, table.remove, table.sort, table.concat

- table.insert(t, v): 끝에 삽입.
- table.remove(t, i): 인덱스 i 제거 후 당김.
- table.sort(t, comp): 비교 함수 기준 정렬.
- table.concat(t, sep): 문자열 배열 결합.

```lua
local scores = {30, 10, 20}
table.insert(scores, 40)
table.sort(scores, function(a, b) return a > b end)
local removed = table.remove(scores, 2)
print(removed)                        -- 30
print(table.concat({"A", "B", "C"}, ",")) -- A,B,C
```

### 5) string.format, string.match, string.gmatch, string.gsub, string.sub

- string.format: 포맷 문자열 생성.
- string.match: 첫 매칭 1개 추출.
- string.gmatch: 반복 매칭.
- string.gsub: 치환.
- string.sub: 부분 문자열.

```lua
local name, hp = "Hero", 87
print(string.format("%s HP:%d", name, hp))

local s = "Player[Lv.15] HP:80/100"
local n, lv = string.match(s, "([%a_]+)%[Lv%.(%d+)%]")
print(n, lv)                          -- Player 15

for hex in string.gmatch("#FF0000 #00FF00", "#%x%x%x%x%x%x") do
	print(hex)
end

print(string.gsub("a-b-c", "-", "/")) -- a/b/c
print(string.sub("abcdef", 2, 4))       -- bcd
```

### 6) math.min, math.max, math.floor, math.ceil, math.sqrt, math.random

- math.min/max: 범위 제한에 자주 사용.
- math.floor/ceil: 좌표 정수화.
- math.sqrt: 거리 계산.
- math.random: 난수.

```lua
local x = 12.7
print(math.floor(x), math.ceil(x))   -- 12 13

local hp = 120
hp = math.max(0, math.min(100, hp))
print(hp)                             -- 100

local dx, dy = 3, 4
print(math.sqrt(dx * dx + dy * dy))   -- 5

math.randomseed(os.time())
print(math.random(1, 10))
```

### 7) pcall, xpcall, error, assert

- assert(cond, msg): 조건 실패 시 즉시 에러.
- error(msg): 직접 에러 발생.
- pcall(fn): 에러를 잡고 false, err 반환.
- xpcall(fn, handler): 핸들러로 에러 가공 가능.

```lua
local function div(a, b)
	assert(b ~= 0, "division by zero")
	return a / b
end

local ok, result = pcall(div, 10, 0)
print(ok, result) -- false, error message

local ok2, msg = xpcall(function()
	error("boom")
end, function(err)
	return "captured: " .. tostring(err)
end)
print(ok2, msg)   -- false, captured: boom
```

### 8) setmetatable, getmetatable, rawget, rawset

- setmetatable/getmetatable: 동작 커스터마이징의 핵심.
- rawget/rawset: __index, __newindex를 우회.

```lua
local defaults = {hp = 100}
local player = {}

setmetatable(player, {
	__index = defaults,
	__newindex = function(t, k, v)
		print("set", k, v)
		rawset(t, k, v)
	end,
})

print(player.hp)         -- 100 (__index)
player.hp = 80           -- __newindex 호출
print(rawget(player, "hp")) -- 80
print(getmetatable(player) ~= nil) -- true
```

### 9) coroutine.create, coroutine.resume, coroutine.yield

- 긴 절차를 프레임 단위로 나눠 실행할 때 유용하다.

```lua
local co = coroutine.create(function()
	print("3")
	coroutine.yield()
	print("2")
	coroutine.yield()
	print("1")
end)

coroutine.resume(co) -- 3
coroutine.resume(co) -- 2
coroutine.resume(co) -- 1
```

---

## 전역 기본 함수

| 이름 | 용도 |
|---|---|
| assert(v, message) | 조건이 거짓이면 에러 발생 |
| collectgarbage(opt, arg) | GC 제어/메모리 확인 |
| dofile(path) | 파일을 로드하고 즉시 실행 |
| error(message, level) | 에러 발생 |
| getfenv(fn) | 함수/스레드 환경 테이블 조회 (5.1) |
| getmetatable(v) | 메타테이블 조회 |
| ipairs(t) | 배열 파트 1부터 순회 |
| load(func, chunkname) | reader 함수 기반 청크 로드 |
| loadfile(path) | 파일에서 청크 로드 |
| loadstring(src, chunkname) | 문자열 코드 로드 |
| next(t, key) | 테이블 다음 키 조회 |
| pairs(t) | 테이블 전체 순회 |
| pcall(fn, ...) | 보호 호출 (성공여부, 결과 반환) |
| print(...) | 디버그 출력 |
| rawequal(a, b) | 메타메서드 무시 동등 비교 |
| rawget(t, k) | 메타메서드 무시 읽기 |
| rawset(t, k, v) | 메타메서드 무시 쓰기 |
| select(index, ...) | 가변 인자 선택 |
| setfenv(fn, env) | 함수 환경 변경 (5.1) |
| setmetatable(t, mt) | 메타테이블 설정 |
| tonumber(v, base) | 숫자 변환 |
| tostring(v) | 문자열 변환 |
| type(v) | 타입 문자열 반환 |
| unpack(t, i, j) | 배열 풀기 (Lua 5.1 전역) |
| xpcall(fn, errHandler) | 에러 핸들러 포함 보호 호출 |

전역 상수:
- _G: 전역 환경 테이블
- _VERSION: Lua 버전 문자열

---

## coroutine 라이브러리

| 이름 | 용도 |
|---|---|
| coroutine.create(f) | 코루틴 생성 |
| coroutine.resume(co, ...) | 코루틴 재개 |
| coroutine.running() | 현재 코루틴 반환 |
| coroutine.status(co) | 상태 조회 (running/suspended/dead) |
| coroutine.wrap(f) | resume 래핑 함수 생성 |
| coroutine.yield(...) | 실행 양보 |

---

## string 라이브러리

| 이름 | 용도 |
|---|---|
| string.byte(s, i, j) | 문자 코드 조회 |
| string.char(...) | 문자 코드 -> 문자열 |
| string.find(s, pattern, init, plain) | 패턴/문자열 검색 |
| string.format(fmt, ...) | 포맷 문자열 |
| string.gmatch(s, pattern) | 반복 매칭 이터레이터 |
| string.gsub(s, pattern, repl, n) | 치환 |
| string.len(s) | 길이 |
| string.lower(s) | 소문자 |
| string.match(s, pattern, init) | 단일 매칭 |
| string.rep(s, n) | 반복 문자열 |
| string.reverse(s) | 뒤집기 |
| string.sub(s, i, j) | 부분 문자열 |
| string.upper(s) | 대문자 |

메서드 문법 예:
- s:sub(1, 3) 는 string.sub(s, 1, 3) 와 동일.

---

## table 라이브러리

| 이름 | 용도 |
|---|---|
| table.concat(t, sep, i, j) | 배열 문자열 결합 |
| table.insert(t, pos, v) | 삽입 |
| table.maxn(t) | 최대 숫자 키 조회 (5.1 구식) |
| table.remove(t, pos) | 제거 |
| table.sort(t, comp) | 정렬 |

---

## math 라이브러리

| 이름 | 용도 |
|---|---|
| math.abs(x) | 절대값 |
| math.acos(x), math.asin(x), math.atan(x) | 역삼각 함수 |
| math.atan2(y, x) | 2인자 atan (LuaJIT/Lua 5.1 계열에서 사용 가능) |
| math.ceil(x), math.floor(x) | 올림/내림 |
| math.cos(x), math.sin(x), math.tan(x) | 삼각 함수 |
| math.deg(x), math.rad(x) | 라디안/도 변환 |
| math.exp(x), math.log(x), math.log10(x) | 지수/로그 |
| math.fmod(x, y), math.modf(x) | 나머지/정수소수 분리 |
| math.frexp(x), math.ldexp(x) | 부동소수 분해/구성 |
| math.max(...), math.min(...) | 최대/최소 |
| math.pow(x, y), x ^ y | 거듭제곱 |
| math.random([m [, n]]) | 난수 |
| math.randomseed(seed) | 난수 시드 |
| math.sqrt(x) | 제곱근 |
| math.huge, math.pi | 상수 |

---

## io 라이브러리

| 이름 | 용도 |
|---|---|
| io.open(path, mode) | 파일 열기 |
| io.close(file) | 파일 닫기 |
| io.read(...), io.write(...) | 표준 입출력 |
| io.input([file]), io.output([file]) | 기본 입출력 대상 설정 |
| io.lines([path]) | 줄 단위 반복 |
| io.flush() | 출력 버퍼 비우기 |
| io.tmpfile() | 임시 파일 |
| io.type(obj) | 파일 핸들 타입 확인 |
| io.popen(prog, mode) | 프로세스 파이프 (플랫폼 주의) |

게임 프로젝트에서는 io 대신 love.filesystem 사용이 더 안전하고 이식성이 좋다.

---

## os 라이브러리

| 이름 | 용도 |
|---|---|
| os.clock() | CPU 시간 |
| os.date(fmt, time) | 날짜/시간 문자열 |
| os.difftime(t2, t1) | 시간 차 |
| os.execute(cmd) | 쉘 명령 실행 |
| os.exit([code]) | 프로세스 종료 |
| os.getenv(name) | 환경 변수 |
| os.remove(path), os.rename(old, new) | 파일 삭제/이름 변경 |
| os.setlocale(loc, category) | 로케일 설정 |
| os.time(tbl) | 타임스탬프 생성 |
| os.tmpname() | 임시 파일명 |

---

## package 라이브러리

| 이름 | 용도 |
|---|---|
| require(name) | 모듈 로드 (캐시 사용) |
| package.loaded | 로드된 모듈 캐시 |
| package.path, package.cpath | 검색 경로 |
| package.preload | 사전 등록 로더 |
| package.loadlib(lib, func) | C 라이브러리 로드 |
| package.seeall(moduleTable) | 구식 모듈 패턴 보조 |

---

## debug 라이브러리 (고급)

| 이름 | 용도 |
|---|---|
| debug.traceback([thread,] [msg [,level]]) | 스택 트레이스 생성 |
| debug.getinfo(f, what) | 함수/프레임 메타정보 |
| debug.getlocal(level, i), setlocal(level, i, v) | 로컬 변수 접근 |
| debug.getupvalue(f, i), setupvalue(f, i, v) | 업밸류 접근 |
| debug.sethook(thread, hook, mask, count) | 디버그 훅 |
| debug.getmetatable(v), debug.setmetatable(v, mt) | 메타테이블 조작 |
| debug.getfenv(obj), debug.setfenv(obj, env) | 환경 접근 |

주의: debug 계열은 강력하지만 성능과 안정성에 영향을 줄 수 있어 개발/디버그 모드에서만 권장.

---

## 빠른 찾기

- 문자열 처리: string
- 정렬/배열 조작: table
- 수학/난수: math
- 파일 입출력: io, os
- 모듈 관리: require, package
- 예외 보호: pcall, xpcall
- 메타테이블: getmetatable, setmetatable, rawget, rawset
- 코루틴: coroutine

---

## 실전 메모 (LÖVE2D)

- 파일 저장/로드는 가능한 love.filesystem 사용.
- 프레임 루프에서 빈번한 문자열 생성, debug 함수 호출은 최소화.
- 코어 루프 에러 보호는 xpcall + debug.traceback 패턴이 유용.

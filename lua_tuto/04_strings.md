# 04. 문자열

## 문자열 기본

```lua
-- 문자열 리터럴 3가지
local s1 = "hello"           -- 큰따옴표
local s2 = 'hello'           -- 작은따옴표 (완전히 동일)
local s3 = [[
여러 줄
문자열
]]                           -- 긴 괄호 (raw string)

-- 이스케이프 시퀀스 (C와 동일)
local s4 = "line1\nline2"    -- 줄바꿈
local s5 = "tab\there"       -- 탭
local s6 = "quote: \""       -- 따옴표

-- 긴 괄호는 이스케이프 불필요
local shader = [[
    vec4 color = vec4(1.0, 0.0, 0.0, 1.0);
    // 따옴표나 역슬래시를 자유롭게 쓸 수 있다
]]
```

## 문자열은 불변 (Immutable)

```lua
local s = "hello"
-- s[1] = "H"   -- 에러! C처럼 개별 문자 수정 불가
-- C#의 string과 동일하게 불변

-- 새 문자열을 만들어야 한다
local s2 = "H" .. string.sub(s, 2)  -- "Hello"
```

## 문자열 연결

```lua
-- .. 연산자
local full = "Player" .. " " .. "One"   -- "Player One"

-- ⚠️ 루프에서 .. 반복 사용은 느리다! (매번 새 문자열 생성)
-- 나쁜 예:
local result = ""
for i = 1, 1000 do
    result = result .. tostring(i) .. ","   -- O(n²) ⚠️
end

-- 좋은 예: table.concat 사용
local parts = {}
for i = 1, 1000 do
    parts[i] = tostring(i)
end
local result = table.concat(parts, ",")     -- O(n)

-- C# 비교: StringBuilder와 같은 이유
```

## string 라이브러리

```lua
local s = "Hello, World!"

-- 길이
print(#s)                        -- 13
print(string.len(s))             -- 13

-- 대소문자
print(string.upper(s))           -- "HELLO, WORLD!"
print(string.lower(s))           -- "hello, world!"

-- 부분 문자열 (1-based 인덱스! ⚠️)
print(string.sub(s, 1, 5))      -- "Hello"
print(string.sub(s, 8))         -- "World!"
print(string.sub(s, -6))        -- "World!" (뒤에서 6번째부터)

-- 반복
print(string.rep("ab", 3))      -- "ababab"

-- 뒤집기
print(string.reverse(s))        -- "!dlroW ,olleH"

-- 바이트 / 문자
print(string.byte("A"))         -- 65
print(string.char(65))          -- "A"
```

## string.format — C의 printf

```lua
-- C의 printf/sprintf와 거의 동일!
local name = "Hero"
local hp = 85
local maxHp = 100

print(string.format("Name: %s", name))           -- "Name: Hero"
print(string.format("HP: %d/%d", hp, maxHp))     -- "HP: 85/100"
print(string.format("Ratio: %.2f", hp/maxHp))    -- "Ratio: 0.85"
print(string.format("Hex: 0x%04X", 255))         -- "Hex: 0x00FF"

-- 주요 포맷 지정자 (C와 동일):
-- %d: 정수
-- %f: 실수
-- %s: 문자열
-- %x: 16진수
-- %02d: 2자리 0채움
-- %8.2f: 전체 8자리, 소수점 2자리

-- 게임에서 흔한 사용 예
local msg = string.format("[%s] Damage: %d (%.1f%%)", "CRIT", 150, 12.5)
-- "[CRIT] Damage: 150 (12.5%)"
```

## string.find — 위치 검색 (인덱스가 필요할 때)

```lua
local s = "Hello, World!"

-- 단순 검색: 시작/끝 인덱스 반환
local start, finish = string.find(s, "World")
print(start, finish)   -- 8  12

-- 패턴 검색
local start, finish = string.find(s, "%a+")   -- 첫 번째 단어
print(start, finish)   -- 1  5

-- plain 모드 (패턴 해석 안 함)
-- 패턴 특수문자를 "문자 그대로" 찾고 싶을 때 사용
local text = "price = 9.99"
local dotPos = string.find(text, ".", 1, true)  -- 4번째 인자 = plain
print(dotPos)         -- 10

-- 시작 위치 지정 (3번째 인자)
local s2 = "cat dog cat"
print(string.find(s2, "cat"))       -- 1 3
print(string.find(s2, "cat", 2))    -- 9 11
```

### find vs match 빠른 기준

- `string.find`: "어디에 있는지"(시작/끝 인덱스) 알고 싶을 때
- `string.match`: "무엇이 매칭됐는지"(문자열/캡처값) 뽑고 싶을 때

```lua
local s = "HP=120"

local i, j = string.find(s, "%d+")
print(i, j)                         -- 4 6

local num = string.match(s, "%d+")
print(num)                          -- "120"
```

## 패턴 매칭 — 정규식이 아니다! ⚠️

Lua는 자체 패턴 시스템을 사용한다. 정규식보다 단순하지만 가볍다.

> ⚠️ Lua 패턴은 **바이트 기반**으로 동작한다. 한글 등 멀티바이트 문자에는
> `%a`, `%w` 등이 정상 작동하지 않는다 (UTF-8 라이브러리 필요).

### 문자 클래스

```lua
-- 소문자: 해당 문자 종류 매치
-- 대문자: 해당 문자 종류의 보집합 (나머지 전부)
-- %a: 알파벳 (a-zA-Z)         %A: 알파벳 아닌 것
-- %d: 숫자 (0-9)              %D: 숫자 아닌 것
-- %w: 영숫자 (a-zA-Z0-9)     %W: 영숫자 아닌 것
-- %s: 공백 (스페이스,탭,줄바꿈) %S: 공백 아닌 것
-- %l: 소문자                   %u: 대문자
-- %p: 구두점                   %c: 제어 문자
-- .  : 아무 문자 1개 (줄바꿈 포함)
```

### 문자 집합 (Character Set)

`[...]`로 직접 문자 집합을 정의한다.

```lua
-- [aeiou]: a, e, i, o, u 중 하나
local vowel = string.match("hello", "[aeiou]")
print(vowel)   -- "e" (첫 번째 모음)

-- [0-9]: 범위 지정 (0~9)
-- [a-z]: 소문자 a~z
-- [A-Za-z0-9_]: 식별자 문자

-- [^...]: 보집합 (해당 문자가 아닌 것)
local non_digit = string.match("abc123", "[^%d]+")
print(non_digit)   -- "abc"

-- 집합 안에서 % 이스케이프 사용 가능
-- [%d%s]: 숫자 또는 공백
-- [^%s]: 공백이 아닌 문자
```

### 수량자

```lua
-- *  : 0회 이상 (greedy, 최대한 많이)
-- +  : 1회 이상 (greedy)
-- -  : 0회 이상 (lazy, 최소한으로)
-- ?  : 0 또는 1회

-- greedy vs lazy 차이
local s = "<tag>content</tag>"
print(string.match(s, "<(.+)>"))    -- "tag>content</tag" (greedy: 마지막 >까지)
print(string.match(s, "<(.-)>"))    -- "tag" (lazy: 첫 번째 >에서 멈춤)
```

### 앵커

```lua
-- ^: 문자열 시작 위치
-- $: 문자열 끝 위치

local s = "hello world"
print(string.match(s, "^hello"))   -- "hello" (시작이 hello면 매치)
print(string.match(s, "^world"))   -- nil (시작이 world가 아님)
print(string.match(s, "world$"))   -- "world" (끝이 world면 매치)

-- 전체 문자열이 패턴과 일치하는지 확인
local valid = string.match("123", "^%d+$")   -- 숫자만으로 구성?
print(valid)   -- "123"

local invalid = string.match("12a", "^%d+$")
print(invalid) -- nil
```

### 매직 문자 (이스케이프 필수)

다음 문자들은 패턴에서 특별한 의미를 가진다. 문자 그대로 찾으려면 `%`로 이스케이프:

```lua
-- 매직 문자: ( ) . % + - * ? [ ] ^ $
-- 리터럴로 찾으려면 앞에 % 붙이기

local price = "Total: $9.99"
print(string.match(price, "%$(%d+%.%d+)"))  -- "9.99"
-- %$ → 달러 기호 문자 그대로
-- %d+ → 숫자 1개 이상
-- %. → 점 문자 그대로
-- %d+ → 숫자 1개 이상

-- 괄호를 문자 그대로 찾기
local coord = "(10, 20)"
local x, y = string.match(coord, "%((%d+),%s*(%d+)%)")
print(x, y)   -- 10  20
```

### 캡처 그룹 `()`

괄호로 감싼 부분이 **캡처**되어 별도로 반환된다.

```lua
-- 캡처 없음: 매치된 전체 문자열 반환
print(string.match("id=42", "%a+=%d+"))        -- "id=42"

-- 캡처 있음: 캡처된 부분만 반환
print(string.match("id=42", "(%a+)=(%d+)"))    -- "id"  "42"

-- 캡처는 여러 개 가능 (다중 반환값)
local y, m, d = string.match("2024-01-15", "(%d+)-(%d+)-(%d+)")

-- gsub에서 캡처 참조: %1, %2, ...
local swapped = string.gsub("first-second", "(%a+)-(%a+)", "%2-%1")
print(swapped)   -- "second-first"
```

### %b — 균형 매치 (Balanced Match)

중첩된 괄호 쌍을 매칭한다.

```lua
-- %bxy: x로 시작해서 y로 끝나는 균형 잡힌 부분
local s = "call(a, fn(b, c), d)"
print(string.match(s, "%b()"))   -- "(a, fn(b, c), d)" (중첩 괄호 포함)

-- {} 매치
local json = '{"a": {"b": 1}}'
print(string.match(json, "%b{}"))  -- '{"a": {"b": 1}}'
```

### 정규식과의 차이 요약

```
정규식              Lua 패턴         비고
──────────────────────────────────────────
\d                  %d              이스케이프가 % 사용
[0-9]{3}            %d%d%d          반복 횟수 지정 불가
a|b                 [ab]            | 없음 (집합으로 대체)
(?:...)             (없음)          비캡처 그룹 없음
\b (word boundary)  (없음)          직접 구현 필요
.*? (lazy)          .-              - 가 lazy 수량자
```

### string.match — 첫 번째 매치 추출

```lua
-- 시그니처: string.match(s, pattern [, init])
--   s       : 대상 문자열
--   pattern : Lua 패턴
--   init    : 검색 시작 위치 (기본 1). 음수면 뒤에서부터 셈
--
-- 반환값 규칙:
--   캡처 ()가 없으면 → 매치된 전체 부분문자열
--   캡처 ()가 있으면 → 각 캡처를 다중 반환값으로
--   매치 실패         → nil
```

```lua
-- 기본: 캡처 없이 전체 매치
local whole = string.match("id=AB-12", "%u%u%-%d%d")
print(whole)              -- "AB-12"

-- 캡처: 필요한 부분만 추출
local left, right = string.match("id=AB-12", "(%u%u)%-(%d%d)")
print(left, right)        -- AB  12

-- 날짜 파싱
local year, month, day = string.match("2024-01-15", "(%d+)-(%d+)-(%d+)")
print(year, month, day)   -- 2024  01  15

-- 파일 이름/확장자 분리
local name, ext = string.match("sprite.png", "(.+)%.(%w+)")
print(name, ext)          -- sprite  png

-- init 인자: 특정 위치부터 검색
local s = "aaa 111 bbb 222"
print(string.match(s, "%d+"))       -- "111" (처음부터)
print(string.match(s, "%d+", 10))   -- "222" (10번째 바이트부터)

-- init 음수: 끝에서 n번째부터
print(string.match(s, "%d+", -5))   -- "222"

-- 매치 실패
print(string.match("hello", "%d+")) -- nil
```

> **C# 비교**: `Regex.Match(s, pattern)` → `match.Value` / `match.Groups`에 해당.
> Lua는 별도 Match 객체 없이 캡처를 바로 다중 반환값으로 준다.

### string.gmatch — 모든 매치 반복 (iterator)

```lua
-- 시그니처: string.gmatch(s, pattern)
--   매치될 때마다 캡처(또는 전체 매치)를 yield하는 이터레이터 반환
--   for 루프에서 사용하는 것이 관용
--
-- 반환값 규칙 (match와 동일):
--   캡처 없으면 → 매치된 전체 부분문자열
--   캡처 있으면 → 각 캡처를 다중 반환값으로
```

```lua
-- 단어 순회
for word in string.gmatch("Hello World Lua", "%a+") do
    print(word)    -- Hello → World → Lua
end

-- 숫자 수집
local nums = {}
for n in string.gmatch("x=10 y=20 z=30", "%d+") do
    nums[#nums + 1] = tonumber(n)
end
-- nums = {10, 20, 30}

-- 다중 캡처: key=value 파싱
local logLine = "stage=3 wave=12 hp=85 score=10900"
local kv = {}
for k, v in string.gmatch(logLine, "(%a+)=(%w+)") do
    kv[k] = v
end
-- kv.stage == "3", kv.wave == "12"

-- CSV 분리 (쉼표가 아닌 부분을 매치)
local csv = "apple,banana,,cherry"
local items = {}
for item in string.gmatch(csv .. ",", "([^,]*),") do
    items[#items + 1] = item
end
-- items = {"apple", "banana", "", "cherry"} (빈 필드 보존)

-- 좌표 목록 파싱
local points = {}
for x, y in string.gmatch("(10,20) (30,-5)", "%((%-?%d+),(%-?%d+)%)") do
    points[#points + 1] = { x = tonumber(x), y = tonumber(y) }
end
```

> ⚠️ `gmatch`는 **init 인자가 없다**. 중간부터 검색하려면 `string.sub`로 잘라서 넘긴다.

> **C# 비교**: `Regex.Matches(s, pattern)` → `foreach (Match m in matches)` 에 해당.

### string.gfind 는?

Lua 5.1.5 학습 자료를 보면 `string.gfind`가 보일 때가 있다.

- 현재 표준 문법은 `string.gmatch`
- `string.gfind`는 구버전 코드 또는 일부 호환 빌드에서만 보이는 이름
- 실무/신규 코드에서는 `gmatch`만 사용하면 된다

```lua
-- 권장
for token in string.gmatch("a,b,c", "[^,]+") do
    print(token)
end

-- 구문서에서 gfind를 봤다면 이렇게 읽으면 된다:
-- "gfind == gmatch(호환 별칭)"
```

### find / match / gmatch 선택 가이드

```lua
local line = "enemy#42 hp=150 pos=(12,-3)"

-- 1) 위치가 필요하면 find
local hs, he = string.find(line, "hp=%d+")
print(hs, he)

-- 2) 값 1개(첫 매치)만 필요하면 match
local hp = string.match(line, "hp=(%d+)")
print(hp)                 -- "150"

-- 3) 여러 개를 전부 순회하면 gmatch
for num in string.gmatch(line, "%d+") do
    print(num)            -- 42, 150, 12, 3
end
```

### 자주 하는 실수

- `find` 결과를 문자열로 착각: `find`는 기본적으로 인덱스를 반환
- `%` 이스케이프 누락: 예) 점(`.`)을 문자 그대로 찾으려면 `%.` 또는 `plain=true`
- `gmatch`에서 수정/삭제를 동시에 하려는 패턴: 순회 중 원본 문자열 변경 로직은 피하고, 결과를 별도 테이블에 수집
- `gfind`를 최신 API로 오해: 문서/강의가 오래된 경우가 많다

### string.gsub — 치환

```lua
-- 시그니처: string.gsub(s, pattern, repl [, n])
--   s       : 대상 문자열
--   pattern : Lua 패턴
--   repl    : 치환 대상 (문자열 / 테이블 / 함수)
--   n       : 최대 치환 횟수 (생략하면 전부)
--
-- 반환값: (새 문자열, 치환 횟수)
--   원본 s는 변경되지 않음 (Lua 문자열은 불변)
```

**repl이 문자열일 때** — `%1`, `%2` 등으로 캡처 참조:

```lua
local result = string.gsub("Hello World", "World", "Lua")
print(result)   -- "Hello Lua"

-- 캡처 참조
local result = string.gsub("hp:100 mp:50", "(%a+):(%d+)", "%1=%2")
print(result)   -- "hp=100 mp=50"

-- %0: 매치된 전체 (캡처 유무와 무관)
local result = string.gsub("cat dog", "%a+", "[%0]")
print(result)   -- "[cat] [dog]"

-- 캡처 순서 바꾸기
local swapped = string.gsub("first-second", "(%a+)-(%a+)", "%2-%1")
print(swapped)  -- "second-first"
```

**repl이 테이블일 때** — 매치(또는 첫 번째 캡처)를 키로 조회:

```lua
local abbr = { hp = "Health Point", mp = "Mana Point", atk = "Attack" }
local result = string.gsub("hp mp atk", "%a+", abbr)
print(result)   -- "Health Point Mana Point Attack"

-- 키가 없으면 (nil/false) 치환하지 않고 원래 매치를 유지
local partial = { hp = "HP!" }
local result = string.gsub("hp mp", "%a+", partial)
print(result)   -- "HP! mp"
```

**repl이 함수일 때** — 매치마다 함수를 호출, 반환값으로 치환:

```lua
-- 숫자를 2배로
local result = string.gsub("damage: 100, heal: 50", "%d+", function(n)
    return tostring(tonumber(n) * 2)
end)
print(result)   -- "damage: 200, heal: 100"

-- 함수가 nil/false 반환하면 치환 안 함
local result = string.gsub("a1 b2 c3", "(%a)(%d)", function(letter, digit)
    if digit == "2" then return letter:upper() .. digit end
    -- 나머지는 nil → 원본 유지
end)
print(result)   -- "a1 B2 c3"
```

**치환 횟수 제한 & 반환값 활용:**

```lua
local result, count = string.gsub("aaa", "a", "b", 2)
print(result, count)   -- "bba"  2

-- count를 이용한 존재 여부 확인 (match 대용)
local _, found = string.gsub("hello world", "world", "")
if found > 0 then print("found!") end
```

> **C# 비교**: `Regex.Replace(s, pattern, replacement)` 에 해당.
> `repl`이 테이블/함수인 것은 C#의 `MatchEvaluator` 델리게이트와 유사.

## 메서드 호출 문법

```lua
-- 아래 두 줄은 동일
string.upper("hello")
("hello"):upper()

-- 메서드 문법이 더 읽기 쉬울 때가 있다
local s = "hello world"
local result = s:upper():sub(1, 5)   -- "HELLO"

-- C# 비교: "hello".ToUpper().Substring(0, 5)
```

---

## 연습문제

### 연습 4-1: string.format 활용
게임 로그 메시지를 format으로 구성하라.

```lua
-- 출력: "[Wave 03] Enemy spawned at (12.50, -8.30) — HP: 100"
local wave = 3
local x, y = 12.5, -8.3
local hp = 100
-- 여기에 string.format 작성
```

### 연습 4-2: 패턴 매칭
아래 문자열에서 모든 색상 코드(#RRGGBB 형식)를 추출하라.

```lua
local text = "Background: #FF0000, Text: #00FF00, Border: #0000FF"
-- 힌트: %x는 16진수 문자
```

### 연습 4-3: 효율적 문자열 연결
1부터 100까지의 숫자를 `"1, 2, 3, ..., 100"` 형태로 결합하라.
`table.concat`을 사용하여 효율적으로 작성하라.

### 연습 4-4: 파싱
`"Player[Lv.15] HP:80/100"` 문자열에서 이름, 레벨, 현재HP, 최대HP를 추출하라.

### 연습 4-5: 로그 타임스탬프 추출
서버 로그에서 시간과 레벨을 분리하라.

```lua
local log = "[2024-06-15 14:32:07] [ERROR] Connection timeout: server=db01 port=5432"
-- 추출 목표: date="2024-06-15", time="14:32:07", level="ERROR"
-- 힌트: %d, %-, %: 조합
```

### 연습 4-6: 로그 필터링 (gmatch + 조건)
여러 줄 로그에서 ERROR 레벨만 골라 메시지를 수집하라.

```lua
local logs = [[
[INFO] Player joined: uid=1001
[ERROR] Nil reference in update(): entity_id=42
[WARN] Frame drop detected: dt=0.083
[ERROR] Asset not found: sprites/boss.png
[INFO] Wave 3 started
]]
-- 결과: {"Nil reference in update(): entity_id=42", "Asset not found: sprites/boss.png"}
-- 힌트: gmatch로 한 줄씩 순회 후 match로 레벨 확인
```

### 연습 4-7: key=value 파서
임의의 로그 라인에서 모든 key=value 쌍을 테이블로 변환하라.
값에 소수점이나 음수가 올 수 있다.

```lua
local line = "event=damage src=player01 target=enemy_03 amount=125.5 crit=true"
-- 결과: {event="damage", src="player01", target="enemy_03", amount="125.5", crit="true"}
-- 힌트: (%S+)=(%S+) 또는 좀 더 정교한 패턴
```

### 연습 4-8: gsub로 로그 마스킹
로그에 포함된 IP 주소를 `***.***.***.***`로 마스킹하라.

```lua
local log = "Login from 192.168.1.100 failed. Retry from 10.0.0.42."
-- 결과: "Login from ***.***.***.*** failed. Retry from ***.***.***.***.
-- 힌트: %d+%.%d+%.%d+%.%d+ 패턴
```

### 연습 4-9: 구조화된 로그 변환
콜론 구분 로그를 JSON-like 형식으로 변환하라.

```lua
local entry = "time:14:32:07|level:ERROR|msg:timeout|code:504"
-- 결과: {time="14:32:07", level="ERROR", msg="timeout", code="504"}
-- 주의: time 값 안에도 콜론이 있다. 첫 번째 콜론만 구분자다.
-- 힌트: | 로 분리 후, 각 필드에서 첫 : 위치를 find로 찾기
```

### 연습 4-10: 패턴으로 간이 템플릿 엔진
`{key}` 형태의 플레이스홀더를 테이블 값으로 치환하라.

```lua
local template = "{name} dealt {damage} damage to {target}!"
local data = { name = "Knight", damage = "350", target = "Dragon" }
-- 결과: "Knight dealt 350 damage to Dragon!"
-- 힌트: gsub + 테이블 또는 gsub + 함수
```

---

[← 이전: 03. 제어문](03_control_flow.md) | [다음: 05. 함수 →](05_functions.md)

## 모범 답안

### 4-1
```lua
local msg = string.format("[Wave %02d] Enemy spawned at (%.2f, %.2f) - HP: %d", wave, x, y, hp)
print(msg)
```

### 4-2
```lua
for hex in text:gmatch("#%x%x%x%x%x%x") do
    print(hex)
end
```

### 4-3
```lua
local parts = {}
for i = 1, 100 do
    parts[i] = tostring(i)
end
local s = table.concat(parts, ", ")
```

### 4-4
```lua
local name, lv, cur, max = string.match("Player[Lv.15] HP:80/100", "([%a_]+)%[Lv%.(%d+)%]%sHP:(%d+)/(%d+)")
print(name, tonumber(lv), tonumber(cur), tonumber(max))
```

### 4-5
```lua
local log = "[2024-06-15 14:32:07] [ERROR] Connection timeout: server=db01 port=5432"
local date, time, level = string.match(log, "%[(%d+%-%d+%-%d+)%s(%d+:%d+:%d+)%]%s%[(%u+)%]")
print(date, time, level)   -- 2024-06-15  14:32:07  ERROR
```

### 4-6
```lua
local logs = [[
[INFO] Player joined: uid=1001
[ERROR] Nil reference in update(): entity_id=42
[WARN] Frame drop detected: dt=0.083
[ERROR] Asset not found: sprites/boss.png
[INFO] Wave 3 started
]]

local errors = {}
for line in logs:gmatch("[^\n]+") do
    local msg = line:match("^%[ERROR%]%s(.+)")
    if msg then
        errors[#errors + 1] = msg
    end
end
for _, e in ipairs(errors) do print(e) end
```

### 4-7
```lua
local line = "event=damage src=player01 target=enemy_03 amount=125.5 crit=true"
local kv = {}
for k, v in line:gmatch("(%S+)=(%S+)") do
    kv[k] = v
end
-- kv.event == "damage", kv.amount == "125.5"
```

### 4-8
```lua
local log = "Login from 192.168.1.100 failed. Retry from 10.0.0.42."
local masked = log:gsub("%d+%.%d+%.%d+%.%d+", "***.***.***.***")
print(masked)
```

### 4-9
```lua
local entry = "time:14:32:07|level:ERROR|msg:timeout|code:504"
local result = {}
for field in entry:gmatch("[^|]+") do
    local sep = field:find(":")
    local k = field:sub(1, sep - 1)
    local v = field:sub(sep + 1)
    result[k] = v
end
-- result.time == "14:32:07", result.level == "ERROR"
```

### 4-10
```lua
local template = "{name} dealt {damage} damage to {target}!"
local data = { name = "Knight", damage = "350", target = "Dragon" }
local result = template:gsub("{(%w+)}", data)
print(result)   -- "Knight dealt 350 damage to Dragon!"
```

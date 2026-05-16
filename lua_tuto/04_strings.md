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
print(string.sub(s, -6))        -- "orld!" (뒤에서부터)

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

## string.find — 검색

```lua
local s = "Hello, World!"

-- 단순 검색
local start, finish = string.find(s, "World")
print(start, finish)   -- 8  12

-- 패턴 검색
local start, finish = string.find(s, "%a+")   -- 첫 번째 단어
print(start, finish)   -- 1  5

-- plain 모드 (패턴 해석 안 함)
local start = string.find(s, ".", 1, true)  -- 4번째 인자 = plain
print(start)           -- nil (. 은 패턴에서 아무 문자)
```

## 패턴 매칭 — 정규식이 아니다! ⚠️

Lua는 자체 패턴 시스템을 사용한다. 정규식보다 단순하지만 가볍다.

```lua
-- 문자 클래스
-- %a: 알파벳     %A: 알파벳 아닌 것
-- %d: 숫자       %D: 숫자 아닌 것
-- %w: 영숫자     %W: 영숫자 아닌 것
-- %s: 공백       %S: 공백 아닌 것
-- %p: 구두점     %l: 소문자     %u: 대문자
-- .  : 아무 문자

-- 수량자
-- *  : 0회 이상 (greedy)
-- +  : 1회 이상 (greedy)
-- -  : 0회 이상 (lazy)
-- ?  : 0 또는 1회

-- ⚠️ 정규식과 다른 점:
-- { } 수량자 없음 ({3} 같은 것)
-- | (alternation) 없음
-- \d 대신 %d (백슬래시 대신 %)
-- 그룹은 () (동일)
```

### string.match — 추출

```lua
-- 숫자 추출
local year, month, day = string.match("2024-01-15", "(%d+)-(%d+)-(%d+)")
print(year, month, day)   -- 2024  01  15

-- 파일 이름/확장자 분리
local name, ext = string.match("sprite.png", "(.+)%.(%w+)")
print(name, ext)          -- sprite  png
```

### string.gmatch — 반복 추출

```lua
-- 모든 단어 추출
for word in string.gmatch("Hello World Lua", "%a+") do
    print(word)    -- Hello, World, Lua
end

-- CSV 파싱
local csv = "100,200,300"
local values = {}
for num in string.gmatch(csv, "(%d+)") do
    values[#values + 1] = tonumber(num)
end
```

### string.gsub — 치환

```lua
-- 단순 치환
local result = string.gsub("Hello World", "World", "Lua")
print(result)   -- "Hello Lua"

-- 패턴 치환
local result = string.gsub("hp:100 mp:50", "(%a+):(%d+)", "%1=%2")
print(result)   -- "hp=100 mp=50"

-- 함수로 치환
local result = string.gsub("damage: 100", "%d+", function(n)
    return tostring(tonumber(n) * 2)
end)
print(result)   -- "damage: 200"

-- 치환 횟수 제한
local result, count = string.gsub("aaa", "a", "b", 2)
print(result, count)   -- "bba"  2
```

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

---

[← 이전: 03. 제어문](03_control_flow.md) | [다음: 05. 함수 →](05_functions.md)

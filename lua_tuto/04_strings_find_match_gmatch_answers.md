# `string.find`, `string.match`, `string.gmatch` 모범 답안

> [실습 데이터](04_strings_find_match_gmatch_data.md)의 문제 번호와 대응합니다.
> 출력 형식은 한 가지 예시일 뿐이며, 핵심은 매칭 결과를 올바르게 얻는 것입니다.
> Lua 5.1/LuaJIT에서 실행할 수 있는 문법을 사용했습니다.

## Lv.1 기초 찾기 (1-20)

```lua
-- 1
local text = "I like apple pie."
local start, finish = string.find(text, "apple", 1, true)
print(start ~= nil, start, finish)

-- 2
local text = "A small game starts today."
print(string.find(text, "game", 1, true))

-- 3
local text = "Lua lua LUA"
print(string.find(text, "lua", 1, true))

-- 4
local text = "hello world"
print(string.find(text, " ", 1, true))

-- 5
local text = "red,green,blue"
print(string.find(text, ",", 1, true))

-- 6
local text = "banana"
local last
local position = 1
while true do
    local start = string.find(text, "a", position, true)
    if not start then break end
    last = start
    position = start + 1
end
print(last)

-- 7
local text = "ID: player-01"
print(string.find(text, "^ID:") ~= nil)

-- 8
local text = "sprite/player.png"
print(string.find(text, "%.png$") ~= nil)

-- 9
local text = "ERROR: file not found"
print(string.find(text, "error", 1, true) ~= nil)
print(string.find(string.lower(text), "error", 1, true) ~= nil)

-- 10
local text = "Visit https://example.com now"
print(string.find(text, "://", 1, true))

-- 11
local text = "ha ha ha"
local first_end = string.find(text, "ha", 1, true)
local second_start, second_end = string.find(text, "ha", first_end + 1, true)
print(second_start, second_end)

-- 12
local text = "ab--ab--ab"
local position, finish
for occurrence = 1, 3 do
    position, finish = string.find(text, "ab", (finish or 0) + 1, true)
end
print(position, finish)

-- 13
local text = "12345 cat 678"
print(string.find(text, "cat", 6, true))

-- 14
local text = "This is a simple island."
local position = 1
while true do
    local start, finish = string.find(text, "is", position, true)
    if not start then break end
    print(start, finish)
    position = start + 1
end

-- 15
local text = "name [player] score"
local left = string.find(text, "%[")
local right = string.find(text, "%]", left + 1)
print(left, right)

-- 16
local text = "player level 42"
print(string.find(text, "%d+") ~= nil)

-- 17
local text = "123456"
print(string.find(text, "%D+") ~= nil)

-- 18
local text = "level Up"
print(string.find(text, "%u"))

-- 19
local text = "1234abcDEF"
print(string.find(text, "%l", 5))

-- 20
local text = "price = 9.99"
print(string.find(text, ".", 1, true))
```

## Lv.2 find 패턴 확장 (21-35)

```lua
-- 21: Lua 패턴에는 lookaround가 없으므로 주변 문자를 직접 검사한다.
local text = "cat scatter catapult cat"
local position = 1
while true do
    local start, finish = string.find(text, "cat", position, true)
    if not start then break end
    local before = start == 1 and "" or string.sub(text, start - 1, start - 1)
    local after = finish == #text and "" or string.sub(text, finish + 1, finish + 1)
    if not string.find(before, "%w") and not string.find(after, "%w") then
        print(start, finish)
    end
    position = start + 1
end

-- 22
local text = "one  two   three"
print(string.find(text, "%s%s+"))

-- 23: 교육용 단순 IPv4 패턴이며 각 숫자 범위는 별도 검증하지 않는다.
local text = "Servers: 10.0.0.1 and 192.168.1.20"
print(string.find(text, "%d+%.%d+%.%d+%.%d+"))

-- 24
local text = "Events: 2026-09-05 and 2026-12-25"
print(string.find(text, "%d%d%d%d%-%d%d%-%d%d"))

-- 25
local text = [[say "hello world" then "bye"]]
print(string.find(text, '".-"'))

-- 26
local text = "<div>content</div> <span>text</span>"
print(string.find(text, "<.->"))

-- 27
local text = "draw(player, 10, 20)"
local start, _, name = string.find(text, "([%a_][%w_]*)%s*%(")
local finish = start and (start + #name - 1)
print(start, finish)

-- 28
local text = "flags: 0xFF and 0x10"
print(string.find(text, "0x%x+"))

-- 29
local text = "local hp = 100 -- player health"
print(string.find(text, "--", 1, true))

-- 30
local text = "move(10, 20) then wait()"
print(string.find(text, "%b()"))

-- 31
local text = "Contact dev@example.com for help"
print(string.find(text, "[%w%._%%+-]+@[%w%.%-]+"))

-- 32
local text = "Values: 3.14, 10.0, 7"
print(string.find(text, "%d+%.%d+"))

-- 33
local text = "name\tvalue"
print(string.find(text, "%s"))

-- 34
local text = "HP=120 MP=35"
print(string.find(text, "%d+"))

-- 35
local text = "Load /assets/images/player.png now"
print(string.find(text, "/[%w%._/-]+"))
```

## Lv.3 match 기초 추출 (36-50)

```lua
-- 36
local text = "There are 24 enemies."
print(string.match(text, "%d+"))

-- 37
local text = "Email: knight@example.com"
print(string.match(text, "([%w%._%%+-]+)@"))

-- 38
local text = "Email: knight@example.com"
print(string.match(text, "@([%w%.%-]+)"))

-- 39
local text = "Save file: player.stats.json"
print(string.match(text, "%.([%w]+)$"))

-- 40
local text = "https://game.example.com/start"
print(string.match(text, "^(%a+)://"))

-- 41
local text = "Release date: 2026/09/05"
local year, month, day = string.match(text, "(%d%d%d%d)/(%d%d)/(%d%d)")
print(year, month, day)

-- 42
local text = "Start at 08:35 sharp"
local hour, minute = string.match(text, "(%d%d):(%d%d)")
print(hour, minute)

-- 43
local text = "name=kim"
local key, value = string.match(text, "(%w+)=(%S+)")
print(key, value)

-- 44
local text = "Hello brave player"
print(string.match(text, "%S+"))

-- 45
local text = "The final score"
print(string.match(text, "(%S+)%s*$"))

-- 46
local text = "color = rgb(12,34,56)"
local red, green, blue = string.match(text, "rgb%((%d+),(%d+),(%d+)%)")
print(red, green, blue)

-- 47
local text = "position: x=10,y=20"
local x, y = string.match(text, "x=(%d+),y=(%d+)")
print(x, y)

-- 48
local text = "Changes: +42 -7 0"
local sign, number = string.match(text, "([+-])(%d+)")
print(sign, number)

-- 49
local text = "price=12.50"
local integer_part, fraction_part = string.match(text, "(%d+)%.(%d+)")
print(integer_part, fraction_part)

-- 50
local text = "bookkeeper"
local repeated = string.match(text, "(.)%1")
print(repeated)
```

## Lv.4 match 중급 파싱 (51-65)

```lua
-- 51
local function is_identifier(text)
    return string.match(text, "^[%a_][%w_]*$") ~= nil
end
print(is_identifier("player_01"))
print(is_identifier("1player"))

-- 52
local text = "score = 1234"
local name, value = string.match(text, "^%s*([%a_][%w_]*)%s*=%s*(%d+)%s*$")
print(name, value)

-- 53
local text = "local hp = 100"
local name, value = string.match(text, "^local%s+([%a_][%w_]*)%s*=%s*(%d+)%s*$")
print(name, value)

-- 54
local text = "move(player, 10, 20)"
local name, arguments = string.match(text, "([%a_][%w_]*)%s*(%b())")
print(name, arguments)

-- 55
local text = "user:'tom'"
local key, value = string.match(text, "(%w+):'([^']*)'")
print(key, value)

-- 56
local text = "[INFO] init done"
local level, message = string.match(text, "^%[([%u]+)%]%s*(.*)$")
print(level, message)

-- 57
local text = "[2026-09-05 10:30:15] hello"
local date, time, message = string.match(text, "^%[(%d%d%d%d%-%d%d%-%d%d)%s(%d%d:%d%d:%d%d)%]%s*(.*)$")
print(date, time, message)

-- 58
local text = "version v1.2.3"
local major, minor, patch = string.match(text, "v(%d+)%.(%d+)%.(%d+)")
print(major, minor, patch)

-- 59
local text = "accent color: #FFA07A"
local red, green, blue = string.match(text, "#(%x%x)(%x%x)(%x%x)")
print(red, green, blue)

-- 60
local text = "report.final.txt"
local base = string.match(text, "^(.+)%.[%w]+$")
print(base)

-- 61
local text = "### Intro to Lua"
local hashes, title = string.match(text, "^(#+)%s+(.+)$")
print(#hashes, title)

-- 62
local text = "  key_name : some value  "
local key, value = string.match(text, "^%s*([%w_]+)%s*:%s*(.-)%s*$")
print(key, value)

-- 63
local text = "updated 2026-09-05T14:30"
local date, time = string.match(text, "(%d%d%d%d%-%d%d%-%d%d)T(%d%d:%d%d)")
print(date, time)

-- 64
local text = "function foo_bar123(a, b)"
print(string.match(text, "^function%s+([%a_][%w_]*)%s*%("))

-- 65
local text = "game.core.player"
print(string.match(text, "([%w_]+)$"))
```

## Lv.5 gmatch 기초 순회 (66-80)

```lua
-- 66
local text = "Hello, brave Lua player!"
for word in string.gmatch(text, "%a+") do
    print(word)
end

-- 67
local text = "One two three four five"
local count = 0
for _ in string.gmatch(text, "%a+") do
    count = count + 1
end
print(count)

-- 68
local text = "Player 12 found 3 keys and 100 coins"
for number in string.gmatch(text, "%d+") do
    print(number)
end

-- 69
local text = "sword,shield,potion,bow"
for cell in string.gmatch(text .. ",", "([^,]*),") do
    print(cell)
end

-- 70
local text = "New #lua #game_dev release"
for tag in string.gmatch(text, "#([%w_]+)") do
    print(tag)
end

-- 71
local text = "Thanks @alice and @bob for testing"
for name in string.gmatch(text, "@([%w_]+)") do
    print(name)
end

-- 72
local text = "assets/images/player/avatar.png"
for part in string.gmatch(text, "[^/]+") do
    print(part)
end

-- 73
local text = "first line\nsecond line\nthird line"
for line in string.gmatch(text, "[^\n]+") do
    print(line)
end

-- 74
local text = "user=kim&level=15&mode=hard"
for key, value in string.gmatch(text, "([^&=]+)=([^&]*)") do
    print(key, value)
end

-- 75
local text = "A 7 B 42 C 105 D 99"
for number in string.gmatch(text, "%f[%d]%d%d%f[%D]") do
    print(number)
end

-- 76
local text = "x:10,y:20,z:30"
local coordinates = {}
for key, value in string.gmatch(text, "([%a_]+):(%-?%d+)") do
    coordinates[key] = tonumber(value)
end
print(coordinates.x, coordinates.y, coordinates.z)

-- 77
local text = "Lua lua GAME game game"
local counts = {}
for word in string.gmatch(text, "%a+") do
    word = string.lower(word)
    counts[word] = (counts[word] or 0) + 1
end
for word, count in pairs(counts) do
    print(word, count)
end

-- 78
local text = "<div>Hello</div><p>World</p><img>"
for tag in string.gmatch(text, "<%/?([%w]+)") do
    print(tag)
end

-- 79
local text = [[print("hello") say("world again")]]
for value in string.gmatch(text, '"(.-)"') do
    print(value)
end

-- 80
local text = "Builds: 2026-01-01, 2026-05-30, 2026-09-05"
for date in string.gmatch(text, "%d%d%d%d%-%d%d%-%d%d") do
    print(date)
end
```

## Lv.6 gmatch 고급 파싱 (81-90)

```lua
-- 81: 이 패턴은 키워드도 식별자로 반환한다. 키워드 제외는 별도 목록으로 처리한다.
local text = "local player_1 = enemy2 + 10"
for identifier in string.gmatch(text, "[%a_][%w_]*") do
    print(identifier)
end

-- 82
local text = "draw(player) move(enemy, 2) wait()"
for name in string.gmatch(text, "([%a_][%w_]*)%s*%(") do
    print(name)
end

-- 83
local text = "scores = [1, 2, 3, 4]"
local scores = {}
for number in string.gmatch(text, "%d+") do
    scores[#scores + 1] = tonumber(number)
end
for index, value in ipairs(scores) do
    print(index, value)
end

-- 84
local text = "delta=-3.5 speed=10.0 bonus=+2"
for number in string.gmatch(text, "[+-]?%d+%.?%d*") do
    print(number)
end

-- 85
local text = "TODO: add sound\nFIXME: reset state\nTODO: tune balance"
for line in string.gmatch(text, "[^\n]+") do
    local item = string.match(line, "^%s*TODO:%s*(.-)%s*$")
    if item then print(item) end
end

-- 86
local text = [[id="p01" name="Blue Knight" class="warrior"]]
for key, value in string.gmatch(text, '([%w_]+)="(.-)"') do
    print(key, value)
end

-- 87
local text = "[INFO] start\n[ERROR] fail\n[WARN] retry\n[ERROR] timeout"
local counts = {}
for line in string.gmatch(text, "[^\n]+") do
    local level = string.match(line, "^%[([%u]+)%]")
    if level then counts[level] = (counts[level] or 0) + 1 end
end
for level, count in pairs(counts) do
    print(level, count)
end

-- 88: %b()는 중첩 괄호를 균형 있게 매칭한다.
local text = "draw(player, move(enemy, 10)) wait()"
for block in string.gmatch(text, "%b()") do
    print(block)
end

-- 89
local text = "player.attack enemy.move ui.show"
for qualified_name in string.gmatch(text, "[%w_]+%.[%w_]+") do
    print(qualified_name)
end

-- 90
local text = "the quick brown brown fox and the the dog"
local position = 1
while true do
    local start, finish, word = string.find(text, "(%w+)%s+%1", position)
    if not start then break end
    print(word, start, finish)
    position = start + 1
end
```

## Lv.7 종합/어려움 (91-100)

```lua
-- 91: 다음 검색을 finish + 1이 아니라 start + 1부터 하여 겹침을 허용한다.
local text = "banana bandana"
local position = 1
while true do
    local start, finish = string.find(text, "ana", position, true)
    if not start then break end
    print(start, finish)
    position = start + 1
end

-- 92
local text = "# Title\nintro\n## Chapter 1\ntext\n### Details"
local line_number = 0
for line in string.gmatch(text, "[^\n]+") do
    line_number = line_number + 1
    local hashes, title = string.match(line, "^(#+)%s+(.+)$")
    if hashes then print(line_number, #hashes, title) end
end

-- 93
local text = "[graphics]\nwidth=1280\nheight=720\n\n[audio]\nvolume=80"
local ini = {}
local section
for line in string.gmatch(text, "[^\n]+") do
    line = string.match(line, "^%s*(.-)%s*$")
    if line ~= "" then
        local name = string.match(line, "^%[([^%]]+)%]$")
        if name then
            section = name
            ini[section] = {}
        else
            local key, value = string.match(line, "^([^=]+)=(.*)$")
            if section and key then
                key = string.match(key, "^%s*(.-)%s*$")
                value = string.match(value, "^%s*(.-)%s*$")
                ini[section][key] = value
            end
        end
    end
end
print(ini.graphics.width, ini.audio.volume)

-- 94: Lua 패턴에는 alternation이 없으므로 위치를 직접 이동하며 토큰을 읽는다.
local text = [[load "player one" --verbose 2]]
local tokens = {}
local position = 1
while position <= #text do
    local space_start, space_end = string.find(text, "%s+", position)
    local token_end = space_start and space_start - 1 or #text
    if string.sub(text, position, position) == '"' then
        local close = string.find(text, '"', position + 1, true)
        tokens[#tokens + 1] = string.sub(text, position + 1, close - 1)
        position = close + 1
    else
        if position <= token_end then
            tokens[#tokens + 1] = string.sub(text, position, token_end)
        end
        position = token_end + 1
    end
    local next_start = string.find(text, "%S", position)
    position = next_start or (#text + 1)
end
for index, token in ipairs(tokens) do print(index, token) end

-- 95
local text = "Hello {{name}}, you scored {{score}} points."
local position = 1
while true do
    local start, finish, name = string.find(text, "{{(.-)}}", position)
    if not start then break end
    print(name, start, finish)
    position = finish + 1
end

-- 96
local text = [[127.0.0.1 - frank [05/Sep/2026:10:30:15 +0900] "GET /index.html HTTP/1.1" 200 1234]]
local ip, identity, user, timestamp, request, code, size = string.match(
    text,
    '^(%S+)%s+(%S+)%s+(%S+)%s+%[(.-)%]%s+"(.-)"%s+(%d+)%s+(%d+)$'
)
print(ip, identity, user, timestamp, request, code, size)

-- 97
local text = [[10.0.0.2 - - [05/Sep/2026:10:31:00 +0900] "GET /missing HTTP/1.1" 404 512 "-" "Mozilla/5.0"]]
local ip, identity, user, timestamp, request, code, size, referer, agent = string.match(
    text,
    '^(%S+)%s+(%S+)%s+(%S+)%s+%[(.-)%]%s+"(.-)"%s+(%d+)%s+(%d+)%s+"(.-)"%s+"(.-)"$'
)
print(ip, identity, user, timestamp, request, code, size, referer, agent)

-- 98
local text = "Read [Lua guide](https://lua.org) and [API docs](https://lua.org/manual)"
for label, url in string.gmatch(text, "%[(.-)%]%((.-)%)") do
    print(label, url)
end

-- 99
local text = "[2026-09-05 10:00] [INFO] core: started\n[2026-09-05 10:01] [WARN] net: slow\n[2026-09-05 10:02] [ERROR] save: failed"
local counts = {}
for line in string.gmatch(text, "[^\n]+") do
    local date, time, level, module, message = string.match(
        line,
        "^%[(%d%d%d%d%-%d%d%-%d%d)%s(%d%d:%d%d)%]%s+%[([%u]+)%]%s+([%w_]+):%s*(.*)$"
    )
    if level then
        counts[level] = (counts[level] or 0) + 1
        print(date, time, level, module, message)
    end
end
for level, count in pairs(counts) do print(level, count) end

-- 100: 간단한 토큰 분류기. 문자열/주석을 먼저 소비한 뒤 나머지를 분류한다.
local text = [[local hp = 100 -- initial
move(player, 10)
name = "Knight Mage"
if hp > 0 then attack() end]]
local keywords = { ["local"] = true, ["if"] = true, ["then"] = true, ["end"] = true }
local tokens = {}
local position = 1

local function add_token(kind, value, start, finish)
    tokens[#tokens + 1] = { kind = kind, value = value, start = start, finish = finish }
end

while position <= #text do
    local char = string.sub(text, position, position)
    if string.find(char, "%s") then
        position = position + 1
    elseif string.sub(text, position, position + 1) == "--" then
        local finish = string.find(text, "\n", position, true) or (#text + 1)
        add_token("comment", string.sub(text, position, finish - 1), position, finish - 1)
        position = finish
    elseif char == '"' then
        local finish = string.find(text, '"', position + 1, true)
        if not finish then
            print("parse error at", position, "unterminated string")
            break
        end
        add_token("string", string.sub(text, position + 1, finish - 1), position, finish)
        position = finish + 1
    else
        local start, finish, value = string.find(text, "^([%a_][%w_]*)", position)
        if start then
            add_token(keywords[value] and "keyword" or "identifier", value, start, finish)
            position = finish + 1
        else
            start, finish, value = string.find(text, "^(%d+%.?%d*)", position)
            if start then
                add_token("number", value, start, finish)
                position = finish + 1
            else
                start, finish, value = string.find(text, "^([+%-%*/=<>])", position)
                if start then
                    add_token("operator", value, start, finish)
                    position = finish + 1
                elseif string.find(char, "[%(%)%,]") then
                    add_token("punctuation", char, position, position)
                    position = position + 1
                else
                    print("parse error at", position, "unexpected character: " .. char)
                    break
                end
            end
        end
    end
end

for _, token in ipairs(tokens) do
    print(token.kind, token.value, token.start, token.finish)
end
```

## 답안 적용 시 주의점

- `string.match`와 `string.gmatch`가 반환하는 숫자처럼 보이는 값도 기본적으로 문자열이다. 계산하려면 `tonumber`를 사용한다.
- Lua 패턴에는 정규식의 `|`, lookaround, `\d`가 없다. Lua 방식인 `%d`, 캡처, `%b()`를 사용한다.
- `string.find`의 시작 위치는 1부터이며, 겹치는 매치를 찾을 때는 이전 매치의 끝이 아니라 시작 위치에 1을 더한다.
- `gmatch`만으로 위치를 얻을 수 없으므로 위치가 필요하면 `find` 루프를 사용한다.
- 이메일, IPv4, 로그 파서는 예시 입력을 위한 단순 패턴이다. 실제 서비스 입력에서는 형식 검증과 오류 처리를 추가해야 한다.

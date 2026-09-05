# `string.find`, `string.match`, `string.gmatch` 실습 데이터

> [힌트 목록](04_strings_find_match_gmatch_hints.md)의 문제 번호와 대응합니다.
> 각 문제의 `text`를 Lua 코드에 복사하고, 요구한 결과를 직접 출력하거나 테이블로 수집하세요.
> 정답은 제공하지 않습니다.

## Lv.1 기초 찾기 (1-20)

1. `text = "I like apple pie."`에서 `apple`의 포함 여부와 위치를 구한다.
2. `text = "A small game starts today."`에서 `game`의 시작 위치를 구한다.
3. `text = "Lua lua LUA"`에서 소문자 `lua`의 첫 위치를 구한다.
4. `text = "hello world"`에서 첫 공백 위치를 구한다.
5. `text = "red,green,blue"`에서 첫 콤마 위치를 구한다.
6. `text = "banana"`에서 `a`가 마지막으로 나타나는 위치를 구한다.
7. `text = "ID: player-01"`이 `ID:`로 시작하는지 확인한다.
8. `text = "sprite/player.png"`가 `.png`로 끝나는지 확인한다.
9. `text = "ERROR: file not found"`에 `error`가 있는지 확인한다. 대소문자 구분 여부도 관찰한다.
10. `text = "Visit https://example.com now"`에서 `://`의 위치를 구한다.
11. `text = "ha ha ha"`에서 두 번째 `ha`의 위치를 구한다.
12. `text = "ab--ab--ab"`에서 세 번째 `ab`의 위치를 구한다.
13. `text = "12345 cat 678"`에서 6번째 문자 이후의 `cat` 위치를 구한다.
14. `text = "This is a simple island."`에서 `is`가 나타나는 모든 위치를 구한다.
15. `text = "name [player] score"`에서 첫 `[`와 `]`의 위치를 구한다.
16. `text = "player level 42"`에 숫자가 있는지 확인한다.
17. `text = "123456"`에 숫자가 아닌 문자가 있는지 확인한다.
18. `text = "level Up"`에서 첫 대문자 위치를 구한다.
19. `text = "1234abcDEF"`에서 5번째 문자 이후 첫 소문자 위치를 구한다.
20. `text = "price = 9.99"`에서 점(`.`) 문자의 위치를 구한다.

## Lv.2 find 패턴 확장 (21-35)

21. `text = "cat scatter catapult cat"`에서 독립 단어 `cat`의 위치만 찾는다.
22. `text = "one  two   three"`에서 2칸 이상 연속된 공백의 위치를 구한다.
23. `text = "Servers: 10.0.0.1 and 192.168.1.20"`에서 첫 IPv4 형태의 위치를 구한다.
24. `text = "Events: 2026-09-05 and 2026-12-25"`에서 첫 날짜의 위치를 구한다.
25. `text = [[say "hello world" then "bye"]]`에서 첫 큰따옴표 문자열의 범위를 구한다.
26. `text = "<div>content</div> <span>text</span>"`에서 첫 태그 구간의 범위를 구한다.
27. `text = "draw(player, 10, 20)"`에서 함수 호출 이름 `draw`의 위치를 구한다.
28. `text = "flags: 0xFF and 0x10"`에서 첫 16진수 토큰의 위치를 구한다.
29. `text = "local hp = 100 -- player health"`에서 주석 시작 위치를 구한다.
30. `text = "move(10, 20) then wait()"`에서 첫 괄호 블록의 범위를 구한다.
31. `text = "Contact dev@example.com for help"`에서 이메일의 위치를 구한다.
32. `text = "Values: 3.14, 10.0, 7"`에서 첫 소수의 위치를 구한다.
33. `text = "name\tvalue"`에서 첫 탭 또는 공백의 위치를 구한다.
34. `text = "HP=120 MP=35"`에서 첫 숫자 덩어리의 범위를 구한다.
35. `text = "Load /assets/images/player.png now"`에서 첫 경로의 범위를 구한다.

## Lv.3 match 기초 추출 (36-50)

36. `text = "There are 24 enemies."`에서 첫 숫자를 추출한다.
37. `text = "Email: knight@example.com"`에서 `@` 앞 사용자명을 추출한다.
38. `text = "Email: knight@example.com"`에서 `@` 뒤 도메인을 추출한다.
39. `text = "Save file: player.stats.json"`에서 확장자를 추출한다.
40. `text = "https://game.example.com/start"`에서 프로토콜을 추출한다.
41. `text = "Release date: 2026/09/05"`에서 연, 월, 일을 각각 추출한다.
42. `text = "Start at 08:35 sharp"`에서 시와 분을 각각 추출한다.
43. `text = "name=kim"`에서 key와 value를 추출한다.
44. `text = "Hello brave player"`에서 첫 단어를 추출한다.
45. `text = "The final score"`에서 마지막 단어를 추출한다.
46. `text = "color = rgb(12,34,56)"`에서 R, G, B 값을 추출한다.
47. `text = "position: x=10,y=20"`에서 x 값과 y 값을 추출한다.
48. `text = "Changes: +42 -7 0"`에서 첫 정수의 부호와 숫자를 분리한다.
49. `text = "price=12.50"`에서 정수부와 소수부를 분리한다.
50. `text = "bookkeeper"`에서 처음 연속 중복되는 문자를 찾는다.

## Lv.4 match 중급 파싱 (51-65)

51. `text = "player_01"`이 식별자 규칙에 맞는지 전체 검증한다. `"1player"`도 시험한다.
52. `text = "score = 1234"`에서 변수명과 값을 추출한다.
53. `text = "local hp = 100"`에서 변수명과 숫자값을 추출한다.
54. `text = "move(player, 10, 20)"`에서 함수명과 인자 문자열을 추출한다.
55. `text = "user:'tom'"`에서 key와 따옴표 안 value를 추출한다.
56. `text = "[INFO] init done"`에서 로그 레벨과 메시지를 추출한다.
57. `text = "[2026-09-05 10:30:15] hello"`에서 날짜, 시간, 메시지를 추출한다.
58. `text = "version v1.2.3"`에서 major, minor, patch를 추출한다.
59. `text = "accent color: #FFA07A"`에서 RR, GG, BB를 추출한다.
60. `text = "report.final.txt"`에서 확장자를 제외한 베이스 이름을 추출한다.
61. `text = "### Intro to Lua"`에서 샵 개수와 제목을 추출한다.
62. `text = "  key_name : some value  "`에서 key와 value를 공백을 제외하고 추출한다.
63. `text = "updated 2026-09-05T14:30"`에서 날짜와 시간을 추출한다.
64. `text = "function foo_bar123(a, b)"`에서 함수명을 추출한다.
65. `text = "game.core.player"`에서 마지막 모듈 세그먼트를 추출한다.

## Lv.5 gmatch 기초 순회 (66-80)

66. `text = "Hello, brave Lua player!"`의 모든 단어를 순회한다.
67. `text = "One two three four five"`의 단어 개수를 센다.
68. `text = "Player 12 found 3 keys and 100 coins"`의 모든 숫자를 추출한다.
69. `text = "sword,shield,potion,bow"`의 모든 CSV 셀을 순회한다.
70. `text = "New #lua #game_dev release"`의 모든 해시태그를 추출한다.
71. `text = "Thanks @alice and @bob for testing"`의 모든 멘션을 추출한다.
72. `text = "assets/images/player/avatar.png"`를 슬래시 기준으로 토큰화한다.
73. `text = "first line\nsecond line\nthird line"`의 각 줄을 순회한다.
74. `text = "user=kim&level=15&mode=hard"`의 모든 key,value 쌍을 추출한다.
75. `text = "A 7 B 42 C 105 D 99"`에서 두 자리 숫자 토큰만 추출한다.
76. `text = "x:10,y:20,z:30"`의 좌표를 테이블로 만든다.
77. `text = "Lua lua GAME game game"`의 단어 빈도를 대소문자 무시 기준으로 집계한다.
78. `text = "<div>Hello</div><p>World</p><img>"`의 태그 이름을 순회한다.
79. `text = [[print("hello") say("world again")]]`의 큰따옴표 문자열을 추출한다.
80. `text = "Builds: 2026-01-01, 2026-05-30, 2026-09-05"`의 모든 날짜를 추출한다.

## Lv.6 gmatch 고급 파싱 (81-90)

81. `text = "local player_1 = enemy2 + 10"`에서 Lua 식별자 토큰을 추출한다.
82. `text = "draw(player) move(enemy, 2) wait()"`에서 함수 호출 이름을 추출한다.
83. `text = "scores = [1, 2, 3, 4]"`에서 정수를 배열로 만든다.
84. `text = "delta=-3.5 speed=10.0 bonus=+2"`에서 부호가 있는 숫자 토큰을 추출한다.
85. `text = "TODO: add sound\nFIXME: reset state\nTODO: tune balance"`에서 TODO 항목을 추출한다.
86. `text = [[id="p01" name="Blue Knight" class="warrior"]]`에서 모든 속성 key,value를 추출한다.
87. `text = "[INFO] start\n[ERROR] fail\n[WARN] retry\n[ERROR] timeout"`에서 레벨별 줄 수를 집계한다.
88. `text = "draw(player, move(enemy, 10)) wait()"`에서 괄호 블록을 순회 추출한다.
89. `text = "player.attack enemy.move ui.show"`에서 모듈명.함수명 토큰을 추출한다.
90. `text = "the quick brown brown fox and the the dog"`에서 중복 단어와 위치를 찾는다.

## Lv.7 종합/어려움 (91-100)

91. `text = "banana bandana"`에서 겹치는 `ana`의 모든 위치를 찾는다.
92. `text = "# Title\nintro\n## Chapter 1\ntext\n### Details"`에서 제목 라인의 위치와 제목을 추출한다.
93. `text = "[graphics]\nwidth=1280\nheight=720\n\n[audio]\nvolume=80"`를 INI 구조로 파싱한다.
94. `text = [[load "player one" --verbose 2]]`를 따옴표 안 공백을 보존하는 토큰 배열로 만든다.
95. `text = "Hello {{name}}, you scored {{score}} points."`에서 플레이스홀더 이름과 위치를 추출한다.
96. `text = [[127.0.0.1 - frank [05/Sep/2026:10:30:15 +0900] "GET /index.html HTTP/1.1" 200 1234]]`를 필드별로 파싱한다.
97. `text = [[10.0.0.2 - - [05/Sep/2026:10:31:00 +0900] "GET /missing HTTP/1.1" 404 512 "-" "Mozilla/5.0"]]`에서 `-` 필드도 보존한다.
98. `text = "Read [Lua guide](https://lua.org) and [API docs](https://lua.org/manual)"`에서 링크를 모두 추출한다.
99. `text = "[2026-09-05 10:00] [INFO] core: started\n[2026-09-05 10:01] [WARN] net: slow\n[2026-09-05 10:02] [ERROR] save: failed"`에서 분류, 타임스탬프, 모듈, 메시지, 카운트를 추출한다.
100. `text = [[local hp = 100 -- initial\nmove(player, 10)\nname = "Knight Mage"\nif hp > 0 then attack() end]]`를 식별자, 숫자, 문자열, 연산자, 주석 토큰으로 분류하고 첫 오류 위치를 보고한다.

## 실행용 기본 틀

```lua
local text = "여기에 문제의 text를 넣으세요"

-- 문제에 따라 find, match, gmatch 중 하나를 선택하세요.
-- 결과를 print하거나 테이블에 저장해 확인하세요.
```

-- 연습 4-1: string.format
local wave = 3
local x, y = 12.5, -8.3
local hp = 100
local msg = string.format("[Wave %02d] Enemy spawned at (%.2f, %.2f) — HP: %d",
    wave, x, y, hp)
print(msg)
-- [Wave 03] Enemy spawned at (12.50, -8.30) — HP: 100


-- 연습 4-2: 색상 코드 추출
local text = "Background: #FF0000, Text: #00FF00, Border: #0000FF"
for color in string.gmatch(text, "#%x%x%x%x%x%x") do
    print(color)   -- #FF0000, #00FF00, #0000FF
end


-- 연습 4-3: 효율적 문자열 연결
local parts = {}
for i = 1, 100 do
    parts[i] = tostring(i)
end
local result = table.concat(parts, ", ")
print(result)   -- "1, 2, 3, ..., 100"


-- 연습 4-4: 파싱
local input = "Player[Lv.15] HP:80/100"
local name, level, curHp, maxHp = string.match(input, "(%a+)%[Lv%.(%d+)%] HP:(%d+)/(%d+)")
print(name, level, curHp, maxHp)   -- Player  15  80  100

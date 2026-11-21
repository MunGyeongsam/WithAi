-- metatable_tasks_test.lua
-- 08 메타테이블 실습 과제 헤드리스 테스트 (LÖVE 불필요).
-- 실행: lua lua_tuto/assignments/08_metatables/metatable_tasks_test.lua          (학생 파일)
--       lua lua_tuto/assignments/08_metatables/metatable_tasks_test.lua answers  (모범 답안)
-- luajit 으로도 실행 가능.

local here = (arg and arg[0] or ""):match("(.*[/\\])") or "./"
local target = (arg and arg[1] == "answers") and (here .. "answers/") or here
package.path = target .. "?.lua;" .. package.path

local M = require("metatable_tasks")

local passed, failed = 0, 0
local scores = {}

local function check(section, name, fn)
  local ok, result = pcall(fn)
  scores[section] = scores[section] or { pass = 0, total = 0 }
  scores[section].total = scores[section].total + 1
  if ok and result then
    passed = passed + 1
    scores[section].pass = scores[section].pass + 1
    print("  ok   - " .. name)
  else
    failed = failed + 1
    local why = ok and "" or ("  (" .. tostring(result) .. ")")
    print("  FAIL - " .. name .. why)
  end
end

local function raises(fn, pattern)
  local ok, err = pcall(fn)
  return not ok and tostring(err):find(pattern, 1, true) ~= nil
end

local function countKeys(t)
  local n = 0
  for _ in pairs(t) do
    n = n + 1
  end
  return n
end

print("[문제 1] withDefaults")
check(1, "없는 키는 defaults 에서 읽는다", function()
  local e = M.withDefaults({ name = "Slime" }, { hp = 100, speed = 5 })
  return e.name == "Slime" and e.hp == 100 and e.speed == 5
end)
check(1, "자기 값이 defaults 보다 우선한다", function()
  local e = M.withDefaults({ hp = 30 }, { hp = 100 })
  return e.hp == 30
end)
check(1, "같은 테이블을 반환하고 defaults 를 복사하지 않는다", function()
  local t = { name = "Bat" }
  local e = M.withDefaults(t, { hp = 1, mp = 2 })
  return e == t and countKeys(t) == 1 and rawget(t, "hp") == nil
end)
check(1, "defaults 변경이 즉시 반영된다", function()
  local d = { hp = 100 }
  local e = M.withDefaults({}, d)
  d.hp = 120
  return e.hp == 120
end)

print("[문제 2] readOnly")
check(2, "읽기는 원본 값을 돌려준다", function()
  local c = M.readOnly({ maxHp = 100, speed = 5 })
  return c.maxHp == 100 and c.speed == 5
end)
check(2, "새 키 쓰기는 에러", function()
  local c = M.readOnly({ maxHp = 100 })
  return raises(function() c.mp = 1 end, "read-only: mp")
end)
check(2, "기존 키 덮어쓰기도 에러", function()
  local c = M.readOnly({ maxHp = 100 })
  return raises(function() c.maxHp = 1 end, "read-only: maxHp")
end)
check(2, "실패한 쓰기 후 원본은 그대로", function()
  local src = { maxHp = 100 }
  local c = M.readOnly(src)
  pcall(function() c.maxHp = 1 end)
  return src.maxHp == 100 and c.maxHp == 100
end)

print("[문제 3] Stats")
local Stats = M.Stats
check(3, "new 는 빠진 필드를 DEFAULT 로 채운다", function()
  local s = Stats.new({ atk = 20 })
  return s.hp == 100 and s.atk == 20 and s.def == 5
end)
check(3, "new() 인자 없이도 동작", function()
  local s = Stats.new()
  return s.hp == 100 and s.atk == 10 and s.def == 5
end)
check(3, "a + b 필드별 합, 원본 불변", function()
  local a = Stats.new({ hp = 10, atk = 1, def = 2 })
  local b = Stats.new({ hp = 5, atk = 3, def = 4 })
  local c = a + b
  return c.hp == 15 and c.atk == 4 and c.def == 6 and a.hp == 10 and getmetatable(c) == getmetatable(a)
end)
check(3, "s * n 과 n * s 모두 동작", function()
  local s = Stats.new({ hp = 10, atk = 2, def = 3 })
  local x, y = s * 2, 2 * s
  return x.hp == 20 and x.atk == 4 and x.def == 6 and y.hp == 20 and y.def == 6
end)
check(3, "== 는 값 비교", function()
  return Stats.new({ hp = 1 }) == Stats.new({ hp = 1 }) and not (Stats.new({ hp = 1 }) == Stats.new({ hp = 2 }))
end)
check(3, "tostring 형식", function()
  return tostring(Stats.new({ hp = 50 })) == "Stats(hp=50, atk=10, def=5)"
end)
check(3, "power() 는 atk*2 + def", function()
  return Stats.new({ atk = 7, def = 3 }):power() == 17
end)
check(3, "인스턴스에 메서드가 복사되지 않는다", function()
  local s = Stats.new()
  return rawget(s, "power") == nil and countKeys(s) == 3
end)

print("[문제 4] tracked")
check(4, "새 키 쓰기: 원본 저장 + 콜백", function()
  local src, log = {}, {}
  local p = M.tracked(src, function(k, old, new) log[#log + 1] = { k, old, new } end)
  p.mp = 30
  return src.mp == 30 and p.mp == 30 and #log == 1 and log[1][1] == "mp" and log[1][2] == nil and log[1][3] == 30
end)
check(4, "기존 키 수정도 콜백 호출", function()
  local log = {}
  local p = M.tracked({ hp = 100 }, function(k, old, new) log[#log + 1] = { k, old, new } end)
  p.hp = 80
  p.hp = 60
  return #log == 2 and log[1][2] == 100 and log[1][3] == 80 and log[2][2] == 80 and log[2][3] == 60
end)
check(4, "같은 값 쓰기는 콜백 없음", function()
  local calls = 0
  local p = M.tracked({ hp = 100 }, function() calls = calls + 1 end)
  p.hp = 100
  return calls == 0
end)
check(4, "프록시 자체는 비어 있다", function()
  local p = M.tracked({ hp = 100 }, function() end)
  p.hp = 1
  p.mp = 2
  return countKeys(p) == 0
end)

print("[문제 5] Enemy")
local Enemy = M.Enemy
check(5, "Enemy.new 와 Enemy() 둘 다 생성, count/id 증가", function()
  local base = Enemy.count
  local a = Enemy.new("Slime", 50)
  local b = Enemy("Goblin", 80)
  return Enemy.count == base + 2 and a.id == base + 1 and b.id == base + 2 and b.name == "Goblin"
    and getmetatable(a) == getmetatable(b)
end)
check(5, "tostring 형식", function()
  local e = Enemy("Bat", 12)
  return tostring(e) == string.format("Bat#%d(hp=12)", e.id)
end)
check(5, "< 는 hp, 동률이면 id 비교", function()
  local a, b, c = Enemy("A", 10), Enemy("B", 20), Enemy("C", 10)
  return a < b and not (b < a) and a < c and not (c < a)
end)
check(5, "table.sort 가 __lt 로 정렬", function()
  local list = { Enemy("Orc", 70), Enemy("Rat", 5), Enemy("Imp", 30), Enemy("Rat2", 5) }
  table.sort(list)
  return list[1].name == "Rat" and list[2].name == "Rat2" and list[3].name == "Imp" and list[4].name == "Orc"
end)

local weights = { 15, 15, 25, 20, 15 }
local total = 0
print("\n--- 자동 채점 (문제 1~5, 통과 비율로 배점) ---")
for i = 1, #weights do
  local s = scores[i] or { pass = 0, total = 1 }
  local got = weights[i] * s.pass / s.total
  total = total + got
  print(string.format("  문제 %d: %d/%d  → %.1f / %d", i, s.pass, s.total, got, weights[i]))
end
print(string.format("  합계: %.1f / 90  (문제 6 보고서 10점 별도)", total))
print(string.format("\n%d passed, %d failed", passed, failed))
if failed > 0 then
  os.exit(1)
end

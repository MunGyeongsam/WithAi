-- 08 메타테이블 실습 과제 — 학생 작성 파일
-- 각 TODO 를 채운 뒤 테스트로 확인한다.
--   lua lua_tuto/assignments/08_metatables/metatable_tasks_test.lua
-- 규칙: 전역 변수 금지, Lua 5.1 / LuaJIT 호환 문법만 사용.

local M = {}

-- 문제 1. 기본값 테이블 (15점)
-- t 에 없는 키를 읽으면 defaults 에서 값을 가져온다.
-- t 자체를 반환하며, defaults 의 키가 t 에 복사되면 안 된다.
function M.withDefaults(t, defaults)
  error("TODO: 문제 1")
end

-- 문제 2. 읽기 전용 테이블 (15점)
-- 읽기는 원본 t 에서, 쓰기는 항상 error("read-only: <key>") 를 발생시킨다.
-- 이미 있는 키에 대한 쓰기도 막아야 한다.
function M.readOnly(t)
  error("TODO: 문제 2")
end

-- 문제 3. Stats 값 타입 (25점)
-- Stats.new({hp=?, atk=?, def=?}) : 빠진 필드는 Stats.DEFAULT 값으로 채운다.
-- a + b       : 필드별 합으로 새 Stats 반환 (원본 불변)
-- s * n, n * s: 필드별 스칼라 곱으로 새 Stats 반환
-- a == b      : 세 필드가 모두 같으면 true
-- tostring(s) : "Stats(hp=100, atk=10, def=5)"  (%g 형식, 필드 순서 고정)
-- s:power()   : atk * 2 + def
local Stats = {}
Stats.DEFAULT = { hp = 100, atk = 10, def = 5 }

function Stats.new(o)
  error("TODO: 문제 3")
end

M.Stats = Stats

-- 문제 4. 변경 감시 프록시 (20점)
-- 반환된 프록시에 값을 쓰면 원본 t 에 저장하고 onChange(key, old, new) 를 호출한다.
-- 값이 실제로 바뀌지 않으면(old == new) onChange 를 호출하지 않는다.
-- 이미 있는 키를 수정할 때도 onChange 가 호출되어야 한다.
function M.tracked(t, onChange)
  error("TODO: 문제 4")
end

-- 문제 5. __call 팩토리 + __lt 정렬 (15점)
-- Enemy.new(name, hp) 와 Enemy(name, hp) 둘 다 인스턴스를 만든다.
-- 생성될 때마다 Enemy.count 가 1 증가하고, 인스턴스 id 는 생성 순번이다.
-- a < b : hp 오름차순, hp 가 같으면 id 오름차순 → table.sort(list) 가 그대로 동작해야 한다.
-- tostring(e) : "Slime#1(hp=50)"
local Enemy = {}
Enemy.count = 0

function Enemy.new(name, hp)
  error("TODO: 문제 5")
end

M.Enemy = Enemy

return M

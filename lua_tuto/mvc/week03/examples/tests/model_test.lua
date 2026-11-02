-- model_test.lua
-- GameModel 의 헤드리스 단위 테스트. 창(love) 없이 luajit 으로 로직만 검증한다.
-- 실행: cd lua_tuto/mvc/week03/examples/tests
--   luajit model_test.lua           ← 완성본(models/) 검사
--   luajit model_test.lua starter   ← 실습용 스켈레톤(starter/) 검사: 처음엔 실패, 채울수록 통과

local here = (arg[0] or ""):match("(.*/)") or "./"
local target = arg[1] or "models"
package.path = here .. "../" .. target .. "/?.lua;" .. package.path

local GameModel = require("GameModel")
local BulletModel = require("BulletModel")

local FIXED_DT = 1 / 60

local passed, failed = 0, 0

-- 각 테스트를 pcall 로 감싸, 미완성 코드가 에러를 내도 다음 테스트를 계속 돌린다.
local function test(name, fn)
  local ok, err = pcall(fn)
  -- 반드시 true 여야 통과. `a and b` 가 nil 을 내도 실패로 본다(6주차 검토에서 발견한 러너 버그).
  if ok and err == true then
    passed = passed + 1
    print("  ok   - " .. name)
  else
    failed = failed + 1
    local reason = ok and "조건 불일치" or tostring(err):gsub("^.-:%d+: ", "")
    print("  FAIL - " .. name .. "  (" .. reason .. ")")
  end
end

local function hasEvent(events, t)
  for _, e in ipairs(events) do
    if e.type == t then
      return true
    end
  end
  return false
end

local function newGame(seed)
  return GameModel({ width = 600, height = 800, seed = seed or 1 })
end

local IDLE = { move = 0, fire = false }

print("[대상] " .. target .. "/")

-- ── 생성 ─────────────────────────────────────────────────────────────────
test("편대 32기 생성", function()
  return #newGame().enemies == 32
end)

-- ── 플레이어 이동 ────────────────────────────────────────────────────────
test("move=1 이면 오른쪽으로 이동", function()
  local g = newGame()
  local x0 = g.player.x
  g:update(FIXED_DT, { move = 1, fire = false })
  return g.player.x > x0
end)

test("화면 왼쪽 밖으로 못 나감", function()
  local g = newGame()
  for _ = 1, 300 do
    g:update(FIXED_DT, { move = -1, fire = false })
  end
  return g.player.x == 0
end)

-- ── 발사 ─────────────────────────────────────────────────────────────────
test("fire 입력 시 총알 1발 생성", function()
  local g = newGame()
  g:update(FIXED_DT, { move = 0, fire = true })
  return #g.bullets == 1
end)

test("fire 이벤트 발행", function()
  local g = newGame()
  g:update(FIXED_DT, { move = 0, fire = true })
  return hasEvent(g:drainEvents(), "fire")
end)

test("쿨다운 중에는 연사 불가", function()
  local g = newGame()
  g:update(FIXED_DT, { move = 0, fire = true })
  g:update(FIXED_DT, { move = 0, fire = true })
  return #g.bullets == 1
end)

-- ── 충돌 ─────────────────────────────────────────────────────────────────
test("총알×적 충돌 시 점수 +100, 적 사망, enemy_destroyed", function()
  local g = newGame()
  local e = g.enemies[1]
  g.bullets[#g.bullets + 1] = BulletModel(e.x + 4, e.y + 4, 0, 0, 4, 12, "player")
  g:update(FIXED_DT, IDLE)
  return g.score == 100 and e.alive == false and hasEvent(g:drainEvents(), "enemy_destroyed")
end)

test("적 총알×플레이어 시 라이프 2, player_hit", function()
  local g = newGame()
  local p = g.player
  g.enemyBullets[#g.enemyBullets + 1] = BulletModel(p.x + 4, p.y + 4, 0, 0, 4, 12, "enemy")
  g:update(FIXED_DT, IDLE)
  return g.lives == 2 and hasEvent(g:drainEvents(), "player_hit")
end)

test("라이프 0 이면 gameover + game_over 이벤트", function()
  local g = newGame()
  g.lives = 1
  local p = g.player
  g.enemyBullets[#g.enemyBullets + 1] = BulletModel(p.x + 4, p.y + 4, 0, 0, 4, 12, "enemy")
  g:update(FIXED_DT, IDLE)
  return g.state == "gameover" and hasEvent(g:drainEvents(), "game_over")
end)

-- ── 이벤트 수명 (고정 타임스텝 대비) ─────────────────────────────────────
test("한 프레임 2스텝 후에도 enemy_destroyed 보존", function()
  local g = newGame()
  local e = g.enemies[1]
  g.bullets[#g.bullets + 1] = BulletModel(e.x + 4, e.y + 4, 0, 0, 4, 12, "player")
  g:update(FIXED_DT, IDLE)
  g:update(FIXED_DT, IDLE)
  return hasEvent(g:drainEvents(), "enemy_destroyed")
end)

test("drainEvents 는 쌓인 것을 넘기고 비운다", function()
  local g = newGame()
  g:update(FIXED_DT, { move = 0, fire = true })
  local first = g:drainEvents()
  return #first > 0 and #g:drainEvents() == 0
end)

-- ── 전멸 → 재생성 ────────────────────────────────────────────────────────
test("전멸 시 편대 재생성 + formation_cleared", function()
  local g = newGame()
  for _, e in ipairs(g.enemies) do
    e.alive = false
  end
  g:update(FIXED_DT, IDLE)
  local alive = 0
  for _, e in ipairs(g.enemies) do
    if e.alive then
      alive = alive + 1
    end
  end
  return alive == 32 and hasEvent(g:drainEvents(), "formation_cleared")
end)

-- ── 1,000발 동시 충돌 (README 2-3절의 주장 검증) ─────────────────────────
test("1,000발: 적 전부 파괴 & 점수 = 적 수 × 100", function()
  local g = newGame()
  local count = #g.enemies
  for i = 1, 1000 do
    local e = g.enemies[(i - 1) % count + 1]
    g.bullets[#g.bullets + 1] = BulletModel(e.x + 4, e.y + 4, 0, 0, 4, 12, "player")
  end
  local t0 = os.clock()
  g:update(FIXED_DT, IDLE)
  local elapsed = os.clock() - t0
  local destroyed = 0
  for _, ev in ipairs(g:drainEvents()) do
    if ev.type == "enemy_destroyed" then
      destroyed = destroyed + 1
    end
  end
  print(string.format("         (1,000발 충돌 1스텝: %.4f초)", elapsed))
  return destroyed == count and g.score == count * 100
end)

-- ── 결정성 ───────────────────────────────────────────────────────────────
local function simulate(seed, steps)
  local g = newGame(seed)
  for _ = 1, steps do
    g:update(FIXED_DT, { move = 0, fire = true })
  end
  return g.score, g.lives, #g.enemyBullets
end

test("결정성: 같은 시드 → 점수·라이프·적 총알 수 동일", function()
  local s1, l1, eb1 = simulate(42, 180)
  local s2, l2, eb2 = simulate(42, 180)
  return s1 == s2 and l1 == l2 and eb1 == eb2 and s1 > 0
end)

-- ── 결과 ─────────────────────────────────────────────────────────────────
print(string.format("\n통과 %d / 실패 %d", passed, failed))
if failed > 0 then
  os.exit(1)
end

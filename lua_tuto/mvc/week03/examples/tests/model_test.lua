-- model_test.lua
-- GameModel 의 헤드리스 단위 테스트. 창(love) 없이 luajit 으로 로직만 검증한다.
-- 실행: cd lua_tuto/mvc/week03/examples/tests && luajit model_test.lua

local here = (arg[0] or ""):match("(.*/)") or "./"
package.path = here .. "../models/?.lua;" .. package.path

local GameModel = require("GameModel")
local BulletModel = require("BulletModel")

local FIXED_DT = 1 / 60

-- 아주 작은 어서션 도구
local passed, failed = 0, 0
local function check(name, cond)
  if cond then
    passed = passed + 1
    print("  ok  - " .. name)
  else
    failed = failed + 1
    print("  FAIL- " .. name)
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

-- ── 테스트 1: 발사 입력 → fire 이벤트 & 총알 생성 ─────────────────────────
do
  local g = GameModel({ width = 600, height = 800, seed = 1 })
  g:update(FIXED_DT, { move = 0, fire = true })
  check("fire 입력 시 총알 1발 생성", #g.bullets == 1)
  check("fire 이벤트 발행", hasEvent(g.events, "fire"))
end

-- ── 테스트 2: 총알이 적과 겹치면 점수 +100 & enemy_destroyed ──────────────
do
  local g = GameModel({ width = 600, height = 800, seed = 1 })
  local e = g.enemies[1]
  -- 적과 정확히 겹치는 플레이어 총알을 직접 주입
  g.bullets[#g.bullets + 1] = BulletModel(e.x + 4, e.y + 4, 0, 0, 4, 12, "player")
  g:update(FIXED_DT, { move = 0, fire = false })
  check("충돌 시 점수 +100", g.score == 100)
  check("적이 죽음", e.alive == false)
  check("enemy_destroyed 이벤트", hasEvent(g.events, "enemy_destroyed"))
end

-- ── 테스트 3: 적 총알이 플레이어에 맞으면 라이프 감소 & player_hit ─────────
do
  local g = GameModel({ width = 600, height = 800, seed = 1 })
  local p = g.player
  g.enemyBullets[#g.enemyBullets + 1] = BulletModel(p.x + 4, p.y + 4, 0, 0, 4, 12, "enemy")
  g:update(FIXED_DT, { move = 0, fire = false })
  check("피격 시 라이프 2", g.lives == 2)
  check("player_hit 이벤트", hasEvent(g.events, "player_hit"))
end

-- ── 테스트 4: 결정성 — 같은 시드/같은 입력이면 결과 동일 ───────────────────
local function simulate(seed, steps)
  local g = GameModel({ width = 600, height = 800, seed = seed })
  for i = 1, steps do
    -- 발사를 섞어 enemy fire RNG 가 돌도록 3초 분량 시뮬레이션
    g:update(FIXED_DT, { move = 0, fire = true })
  end
  return g.score, g.lives, #g.enemyBullets
end

do
  local s1, l1, eb1 = simulate(42, 180)
  local s2, l2, eb2 = simulate(42, 180)
  check("결정성: 점수 동일", s1 == s2)
  check("결정성: 라이프 동일", l1 == l2)
  check("결정성: 적 총알 수 동일", eb1 == eb2)
  check("시뮬레이션 중 점수 증가함", s1 > 0)
end

-- ── 결과 ─────────────────────────────────────────────────────────────────
print(string.format("\n통과 %d / 실패 %d", passed, failed))
if failed > 0 then
  os.exit(1)
end

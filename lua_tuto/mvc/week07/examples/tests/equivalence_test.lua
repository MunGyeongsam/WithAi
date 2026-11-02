-- equivalence_test.lua
-- 규칙 버전 약속을 검사한다. 6주차 GameModel(규칙 v1)과 이 앱의 GameModel 을 같은 시드·같은 입력으로 나란히 돌린다.
--   RULES_VERSION == 1 → 매 스텝 상태·이벤트가 완전히 같아야 한다(리팩터링·최적화는 동작을 바꾸지 않는다).
--   RULES_VERSION  > 1 → 어딘가에서 실제로 달라야 한다(달라지지 않는데 버전을 올리면 멀쩡한 옛 리플레이를 버리게 된다).
-- 실행: cd lua_tuto/mvc/week07/examples/tests && luajit equivalence_test.lua [galaga_final|starter]
-- (5주차 equivalence_test 를 이어받았다. 비교 대상만 4주차 → 6주차)

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_final"

local here = (arg[0] or ""):match("(.*/)") or "./"
local BASE = package.path

-- 같은 모듈 이름(GameModel 등)을 두 버전에서 각각 불러오기 위해 캐시를 비우고 경로를 바꾼다.
local MODULES = { "GameModel", "PlayerModel", "EnemyModel", "BulletModel", "BossModel", "homing", "rng", "class",
  "FormationPhase", "BossPhase", "ComboModel" }
local function loadGameModel(modelsDir)
  for _, m in ipairs(MODULES) do
    package.loaded[m] = nil
  end
  package.path = modelsDir .. "?.lua;" .. BASE
  return require("GameModel")
end

local OldGame = loadGameModel(here .. "../../../week06/examples/galaga_replay/models/")
local NewGame = loadGameModel(here .. "../" .. app .. "/models/")
local VERSION = NewGame.RULES_VERSION or 1

local DT = 1 / 60
local function num(v)
  return string.format("%.17g", v)
end

-- 두 버전이 공유하는 관찰 가능한 상태를 문자열로 만든다(새로 생긴 필드는 비교하지 않는다).
local function project(g, events)
  local out = {
    "score=" .. g.score,
    "lives=" .. g.lives,
    "state=" .. g.state,
    "phase=" .. g.phase.name,
    "px=" .. num(g.player.x),
    "cd=" .. num(g.player.cooldown),
    "mcd=" .. num(g.missileCooldown),
    "fdir=" .. g.formationDir,
    "eft=" .. num(g.enemyFireTimer),
    "rng=" .. g.rng.state,
  }
  for _, b in ipairs(g.bullets) do
    out[#out + 1] = "b" .. b.kind .. num(b.x) .. "," .. num(b.y) .. "," .. num(b.vx) .. "," .. num(b.vy)
  end
  for _, b in ipairs(g.enemyBullets) do
    out[#out + 1] = "eb" .. num(b.x) .. "," .. num(b.y) .. "," .. num(b.vx) .. "," .. num(b.vy)
  end
  for _, e in ipairs(g.enemies) do
    out[#out + 1] = "e" .. tostring(e.alive) .. num(e.x) .. "," .. num(e.y)
  end
  if g.boss then
    local bs = g.boss
    out[#out + 1] = "boss" .. bs.hp .. tostring(bs.alive) .. num(bs.x) .. "," .. num(bs.y) .. "," .. bs.dir .. "," .. num(bs.fireTimer)
  end
  for _, ev in ipairs(events) do
    if ev.type ~= "combo" then -- 새 기능의 "추가" 이벤트는 비교에서 뺀다(기존 이벤트의 순서·종류만 본다)
      out[#out + 1] = "ev:" .. ev.type
    end
  end
  return table.concat(out, "|")
end

-- 자동 조종: 가장 가까운 적(없으면 보스) 근처로 이동 + 일반 발사 + 미사일. 시드마다 조준 오프셋이 다르다.
local function autopilot(g, step, seed)
  local px = g.player.x + g.player.w * 0.5
  local bestX, bestD = nil, math.huge
  for _, e in ipairs(g.enemies) do
    if e.alive then
      local d = math.abs(e:centerX() - px)
      if d < bestD then
        bestX, bestD = e:centerX(), d
      end
    end
  end
  if not bestX and g.boss and g.boss.alive then
    bestX = g.boss:centerX()
  end
  local move = 0
  if bestX then
    local aim = bestX + math.sin(step / 40 + seed) * 60
    if math.abs(aim - px) > 4 then
      move = aim > px and 1 or -1
    end
  end
  return { move = move, fire = true, missile = step % 90 < 45 }
end

-- @return 결과 요약, 처음 달라진 스텝(없으면 nil)
local function compare(seed, maxSteps, opts)
  opts = opts or {}
  local a = OldGame({ width = 600, height = 800, seed = seed })
  local b = NewGame({ width = 600, height = 800, seed = seed })
  if opts.lives then
    a.lives, b.lives = opts.lives, opts.lives
  end
  local sawBoss, steps = false, 0
  for step = 1, maxSteps do
    local input = autopilot(a, step, seed)
    a:update(DT, input)
    b:update(DT, input)
    if opts.bossHp and a.boss and not sawBoss then
      a.boss.hp, b.boss.hp = opts.bossHp, opts.bossHp
    end
    if project(a, a:drainEvents()) ~= project(b, b:drainEvents()) then
      return { steps = step, state = a.state, score = a.score, lives = a.lives, sawBoss = sawBoss }, step
    end
    sawBoss = sawBoss or a.boss ~= nil
    steps = step
    if a.state ~= "playing" then
      break
    end
  end
  return { sawBoss = sawBoss, state = a.state, steps = steps, score = a.score, lives = a.lives }, nil
end

print(string.format("[equivalence_test] 6주차 galaga_replay(v1)  vs  %s/(v%d)", app, VERSION))

if VERSION == 1 then
  local reached, fingerprints = {}, {}
  local function note(label, r)
    reached[#reached + 1] = r
    print(string.format("         %s → %d스텝(%.1f초) 비교, 보스 %s, 결과 %s, 점수 %d",
      label, r.steps, r.steps / 60, r.sawBoss and "등장" or "미등장", r.state, r.score))
  end
  local function same(label, seed, steps, opts)
    local r, diff = compare(seed, steps, opts)
    if diff then
      error(string.format("규칙 버전이 1 인데 %d번째 스텝에서 달라짐 — 동작을 바꿨다면 RULES_VERSION 을 올려라", diff))
    end
    note(label, r)
    return r
  end

  for _, seed in ipairs({ 1, 7, 42, 99, 2024 }) do
    h.test("v1: seed " .. seed .. " 끝날 때까지(최대 120초) 매 스텝 6주차와 동일", function()
      local r = same("seed " .. seed, seed, 120 * 60, { lives = 999 })
      fingerprints[r.score .. "/" .. r.lives .. "/" .. r.steps] = true
      return true
    end)
  end
  h.test("v1: 승리 경로(보스 HP 3)도 동일하고 실제로 won 에 도달", function()
    return same("seed 42 (보스 HP 3)", 42, 120 * 60, { lives = 999, bossHp = 3 }).state == "won"
  end)
  h.test("v1: 라이프 기본값(3) 게임오버 경로도 동일", function()
    return same("seed 1 (라이프 3)", 1, 120 * 60).state == "gameover"
  end)
  h.test("비교 범위 점검: 보스전 포함 · 모두 결말까지 · 승리와 게임오버 · 시드별 다른 플레이(3가지 이상)", function()
    local boss, allEnded, won, over, distinct = false, true, false, false, 0
    for _, r in ipairs(reached) do
      boss = boss or r.sawBoss
      allEnded = allEnded and r.state ~= "playing"
      won = won or r.state == "won"
      over = over or r.state == "gameover"
    end
    for _ in pairs(fingerprints) do
      distinct = distinct + 1
    end
    if not (#reached == 7 and boss and allEnded and won and over and distinct >= 3) then
      error(string.format("판 %d, 보스 %s, 모두 결말 %s, 승리 %s, 게임오버 %s, 서로 다른 플레이 %d가지",
        #reached, tostring(boss), tostring(allEnded), tostring(won), tostring(over), distinct))
    end
    return true
  end)
else
  h.test(string.format("v%d: 6주차(v1)와 실제로 다른 결과를 낸다 (버전을 올린 근거)", VERSION), function()
    local diverged = 0
    for _, seed in ipairs({ 1, 7, 42, 99, 2024 }) do
      local _, diff = compare(seed, 120 * 60, { lives = 999 })
      if diff then
        diverged = diverged + 1
        print(string.format("         seed %d → %d번째 스텝(%.1f초)에서 처음 달라짐", seed, diff, diff / 60))
      end
    end
    return diverged > 0
  end)
end

h.finish()

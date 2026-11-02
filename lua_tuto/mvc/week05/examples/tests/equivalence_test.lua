-- equivalence_test.lua
-- 리팩터링 증명: 5주차 GameModel(진행 단계 State 분리)이 4주차 GameModel(galaga_mvc_full)과
-- 같은 시드·같은 입력에서 "매 스텝" 완전히 같은 상태·이벤트를 내는지 비교한다(특성 테스트).
-- 실행: cd lua_tuto/mvc/week05/examples/tests && luajit equivalence_test.lua [galaga_states|starter]

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_states"

local here = (arg[0] or ""):match("(.*/)") or "./"
local BASE = package.path

-- 같은 모듈 이름(GameModel 등)을 두 버전에서 각각 불러오기 위해 캐시를 비우고 경로를 바꾼다.
local MODULES = { "GameModel", "PlayerModel", "EnemyModel", "BulletModel", "BossModel", "homing", "rng", "class",
  "FormationPhase", "BossPhase" }
local function loadGameModel(modelsDir)
  for _, m in ipairs(MODULES) do
    package.loaded[m] = nil
  end
  package.path = modelsDir .. "?.lua;" .. BASE
  return require("GameModel")
end

local OldGame = loadGameModel(here .. "../../../week04/examples/galaga_mvc_full/models/")
local NewGame = loadGameModel(here .. "../" .. app .. "/models/")

local DT = 1 / 60
local function num(v)
  return string.format("%.17g", v)
end

-- 두 버전이 공유하는 관찰 가능한 상태를 문자열로 만든다(내부 구조 차이 — bossSpawned vs phase — 는 제외).
local function project(g, events)
  local out = {
    "score=" .. g.score,
    "lives=" .. g.lives,
    "state=" .. g.state,
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
    out[#out + 1] = "ev:" .. ev.type
  end
  return table.concat(out, "|")
end

-- 자동 조종: 가장 가까운 적(없으면 보스) 근처로 이동 + 일반 발사 + 미사일.
-- 시드마다 조준 오프셋을 달리해, 시드가 달라도 플레이가 같아지는 것을 막는다.
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

print("[equivalence_test] 4주차 galaga_mvc_full  vs  5주차 " .. app .. "/")

-- opts.lives: 양쪽 라이프를 똑같이 늘려 일찍 죽지 않게 한다(같은 조작이므로 비교는 공정하다).
-- opts.bossHp: 승리 경로를 보려고 양쪽 보스 HP 를 똑같이 낮춘다.
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
    local pa, pb = project(a, a:drainEvents()), project(b, b:drainEvents())
    if pa ~= pb then
      error(string.format("seed %d, %d번째 스텝에서 달라짐", seed, step))
    end
    sawBoss = sawBoss or a.boss ~= nil
    steps = step
    if a.state ~= "playing" then
      break
    end
  end
  return { sawBoss = sawBoss, state = a.state, steps = steps, score = a.score, lives = a.lives }
end

local reached, fingerprints = {}, {}
local function note(label, r)
  reached[#reached + 1] = r
  print(string.format("         %s → %d스텝(%.1f초) 비교, 보스 %s, 결과 %s, 점수 %d",
    label, r.steps, r.steps / 60, r.sawBoss and "등장" or "미등장", r.state, r.score))
end

for _, seed in ipairs({ 1, 7, 42, 99, 2024 }) do
  h.test("seed " .. seed .. ": 끝날 때까지(최대 120초) 매 스텝 상태·이벤트 동일", function()
    local r = compare(seed, 120 * 60, { lives = 999 })
    note("seed " .. seed, r)
    fingerprints[r.score .. "/" .. r.lives .. "/" .. r.steps] = true
    return true
  end)
end

h.test("승리 경로(보스 HP 3)도 매 스텝 동일하고 실제로 won 에 도달", function()
  local r = compare(42, 120 * 60, { lives = 999, bossHp = 3 })
  note("seed 42 (보스 HP 3)", r)
  return r.state == "won"
end)

h.test("라이프 기본값(3)으로 게임오버 경로도 동일", function()
  local r = compare(1, 120 * 60)
  note("seed 1 (라이프 3)", r)
  return r.state == "gameover"
end)

-- 비교가 의미 있으려면: 보스전이 포함되고, 중간에 잘리지 않고 결말까지 가고, 두 결말을 모두 거치고, 시드마다 다른 플레이여야 한다.
h.test("비교 범위 점검: 보스전 포함 · 모두 결말까지 · 승리와 게임오버 둘 다 · 시드별 다른 플레이(3가지 이상)", function()
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
  if not (boss and allEnded and won and over and distinct >= 3) then
    error(string.format("보스 %s, 모두 결말 %s, 승리 %s, 게임오버 %s, 서로 다른 플레이 %d가지",
      tostring(boss), tostring(allEnded), tostring(won), tostring(over), distinct))
  end
  return true
end)

h.finish()

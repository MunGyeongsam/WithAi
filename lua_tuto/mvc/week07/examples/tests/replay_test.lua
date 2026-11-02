-- replay_test.lua
-- 겔러그 입력 기록·리플레이를 창 없이 검사한다(5주차 씬 구조 그대로 사용).
-- 핵심: 실시간 플레이를 어떤 fps 로 했든, 기록을 다시 돌리면(어떤 배속으로든) 매 스텝 같은 판이 나온다.
-- 실행: cd lua_tuto/mvc/week07/examples/tests && luajit replay_test.lua [galaga_final|starter]  (6주차에서 가져옴 + 버전·저장)

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_final"
h.setup(app)

local SceneStack = require("SceneStack")
local GameModel = require("GameModel")
local InputRecorder = require("InputRecorder")

local function fakeCtx(seedValue)
  local ctx = { width = 600, height = 800, held = {}, quitCalled = false }
  ctx.isDown = function(k)
    return ctx.held[k] == true
  end
  -- 실제 newSeed 처럼 부를 때마다 다른 값(첫 값만 seedValue). 시드를 두 번 읽는 버그를 드러낸다.
  local calls = 0
  ctx.seed = function()
    calls = calls + 1
    return seedValue + (calls - 1) * 7919
  end
  ctx.quit = function()
    ctx.quitCalled = true
  end
  ctx.rand = function()
    return 0.5
  end
  ctx.scenes = {
    Title = require("TitleScene"),
    Play = require("PlayScene"),
    Pause = require("PauseScene"),
    Result = require("ResultScene"),
    Replay = require("ReplayScene"),
  }
  return ctx
end

-- 사람처럼 "시각"에 따라 키를 누르고 떼며 frameDt 간격으로 실시간 플레이. 게임이 끝나거나 seconds 가 지나면 멈춘다.
local function playLive(seed, frameDt, seconds)
  local ctx = fakeCtx(seed)
  local stack = SceneStack()
  stack:push(ctx.scenes.Title(ctx))
  stack:keypressed("return")
  local play = stack:top()
  local t, frames = 0, 0
  while t < seconds and play.game.state == "playing" do
    local phase = math.floor(t / 0.37) % 4 -- 0.37초마다 좌·정지·우·정지 (tick 과 안 맞는 주기)
    ctx.held.left = phase == 0
    ctx.held.right = phase == 2
    ctx.held.space = true
    ctx.held.x = (math.floor(t / 1.1) % 2) == 0
    stack:update(frameDt)
    t = t + frameDt
    frames = frames + 1
  end
  return play, stack, ctx, frames
end

-- 기록만으로 새 GameModel 을 돌린다(씬·화면 없이).
local function rerun(rec)
  local g = GameModel({ width = 600, height = 800, seed = rec.seed })
  for i = 1, #rec.steps do
    g:update(1 / 60, rec.steps[i])
  end
  g:drainEvents()
  return g
end

print("[replay_test] " .. app .. "/")

h.test("기록 = 시드 + 고정 스텝마다 입력 1개 (60fps 는 프레임당 1스텝, 20fps 는 3스텝)", function()
  local p60, _, _, f60 = playLive(42, 1 / 60, 5)
  local p20, _, _, f20 = playLive(42, 3 / 60, 5)
  -- 1/60 을 더한 시간은 부동소수점으로 5.0 에 살짝 못 미쳐 301프레임이 돈다. 그래서 숫자를 직접 쓰지 않는다.
  return p60.recording.seed == 42 and p60.recording:size() == f60 and p20.recording:size() == f20 * 3
end)

h.test("기록은 입력의 복사본이다 (재사용 테이블 함정 — 모든 칸이 같은 값이면 실패)", function()
  local play = playLive(42, 1 / 60, 5)
  local moves = {}
  for _, s in ipairs(play.recording.steps) do
    moves[s.move] = true
  end
  return moves[-1] and moves[0] and moves[1]
end)

for _, fdt in ipairs({ 1 / 60, 3 / 60, 1 / 30 }) do
  h.test(string.format("%.0ffps 실시간 플레이 → 기록만으로 다시 돌리면 최종 상태가 똑같다", 1 / fdt), function()
    local play = playLive(42, fdt, 30)
    local ok, where = h.same(h.snapshot(play.game), h.snapshot(rerun(play.recording)))
    if not ok then
      error("다른 곳: " .. where)
    end
    return play.game.score > 0
  end)
end

h.test("[한계, 그대로] 같은 '시각 기반' 키 조작이라도 60fps 와 20fps 실시간 결과는 다르다", function()
  local a, b = playLive(42, 1 / 60, 10), playLive(42, 3 / 60, 10)
  return a.game.player.x ~= b.game.player.x or a.game.score ~= b.game.score
end)

h.test("하지만 20fps 로 기록한 판을 60fps(그리고 4배속)로 재생해도 매 스텝 같은 판", function()
  local play = playLive(7, 3 / 60, 30)
  local rec = play.recording
  -- ReplayScene 을 직접 써서, 프레임마다 1스텝(60fps) 과 4배속(프레임당 4스텝) 두 방식으로 재생
  for _, speed in ipairs({ 1, 4 }) do
    local ctx = fakeCtx(0)
    local stack = SceneStack()
    stack:push(ctx.scenes.Replay(ctx, rec))
    local scene = stack:top()
    scene.speed = speed
    while not scene:done() do
      stack:update(1 / 60)
    end
    local ok, where = h.same(h.snapshot(play.game), h.snapshot(scene.game))
    if not ok then
      error("speed " .. speed .. " 다른 곳: " .. where)
    end
  end
  return true
end)

h.test("문자열로 저장했다 복원한 기록으로도 같은 판", function()
  local play = playLive(99, 1 / 60, 20)
  local back = InputRecorder.parse(play.recording:serialize())
  return back.seed == 99 and h.same(h.snapshot(play.game), h.snapshot(rerun(back)))
end)

h.test("씬 흐름: 게임이 끝나면 결과 → V → 리플레이, 끝까지 재생 → Esc → 타이틀", function()
  local play, stack = playLive(42, 1 / 60, 300)
  if play.game.state == "playing" then
    error("300초 안에 게임이 끝나지 않음")
  end
  stack:update(1 / 60) -- 결과 push
  if not stack:top().transparent then
    error("결과 화면이 안 뜸")
  end
  stack:keypressed("v")
  local replay = stack:top()
  local gfx = h.fakeGfx()
  replay.speed = 4
  while not replay:done() do
    stack:update(1 / 60)
  end
  stack:draw(gfx)
  local same = h.same(h.snapshot(play.game), h.snapshot(replay.game))
  stack:keypressed("escape")
  return same and h.printed(gfx, "REPLAY END") and stack:size() == 1 and stack:top().game == nil
end)

-- ── 7주차: 규칙 버전 + 저장/불러오기 ─────────────────────────────────────
h.test("기록 헤더에 규칙 버전이 들어가고, 저장→복원해도 유지된다", function()
  local play = playLive(42, 1 / 60, 3)
  local text = play.recording:serialize()
  local back = InputRecorder.parse(text)
  return text:find("\nversion " .. GameModel.RULES_VERSION .. "\n", 1, true) ~= nil
    and back.version == GameModel.RULES_VERSION and #back.steps == #play.recording.steps
end)

h.test("버전 줄이 없는 6주차 형식은 v1 로, 형식이 틀린 파일은 nil + 이유", function()
  local old = InputRecorder.parse("seed 5\nL10\n010")
  local bad, why = InputRecorder.parse("hello\nL10")
  return old.version == 1 and #old.steps == 2 and bad == nil and type(why) == "string"
end)

h.test("규칙 버전이 다른 기록은 재생하지 않고 VERSION MISMATCH 를 보여 준다", function()
  local rec = InputRecorder(42, GameModel.RULES_VERSION + 1)
  for _ = 1, 120 do
    rec:record({ move = 1, fire = true, missile = false })
  end
  local ctx = fakeCtx(0)
  local stack = SceneStack()
  stack:push(ctx.scenes.Replay(ctx, rec))
  local scene = stack:top()
  stack:update(1)
  local gfx = h.fakeGfx()
  stack:draw(gfx)
  return scene:done() and scene.cursor == 0 and h.printed(gfx, "VERSION MISMATCH")
end)

h.test("결과 화면 S → 저장, 타이틀 L → 저장한 판을 처음부터 똑같이 재생", function()
  local ctx = h.fakeCtx()
  local stack = SceneStack()
  stack:push(ctx.scenes.Title(ctx))
  stack:keypressed("return")
  local play = stack:top()
  ctx.held.space, ctx.held.left = true, true
  local frames = 0
  while play.game.state == "playing" and frames < 60 * 300 do
    stack:update(1 / 60)
    frames = frames + 1
  end
  stack:update(1 / 60) -- 결과 push
  stack:keypressed("s")
  local gfx = h.fakeGfx()
  stack:draw(gfx)
  if not (ctx.files["replay.txt"] and h.printed(gfx, "SAVED")) then
    error("저장되지 않음")
  end
  stack:keypressed("return") -- 타이틀
  stack:keypressed("l")
  local replay = stack:top()
  replay.speed = 4
  while not replay:done() do
    stack:update(1 / 60)
  end
  return replay.recording ~= play.recording and h.same(h.snapshot(play.game), h.snapshot(replay.game))
end)

h.test("타이틀 L: 저장된 게 없으면 NO SAVED REPLAY, 깨진 파일이면 INVALID REPLAY FILE (씬은 그대로)", function()
  local ctx = h.fakeCtx()
  local stack = SceneStack()
  stack:push(ctx.scenes.Title(ctx))
  stack:keypressed("l")
  local g1 = h.fakeGfx()
  stack:draw(g1)
  ctx.files["replay.txt"] = "not a replay"
  stack:keypressed("l")
  local g2 = h.fakeGfx()
  stack:draw(g2)
  return h.printed(g1, "NO SAVED REPLAY") and h.printed(g2, "INVALID REPLAY FILE") and stack:top().game == nil
end)

h.finish()

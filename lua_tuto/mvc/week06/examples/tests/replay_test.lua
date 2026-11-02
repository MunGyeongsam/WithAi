-- replay_test.lua
-- 겔러그 입력 기록·리플레이를 창 없이 검사한다(5주차 씬 구조 그대로 사용).
-- 핵심: 실시간 플레이를 어떤 fps 로 했든, 기록을 다시 돌리면(어떤 배속으로든) 매 스텝 같은 판이 나온다.
-- 실행: cd lua_tuto/mvc/week06/examples/tests && luajit replay_test.lua [galaga_replay|starter_galaga]

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_replay"
h.setupGalaga(app)

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

h.finish()

-- equivalence_test.lua
-- 여섯 구조가 같은 규칙을 지키는가: 같은 시드 + 같은 입력 대본 → 매 단계 같은 상태.
-- "구조를 바꿔도 게임은 그대로"라는 약속을 숫자로 확인한다(7주차 equivalence_test 와 같은 생각).
-- 실행: cd lua_tuto/mvc/week08_more/examples/tests && luajit equivalence_test.lua

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local helper = require("helper")

local SEEDS = { 1, 42, 2026, 99991 }
local STEPS = 300

--- 테스트 전용 대본: 게임과 다른 곱수(16807)의 난수로 tick/left/right 를 섞는다.
local function makeScript(seed)
  local s, out = seed, {}
  for i = 1, STEPS do
    s = (s * 16807) % 2147483647
    local r = s % 10
    out[i] = r < 6 and "tick" or (r < 8 and "left" or "right")
  end
  return out
end

-- 앱마다 "시작 · 한 걸음 · 요약"만 맞춰 주는 얇은 어댑터. 요약: score hp lane ticks over items
local DRIVERS = {
  catch_mvc = function(seed)
    local R = require("rules")
    local m = require("CatchModel")(seed)
    local c = require("CatchController")(m)
    return {
      step = function(a)
        if a == "tick" then
          c:update(R.TICK)
        else
          c:keypressed(a)
        end
      end,
      summary = function()
        return { m.score, m.hp, m.lane, m.ticks, m.over, #m.items }
      end,
    }
  end,

  catch_mvp = function(seed)
    local R = require("rules")
    local m = require("CatchModel")(seed)
    local p = require("CatchPresenter")(m, require("CatchView")())
    return {
      step = function(a)
        if a == "tick" then
          p:update(R.TICK)
        else
          p:onKey(a)
        end
      end,
      summary = function()
        return { m.score, m.hp, m.lane, m.ticks, m.over, #m.items }
      end,
    }
  end,

  catch_mvvm = function(seed)
    local R = require("rules")
    local m = require("CatchModel")(seed)
    local vm = require("CatchViewModel")(m)
    local view = require("CatchView")(vm)
    return {
      step = function(a)
        if a == "tick" then
          vm:update(R.TICK)
        else
          view:keypressed(a)
        end
      end,
      summary = function()
        return { m.score, m.hp, m.lane, m.ticks, m.over, #m.items }
      end,
    }
  end,

  catch_tea = function(seed)
    local R = require("rules")
    local rt = require("Runtime")(require("catch"), seed)
    return {
      step = function(a)
        if a == "tick" then
          rt:update(R.TICK)
        else
          rt:keypressed(a)
        end
      end,
      summary = function()
        local m = rt.model
        return { m.score, m.hp, m.lane, m.ticks, m.over, #m.items }
      end,
    }
  end,

  catch_ecs = function(seed)
    local g = require("CatchGame")({ seed = seed })
    return {
      step = function(a)
        if a == "tick" then
          g:tick()
        else
          g:move(a == "left" and -1 or 1)
        end
      end,
      summary = function()
        local s = g:summary()
        return { s.score, s.hp, s.lane, s.ticks, s.over, s.items }
      end,
    }
  end,

  catch_hex = function(seed)
    local g = require("CatchGame")({
      random = require("PrngRandom")(seed),
      scores = require("MemoryScores")(),
    })
    return {
      step = function(a)
        if a == "tick" then
          g:tick()
        else
          g:move(a == "left" and -1 or 1)
        end
      end,
      summary = function()
        return { g.score, g.hp, g.lane, g.ticks, g.over, #g.items }
      end,
    }
  end,
}

local APPS = { "catch_mvc", "catch_mvp", "catch_mvvm", "catch_tea", "catch_ecs", "catch_hex" }

--- 앱 하나를 대본대로 돌려 매 단계 요약을 문자열로 남긴다.
local function trace(app, seed, script)
  return helper.withApp(app, function()
    local d = DRIVERS[app](seed)
    local out = {}
    for i, a in ipairs(script) do
      d.step(a)
      local s = d.summary()
      out[i] = table.concat({ tostring(s[1]), s[2], s[3], s[4], tostring(s[5]), s[6] }, ",")
    end
    return out
  end)
end

print("[equivalence_test] 여섯 구조, 같은 규칙")

local finals = {}
for _, seed in ipairs(SEEDS) do
  local script = makeScript(seed)
  local base = trace("catch_mvc", seed, script)
  finals[#finals + 1] = base[#base]
  for i = 2, #APPS do
    local app = APPS[i]
    helper.test(string.format("seed %-5d %-10s = catch_mvc (%d 단계)", seed, app, STEPS), function()
      local t = trace(app, seed, script)
      for step = 1, STEPS do
        if t[step] ~= base[step] then
          error(string.format("%d 단계에서 다름: %s ≠ %s", step, t[step], base[step]))
        end
      end
      return true
    end)
  end
end

helper.test("대본이 헛돌지 않는다: 점수가 난 판과 게임 오버된 판이 모두 있다", function()
  local scored, ended = false, false
  for _, f in ipairs(finals) do
    local score, _, _, _, over = f:match("^(%d+),(%d+),(%d+),(%d+),(%a+)")
    scored = scored or tonumber(score) > 0
    ended = ended or over == "true"
    print("        최종 " .. f)
  end
  return scored and ended
end)

helper.finish()

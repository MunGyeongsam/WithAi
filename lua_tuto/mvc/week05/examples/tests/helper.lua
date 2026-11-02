-- helper.lua
-- 5주차 헤드리스 테스트 공용 도구: 경로 설정, 테스트 러너, 가짜 그래픽, 가짜 씬 문맥(ctx).
-- (4주차 helper 에 scenes/ 경로와 fakeCtx 를 더했다)

local helper = {}

--- 테스트 대상 앱 폴더를 require 경로에 등록한다.
-- main.lua 의 love.filesystem.setRequirePath 와 같은 규칙을 package.path 로 흉내 낸다.
function helper.setup(appName)
  local here = (arg[0] or ""):match("(.*/)") or "./"
  local root = here .. "../" .. appName .. "/"
  package.path = table.concat({
    root .. "models/?.lua",
    root .. "views/?.lua",
    root .. "controllers/?.lua",
    root .. "scenes/?.lua",
    package.path,
  }, ";")
  helper.root = root
  return root
end

local passed, failed = 0, 0

-- 각 테스트를 pcall 로 감싸 미완성 코드가 에러를 내도 계속 진행한다.
function helper.test(name, fn)
  local ok, res = pcall(fn)
  -- 반드시 true 여야 통과. `a and b` 가 nil 을 내도 실패로 본다(6주차 검토에서 발견한 러너 버그).
  if ok and res == true then
    passed = passed + 1
    print("  ok   - " .. name)
  else
    failed = failed + 1
    local reason = ok and "조건 불일치" or tostring(res):gsub("^.-:%d+: ", "")
    print("  FAIL - " .. name .. "  (" .. reason .. ")")
  end
end

function helper.finish()
  print(string.format("\n통과 %d / 실패 %d", passed, failed))
  if failed > 0 then
    os.exit(1)
  end
end

--- love.graphics 대신 넘기는 가짜. 어떤 함수든 호출되면 이름과 인자를 기록만 한다.
function helper.fakeGfx()
  local calls = {}
  local gfx = setmetatable({ calls = calls }, {
    __index = function(t, name)
      local fn = function(...)
        calls[#calls + 1] = { name = name, args = { ... } }
      end
      rawset(t, name, fn)
      return fn
    end,
  })
  return gfx
end

function helper.count(gfx, name)
  local n = 0
  for _, c in ipairs(gfx.calls) do
    if c.name == name then
      n = n + 1
    end
  end
  return n
end

--- 테이블을 숫자/문자열/불리언만 남겨 깊게 복사한다(함수·메타테이블 무시). 변경 감지용.
function helper.snapshot(value, seen)
  if type(value) ~= "table" then
    return value
  end
  seen = seen or {}
  if seen[value] then
    return seen[value]
  end
  local copy = {}
  seen[value] = copy
  for k, v in pairs(value) do
    if type(v) ~= "function" then
      copy[k] = helper.snapshot(v, seen)
    end
  end
  return copy
end

--- 두 스냅숏이 같은지 비교. 다르면 false, 경로 문자열 반환.
function helper.same(a, b, path)
  path = path or "game"
  if type(a) ~= type(b) then
    return false, path
  end
  if type(a) ~= "table" then
    return a == b, path
  end
  for k, v in pairs(a) do
    local ok, where = helper.same(v, b[k], path .. "." .. tostring(k))
    if not ok then
      return false, where
    end
  end
  for k in pairs(b) do
    if a[k] == nil then
      return false, path .. "." .. tostring(k)
    end
  end
  return true
end

--- 고정 순서로 0~1 값을 돌려주는 난수 대용(연출 테스트용).
function helper.fixedRand()
  local i = 0
  return function()
    i = i % 10 + 1
    return i / 10 - 0.05
  end
end

--- main.lua 의 ctx 를 흉내 낸 가짜. 눌린 키는 ctx.held[키] = true 로 조작한다.
-- ctx.seeds: 새 게임이 만들어진 횟수 / ctx.quitCalled: 종료 요청 여부
function helper.fakeCtx()
  local ctx = { width = 600, height = 800, held = {}, seeds = 0, quitCalled = false }
  ctx.isDown = function(k)
    return ctx.held[k] == true
  end
  ctx.seed = function()
    ctx.seeds = ctx.seeds + 1
    return ctx.seeds
  end
  ctx.quit = function()
    ctx.quitCalled = true
  end
  ctx.rand = helper.fixedRand()
  ctx.scenes = {
    Title = require("TitleScene"),
    Play = require("PlayScene"),
    Pause = require("PauseScene"),
    Result = require("ResultScene"),
  }
  return ctx
end

return helper

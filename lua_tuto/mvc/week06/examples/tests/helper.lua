-- helper.lua
-- 6주차 헤드리스 테스트 공용 도구.

local helper = {}

local here = (arg[0] or ""):match("(.*/)") or "./"
helper.here = here

--- Snake 앱 폴더들을 require 경로에 등록(main.lua 의 setRequirePath 와 같은 규칙).
function helper.setupSnake(appName)
  local root = here .. "../" .. (appName or "snake_flux") .. "/"
  package.path = table.concat({
    root .. "?.lua",
    root .. "core/?.lua",
    root .. "flux/?.lua",
    root .. "game/?.lua",
    root .. "views/?.lua",
    root .. "controllers/?.lua",
    package.path,
  }, ";")
  return root
end

--- 겔러그(5주차 구조) 앱 폴더들을 require 경로에 등록.
function helper.setupGalaga(appName)
  local root = here .. "../" .. (appName or "galaga_replay") .. "/"
  package.path = table.concat({
    root .. "models/?.lua",
    root .. "views/?.lua",
    root .. "controllers/?.lua",
    root .. "scenes/?.lua",
    package.path,
  }, ";")
  return root
end

local passed, failed = 0, 0

function helper.test(name, fn)
  local ok, res = pcall(fn)
  -- 반드시 true 여야 통과. `a and b` 가 nil 을 내도 실패로 본다(이전 러너는 nil 을 통과로 봤다).
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

function helper.fakeGfx()
  local calls = {}
  return setmetatable({ calls = calls }, {
    __index = function(t, name)
      local fn = function(...)
        calls[#calls + 1] = { name = name, args = { ... } }
      end
      rawset(t, name, fn)
      return fn
    end,
  })
end

function helper.printed(gfx, text)
  for _, c in ipairs(gfx.calls) do
    if (c.name == "print" or c.name == "printf") and tostring(c.args[1]):find(text, 1, true) then
      return true
    end
  end
  return false
end

--- 함수를 뺀 깊은 복사(변경 감지용). 공유된 하위 테이블도 따라간다.
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

function helper.same(a, b, path)
  path = path or "state"
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

return helper

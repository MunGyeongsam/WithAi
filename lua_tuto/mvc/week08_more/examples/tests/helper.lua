-- helper.lua
-- 8주차(심화) 헤드리스 테스트 공용 도구.

local helper = {}

local here = (arg[0] or ""):match("(.*/)") or "./"
helper.here = here

-- 각 앱 main.lua 의 setRequirePath 와 같은 규칙.
helper.DIRS = {
  catch_mvc = { "", "models/", "views/", "controllers/" },
  catch_mvp = { "", "models/", "views/", "presenters/" },
  catch_mvvm = { "", "core/", "models/", "viewmodels/", "views/" },
  catch_tea = { "", "tea/" },
  catch_ecs = { "", "ecs/", "game/", "systems/" },
  catch_hex = { "", "core/", "adapters/" },
}

function helper.root(app)
  return here .. "../" .. app .. "/"
end

function helper.setup(app)
  local root = helper.root(app)
  local paths = {}
  for _, dir in ipairs(helper.DIRS[app]) do
    paths[#paths + 1] = root .. dir .. "?.lua"
  end
  paths[#paths + 1] = package.path
  package.path = table.concat(paths, ";")
  return root
end

--- 앱 하나를 격리해 불러 fn 을 실행한다. 여러 앱이 같은 모듈 이름(rules, CatchModel…)을 써도 섞이지 않는다.
function helper.withApp(app, fn)
  local savedPath = package.path
  local before = {}
  for name in pairs(package.loaded) do
    before[name] = true
  end
  helper.setup(app)
  local ok, res = pcall(fn)
  package.path = savedPath
  for name in pairs(package.loaded) do
    if not before[name] then
      package.loaded[name] = nil
    end
  end
  if not ok then
    error(res, 0)
  end
  return res
end

function helper.readFile(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local text = f:read("*a")
  f:close()
  return text
end

local passed, failed = 0, 0

function helper.test(name, fn)
  local ok, res = pcall(fn)
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

--- 함수를 뺀 깊은 복사(변경 감지용).
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
  path = path or "value"
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

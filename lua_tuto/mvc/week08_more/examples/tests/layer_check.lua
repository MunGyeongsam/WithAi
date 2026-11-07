-- layer_check.lua
-- 여섯 앱의 "누가 누구를 알면 안 되는가"를 정적으로 검사한다(주석 제외). main.lua·conf.lua 는 검사하지 않는다.
-- 문자열 검사는 근사치다. 동작은 각 *_test 가 따로 확인한다.
-- 실행: cd lua_tuto/mvc/week08_more/examples/tests && luajit layer_check.lua

local here = (arg[0] or ""):match("(.*/)") or "./"

local function req(name, why)
  return { pattern = "require%s*%(?%s*[\"']" .. name .. "[\"']", why = why or (name .. " require") }
end

local LOVE = { pattern = "[^%w_]love[^%w_]", why = "love (main.lua 만 love 를 안다)" }
local PURE = {
  LOVE,
  { pattern = "[^%w_%.:]print%s*%(", why = "print (gfx.print 는 괜찮다)" },
  { pattern = "[^%w_]io%.", why = "io" },
  { pattern = "os%.time", why = "os.time (시드는 주입받는다)" },
  { pattern = "math%.random", why = "math.random (결정성)" },
}

local function with(base, extra)
  local out = {}
  for _, r in ipairs(base) do
    out[#out + 1] = r
  end
  for _, r in ipairs(extra or {}) do
    out[#out + 1] = r
  end
  return out
end

local APPS = {
  catch_mvc = {
    ["models/"] = with(PURE, { req("CatchView"), req("CatchController") }),
    ["views/"] = { LOVE, req("CatchController"), { pattern = "model%.[%w_]+%s*=[^=]", why = "Model 필드 대입 (View 는 읽기만)" } },
    ["controllers/"] = { LOVE, req("CatchView") },
  },
  catch_mvp = {
    ["models/"] = with(PURE, { req("CatchView"), req("CatchPresenter") }),
    ["views/"] = { LOVE, req("CatchModel", "Model require (Passive View 는 Model 을 모른다)"), req("CatchPresenter") },
    ["presenters/"] = { LOVE, req("CatchView", "View require (View 는 주입받는다)") },
  },
  catch_mvvm = {
    ["core/"] = { LOVE },
    ["models/"] = with(PURE, { req("CatchView"), req("CatchViewModel") }),
    ["viewmodels/"] = { LOVE, req("CatchView", "View require (ViewModel 은 View 를 모른다)") },
    ["views/"] = { LOVE, req("CatchModel", "Model require (View 는 ViewModel 만 안다)") },
  },
  catch_tea = {
    ["tea/"] = { LOVE },
    ["tea/catch.lua"] = with(PURE, { req("Runtime", "Runtime require (프로그램은 런타임을 모른다)") }),
  },
  catch_ecs = {
    ["ecs/"] = with(PURE, { req("CatchGame"), req("kinds") }),
    ["systems/"] = with(PURE, { req("CatchGame", "CatchGame require (시스템은 World 만 받는다)") }),
    ["game/"] = PURE,
  },
  catch_hex = {
    ["core/"] = with(PURE, {
      req("PrngRandom", "어댑터 require (코어는 포트만 안다)"),
      req("ScriptedRandom", "어댑터 require"),
      req("MemoryScores", "어댑터 require"),
      req("FileScores", "어댑터 require"),
      req("Renderer", "어댑터 require"),
    }),
    ["adapters/"] = { LOVE },
  },
}

local IS_WINDOWS = package.config:sub(1, 1) == "\\"

local function listLua(dir)
  local cmd
  if IS_WINDOWS then
    cmd = 'dir /b "' .. (dir:gsub("/", "\\")) .. '" 2>nul'
  else
    cmd = 'ls "' .. dir .. '" 2>/dev/null'
  end
  local files = {}
  local p = io.popen(cmd)
  if p then
    for name in p:lines() do
      if name:match("%.lua$") and name ~= "main.lua" and name ~= "conf.lua" then
        files[#files + 1] = name
      end
    end
    p:close()
  end
  return files
end

local function stripComments(src)
  src = src:gsub("%-%-%[%[.-%]%]", "")
  return (" " .. src:gsub("%-%-[^\n]*", "") .. " ")
end

local violations, checked = 0, 0

local function checkFile(app, path, rules)
  local f = io.open(path, "r")
  if not f then
    return
  end
  local src = stripComments(f:read("*a"))
  f:close()
  checked = checked + 1
  for _, rule in ipairs(rules) do
    if src:find(rule.pattern) then
      violations = violations + 1
      print(string.format("  FAIL - %s/%s : %s", app, path:match("[^/]+/[^/]+$"), rule.why))
    end
  end
end

print("[layer_check] 계층 규칙")
local appNames = {}
for app in pairs(APPS) do
  appNames[#appNames + 1] = app
end
table.sort(appNames)

for _, app in ipairs(appNames) do
  local root = here .. "../" .. app .. "/"
  local before = violations
  for target, rules in pairs(APPS[app]) do
    if target:match("%.lua$") then
      checkFile(app, root .. target, rules)
    else
      for _, name in ipairs(listLua(root .. target)) do
        checkFile(app, root .. target .. name, rules)
      end
    end
  end
  if violations == before then
    print("  ok   - " .. app)
  end
end

if checked == 0 then
  print("  FAIL - 검사한 파일이 없다(경로 확인)")
  violations = violations + 1
end

print(string.format("\n검사 %d 파일 · 통과 %d / 실패 %d", checked, violations == 0 and 1 or 0, violations))
if violations > 0 then
  os.exit(1)
end

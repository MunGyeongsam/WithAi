-- layer_check.lua
-- Flux 구조의 규칙을 정적으로 검사한다(주석 제외). love 를 아는 파일은 main.lua 하나뿐이어야 한다.
--   game/        : 순수 규칙 — print·io·love 금지, Store·Dispatcher require 금지, os.time·math.random 금지(결정성)
--   flux/        : love 금지
--   views/       : love 금지, dispatch 금지(View 는 읽기만)
--   controllers/ : love 금지, 상태 직접 대입 금지(Action 으로만)
--   App.lua      : love 금지
-- 겔러그(galaga_replay|starter_galaga) 는 5주차 규칙 + models/ 의 os.time·math.random 금지.
-- 실행: cd lua_tuto/mvc/week06/examples/tests && luajit layer_check.lua [snake_flux|starter|galaga_replay|starter_galaga]

local here = (arg[0] or ""):match("(.*/)") or "./"
local app = arg[1] or "snake_flux"
local root = here .. "../" .. app .. "/"

local LOVE = { pattern = "[^%w_]love[^%w_]", why = "love (main.lua 만 love 를 안다)" }

local RULES = {
  ["game/"] = {
    LOVE,
    { pattern = "[^%w_]print[^%w_]", why = "print" },
    { pattern = "[^%w_]io[^%w_]", why = "io" },
    { pattern = "os%.time", why = "os.time (시드는 Action 으로 받는다)" },
    { pattern = "math%.random", why = "math.random (prng 상태를 state 에 둔다)" },
    { pattern = "require%s*%(?%s*[\"']Store[\"']", why = "Store require (규칙은 저장소를 모른다)" },
    { pattern = "require%s*%(?%s*[\"']Dispatcher[\"']", why = "Dispatcher require" },
  },
  ["flux/"] = { LOVE },
  ["views/"] = {
    LOVE,
    { pattern = "dispatch", why = "dispatch (View 는 읽기만 한다)" },
  },
  ["controllers/"] = {
    LOVE,
    { pattern = "[^%w_]state%.[%w_]+%s*=[^=]", why = "state 직접 대입 (Action 으로만 바꾼다)" },
    { pattern = "%.state%s*=[^=]", why = "state 직접 대입 (Action 으로만 바꾼다)" },
  },
  [""] = { LOVE }, -- 앱 루트의 App.lua (main.lua 는 제외)
}

local VIEW_REQ = { pattern = "require%s*%(?%s*[\"'][%w_]*View[\"']", why = "View require" }
local CTRL_REQ = { pattern = "require%s*%(?%s*[\"'][%w_]*Controller[\"']", why = "Controller require" }
local SCENE_REQ = { pattern = "require%s*%(?%s*[\"'][%w_]+Scene[\"']", why = "Scene require (ctx.scenes 를 쓴다)" }

if app:find("galaga") then
  RULES = {
    ["models/"] = {
      LOVE,
      { pattern = "[^%w_]print[^%w_]", why = "print" },
      { pattern = "[^%w_]io[^%w_]", why = "io" },
      { pattern = "os%.time", why = "os.time (시드는 주입받는다)" },
      { pattern = "math%.random", why = "math.random (리플레이가 깨진다)" },
      VIEW_REQ,
      CTRL_REQ,
    },
    ["views/"] = { LOVE, CTRL_REQ },
    ["controllers/"] = { LOVE, VIEW_REQ, SCENE_REQ },
    ["scenes/"] = { LOVE, SCENE_REQ },
  }
end

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

local violations, scanned = 0, 0
for folder, rules in pairs(RULES) do
  local dir = root .. folder
  for _, name in ipairs(listLua(dir)) do
    scanned = scanned + 1
    local f = assert(io.open(dir .. name, "r"))
    local lineNo = 0
    for line in f:lines() do
      lineNo = lineNo + 1
      local code = " " .. line:gsub("%-%-.*$", "") .. " "
      for _, rule in ipairs(rules) do
        if code:find(rule.pattern) then
          violations = violations + 1
          print(string.format("FAIL  %s%s:%d  [%s]  %s", folder, name, lineNo, rule.why, (line:gsub("^%s+", ""))))
        end
      end
    end
    f:close()
  end
end

print(string.format("[layer_check] %s/  파일 %d개 검사", app, scanned))
if scanned == 0 then
  print("❌ 검사할 파일이 없다. 앱 이름을 확인하라.")
  os.exit(1)
elseif violations > 0 then
  print(string.format("❌ 계층 규칙 위반 %d건", violations))
  os.exit(1)
else
  print("✅ OK: 계층 규칙 위반 0건")
end

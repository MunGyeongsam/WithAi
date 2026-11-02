-- layer_check.lua
-- 계층 규칙을 정적으로 검사한다(주석 제외, 식별자 경계 기준). love 를 아는 파일은 main.lua 하나뿐이어야 한다.
--   models/      : print · io · love 금지, View/Controller require 금지
--   views/       : love 금지(주입받은 gfx 만), Controller require 금지
--   controllers/ : love 금지(주입받은 isDown 만, 종료는 main), View·Scene require 금지
--   scenes/      : love 금지(ctx 로만 받는다), 다른 Scene require 금지(ctx.scenes 사용)
-- 실행: cd lua_tuto/mvc/week05/examples/tests && luajit layer_check.lua [galaga_states|starter]

local here = (arg[0] or ""):match("(.*/)") or "./"
local app = arg[1] or "galaga_states"
local root = here .. "../" .. app .. "/"

local RULES = {
  models = {
    { pattern = "[^%w_]print[^%w_]", why = "print (Model 은 출력 장치를 모른다)" },
    { pattern = "[^%w_]io[^%w_]", why = "io" },
    { pattern = "[^%w_]love[^%w_]", why = "love" },
    { pattern = "require%s*%(?%s*[\"'][%w_]*View[\"']", why = "View require" },
    { pattern = "require%s*%(?%s*[\"'][%w_]*Controller[\"']", why = "Controller require" },
  },
  views = {
    { pattern = "[^%w_]love[^%w_]", why = "love (View 는 주입받은 gfx 만 쓴다)" },
    { pattern = "require%s*%(?%s*[\"'][%w_]*Controller[\"']", why = "Controller require" },
  },
  controllers = {
    { pattern = "[^%w_]love[^%w_]", why = "love (Controller 는 주입받은 isDown 만 쓴다, 종료는 main)" },
    { pattern = "require%s*%(?%s*[\"'][%w_]*View[\"']", why = "View require" },
    { pattern = "require%s*%(?%s*[\"'][%w_]*Scene[\"']", why = "Scene require (화면 흐름은 씬의 일)" },
  },
  scenes = {
    { pattern = "[^%w_]love[^%w_]", why = "love (씬은 ctx 로만 받는다)" },
    { pattern = "require%s*%(?%s*[\"'][%w_]+Scene[\"']", why = "다른 Scene require (순환 위험, ctx.scenes 를 쓴다)" },
  },
}

local IS_WINDOWS = package.config:sub(1, 1) == "\\"

-- 폴더의 .lua 목록. 표준 라이브러리에 디렉터리 함수가 없어 OS 명령을 쓴다.
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
      if name:match("%.lua$") then
        files[#files + 1] = name
      end
    end
    p:close()
  end
  return files
end

local violations, scanned = 0, 0

for layer, rules in pairs(RULES) do
  local dir = root .. layer .. "/"
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
          print(string.format("FAIL  %s/%s:%d  [%s]  %s", layer, name, lineNo, rule.why, (line:gsub("^%s+", ""))))
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

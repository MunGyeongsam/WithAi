-- globals_check.lua
-- 암묵적 전역을 찾는다. 두 겹으로 검사한다.
--   ① 정적(LuaJIT 에서만): `luajit -bl` 바이트코드 목록에서 GSET(전역 쓰기)과,
--      표준 라이브러리에 없는 이름의 GGET(오타·정의 안 된 전역 읽기)을 찾는다. 실행되지 않는 줄도 잡는다.
--   ② 실행: _G 를 잠근 뒤 모든 모듈을 불러 타이틀→플레이→결과→저장→리플레이→타이틀을 한 바퀴 돈다.
--      정적 검사가 못 보는 `_G[name] = …` 같은 동적 접근을 잡는다. 대신 실행된 경로만 본다.
-- 실행: cd lua_tuto/mvc/week07/examples/tests && luajit globals_check.lua [galaga_final|starter]

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_final"
local root = h.setup(app)

local FOLDERS = { "models/", "views/", "controllers/", "scenes/" }
local IS_WINDOWS = package.config:sub(1, 1) == "\\"

local function listLua(dir)
  local cmd = IS_WINDOWS and ('dir /b "' .. (dir:gsub("/", "\\")) .. '" 2>nul') or ('ls "' .. dir .. '" 2>/dev/null')
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

-- 지금 _G 에 있는 이름 = 허용되는 전역(표준 라이브러리). 검사 도구가 만든 것은 빼고 시작한다.
local STANDARD = {}
for k in pairs(_G) do
  STANDARD[k] = true
end

print("[globals_check] " .. app .. "/")

-- ① 정적 검사
local staticIssues, files = 0, {}
for _, folder in ipairs(FOLDERS) do
  for _, name in ipairs(listLua(root .. folder)) do
    files[#files + 1] = { folder = folder, name = name, path = root .. folder .. name }
  end
end

local interp = arg[-1] or "luajit"
if not jit then
  print("  (정적 검사 생략: LuaJIT 가 아니다. luajit 로 실행하면 실행되지 않는 줄까지 검사한다)")
else
  for _, f in ipairs(files) do
    local p = io.popen(interp .. ' -bl "' .. f.path .. '" 2>&1')
    local out = p and p:read("*a") or ""
    if p then
      p:close()
    end
    if not out:find("BYTECODE", 1, true) then
      print("  (정적 검사 실패: " .. interp .. " -bl 출력이 없다 — " .. f.name .. ")")
      staticIssues = staticIssues + 1
    end
    for op, gname in out:gmatch("(G[SG]ET)%s+%d+%s+%d+%s+; \"([%w_]+)\"") do
      if op == "GSET" then
        staticIssues = staticIssues + 1
        print(string.format("  FAIL  %s%s  전역 쓰기 '%s'", f.folder, f.name, gname))
      elseif not STANDARD[gname] then
        staticIssues = staticIssues + 1
        print(string.format("  FAIL  %s%s  정의 안 된 전역 읽기 '%s' (오타? love?)", f.folder, f.name, gname))
      end
    end
  end
  print(string.format("  정적: 파일 %d개, 문제 %d건", #files, staticIssues))
end

-- ② 실행 검사: 이제부터 새 전역 쓰기·없는 전역 읽기는 즉시 에러
local runtimeIssue
setmetatable(_G, {
  __newindex = function(_, k)
    error("전역 쓰기: " .. tostring(k), 2)
  end,
  __index = function(_, k)
    error("정의 안 된 전역 읽기: " .. tostring(k), 2)
  end,
})

local ok, err = pcall(function()
  for _, f in ipairs(files) do
    require((f.name:gsub("%.lua$", "")))
  end
  local SceneStack = require("SceneStack")
  local ctx = h.fakeCtx()
  local stack = SceneStack()
  stack:push(ctx.scenes.Title(ctx))
  stack:keypressed("return")
  ctx.held.space, ctx.held.x = true, true
  local frames = 0
  repeat
    ctx.held.left = (frames % 120) < 60
    ctx.held.right = not ctx.held.left
    stack:update(1 / 60)
    stack:draw(h.fakeGfx())
    frames = frames + 1
  until stack:top().transparent or frames > 60 * 600
  if not stack:top().transparent then
    error("10분 안에 결과 화면이 나오지 않음")
  end
  stack:keypressed("p") -- 결과 화면에선 무시되어야 함
  stack:keypressed("s")
  stack:keypressed("v")
  stack:top().speed = 4
  while not stack:top():done() do
    stack:update(1 / 60)
  end
  stack:draw(h.fakeGfx())
  stack:keypressed("escape")
  stack:keypressed("l")
  stack:update(1 / 60)
  stack:draw(h.fakeGfx())
  stack:keypressed("escape")
  stack:draw(h.fakeGfx())
end)
setmetatable(_G, nil)
if not ok then
  runtimeIssue = tostring(err)
  print("  FAIL  실행 중: " .. runtimeIssue)
else
  print("  실행: 타이틀→플레이→결과→저장→리플레이→불러오기→타이틀 경로에서 전역 접근 없음")
end

if staticIssues > 0 or runtimeIssue then
  print("❌ 전역 문제 있음")
  os.exit(1)
end
print("✅ OK: 암묵적 전역 0건")

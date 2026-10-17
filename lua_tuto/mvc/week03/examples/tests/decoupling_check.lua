-- decoupling_check.lua
-- models/ 안의 모든 .lua 파일을 스캔해 "love" 참조가 있으면 실패시킨다.
-- 핵심: Model 은 love 를 한 글자도 몰라야 한다. 창 없이 luajit 으로 실행.
-- 실행: cd lua_tuto/mvc/week03/examples/tests && luajit decoupling_check.lua

local here = (arg[0] or ""):match("(.*/)") or "./"
local modelsDir = here .. "../models/"

local files = {
  "class.lua",
  "rng.lua",
  "PlayerModel.lua",
  "EnemyModel.lua",
  "BulletModel.lua",
  "GameModel.lua",
}

local failed = false

for _, name in ipairs(files) do
  local path = modelsDir .. name
  local f = assert(io.open(path, "r"), "파일 없음: " .. path)
  local lineNo = 0
  for line in f:lines() do
    lineNo = lineNo + 1
    -- 주석(--)이 아닌 실제 코드에서 love 참조를 찾는다.
    local code = line:gsub("%-%-.*$", "")
    if code:find("love%s*%.") or code:find("[^%w_]love[^%w_]") or code:find("^love[^%w_]") then
      print(string.format("FAIL  %s:%d  → %s", name, lineNo, line:gsub("^%s+", "")))
      failed = true
    end
  end
  f:close()
end

if failed then
  print("\n❌ Model 에 love 의존이 남아 있다. 디커플링 실패.")
  os.exit(1)
else
  print("✅ OK: models/ 에 love 참조 0건. 디커플링 성공.")
end

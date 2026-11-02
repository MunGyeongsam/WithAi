-- decoupling_check.lua
-- models/ 안의 모든 .lua 파일을 스캔해 print / io / love 참조가 있으면 실패시킨다.
-- 핵심: Model 은 출력·입력·love 를 한 글자도 몰라야 한다. 창 없이 luajit 으로 실행.
-- 실행: cd lua_tuto/mvc/week03/examples/tests
--   luajit decoupling_check.lua           ← models/ 검사
--   luajit decoupling_check.lua starter   ← starter/ 검사

local here = (arg[0] or ""):match("(.*/)") or "./"
local target = arg[1] or "models"
local modelsDir = here .. "../" .. target .. "/"

local files = {
  "class.lua",
  "rng.lua",
  "PlayerModel.lua",
  "EnemyModel.lua",
  "BulletModel.lua",
  "GameModel.lua",
}

local failed = false

-- Model 합격 기준(basics/README 3절과 동일): print, io, love 가 한 글자도 없어야 한다.
local FORBIDDEN = { "love", "print", "io" }

local function usesName(code, name)
  -- 식별자 경계: 앞뒤가 영문/숫자/_ 가 아닌 곳에서만 일치 (예: "ratio" 의 "io" 는 제외)
  local padded = " " .. code .. " "
  return padded:find("[^%w_]" .. name .. "[^%w_]") ~= nil
end

for _, name in ipairs(files) do
  local path = modelsDir .. name
  local f = assert(io.open(path, "r"), "파일 없음: " .. path)
  local lineNo = 0
  for line in f:lines() do
    lineNo = lineNo + 1
    local code = line:gsub("%-%-.*$", "")
    for _, word in ipairs(FORBIDDEN) do
      if usesName(code, word) then
        print(string.format("FAIL  %s:%d  [%s] → %s", name, lineNo, word, line:gsub("^%s+", "")))
        failed = true
      end
    end
  end
  f:close()
end

if failed then
  print("\n❌ " .. target .. "/ 에 print/io/love 의존이 남아 있다. 디커플링 실패.")
  os.exit(1)
else
  print("✅ OK: " .. target .. "/ 에 print/io/love 참조 0건. 디커플링 성공.")
end

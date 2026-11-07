-- run_all.lua
-- 8주차(심화)의 모든 검사를 한 번에 돌리고 요약한다. 지금 실행 중인 인터프리터를 그대로 쓴다.
-- 실행: cd lua_tuto/mvc/week08_more/examples/tests && luajit run_all.lua

local here = (arg[0] or ""):match("(.*/)") or "./"
local interp = arg[-1] or "luajit"

local SUITES = {
  { "layer_check", "계층 규칙 (6개 앱)" },
  { "rules_test", "규칙 명세 (기준: MVC)" },
  { "mvc_test", "MVC 기준점과 불편" },
  { "mvp_test", "MVP" },
  { "mvvm_test", "MVVM" },
  { "tea_test", "TEA" },
  { "ecs_test", "ECS" },
  { "hex_test", "Hexagonal" },
  { "equivalence_test", "여섯 구조 = 같은 규칙" },
}

print(string.format("[run_all] week08_more  (%s)", interp))
local failed = 0
for _, s in ipairs(SUITES) do
  local cmd = string.format('%s "%s%s.lua" 2>&1', interp, here, s[1])
  local p = io.popen(cmd)
  local out = p:read("*a")
  p:close()
  local last = ""
  for line in out:gmatch("[^\n]+") do
    last = line
  end
  local ok = last:find("실패 0", 1, true) ~= nil
  if not ok then
    failed = failed + 1
  end
  print(string.format("  %s %-18s %-26s %s", ok and "✅" or "❌", s[1], s[2], last))
end
print(failed == 0 and "\n전부 통과" or string.format("\n실패한 묶음 %d개 — 위 파일을 따로 실행해 자세히 본다", failed))
if failed > 0 then
  os.exit(1)
end

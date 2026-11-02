-- run_all.lua
-- 템플릿의 모든 검사를 한 번에 돌리고 요약한다. 지금 실행 중인 인터프리터(luajit/lua5.1)를 그대로 쓴다.
-- 실행: cd lua_tuto/mvc/week07/examples/tests && luajit run_all.lua [galaga_final|starter]

local here = (arg[0] or ""):match("(.*/)") or "./"
local app = arg[1] or "galaga_final"
local interp = arg[-1] or "luajit"

-- 이어받은 순서대로: 구조 검사 → 4·5·6주차 → 7주차
local SUITES = {
  { "layer_check", "계층 규칙" },
  { "globals_check", "암묵적 전역" },
  { "view_test", "View (4주차)" },
  { "feature_test", "미사일·보스 (4주차)" },
  { "scene_test", "씬 (5주차)" },
  { "phase_test", "진행 단계 (5주차)" },
  { "replay_test", "리플레이·버전·저장 (6·7주차)" },
  { "equivalence_test", "규칙 버전 약속 (7주차)" },
  { "perf_test", "할당 회귀 (7주차)" },
  { "combo_test", "콤보 (7주차 기능)" },
}

print(string.format("[run_all] %s/  (%s)", app, interp))
local failed = 0
for _, s in ipairs(SUITES) do
  local cmd = string.format('%s "%s%s.lua" %s 2>&1', interp, here, s[1], app)
  local p = io.popen(cmd)
  local out = p:read("*a")
  p:close()
  local last = ""
  for line in out:gmatch("[^\n]+") do
    last = line
  end
  local ok = last:find("실패 0", 1, true) or last:find("OK", 1, true)
  if not ok then
    failed = failed + 1
  end
  print(string.format("  %s %-18s %-28s %s", ok and "✅" or "❌", s[1], s[2], last))
end
print(failed == 0 and "\n전부 통과" or string.format("\n실패한 묶음 %d개 — 위 파일을 따로 실행해 자세히 본다", failed))
if failed > 0 then
  os.exit(1)
end

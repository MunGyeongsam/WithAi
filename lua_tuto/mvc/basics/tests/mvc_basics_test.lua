-- mvc_basics_test.lua
-- basics 예제 5개의 헤드리스 테스트. 화면/키보드 없이 Model 과 Controller 를 검증한다.
-- 실행: lua lua_tuto/mvc/basics/tests/mvc_basics_test.lua   (luajit 도 가능)

local here = (arg and arg[0] or ""):match("(.*[/\\])") or "./"
local root = here .. "../"

local function load(path)
  return dofile(root .. path)
end

local passed, failed = 0, 0
local function check(name, cond)
  if cond then
    passed = passed + 1
    print("  ok   - " .. name)
  else
    failed = failed + 1
    print("  FAIL - " .. name)
  end
end

-- 가짜 View: 어떤 메서드가 호출됐는지만 기록한다 (Controller 테스트용).
local function spyView()
  local calls = {}
  local spy = setmetatable({ calls = calls }, {
    __index = function(_, method)
      return function(_, ...)
        calls[#calls + 1] = { method = method, args = { ... } }
      end
    end,
  })
  return spy
end

local function called(spy, method)
  for _, call in ipairs(spy.calls) do
    if call.method == method then
      return true
    end
  end
  return false
end

-- ── 0. 디커플링: Model 파일에는 입출력/LÖVE 코드가 없어야 한다 ───────────────
print("[0] Model 디커플링")
local MODEL_FILES = {
  "01_counter/counter_model.lua",
  "02_todo/todo_model.lua",
  "03_temperature/temperature_model.lua",
  "04_guess_number/guess_model.lua",
  "05_grid_robot/robot_model.lua",
}
for _, path in ipairs(MODEL_FILES) do
  local file = assert(io.open(root .. path, "r"), "파일 없음: " .. path)
  local clean = true
  for line in file:lines() do
    local code = line:gsub("%-%-.*$", "")
    if code:find("print%s*%(") or code:find("io%.") or code:find("love%.") then
      clean = false
    end
  end
  file:close()
  check(path .. " 에 print/io/love 없음", clean)
end

-- ── 1. 카운터 ───────────────────────────────────────────────────────────────
print("[1] 카운터")
do
  local CounterModel = load("01_counter/counter_model.lua")
  local CounterController = load("01_counter/counter_controller.lua")

  local m = CounterModel.new(0, 2)
  check("시작값은 min", m.value == 0)
  check("감소 불가 시 false", m:decrement() == false and m.value == 0)
  m:increment()
  m:increment()
  check("최댓값에서 증가 불가", m:increment() == false and m.value == 2)
  m:reset()
  check("reset 은 min 으로", m.value == 0)

  local view = spyView()
  local c = CounterController.new(CounterModel.new(0, 1), view)
  check("+ 명령은 계속 실행", c:handle("+") == true)
  check("+ 후 render 호출", called(view, "render"))
  check("최댓값에서 + 하면 showMessage", c:handle("+") and called(view, "showMessage"))
  check("q 는 종료(false)", c:handle("q") == false)
end

-- ── 2. 할 일 목록 ───────────────────────────────────────────────────────────
print("[2] 할 일 목록")
do
  local TodoModel = load("02_todo/todo_model.lua")
  local TodoController = load("02_todo/todo_controller.lua")

  local m = TodoModel.new()
  local ok, err = m:add("   ")
  check("빈 내용 거부", ok == false and err ~= nil and #m.items == 0)
  m:add("  우유  ")
  check("앞뒤 공백 제거", m.items[1].text == "우유")
  check("토글", m:toggle(1) and m.items[1].done == true and m:countDone() == 1)
  check("없는 번호 거부", m:toggle(5) == false and m:remove(nil) == false)
  check("삭제", m:remove(1) and #m.items == 0)

  local view = spyView()
  local c = TodoController.new(TodoModel.new(), view)
  c:handle("add 숙제")
  check("Controller 가 add 를 Model 에 전달", #c.model.items == 1 and c.model.items[1].text == "숙제")
  c:handle("done abc")
  check("숫자가 아닌 번호 → showError", called(view, "showError"))
  check("quit 은 종료", c:handle("quit") == false)
end

-- ── 3. 온도 (Observer) ─────────────────────────────────────────────────────
print("[3] 온도 변환기")
do
  local TemperatureModel = load("03_temperature/temperature_model.lua")
  local TemperatureController = load("03_temperature/temperature_controller.lua")

  local m = TemperatureModel.new(0)
  local notified = 0
  local unsubscribe = m:subscribe(function()
    notified = notified + 1
  end)
  m:setCelsius(100)
  check("값이 바뀌면 알림", notified == 1)
  check("화씨 변환", m:getFahrenheit() == 212)
  m:setCelsius(100)
  check("같은 값이면 알림 없음", notified == 1)
  check("절대영도 미만 거부", m:setCelsius(-300) == false and m.celsius == 100)
  m:setFahrenheit(32)
  check("화씨 입력 → 섭씨 0", m.celsius == 0)
  unsubscribe()
  m:setCelsius(10)
  check("구독 해제 후 알림 없음", notified == 2)

  local errors = {}
  local c = TemperatureController.new(TemperatureModel.new(20), function(msg)
    errors[#errors + 1] = msg
  end)
  c:handle("up")
  check("up → +5", c.model.celsius == 25)
  c:handle("c hello")
  check("잘못된 값 → onError", #errors == 1)
end

-- ── 4. 숫자 맞히기 ─────────────────────────────────────────────────────────
print("[4] 숫자 맞히기")
do
  local GuessModel = load("04_guess_number/guess_model.lua")
  local GuessController = load("04_guess_number/guess_controller.lua")

  local function fixed()
    return 30
  end

  local m = GuessModel.new({ min = 1, max = 50, maxAttempts = 3, random = fixed })
  check("주입한 random 으로 정답 고정", m.secret == 30)
  check("작으면 low", m:guess(10) == "low")
  check("크면 high", m:guess(40) == "high")
  local result, err = m:guess(99)
  check("범위 밖은 시도 횟수 미소모", result == nil and err ~= nil and m.attempts == 2)
  check("마지막 기회 실패 → lost", m:guess(20) == "low" and m.state == "lost")
  check("끝난 게임은 추측 불가", m:guess(30) == nil)
  m:restart()
  check("restart 후 정답 → won", m:guess(30) == "correct" and m.state == "won")

  local view = spyView()
  local c = GuessController.new(GuessModel.new({ random = fixed }), view)
  c:handle("3.5")
  check("정수가 아니면 Model 호출 없이 showError", called(view, "showError") and c.model.attempts == 0)
  c:handle("30")
  check("정답 입력 → showResult", called(view, "showResult") and c.model.state == "won")
end

-- ── 5. 격자 로봇 ───────────────────────────────────────────────────────────
print("[5] 격자 로봇")
do
  local RobotModel = load("05_grid_robot/robot_model.lua")
  local RobotController = load("05_grid_robot/robot_controller.lua")
  local MAP = {
    "#####",
    "#S.G#",
    "#####",
  }

  local m = RobotModel.new(MAP)
  check("시작 위치", m.x == 2 and m.y == 2)
  check("벽이면 blocked, 위치 유지", m:move("up") == "blocked" and m.x == 2 and m.moves == 0)
  check("잘못된 방향 거부", m:move("jump") == nil)
  check("이동", m:move("right") == "moved" and m.x == 3 and m.moves == 1)
  check("목표 도착", m:move("right") == "goal" and m.state == "cleared")
  check("도착 후 이동 불가", m:move("left") == nil)

  local view = spyView()
  local c = RobotController.new(RobotModel.new(MAP), view)
  c:handle("d")
  check("d 키 → 오른쪽 이동", c.model.x == 3)
  check("목표 도착 시 종료(false)", c:handle("d") == false)
end

print(string.format("\n결과: %d 통과, %d 실패", passed, failed))
if failed > 0 then
  os.exit(1)
end

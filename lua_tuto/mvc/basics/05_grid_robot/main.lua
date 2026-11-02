-- main.lua  (예제 5: 격자 로봇 — 게임 구조로 가는 다리)
-- 실행: lua main.lua        → 자동 시연
--       lua main.lua -i     → 직접 조작 (w/a/s/d 입력 후 Enter, q 종료)

local here = (arg and arg[0] or ""):match("(.*[/\\])") or "./"
package.path = here .. "?.lua;" .. package.path

local RobotModel = require("robot_model")
local ConsoleView = require("console_view")
local RobotController = require("robot_controller")

local MAP = {
  "#######",
  "#S..#.#",
  "#.#.#.#",
  "#.#...#",
  "#...#G#",
  "#######",
}

local model = RobotModel.new(MAP)
local view = ConsoleView.new(print)
local controller = RobotController.new(model, view)

local interactive = arg and arg[1] == "-i"
local script = { "w", "d", "d", "s", "s", "x", "d", "d", "s" }
local step = 0

local function nextCommand()
  if interactive then
    io.write("> ")
    return io.read("*l")
  end
  step = step + 1
  local command = script[step]
  if command then
    print("> " .. command)
  end
  return command
end

view:render(model)
while true do
  local command = nextCommand()
  if command == nil or not controller:handle(command) then
    break
  end
end
print("종료합니다.")

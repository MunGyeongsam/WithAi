-- main.lua  (예제 1: 카운터)
-- 조립 담당: Model / View / Controller 를 만들고 연결한 뒤 입력 루프를 돌린다.
-- 실행: lua main.lua        → 미리 정한 명령으로 자동 시연
--       lua main.lua -i     → 직접 입력 (명령: + - r q)

local here = (arg and arg[0] or ""):match("(.*[/\\])") or "./"
package.path = here .. "?.lua;" .. package.path

local CounterModel = require("counter_model")
local CounterView = require("counter_view")
local CounterController = require("counter_controller")

local model = CounterModel.new(0, 3)
local view = CounterView.new(print)
local controller = CounterController.new(model, view)

local interactive = arg and arg[1] == "-i"
local script = { "+", "+", "+", "+", "-", "x", "r", "q" }
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

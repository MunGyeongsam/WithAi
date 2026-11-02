-- main.lua  (예제 2: 할 일 목록)
-- 실행: lua main.lua        → 자동 시연
--       lua main.lua -i     → 직접 입력 (help 로 명령 확인)

local here = (arg and arg[0] or ""):match("(.*[/\\])") or "./"
package.path = here .. "?.lua;" .. package.path

local TodoModel = require("todo_model")
local TodoView = require("todo_view")
local TodoController = require("todo_controller")

local model = TodoModel.new()
local view = TodoView.new(print)
local controller = TodoController.new(model, view)

local interactive = arg and arg[1] == "-i"
local script = {
  "help",
  "add 우유 사기",
  "add Lua 과제 제출",
  "add    ",
  "done 1",
  "done 9",
  "del 2",
  "quit",
}
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

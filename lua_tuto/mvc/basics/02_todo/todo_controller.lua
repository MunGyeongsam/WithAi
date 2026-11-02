-- todo_controller.lua
-- Controller: "add 우유 사기" 같은 문장을 (명령, 인자) 로 해석해 Model 을 호출한다.
-- 입력 해석(파싱)은 Controller, 데이터 규칙 검사는 Model 이 맡는다.

local TodoController = {}
TodoController.__index = TodoController

function TodoController.new(model, view)
  return setmetatable({ model = model, view = view }, TodoController)
end

local function parse(line)
  local command, rest = (line or ""):match("^%s*(%S*)%s*(.-)%s*$")
  return command or "", rest or ""
end

-- 계속 실행하면 true, 종료 명령이면 false.
function TodoController:handle(line)
  local model, view = self.model, self.view
  local command, rest = parse(line)
  local ok, err = true, nil

  if command == "add" then
    ok, err = model:add(rest)
  elseif command == "done" then
    ok, err = model:toggle(tonumber(rest))
  elseif command == "del" then
    ok, err = model:remove(tonumber(rest))
  elseif command == "list" then
    ok = true
  elseif command == "help" then
    view:showHelp()
    return true
  elseif command == "quit" then
    return false
  else
    ok, err = false, "알 수 없는 명령: " .. command
  end

  if ok then
    view:render(model)
  else
    view:showError(err)
  end
  return true
end

return TodoController

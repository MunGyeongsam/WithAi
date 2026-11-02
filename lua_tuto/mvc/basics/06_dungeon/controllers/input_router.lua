-- input_router.lua
-- 입력을 "현재 모드 담당 Controller" 에게 넘겨주는 교환원.
-- 모드가 늘어나면 Controller 파일 하나를 만들고 여기 등록만 하면 된다.
-- (5주차에서 배울 State/Scene 패턴의 가장 단순한 형태)
--
-- Controller 규약: controller:handle(game, input) → ok, err, signal
--   signal == "quit" 이면 프로그램 종료 요청

local InputRouter = {}
InputRouter.__index = InputRouter

-- controllers: { explore = ..., battle = ..., inventory = ..., gameover = ..., victory = ... }
function InputRouter.new(game, view, controllers)
  return setmetatable({ game = game, view = view, controllers = controllers }, InputRouter)
end

-- 계속 실행하면 true, 종료면 false.
function InputRouter:handle(input)
  input = (input or ""):match("^%s*(.-)%s*$")
  if input == "q" then
    return false
  end

  local controller = self.controllers[self.game.mode]
  if not controller then
    self.view:showNotice("이 모드를 담당하는 Controller 가 없습니다: " .. self.game.mode)
    self.view:render(self.game)
    return true
  end

  local ok, err, signal = controller:handle(self.game, input)
  if signal == "quit" then
    return false
  end
  if not ok then
    self.view:showNotice(err)
  end
  self.view:render(self.game)
  return true
end

return InputRouter

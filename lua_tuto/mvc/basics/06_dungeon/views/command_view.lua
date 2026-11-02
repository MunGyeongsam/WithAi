-- command_view.lua
-- 현재 모드에서 쓸 수 있는 명령 안내. 읽는 값: game.mode

local COMMANDS = {
  explore = "n: 다음 방  |  i: 가방  |  q: 종료",
  battle = "a: 공격  |  r: 도망  |  i: 가방(아이템 사용 시 턴 소모)  |  q: 종료",
  inventory = "번호: 사용  |  b: 닫기  |  q: 종료",
  gameover = "GAME OVER — 아무 키나 입력하면 종료",
  victory = "VICTORY — 아무 키나 입력하면 종료",
}

local CommandView = { title = "명령" }
CommandView.__index = CommandView

function CommandView.new()
  return setmetatable({}, CommandView)
end

function CommandView:lines(game)
  return { COMMANDS[game.mode] or "" }
end

return CommandView

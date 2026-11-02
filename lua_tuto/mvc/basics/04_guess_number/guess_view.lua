-- guess_view.lua
-- View: 게임 결과를 문장으로 바꿔 보여준다. "low" → "더 큰 수입니다" 같은 표현은 View 의 몫.

local RESULT_TEXT = {
  low = "더 큰 수입니다 ↑",
  high = "더 작은 수입니다 ↓",
  correct = "정답입니다!",
}

local GuessView = {}
GuessView.__index = GuessView

function GuessView.new(write)
  return setmetatable({ write = write or print }, GuessView)
end

function GuessView:showIntro(model)
  self.write(string.format("%d ~ %d 사이의 숫자를 %d번 안에 맞혀 보세요.",
    model.min, model.max, model.maxAttempts))
end

function GuessView:showResult(model, result)
  self.write(string.format("  %s  (남은 기회 %d)", RESULT_TEXT[result], model:remaining()))
  if model.state == "won" then
    self.write(string.format("  %d번 만에 성공! 기록: %s", model.attempts, table.concat(model.history, ", ")))
  elseif model.state == "lost" then
    self.write(string.format("  실패... 정답은 %d 였습니다.", model.secret))
  end
end

function GuessView:showError(message)
  self.write("  ! " .. message)
end

return GuessView

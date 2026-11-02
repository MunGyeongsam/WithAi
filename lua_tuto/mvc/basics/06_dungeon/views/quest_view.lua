-- quest_view.lua
-- 퀘스트 목록과 진행도. 읽는 모델: quests

local QuestView = { title = "퀘스트" }
QuestView.__index = QuestView

function QuestView.new()
  return setmetatable({}, QuestView)
end

function QuestView:lines(game)
  local lines = {}
  for i, q in ipairs(game.quests.quests) do
    local mark = q.done and "v" or " "
    lines[i] = string.format("[%s] %s (%d/%d)", mark, q.text, math.min(q.progress, q.needed), q.needed)
  end
  return lines
end

return QuestView

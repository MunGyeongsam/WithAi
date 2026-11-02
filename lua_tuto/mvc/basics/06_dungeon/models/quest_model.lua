-- quest_model.lua
-- 퀘스트 진행도. GameModel 을 전혀 모르고, 이벤트 버스만 구독해서 스스로 진행도를 올린다.
-- 새 퀘스트 종류를 추가해도 GameModel 은 고칠 필요가 없다.

local QuestModel = {}
QuestModel.__index = QuestModel

-- defs: { { id, text, event, needed }, ... }
function QuestModel.new(bus, defs)
  local self = setmetatable({ bus = bus, quests = {} }, QuestModel)
  for _, def in ipairs(defs or {}) do
    local quest = { id = def.id, text = def.text, event = def.event, needed = def.needed, progress = 0, done = false }
    self.quests[#self.quests + 1] = quest
    bus:on(def.event, function()
      self:advance(quest)
    end)
  end
  return self
end

function QuestModel:advance(quest)
  if quest.done then
    return
  end
  quest.progress = quest.progress + 1
  if quest.progress >= quest.needed then
    quest.done = true
    self.bus:emit("quest_completed", { text = quest.text })
  end
end

function QuestModel:countDone()
  local count = 0
  for _, quest in ipairs(self.quests) do
    if quest.done then
      count = count + 1
    end
  end
  return count
end

return QuestModel

-- log_model.lua
-- 최근 사건 기록. "문장"이 아니라 { type, data } 원본을 저장한다.
-- 어떤 문장으로 보여줄지(번역, 색, 아이콘)는 LogView 의 몫이다.

local LogModel = {}
LogModel.__index = LogModel

function LogModel.new(bus, limit)
  local self = setmetatable({ entries = {}, limit = limit or 5, turn = 0 }, LogModel)
  bus:onAny(function(eventType, data)
    self:push(eventType, data)
  end)
  return self
end

function LogModel:push(eventType, data)
  self.turn = self.turn + 1
  local entries = self.entries
  entries[#entries + 1] = { type = eventType, data = data, turn = self.turn }
  while #entries > self.limit do
    table.remove(entries, 1)
  end
end

return LogModel

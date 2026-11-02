-- dungeon_model.lua
-- 방(room) 목록과 현재 위치. 방에 무엇이 있는지는 데이터 파일이 정한다.

local DungeonModel = {}
DungeonModel.__index = DungeonModel

-- rooms: { { kind = "enemy", enemy = {...} }, { kind = "item", item = {...} }, { kind = "exit" } }
function DungeonModel.new(rooms)
  assert(type(rooms) == "table" and #rooms > 0, "방이 최소 1개 필요합니다")
  return setmetatable({ rooms = rooms, index = 0 }, DungeonModel)
end

function DungeonModel:hasNext()
  return self.index < #self.rooms
end

-- 다음 방으로 이동하고 그 방 데이터를 돌려준다. 더 없으면 nil.
function DungeonModel:advance()
  if not self:hasNext() then
    return nil
  end
  self.index = self.index + 1
  return self.rooms[self.index]
end

return DungeonModel

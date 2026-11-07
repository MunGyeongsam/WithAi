-- World.lua (ECS)
-- 엔티티 = 번호. 컴포넌트 = 이름별 표(store[name][id] = data). 시스템 = World 를 받는 평범한 함수.
-- love 를 모른다.

local class = require("class")

local World = class()

function World:init()
  self.nextId = 1
  self.alive = {}
  self.store = {}
  self.dead = {}
end

function World:spawn(components)
  local id = self.nextId
  self.nextId = id + 1
  self.alive[id] = true
  for name, data in pairs(components) do
    self:add(id, name, data)
  end
  return id
end

function World:add(id, name, data)
  local s = self.store[name]
  if not s then
    s = {}
    self.store[name] = s
  end
  s[id] = data
end

function World:get(id, name)
  local s = self.store[name]
  return s and s[id]
end

--- 지연 삭제: 시스템이 목록을 도는 중에 지워도 안전하다. flush 에서 실제로 지운다.
function World:destroy(id)
  self.dead[#self.dead + 1] = id
end

function World:flush()
  for _, id in ipairs(self.dead) do
    self.alive[id] = nil
    for _, s in pairs(self.store) do
      s[id] = nil
    end
  end
  self.dead = {}
end

--- 주어진 컴포넌트를 모두 가진 엔티티 번호들. pairs 순서는 정해져 있지 않으므로 정렬해 결정성을 지킨다.
function World:query(...)
  local names = { ... }
  local first = self.store[names[1]]
  local ids = {}
  if not first then
    return ids
  end
  for id in pairs(first) do
    local ok = self.alive[id]
    for i = 2, #names do
      local s = self.store[names[i]]
      if not (s and s[id]) then
        ok = false
        break
      end
    end
    if ok then
      ids[#ids + 1] = id
    end
  end
  table.sort(ids)
  return ids
end

return World

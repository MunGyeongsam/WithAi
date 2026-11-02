-- event_bus.lua
-- 모델끼리 서로를 직접 참조하지 않고 "사건(event)"으로만 소통하게 해 주는 우체국.
-- 예: GameModel 이 "enemy_killed" 를 발행하면 QuestModel, LogModel 이 각자 받아 처리한다.
-- GameModel 은 퀘스트·로그가 존재하는지조차 몰라도 된다.

local EventBus = {}
EventBus.__index = EventBus

function EventBus.new()
  return setmetatable({ handlers = {}, anyHandlers = {} }, EventBus)
end

-- 특정 이벤트 구독
function EventBus:on(eventType, handler)
  local list = self.handlers[eventType]
  if not list then
    list = {}
    self.handlers[eventType] = list
  end
  list[#list + 1] = handler
end

-- 모든 이벤트 구독 (로그처럼 전부 받아야 하는 경우)
function EventBus:onAny(handler)
  self.anyHandlers[#self.anyHandlers + 1] = handler
end

-- 구독한 순서대로 호출된다. 핸들러 안에서 다시 emit 해도 된다(중첩 호출).
function EventBus:emit(eventType, data)
  data = data or {}
  for _, handler in ipairs(self.anyHandlers) do
    handler(eventType, data)
  end
  local list = self.handlers[eventType]
  if list then
    for _, handler in ipairs(list) do
      handler(data)
    end
  end
end

return EventBus

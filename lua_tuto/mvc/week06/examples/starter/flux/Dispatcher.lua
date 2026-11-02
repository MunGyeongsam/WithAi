-- Dispatcher.lua
-- 모든 Action 이 지나가는 단 하나의 문. 검증 → 기록 → 등록된 Store 들에게 전달.
-- 상태 변경 경로가 이곳 하나뿐이므로, 여기서 기록하면 "일어난 모든 일"이 남는다.

local class = require("class")

local Dispatcher = class()

--- @param validate function(action) -> boolean, string|nil   Action 계약 검사
function Dispatcher:init(validate)
  self.validate = validate
  self.stores = {}
  self.taps = {}
  self.dispatching = false
end

function Dispatcher:register(store)
  self.stores[#self.stores + 1] = store
end

--- 지나가는 Action 을 엿본다(기록기 등). Store 와 달리 상태를 갖지 않는다.
function Dispatcher:tap(fn)
  self.taps[#self.taps + 1] = fn
end

function Dispatcher:dispatch(action)
  local ok, why = self.validate(action)
  if not ok then
    error("잘못된 Action: " .. why, 2)
  end
  -- 처리 도중 또 dispatch 하면 순서가 꼬인다(Flux 의 핵심 규칙: 한 번에 하나).
  if self.dispatching then
    error("dispatch 도중에 dispatch 할 수 없다: " .. tostring(action.type), 2)
  end
  self.dispatching = true
  local ok2, err = pcall(function()
    -- TODO: 모든 tap(기록기)에 action 을 넘기고, 모든 store 의 handle(action) 을 부른다.
  end)
  self.dispatching = false -- Store 가 에러를 내도 잠긴 채로 남지 않게
  if not ok2 then
    error(err, 0)
  end
end

return Dispatcher

-- Store.lua
-- 상태의 유일한 보관소(single source of truth). 상태는 오직 handle(action) 으로만 바뀐다.
-- 실제 규칙은 주입받은 순수 리듀서가 갖는다. Store 는 "지금 상태" 를 들고 있을 뿐이다.

local class = require("class")

local Store = class()

--- @param reduce  function(state, action) -> state   순수 리듀서
--- @param initial table                              초기 상태
function Store:init(reduce, initial)
  self.reduce = reduce
  self.state = initial
  self.listeners = {}
end

function Store:getState()
  return self.state
end

--- Dispatcher 만 부른다. View·Controller 가 직접 부르지 않는다.
function Store:handle(action)
  local before = self.state
  self.state = self.reduce(before, action)
  if self.state ~= before then
    for i = 1, #self.listeners do
      self.listeners[i](self.state, before, action)
    end
  end
end

--- 상태가 바뀔 때 알림을 받는다(선택). 게임 화면은 매 프레임 getState 를 읽으므로(Pull) 쓰지 않아도 된다.
function Store:subscribe(fn)
  self.listeners[#self.listeners + 1] = fn
end

return Store

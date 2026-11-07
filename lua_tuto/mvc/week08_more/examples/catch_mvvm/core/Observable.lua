-- Observable.lua
-- 값 하나 + 구독자 목록. 값이 "바뀔 때만" 구독자에게 알린다. MVVM 바인딩의 바닥 부품.
-- 주의: 비교는 == 이다. 같은 테이블을 고쳐서 다시 set 하면 바뀐 것으로 보지 않는다(mvvm_test [함정]).

local class = require("class")

local Observable = class()

function Observable:init(value)
  self.value = value
  self.subs = {}
end

function Observable:get()
  return self.value
end

function Observable:set(value)
  if value == self.value then
    return
  end
  self.value = value
  for i = 1, #self.subs do
    self.subs[i](value)
  end
end

--- 구독하고 현재 값으로 한 번 바로 부른다. 돌려주는 함수를 부르면 구독이 풀린다.
function Observable:bind(fn)
  self.subs[#self.subs + 1] = fn
  fn(self.value)
  return function()
    for i = #self.subs, 1, -1 do
      if self.subs[i] == fn then
        table.remove(self.subs, i)
      end
    end
  end
end

function Observable:subscriberCount()
  return #self.subs
end

return Observable

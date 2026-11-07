-- mvvm_test.lua
-- MVVM: 바뀐 값만 알린다, View 는 바인딩으로만 갱신된다, 해제를 잊으면 남는다, 같은 테이블 함정.
-- 실행: cd lua_tuto/mvc/week08_more/examples/tests && luajit mvvm_test.lua

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local helper = require("helper")
local root = helper.setup("catch_mvvm")

local R = require("rules")
local Observable = require("Observable")
local CatchModel = require("CatchModel")
local CatchViewModel = require("CatchViewModel")
local CatchView = require("CatchView")

print("[mvvm_test] MVVM")

helper.test("Observable: bind 는 현재 값으로 즉시 한 번 부른다", function()
  local o, got = Observable(5), nil
  o:bind(function(v)
    got = v
  end)
  return got == 5
end)

helper.test("Observable: 같은 값 set 은 알리지 않는다", function()
  local o, n = Observable(1), 0
  o:bind(function()
    n = n + 1
  end)
  o:set(1)
  o:set(2)
  o:set(2)
  return n == 2
end)

helper.test("Observable: 해제 함수를 부르면 더 이상 불리지 않는다", function()
  local o, n = Observable(1), 0
  local unbind = o:bind(function()
    n = n + 1
  end)
  unbind()
  o:set(9)
  return n == 1 and o:subscriberCount() == 0
end)

helper.test("ViewModel: 점수가 안 바뀐 틱에는 scoreText 구독자가 불리지 않는다", function()
  local vm = CatchViewModel(CatchModel(1))
  local n = 0
  vm.scoreText:bind(function()
    n = n + 1
  end)
  vm:update(R.TICK)
  vm:update(R.TICK)
  return n == 1
end)

helper.test("ViewModel 명령 moveLeft → playerLane 속성", function()
  local vm = CatchViewModel(CatchModel(1))
  vm:moveLeft()
  return vm.playerLane:get() == R.START_LANE - 1
end)

helper.test("View: Model 을 읽지 않고 바인딩만으로 값이 따라온다", function()
  local m = CatchModel(1)
  local vm = CatchViewModel(m)
  local view = CatchView(vm)
  m.items = { { lane = R.START_LANE, row = R.ROWS - 1, kind = "coin" } }
  vm:update(R.TICK)
  return view.scoreText == "SCORE 10"
end)

helper.test("View: 키 → ViewModel 명령", function()
  local vm = CatchViewModel(CatchModel(1))
  local view = CatchView(vm)
  view:keypressed("right")
  return view.lane == R.START_LANE + 1
end)

helper.test("View 전용 반응: HP 가 줄면 깜빡임(Model 에 이벤트 없음)", function()
  local m = CatchModel(1)
  local vm = CatchViewModel(m)
  local view = CatchView(vm)
  local before = view.flash
  m.items = { { lane = R.START_LANE, row = R.ROWS - 1, kind = "bomb" } }
  vm:update(R.TICK)
  return before == 0 and view.flash > 0
end)

helper.test("[누수] destroy 안 하면 옛 View 가 구독자로 남고, destroy 하면 0", function()
  local vm = CatchViewModel(CatchModel(1))
  local base = vm.scoreText:subscriberCount()
  local v1 = CatchView(vm)
  CatchView(vm) -- destroy 하지 않은 두 번째 View
  local leaked = vm.scoreText:subscriberCount() - base
  v1:destroy()
  print("        destroy 없이 만든 View 2개 → 구독 " .. leaked .. "개")
  return leaked == 2 and vm.scoreText:subscriberCount() - base == 1
end)

helper.test("[함정] 같은 테이블을 고쳐서 set 하면 알림이 없다", function()
  local o, n = Observable({}), 0
  o:bind(function()
    n = n + 1
  end)
  local t = o:get()
  t[1] = "new"
  o:set(t)
  return n == 1 -- bind 직후 1번뿐. 그래서 ViewModel 은 items 를 매번 새 테이블로 만든다
end)

helper.test("[결합 측정] View 는 Model 을 require 하지도, 필드를 읽지도 않는다", function()
  local src = helper.readFile(root .. "views/CatchView.lua")
  return not src:find("CatchModel") and not src:find("model%.")
end)

helper.finish()

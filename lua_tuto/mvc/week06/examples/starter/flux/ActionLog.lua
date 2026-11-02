-- ActionLog.lua
-- Dispatcher 를 지나간 Action 을 순서대로 기록하고, 문자열로 저장·복원하고, 다시 재생한다.
-- 시간(tick)도 Action 이므로, 재생은 "몇 fps 로 돌았는지"와 무관하게 같은 결과를 낸다.

local class = require("class")

local ActionLog = class()

function ActionLog:init()
  self.entries = {}
end

-- 받은 테이블을 그대로 넣지 않고 값만 복사한다(보낸 쪽이 테이블을 재사용해도 기록이 안 바뀌게).
function ActionLog:record(action)
  -- TODO: action 의 키·값을 새 테이블에 복사해 self.entries 끝에 추가
end

function ActionLog:size()
  return #self.entries
end

--- 한 줄에 Action 하나: "restart 42" / "turn up" / "tick"
function ActionLog:serialize()
  local lines = {}
  for i, a in ipairs(self.entries) do
    if a.type == "restart" then
      lines[i] = "restart " .. string.format("%.0f", a.seed) -- %d 는 32비트 long 환경(Windows Lua 5.1)에서 큰 시드가 깨진다
    elseif a.type == "turn" then
      lines[i] = "turn " .. a.dir
    else
      lines[i] = a.type
    end
  end
  return table.concat(lines, "\n")
end

function ActionLog.parse(text)
  local log = ActionLog()
  for line in text:gmatch("[^\n]+") do
    local kind, arg = line:match("^(%S+)%s*(%S*)$")
    if kind == "restart" then
      log.entries[#log.entries + 1] = { type = "restart", seed = tonumber(arg) }
    elseif kind == "turn" then
      log.entries[#log.entries + 1] = { type = "turn", dir = arg }
    elseif kind then
      log.entries[#log.entries + 1] = { type = kind }
    end
  end
  return log
end

--- 처음부터 n번째 Action 까지 리듀서로 다시 계산한 상태(시간 여행). n 생략 시 끝까지.
function ActionLog:replay(reduce, initial, n)
  -- TODO: state = initial 에서 시작해 entries[1..n] 을 차례로 reduce 한 결과
  return initial
end

return ActionLog

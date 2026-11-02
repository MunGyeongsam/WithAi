-- InputRecorder.lua
-- 고정 스텝마다 "Model 에 실제로 넣은 입력"을 기록한다. 시드 + 스텝별 입력 = 그 판의 전부.
-- (Model 은 결정적이므로 이것만 있으면 몇 fps 로든 똑같이 다시 돌릴 수 있다)
--
-- ⚠️ InputController:read() 는 같은 테이블을 재사용한다(4주차 1-4절). 그대로 넣으면 모든 기록이
--    "마지막 입력"으로 바뀐다. 반드시 값을 복사한다.

local class = require("class")

local InputRecorder = class()

function InputRecorder:init(seed)
  self.seed = seed
  self.steps = {}
end

function InputRecorder:record(input)
  -- TODO: input 의 move·fire·missile 값을 "새 테이블"에 담아 self.steps 에 추가
  --       (input 을 그대로 넣으면? replay_test 의 "복사본" 테스트가 답해 준다)
end

function InputRecorder:size()
  return #self.steps
end

local MOVE_CHAR = { [-1] = "L", [0] = "0", [1] = "R" }
local CHAR_MOVE = { L = -1, ["0"] = 0, R = 1 }

--- 첫 줄 "seed N", 이후 스텝마다 3글자: 이동(L/0/R) 발사(1/0) 미사일(1/0)
function InputRecorder:serialize()
  local lines = { "seed " .. string.format("%.0f", self.seed) } -- %d 는 32비트 long 환경에서 큰 시드가 깨진다
  for i, s in ipairs(self.steps) do
    lines[i + 1] = MOVE_CHAR[s.move] .. (s.fire and "1" or "0") .. (s.missile and "1" or "0")
  end
  return table.concat(lines, "\n")
end

function InputRecorder.parse(text)
  local seed = tonumber(text:match("^seed (%-?%d+)"))
  local rec = InputRecorder(seed)
  for line in text:gmatch("[^\n]+") do
    local m, f, x = line:match("^([L0R])([01])([01])$")
    if m then
      rec.steps[#rec.steps + 1] = { move = CHAR_MOVE[m], fire = f == "1", missile = x == "1" }
    end
  end
  return rec
end

return InputRecorder

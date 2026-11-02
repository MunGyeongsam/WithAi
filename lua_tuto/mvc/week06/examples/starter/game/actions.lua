-- actions.lua
-- Action 계약: "무슨 일이 일어났는가"를 담은 평범한 테이블. 상태를 바꾸는 유일한 수단이다.
-- 함수·테이블 참조를 넣지 않는다(문자열로 저장·재생할 수 있어야 하므로).
--
--   { type = "restart", seed = 정수 }      새 판
--   { type = "turn",    dir = "up"|"down"|"left"|"right" }
--   { type = "tick" }                       시간 1칸 진행 (시간도 Action 이다)

local actions = {}

actions.DIRS = { up = true, down = true, left = true, right = true }

function actions.restart(seed)
  return { type = "restart", seed = seed }
end

function actions.turn(dir)
  return { type = "turn", dir = dir }
end

function actions.tick()
  return { type = "tick" }
end

--- Action 이 계약을 지키는지 검사한다. @return boolean, string|nil 이유
function actions.validate(a)
  if type(a) ~= "table" then
    return false, "action 은 테이블이어야 한다"
  end
  if a.type == "tick" then
    return true
  elseif a.type == "turn" then
    if actions.DIRS[a.dir] then
      return true
    end
    return false, "turn.dir 이 올바르지 않다: " .. tostring(a.dir)
  elseif a.type == "restart" then
    if type(a.seed) == "number" and a.seed == math.floor(a.seed) then
      return true
    end
    return false, "restart.seed 는 정수여야 한다"
  end
  return false, "알 수 없는 action.type: " .. tostring(a.type)
end

return actions

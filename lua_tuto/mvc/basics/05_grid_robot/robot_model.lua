-- robot_model.lua
-- Model: 격자 맵, 로봇 위치, 이동 규칙(벽 충돌, 목표 도착)을 가진다.
-- 좌표와 규칙만 있고 "그리는 방법"은 전혀 없다.
-- 그래서 같은 Model 을 콘솔 View 로도, LÖVE2D View 로도 그릴 수 있다.

local DIRECTIONS = {
  up = { 0, -1 },
  down = { 0, 1 },
  left = { -1, 0 },
  right = { 1, 0 },
}

local RobotModel = {}
RobotModel.__index = RobotModel

-- rows: { "#####", "#S.G#", "#####" } 형태. # 벽, . 바닥, S 시작, G 목표
function RobotModel.new(rows)
  local self = setmetatable({ walls = {}, moves = 0, state = "playing" }, RobotModel)
  self.height = #rows
  self.width = 0
  for y, row in ipairs(rows) do
    self.walls[y] = {}
    self.width = math.max(self.width, #row)
    for x = 1, #row do
      local cell = row:sub(x, x)
      self.walls[y][x] = (cell == "#")
      if cell == "S" then
        self.x, self.y = x, y
      elseif cell == "G" then
        self.goalX, self.goalY = x, y
      end
    end
  end
  assert(self.x and self.goalX, "맵에 S(시작)와 G(목표)가 모두 있어야 합니다")
  return self
end

function RobotModel:isWall(x, y)
  local row = self.walls[y]
  if not row or row[x] == nil then
    return true -- 맵 밖은 벽으로 취급
  end
  return row[x]
end

-- 결과: "moved" | "blocked" | "goal". 잘못된 방향이면 nil, 이유.
function RobotModel:move(direction)
  local delta = DIRECTIONS[direction]
  if not delta then
    return nil, "알 수 없는 방향: " .. tostring(direction)
  end
  if self.state ~= "playing" then
    return nil, "이미 목표에 도착했습니다"
  end

  local nx, ny = self.x + delta[1], self.y + delta[2]
  if self:isWall(nx, ny) then
    return "blocked"
  end

  self.x, self.y = nx, ny
  self.moves = self.moves + 1
  if nx == self.goalX and ny == self.goalY then
    self.state = "cleared"
    return "goal"
  end
  return "moved"
end

return RobotModel

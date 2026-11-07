-- CatchGame.lua (ECS)
-- World 하나 + 시스템 실행 순서. 규칙은 시스템에, 종류는 kinds 데이터에 있다.

local class = require("class")
local prng = require("prng")
local R = require("rules")
local World = require("World")
local kinds = require("kinds")
local fall = require("fall")
local collect = require("collect")
local spawn = require("spawn")
local render = require("render")

local CatchGame = class()

--- @param opts table|nil { seed, spawnTable = kinds.DEFAULT }
function CatchGame:init(opts)
  opts = opts or {}
  self.world = World()
  self.rng = prng.seed(opts.seed)
  self.spawnTable = opts.spawnTable or kinds.DEFAULT
  self.ticks = 0
  self.over = false
  self.player = self.world:spawn({
    position = { lane = R.START_LANE, row = R.ROWS },
    player = true,
    health = { hp = R.START_HP, max = R.START_HP },
    wallet = { score = 0 },
    sprite = { shape = "rect", color = { 0.3, 0.8, 1 } },
  })
end

function CatchGame:move(dir)
  if self.over then
    return
  end
  for _, id in ipairs(self.world:query("player", "position")) do
    local pos = self.world:get(id, "position")
    pos.lane = math.max(1, math.min(R.LANES, pos.lane + dir))
  end
end

--- 시스템 순서가 곧 규칙 순서다: 떨어짐 → 받기 → (삭제 반영) → 게임 오버 → 생성.
function CatchGame:tick()
  if self.over then
    return
  end
  self.ticks = self.ticks + 1
  fall(self.world)
  collect(self.world)
  self.world:flush()

  local health = self.world:get(self.player, "health")
  if health.hp <= 0 then
    health.hp = 0
    self.over = true
    return
  end

  if self.ticks % R.SPAWN_EVERY == 0 then
    self.rng = spawn(self.world, self.rng, self.spawnTable, kinds)
  end
end

function CatchGame:draw(gfx)
  render(gfx, self.world, self.over)
end

--- 비교·테스트용 요약.
function CatchGame:summary()
  local w = self.world
  return {
    score = w:get(self.player, "wallet").score,
    hp = w:get(self.player, "health").hp,
    lane = w:get(self.player, "position").lane,
    ticks = self.ticks,
    over = self.over,
    items = #w:query("falling"),
  }
end

return CatchGame

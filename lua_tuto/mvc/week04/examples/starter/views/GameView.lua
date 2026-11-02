-- GameView.lua  (STARTER)
-- 화면 전체를 조립하는 합성 View. 위젯 View 들을 순서대로 그리고, 이벤트를 연출로 넘긴다.
-- love 를 직접 부르지 않고 주입받은 gfx 로만 그린다(테스트 가능).

local class = require("class")
local PlayerView = require("PlayerView")
local EnemyView = require("EnemyView")
local BulletView = require("BulletView")
local HudView = require("HudView")
local EffectsView = require("EffectsView")

local GameView = class()

--- @param opts table  { width=number, height=number, rand=function|nil }
function GameView:init(opts)
  self.width = opts.width
  self.height = opts.height
  self.effects = EffectsView(opts.rand)
end

function GameView:onEvent(ev)
  self.effects:onEvent(ev)
end

function GameView:update(dt)
  self.effects:update(dt)
end

--- @param gfx  table  love.graphics 또는 가짜
--- @param game table  GameModel (읽기 전용)
function GameView:draw(gfx, game)
  -- TODO: 그리는 순서가 곧 겹침 순서다.
  --   1) gfx.push(); gfx.translate(흔들림 ox, oy)      ← 월드만 흔든다
  --   2) 번쩍임 → 플레이어 → 적 → 총알 → 파티클
  --   3) gfx.pop()                                     ← push/pop 짝이 맞아야 한다
  --   4) HUD → 배너                                    ← HUD 는 흔들리지 않는다
end

return GameView

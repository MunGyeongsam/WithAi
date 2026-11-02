-- GameView.lua
-- 화면 전체를 조립하는 합성 View. 위젯 View 들을 순서대로 그리고, 이벤트를 연출로 넘긴다.
-- Model 을 읽기만 한다. love 를 직접 부르지 않고 주입받은 gfx 로만 그린다(테스트 가능).

local class = require("class")
local PlayerView = require("PlayerView")
local EnemyView = require("EnemyView")
local BulletView = require("BulletView")
local HudView = require("HudView")
local EffectsView = require("EffectsView")
local BossView = require("BossView")

local GameView = class()

--- @param opts table  { width=number, height=number, rand=function|nil }
function GameView:init(opts)
  self.width = opts.width
  self.height = opts.height
  self.effects = EffectsView(opts.rand)
end

--- GameModel:drainEvents() 로 받은 이벤트 1개
function GameView:onEvent(ev)
  self.effects:onEvent(ev)
end

--- 연출 시간 진행 (Model 과 무관한 View 자신의 시간)
function GameView:update(dt)
  self.effects:update(dt)
end

--- @param gfx  table  love.graphics 또는 가짜
--- @param game table  GameModel (읽기 전용)
function GameView:draw(gfx, game)
  local fx = self.effects
  gfx.push()
  gfx.translate(fx.ox, fx.oy)
  fx:drawFlash(gfx, self.width, self.height)
  PlayerView.draw(gfx, game.player)
  EnemyView.draw(gfx, game.enemies)
  BossView.draw(gfx, game.boss, self.width)
  BulletView.draw(gfx, game.bullets, game.enemyBullets)
  fx:drawParticles(gfx)
  gfx.pop()

  HudView.draw(gfx, game, self.width, self.height)
  fx:drawBanner(gfx, self.width, self.height)
end

return GameView

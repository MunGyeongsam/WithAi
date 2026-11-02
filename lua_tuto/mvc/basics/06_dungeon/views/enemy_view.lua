-- enemy_view.lua
-- 전투 중인 적 정보. 적이 없으면 nil 을 돌려 화면에서 빠진다. 읽는 모델: enemy

local Widgets = require("views.widgets")

local EnemyView = { title = "적" }
EnemyView.__index = EnemyView

function EnemyView.new()
  return setmetatable({}, EnemyView)
end

function EnemyView:lines(game)
  local e = game.enemy
  if not e then
    return nil
  end
  return {
    string.format("%s  HP %s %d/%d   공격 %d", e.name, Widgets.bar(e.hp, e.maxHp, 15), e.hp, e.maxHp, e.attack),
  }
end

return EnemyView

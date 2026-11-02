-- status_view.lua
-- HUD: 플레이어 체력/공격력/골드/위치. 읽는 모델: player, dungeon

local Widgets = require("views.widgets")

local StatusView = { title = "상태" }
StatusView.__index = StatusView

function StatusView.new()
  return setmetatable({}, StatusView)
end

function StatusView:lines(game)
  local p, d = game.player, game.dungeon
  local weapon = p.weapon and (" (" .. p.weapon.name .. ")") or ""
  return {
    string.format("%s  HP %s %d/%d", p.name, Widgets.bar(p.hp, p.maxHp, 15), p.hp, p.maxHp),
    string.format("공격 %d%s   골드 %d   위치 %d/%d번 방", p:getAttack(), weapon, p.gold, d.index, #d.rooms),
  }
end

return StatusView

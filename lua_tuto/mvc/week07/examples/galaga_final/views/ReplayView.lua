-- ReplayView.lua
-- 리플레이 진행 표시줄과 안내 문구.

local ReplayView = {}

function ReplayView.draw(gfx, width, cursor, total, speed)
  local ratio = total > 0 and cursor / total or 1
  gfx.setColor(0.2, 0.2, 0.2)
  gfx.rectangle("fill", 10, 30, width - 20, 6)
  gfx.setColor(0.4, 0.9, 1)
  gfx.rectangle("fill", 10, 30, (width - 20) * ratio, 6)
  gfx.setColor(1, 1, 1)
  local status = cursor >= total and "REPLAY END" or ("REPLAY " .. speed .. "x")
  gfx.printf(status .. "   Space: SPEED   Esc: TITLE", 0, 42, width, "center")
end

function ReplayView.drawIncompatible(gfx, width, height, recVersion, rulesVersion)
  gfx.setColor(0, 0, 0, 0.7)
  gfx.rectangle("fill", 0, 0, width, height)
  gfx.setColor(1, 0.6, 0.4)
  gfx.printf(string.format("REPLAY VERSION MISMATCH\nrecorded v%d / game v%d\n\nEsc : TITLE", recVersion, rulesVersion),
    0, height * 0.4, width, "center")
end

return ReplayView

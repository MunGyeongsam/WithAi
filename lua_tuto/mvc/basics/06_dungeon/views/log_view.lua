-- log_view.lua
-- LogModel 의 원본 사건 { type, data } 을 사람이 읽는 문장으로 바꾼다.
-- 번역/문구 변경은 이 파일만 고치면 된다. (다국어 지원도 여기서)

local FORMAT = {
  room_entered = function(d)
    return string.format("%d번 방에 들어섰다.", d.index)
  end,
  enemy_appeared = function(d)
    return d.name .. " 이(가) 나타났다!"
  end,
  player_attacked = function(d)
    return string.format("%s 에게 %d 피해를 입혔다.", d.target, d.damage)
  end,
  enemy_attacked = function(d)
    return string.format("%s 에게 %d 피해를 받았다.", d.name, d.damage)
  end,
  enemy_killed = function(d)
    return string.format("%s 처치! 골드 +%d", d.name, d.gold)
  end,
  fled = function(d)
    return d.name .. " 에게서 도망쳤다."
  end,
  item_picked = function(d)
    return d.name .. " 을(를) 주웠다."
  end,
  item_lost = function(d)
    return d.name .. " 을(를) 두고 왔다 (" .. d.reason .. ")"
  end,
  item_used = function(d)
    if d.kind == "potion" then
      return string.format("%s 사용: HP +%d", d.name, d.amount)
    end
    return string.format("%s 장착: 공격 +%d", d.name, d.amount)
  end,
  quest_completed = function(d)
    return "★ 퀘스트 완료: " .. d.text
  end,
  player_died = function(d)
    return d.by .. " 에게 쓰러졌다..."
  end,
  dungeon_cleared = function(d)
    return string.format("출구를 찾았다! 총 골드 %d", d.gold)
  end,
}

local LogView = { title = "기록" }
LogView.__index = LogView

function LogView.new()
  return setmetatable({}, LogView)
end

function LogView:lines(game)
  local lines = {}
  for _, entry in ipairs(game.log.entries) do
    local format = FORMAT[entry.type]
    lines[#lines + 1] = format and format(entry.data) or ("(" .. entry.type .. ")")
  end
  if #lines == 0 then
    lines[1] = "던전 입구에 서 있다."
  end
  return lines
end

return LogView

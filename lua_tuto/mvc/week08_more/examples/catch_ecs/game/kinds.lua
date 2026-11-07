-- kinds.lua (ECS)
-- 아이템 종류 = 컴포넌트 묶음(데이터). 새 종류는 여기에 한 항목 + 생성 표에 한 줄. 시스템은 고치지 않는다.

local R = require("rules")

local kinds = {}

kinds.coin = {
  pickup = { score = R.COIN_SCORE },
  sprite = { shape = "circle", color = { 1, 0.85, 0.2 } },
}

kinds.bomb = {
  pickup = { damage = 1 },
  sprite = { shape = "circle", color = { 0.9, 0.25, 0.25 } },
}

kinds.heart = {
  pickup = { heal = 1 },
  sprite = { shape = "diamond", color = { 1, 0.45, 0.75 } },
}

-- 생성 표: 1~10 을 뽑아 upTo 이하인 첫 항목. DEFAULT 는 다른 다섯 예제와 같은 규칙이다.
kinds.DEFAULT = {
  { upTo = R.BOMB_CHANCE, kind = "bomb" },
  { upTo = 10, kind = "coin" },
}

kinds.WITH_HEART = {
  { upTo = R.BOMB_CHANCE, kind = "bomb" },
  { upTo = R.BOMB_CHANCE + 1, kind = "heart" },
  { upTo = 10, kind = "coin" },
}

return kinds

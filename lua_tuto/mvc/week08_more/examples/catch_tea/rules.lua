-- rules.lua
-- "동전 받기" 규칙 상수. 여섯 예제가 똑같은 사본을 가진다(love 는 앱 폴더 밖을 require 하지 못한다).

return {
  LANES = 5, -- 가로 칸 수
  ROWS = 6, -- 세로 칸 수. 마지막 줄(ROWS)이 플레이어 줄
  START_LANE = 3,
  TICK = 0.25, -- 아이템이 한 칸 떨어지는 간격(초)
  SPAWN_EVERY = 2, -- 몇 틱마다 새 아이템
  START_HP = 3,
  COIN_SCORE = 10,
  BOMB_CHANCE = 3, -- 1~10 을 뽑아 이 값 이하면 폭탄
}

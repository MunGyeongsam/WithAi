-- dungeon_data.lua
-- 게임 내용(방 구성, 적 능력치, 퀘스트)은 코드가 아니라 데이터로 둔다.
-- 기획자가 이 파일만 고쳐도 새 던전이 된다. Model 코드는 그대로.

return {
  player = { name = "용사", maxHp = 30, attack = 3 },
  inventoryCapacity = 4,
  logLimit = 5,

  rooms = {
    { kind = "enemy", enemy = { name = "슬라임", hp = 6, attack = 2, gold = 3 } },
    { kind = "item", item = { name = "회복 물약", kind = "potion", power = 10 } },
    { kind = "enemy", enemy = { name = "고블린", hp = 10, attack = 3, gold = 5 } },
    { kind = "item", item = { name = "철검", kind = "weapon", power = 2 } },
    { kind = "enemy", enemy = { name = "오크", hp = 16, attack = 4, gold = 10 } },
    { kind = "enemy", enemy = { name = "박쥐 떼", hp = 30, attack = 1, gold = 20 } },
    { kind = "exit" },
  },

  quests = {
    { id = "hunter", text = "몬스터 3마리 처치", event = "enemy_killed", needed = 3 },
    { id = "collector", text = "아이템 2개 줍기", event = "item_picked", needed = 2 },
    { id = "explorer", text = "방 7개 탐험", event = "room_entered", needed = 7 },
  },
}

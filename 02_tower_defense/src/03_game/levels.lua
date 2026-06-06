-- ============================================================================
-- levels.lua — 레벨 데이터 (오픈 필드 맵 설정)
-- ============================================================================
local Levels = {}

-- 레벨 1: 기본 9×14 (상단 진입 → 하단 출구)
Levels[1] = {
    name = "Training Ground",
    cols = 9,
    rows = 14,
    cellSize = 60,
    entryCol = 5,
    entryRow = 1,
    exitCol = 5,
    exitRow = 14,
    startGold = 150,
    startLives = 20,
}

-- 레벨 2: 좌상단 → 우하단 (대각 경로 유도)
Levels[2] = {
    name = "Crossfire",
    cols = 9,
    rows = 14,
    cellSize = 60,
    entryCol = 1,
    entryRow = 1,
    exitCol = 9,
    exitRow = 14,
    startGold = 180,
    startLives = 15,
}

-- 레벨 3: 양쪽 입구 (중앙 출구)
Levels[3] = {
    name = "Pincer",
    cols = 9,
    rows = 14,
    cellSize = 60,
    entryCol = 1,
    entryRow = 7,
    exitCol = 9,
    exitRow = 7,
    startGold = 200,
    startLives = 10,
}

function Levels.getLevel(index)
    return Levels[index]
end

function Levels.getCount()
    return #Levels
end

return Levels

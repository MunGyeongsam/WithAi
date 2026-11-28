package.path = "../../src/?.lua;" .. package.path

local Levels = require("03_game.levels")

local expected = {
    {
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
    },
    {
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
    },
    {
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
    },
}

local function assertLevel(level, fingerprint, index)
    local fields = {
        "name", "cols", "rows", "cellSize",
        "entryCol", "entryRow", "exitCol", "exitRow",
        "startGold", "startLives",
    }
    for _, field in ipairs(fields) do
        assert(level[field] == fingerprint[field],
            "level " .. index .. " " .. field .. " mismatch")
    end
end

local function test_level_fingerprints()
    assert(Levels.getCount() == 3)
    for index, fingerprint in ipairs(expected) do
        assertLevel(Levels.getLevel(index), fingerprint, index)
    end
    assert(Levels.getLevel(4) == nil)
    print("[PASS] test_level_fingerprints")
end

test_level_fingerprints()
print("\n=== All levels_harness tests passed ===")

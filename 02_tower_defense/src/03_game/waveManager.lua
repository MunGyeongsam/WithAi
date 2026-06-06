-- ============================================================================
-- waveManager.lua — 웨이브 스폰 관리 (Xeno Tactic 스타일)
-- ============================================================================
local Enemy = require("03_game.enemy")

local WaveManager = {}
WaveManager.__index = WaveManager

-- 웨이브 데이터: {type, count, interval}
local WAVE_DATA = {
    -- Wave 1: 기본 에일리언
    {{type = "normal", count = 6, interval = 1.0}},
    -- Wave 2: 스카우트 혼합
    {{type = "normal", count = 5, interval = 0.9}, {type = "fast", count = 3, interval = 0.7}},
    -- Wave 3: 더 많은 적
    {{type = "normal", count = 8, interval = 0.8}, {type = "fast", count = 5, interval = 0.6}},
    -- Wave 4: 공중 유닛 등장
    {{type = "normal", count = 6, interval = 0.8}, {type = "flyer", count = 4, interval = 1.0}},
    -- Wave 5: 탱크 등장
    {{type = "tank", count = 3, interval = 1.8}, {type = "normal", count = 8, interval = 0.7}},
    -- Wave 6: 공중 + 지상 혼합
    {{type = "fast", count = 6, interval = 0.5}, {type = "flyer", count = 5, interval = 0.8}},
    -- Wave 7: 대규모
    {{type = "normal", count = 12, interval = 0.6}, {type = "tank", count = 4, interval = 1.5}},
    -- Wave 8: 공중 러시
    {{type = "flyer", count = 8, interval = 0.7}, {type = "fast", count = 6, interval = 0.5}},
    -- Wave 9: 혼합 대군
    {{type = "tank", count = 5, interval = 1.2}, {type = "flyer", count = 6, interval = 0.8}, {type = "normal", count = 10, interval = 0.5}},
    -- Wave 10: 보스
    {{type = "fast", count = 8, interval = 0.4}, {type = "tank", count = 4, interval = 1.0}, {type = "boss", count = 1, interval = 0}},
}

function WaveManager.new()
    local self = setmetatable({}, WaveManager)
    self.currentWave = 0
    self.totalWaves = #WAVE_DATA
    self.spawnQueue = {}
    self.spawnTimer = 0
    self.spawning = false
    self.allWavesComplete = false
    return self
end

function WaveManager:startNextWave()
    if self.currentWave >= self.totalWaves then
        self.allWavesComplete = true
        return false
    end

    self.currentWave = self.currentWave + 1
    self.spawnQueue = {}
    self.spawnTimer = 0
    self.spawning = true

    local waveGroups = WAVE_DATA[self.currentWave]
    local delay = 0
    for _, group in ipairs(waveGroups) do
        for _ = 1, group.count do
            self.spawnQueue[#self.spawnQueue + 1] = {
                type = group.type,
                delay = delay,
            }
            delay = delay + group.interval
        end
    end

    return true
end

--- 적 스폰 (waypoints는 caller가 제공)
-- @param dt number
-- @param groundWaypoints table 지상 경로 (픽셀)
-- @param entryPixel table {x, y}
-- @param exitPixel table {x, y}
-- @return table|nil 스폰된 적 배열
function WaveManager:update(dt, groundWaypoints, entryPixel, exitPixel)
    if not self.spawning then return nil end
    if #self.spawnQueue == 0 then
        self.spawning = false
        return nil
    end

    self.spawnTimer = self.spawnTimer + dt

    local spawned = {}
    while #self.spawnQueue > 0 and self.spawnQueue[1].delay <= self.spawnTimer do
        local entry = table.remove(self.spawnQueue, 1)
        local enemy = Enemy.new(entry.type, groundWaypoints, entryPixel, exitPixel)
        if enemy then
            spawned[#spawned + 1] = enemy
        end
    end

    if #spawned > 0 then
        return spawned
    end
    return nil
end

function WaveManager:isWaveInProgress()
    return self.spawning or #self.spawnQueue > 0
end

function WaveManager:getCurrentWave()
    return self.currentWave
end

function WaveManager:getTotalWaves()
    return self.totalWaves
end

return WaveManager

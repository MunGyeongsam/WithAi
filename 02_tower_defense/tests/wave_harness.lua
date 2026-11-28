-- ============================================================================
-- wave_harness.lua — WaveManager 단위 테스트
-- ============================================================================
package.path = "../src/?.lua;" .. package.path

love = love or {}
love.graphics = love.graphics or {}

local WaveManager = require("03_game.waveManager")

local function test_init()
    local wm = WaveManager.new()
    assert(wm:getCurrentWave() == 0)
    assert(wm:getTotalWaves() == 10)
    assert(wm.allWavesComplete == false)
    print("[PASS] test_init")
end

local function test_start_wave()
    local wm = WaveManager.new()
    assert(wm:startNextWave() == true)
    assert(wm:getCurrentWave() == 1)
    assert(wm:isWaveInProgress() == true)
    print("[PASS] test_start_wave")
end

local function test_spawn()
    local wm = WaveManager.new()
    wm:startNextWave()

    local groundWP = {{x = 0, y = 0}, {x = 100, y = 0}}
    local entry = {x = 0, y = 0}
    local exit = {x = 100, y = 0}

    local totalSpawned = 0
    for _ = 1, 100 do
        local spawned = wm:update(0.1, groundWP, entry, exit)
        if spawned then
            totalSpawned = totalSpawned + #spawned
        end
    end
    -- Wave 1: normal ×6
    assert(totalSpawned == 6, "wave 1 should spawn 6 enemies, got " .. totalSpawned)
    print("[PASS] test_spawn")
end

local function test_all_waves()
    local wm = WaveManager.new()
    local groundWP = {{x = 0, y = 0}, {x = 100, y = 0}}
    local entry = {x = 0, y = 0}
    local exit = {x = 100, y = 0}

    for _ = 1, 10 do
        wm:startNextWave()
        for _ = 1, 300 do
            wm:update(0.1, groundWP, entry, exit)
        end
    end
    assert(wm:startNextWave() == false)
    assert(wm.allWavesComplete == true)
    print("[PASS] test_all_waves")
end

local function test_queue_delay_and_completion()
    local wm = WaveManager.new()
    local groundWP = {{x = 0, y = 0}, {x = 100, y = 0}}
    local entry = {x = 0, y = 0}
    local exit = {x = 100, y = 0}

    assert(wm:startNextWave() == true)

    local first = wm:update(0, groundWP, entry, exit)
    assert(#first == 1 and first[1].type == "normal")
    assert(wm:update(0.999, groundWP, entry, exit) == nil)

    local atOneSecond = wm:update(0.001, groundWP, entry, exit)
    assert(#atOneSecond == 1 and atOneSecond[1].type == "normal")
    assert(wm:isWaveInProgress() == true)
    print("[PASS] test_queue_delay_and_completion")
end

local function test_group_order_and_spawning_completion_tick()
    local wm = WaveManager.new()
    local groundWP = {{x = 0, y = 0}, {x = 100, y = 0}}
    local entry = {x = 0, y = 0}
    local exit = {x = 100, y = 0}

    assert(wm:startNextWave() == true)
    wm:update(100, groundWP, entry, exit)
    assert(wm:isWaveInProgress() == true)
    assert(wm:update(0, groundWP, entry, exit) == nil)
    assert(wm:isWaveInProgress() == false)
    assert(wm:startNextWave() == true)

    local spawned = wm:update(10, groundWP, entry, exit)
    assert(#spawned == 8)

    local types = {}
    for i, enemy in ipairs(spawned) do
        types[i] = enemy.type
    end
    assert(table.concat(types, ",") ==
        "normal,normal,normal,normal,normal,fast,fast,fast")
    assert(#wm.spawnQueue == 0)
    assert(wm.spawning == true, "final spawn tick keeps spawning true")
    assert(wm:isWaveInProgress() == true)

    assert(wm:update(0, groundWP, entry, exit) == nil)
    assert(wm.spawning == false)
    assert(wm:isWaveInProgress() == false)
    print("[PASS] test_group_order_and_spawning_completion_tick")
end

test_init()
test_start_wave()
test_spawn()
test_all_waves()
test_queue_delay_and_completion()
test_group_order_and_spawning_completion_tick()
print("\n=== All wave_harness tests passed ===")

local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*/)") or ""
package.path = scriptDirectory .. "../../src/?.lua;" .. package.path

local trace = {}

local function record(event)
    trace[#trace + 1] = event
end

local StubMap = {}
StubMap.__index = StubMap

function StubMap.new()
    local self = setmetatable({}, StubMap)
    self.entryCol = 1
    self.entryRow = 1
    self.exitCol = 9
    self.exitRow = 16
    return self
end

function StubMap:getPathPixels()
    record("map:path")
    return {{x = 30, y = 30}, {x = 510, y = 930}}
end

function StubMap:cellToPixel(col, row)
    return (col - 1) * 60 + 30, (row - 1) * 60 + 30
end

local StubTowerModule = {}

function StubTowerModule.getCost()
    return 30
end

function StubTowerModule.new()
    return {}
end

local StubWaveManager = {}
StubWaveManager.__index = StubWaveManager

function StubWaveManager.new()
    local self = setmetatable({}, StubWaveManager)
    self.currentWave = 0
    self.spawnQueue = {}
    self.spawnTimer = 0
    self.spawning = false
    self.allWavesComplete = false
    self.spawned = nil
    return self
end

function StubWaveManager:update(dt)
    record("wave:update:" .. tostring(dt))
    return self.spawned
end

function StubWaveManager:isWaveInProgress()
    record("wave:progress")
    return self.spawning or #self.spawnQueue > 0
end

function StubWaveManager:startNextWave()
    self.currentWave = self.currentWave + 1
    self.spawning = true
    return true
end

local StubEconomy = {}
StubEconomy.__index = StubEconomy

function StubEconomy.new(gold, lives)
    local self = setmetatable({}, StubEconomy)
    self.gold = gold or 150
    self.lives = lives or 20
    self.totalSpent = 0
    self.totalEarned = self.gold
    self.gameOver = false
    return self
end

function StubEconomy:earn(amount)
    record("economy:earn:" .. tostring(amount))
    self.gold = self.gold + amount
    self.totalEarned = self.totalEarned + amount
end

function StubEconomy:loseLife(amount)
    record("economy:life:" .. tostring(amount))
    self.lives = self.lives - amount
    if self.lives < 0 then
        self.lives = 0
    end
end

function StubEconomy:isGameOver()
    record("economy:gameover")
    return self.gameOver or self.lives <= 0
end

function StubEconomy:getGold()
    return self.gold
end

function StubEconomy:getLives()
    return self.lives
end

local StubLevels = {}

function StubLevels.getLevel()
    return {
        startGold = 150,
        startLives = 20,
    }
end

local StubHud = {}
StubHud.__index = StubHud

function StubHud.new()
    return setmetatable({}, StubHud)
end

package.loaded["03_game.gameMap"] = StubMap
package.loaded["03_game.tower"] = StubTowerModule
package.loaded["03_game.waveManager"] = StubWaveManager
package.loaded["03_game.economy"] = StubEconomy
package.loaded["03_game.levels"] = StubLevels
package.loaded["04_ui.hud"] = StubHud

local GameplayScene = require("03_game.scenes.gameplayScene")

local function resetTrace()
    trace = {}
end

local function newScene()
    return GameplayScene.new(540, 960, 1)
end

local function fingerprint(scene)
    local wave = scene.waveManager
    return table.concat({
        scene.state,
        tostring(scene.economy.gold),
        tostring(scene.economy.lives),
        tostring(scene.economy.totalSpent),
        tostring(scene.economy.totalEarned),
        tostring(#scene.enemies),
        tostring(wave.currentWave),
        tostring(#wave.spawnQueue),
        tostring(wave.spawnTimer),
        tostring(wave.spawning),
        tostring(wave.allWavesComplete),
    }, "|")
end

local function assertTrace(expected)
    local actual = table.concat(trace, ">")
    local expectedText = table.concat(expected, ">")
    assert(actual == expectedText, "trace mismatch\nexpected: " .. expectedText ..
        "\nactual:   " .. actual)
end

local function makeEnemy(name, transition)
    local enemy = {
        name = name,
        dead = false,
        reachedEnd = false,
        reward = 8,
        x = 10,
        y = 20,
    }

    function enemy:update(dt)
        record("enemy:update:" .. name .. ":" .. tostring(dt))
        if transition == "dead" then
            enemy.dead = true
        elseif transition == "reachedEnd" then
            enemy.reachedEnd = true
        end
    end

    function enemy:takeDamage(amount)
        record("enemy:damage:" .. name .. ":" .. tostring(amount))
        if amount >= 999 then
            self.dead = true
        end
    end

    function enemy:applySlow(amount, duration)
        record("enemy:slow:" .. name .. ":" .. tostring(amount) .. ":" ..
            tostring(duration))
    end

    return enemy
end

local function makeTower(target, projectileOptions)
    local tower = {}
    projectileOptions = projectileOptions or {}

    function tower:update(dt)
        record("tower:update:" .. tostring(dt))
        return {
            target = target,
            damage = projectileOptions.damage or 8,
            slow = projectileOptions.slow or 0,
            slowDuration = projectileOptions.slowDuration,
            splash = projectileOptions.splash or 0,
            targetX = target.x,
            targetY = target.y,
        }
    end

    return tower
end

local function test_tower_damage_precedes_enemy_movement()
    local scene = newScene()
    local target = makeEnemy("target")
    local tower = makeTower(target, {
        damage = 8,
        slow = 0.4,
        slowDuration = 2,
    })
    scene.towers = {tower}
    scene.enemies = {target}
    resetTrace()

    scene:update(0.25)

    assertTrace({
        "tower:update:0.25",
        "enemy:damage:target:8",
        "enemy:slow:target:0.4:2",
        "enemy:update:target:0.25",
        "economy:gameover",
    })
    assert(#scene.enemies == 1)
    assert(fingerprint(scene) ==
        "build|150|20|0|150|1|0|0|0|false|false")
    print("[PASS] test_tower_damage_precedes_enemy_movement")
    return true
end

local function test_splash_is_applied_before_other_enemy_updates()
    local scene = newScene()
    local target = makeEnemy("target")
    local nearby = makeEnemy("nearby")
    local tower = makeTower(target, {
        damage = 10,
        slow = 0.5,
        slowDuration = 2,
        splash = 30,
    })
    scene.towers = {tower}
    scene.enemies = {target, nearby}
    resetTrace()

    scene:update(0.1)

    assertTrace({
        "tower:update:0.1",
        "enemy:damage:target:10",
        "enemy:slow:target:0.5:2",
        "enemy:damage:nearby:3",
        "enemy:slow:nearby:0.25:1",
        "enemy:update:nearby:0.1",
        "enemy:update:target:0.1",
        "economy:gameover",
    })
    assert(fingerprint(scene) ==
        "build|150|20|0|150|2|0|0|0|false|false")
    print("[PASS] test_splash_is_applied_before_other_enemy_updates")
    return true
end

local function test_tower_kill_pays_reward_in_same_update()
    local scene = newScene()
    local target = makeEnemy("target")
    scene.towers = {makeTower(target, {damage = 999})}
    scene.enemies = {target}
    resetTrace()

    scene:update(0.1)

    assertTrace({
        "tower:update:0.1",
        "enemy:damage:target:999",
        "enemy:update:target:0.1",
        "economy:earn:8",
        "economy:gameover",
    })
    assert(fingerprint(scene) ==
        "build|158|20|0|158|0|0|0|0|false|false")
    print("[PASS] test_tower_kill_pays_reward_in_same_update")
    return true
end

local function test_enemy_exit_and_death_update_economy()
    local scene = newScene()
    local dead = makeEnemy("dead", "dead")
    local exiting = makeEnemy("exit", "reachedEnd")
    scene.enemies = {dead, exiting}
    scene.state = GameplayScene.STATE_WAVE
    scene.waveManager.spawning = true
    resetTrace()

    scene:update(0.5)

    assertTrace({
        "enemy:update:exit:0.5",
        "economy:life:1",
        "enemy:update:dead:0.5",
        "economy:earn:8",
        "map:path",
        "wave:update:0.5",
        "wave:progress",
        "economy:gameover",
    })
    assert(scene.economy.gold == 158)
    assert(scene.economy.lives == 19)
    assert(#scene.enemies == 0)
    assert(fingerprint(scene) ==
        "wave|158|19|0|158|0|0|0|0|true|false")
    print("[PASS] test_enemy_exit_and_death_update_economy")
    return true
end

local function test_spawn_runs_after_enemy_movement()
    local scene = newScene()
    local existing = makeEnemy("existing")
    local spawned = makeEnemy("spawned")
    scene.state = GameplayScene.STATE_WAVE
    scene.enemies = {existing}
    scene.waveManager.spawning = true
    scene.waveManager.spawned = {spawned}
    resetTrace()

    scene:update(0.2)

    assertTrace({
        "enemy:update:existing:0.2",
        "map:path",
        "wave:update:0.2",
        "wave:progress",
        "economy:gameover",
    })
    assert(#scene.enemies == 2)
    assert(scene.enemies[2] == spawned)
    assert(fingerprint(scene) ==
        "wave|150|20|0|150|2|0|0|0|true|false")
    print("[PASS] test_spawn_runs_after_enemy_movement")
    return true
end

local function test_completed_wave_returns_to_build()
    local scene = newScene()
    scene.state = GameplayScene.STATE_WAVE
    scene.waveManager.currentWave = 1
    resetTrace()

    scene:update(1 / 60)

    assert(scene.state == GameplayScene.STATE_BUILD)
    assert(fingerprint(scene) ==
        "build|150|20|0|150|0|1|0|0|false|false")
    assertTrace({
        "map:path",
        "wave:update:0.016666666666667",
        "wave:progress",
        "economy:gameover",
    })
    print("[PASS] test_completed_wave_returns_to_build")
    return true
end

local function test_tenth_wave_completion_stays_in_build()
    local scene = newScene()
    scene.state = GameplayScene.STATE_WAVE
    scene.waveManager.currentWave = 10
    resetTrace()

    scene:update(1 / 60)

    assert(scene.state == GameplayScene.STATE_BUILD)
    assert(scene.waveManager.allWavesComplete == false)
    assertTrace({
        "map:path",
        "wave:update:0.016666666666667",
        "wave:progress",
        "economy:gameover",
    })
    print("[PASS] test_tenth_wave_completion_stays_in_build")
    return true
end

local function test_gameover_check_follows_wave_transition()
    local scene = newScene()
    scene.state = GameplayScene.STATE_WAVE
    scene.economy.lives = 0
    resetTrace()

    scene:update(1 / 60)

    assert(scene.state == "gameover")
    assertTrace({
        "map:path",
        "wave:update:0.016666666666667",
        "wave:progress",
        "economy:gameover",
    })
    print("[PASS] test_gameover_check_follows_wave_transition")
    return true
end

local function test_terminal_states_skip_normal_update()
    local terminalStates = {"gameover", "victory"}

    for _, state in ipairs(terminalStates) do
        local scene = newScene()
        local enemy = makeEnemy(state)
        scene.state = state
        scene.towers = {makeTower(enemy)}
        scene.enemies = {enemy}
        scene.waveManager.spawning = true
        local before = fingerprint(scene)
        resetTrace()

        scene:update(1 / 60)

        assert(fingerprint(scene) == before)
        assertTrace({})
    end

    print("[PASS] test_terminal_states_skip_normal_update")
    return true
end

test_tower_damage_precedes_enemy_movement()
test_splash_is_applied_before_other_enemy_updates()
test_tower_kill_pays_reward_in_same_update()
test_enemy_exit_and_death_update_economy()
test_spawn_runs_after_enemy_movement()
test_completed_wave_returns_to_build()
test_tenth_wave_completion_stays_in_build()
test_gameover_check_follows_wave_transition()
test_terminal_states_skip_normal_update()
print("\n=== All gameplay_scene_harness tests passed ===")

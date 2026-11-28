local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*/)") or ""
package.path = scriptDirectory .. "../../src/?.lua;" .. package.path

local GameplayScene = require("03_game.scenes.gameplayScene")

local function tap(scene, x, y)
    scene:setInputSnapshot({
        tapped = true,
        tapX = x,
        tapY = y,
        holding = false,
    })
end

local function mapFingerprint(scene)
    local cells = {}
    for row = 1, scene.map.rows do
        for col = 1, scene.map.cols do
            cells[#cells + 1] = scene.map:getCellType(col, row)
        end
    end
    return table.concat(cells, ",")
end

local function pathFingerprint(scene)
    local nodes = {}
    local path = scene.map:getPath()
    for index = 1, #(path or {}) do
        local node = path[index]
        nodes[index] = node.col .. ":" .. node.row
    end
    return table.concat(nodes, ",")
end

local function worldFingerprint(scene)
    return mapFingerprint(scene) .. "|" ..
        pathFingerprint(scene) .. "|" ..
        tostring(scene.economy:getGold()) .. "|" ..
        tostring(scene.economy:getLives()) .. "|" ..
        tostring(scene.economy.totalSpent) .. "|" ..
        tostring(scene.economy.totalEarned) .. "|" ..
        tostring(#scene.towers)
end

local function sceneFingerprint(scene)
    return worldFingerprint(scene) .. "|" ..
        tostring(scene.state) .. "|" ..
        tostring(scene.placeMode) .. "|" ..
        tostring(scene.selectedTowerType)
end

local function waveFingerprint(scene)
    local wave = scene.waveManager
    return tostring(wave.currentWave) .. "|" ..
        tostring(#wave.spawnQueue) .. "|" ..
        tostring(wave.spawnTimer) .. "|" ..
        tostring(wave.spawning) .. "|" ..
        tostring(wave.allWavesComplete)
end

local function stateFingerprint(scene)
    return sceneFingerprint(scene) .. "|" .. waveFingerprint(scene)
end

local function panelMapPoint(scene)
    return 510, scene.hud.panelY + 20
end

local function newScene()
    return GameplayScene.new(540, 960, 1)
end

local function test_hud_panel_tap_is_consumed_without_placement()
    local scene = newScene()
    local x, y = panelMapPoint(scene)
    local before = worldFingerprint(scene)

    assert(x < scene.map.cols * scene.map.cellSize)
    assert(y < scene.map.rows * scene.map.cellSize)
    tap(scene, x, y)

    assert(worldFingerprint(scene) == before)
    print("[PASS] test_hud_panel_tap_is_consumed_without_placement")
    return true
end

local function test_hud_consumption_fixture_detects_unconsumed_tap()
    local scene = newScene()
    local x, y = panelMapPoint(scene)
    scene.hud.handleTap = function()
        return false
    end

    tap(scene, x, y)

    local col, row = scene.map:pixelToCell(x, y)
    assert(scene.map:getCellType(col, row) == scene.map.CELL_WALL)
    print("[PASS] test_hud_consumption_fixture_detects_unconsumed_tap")
    return true
end

local function test_hud_buttons_select_build_mode_without_placement()
    local scene = newScene()
    local gunButton = scene.hud.buttons[1]
    local before = worldFingerprint(scene)

    tap(scene, gunButton.x + 5, gunButton.y + 5)
    assert(scene.placeMode == GameplayScene.PLACE_TOWER)
    assert(scene.selectedTowerType == "gun")
    assert(worldFingerprint(scene) == before)

    tap(scene, scene.hud.wallBtn.x + 5, scene.hud.wallBtn.y + 5)
    assert(scene.placeMode == GameplayScene.PLACE_WALL)
    assert(worldFingerprint(scene) == before)
    print("[PASS] test_hud_buttons_select_build_mode_without_placement")
    return true
end

local function test_tap_outside_hud_places_wall()
    local scene = newScene()

    tap(scene, 30, 90)

    assert(scene.map:getCellType(1, 2) == scene.map.CELL_WALL)
    assert(scene.economy:getGold() == 145)
    print("[PASS] test_tap_outside_hud_places_wall")
    return true
end

local function test_tap_outside_hud_places_selected_tower()
    local scene = newScene()
    scene:selectTowerType("gun")

    tap(scene, 30, 90)

    assert(scene.map:getCellType(1, 2) == scene.map.CELL_TOWER)
    assert(#scene.towers == 1)
    assert(scene.economy:getGold() == 120)
    print("[PASS] test_tap_outside_hud_places_selected_tower")
    return true
end

local function test_failed_placement_keeps_state_fingerprint_unchanged()
    local scene = newScene()
    tap(scene, 30, 90)
    local before = stateFingerprint(scene)

    tap(scene, 30, 90)

    assert(stateFingerprint(scene) == before)
    print("[PASS] test_failed_placement_keeps_state_fingerprint_unchanged")
    return true
end

local function test_unaffordable_tower_keeps_state_fingerprint_unchanged()
    local scene = newScene()
    assert(scene.economy:spend(121))
    scene:selectTowerType("gun")
    local before = stateFingerprint(scene)

    tap(scene, 30, 90)

    assert(stateFingerprint(scene) == before)
    print("[PASS] test_unaffordable_tower_keeps_state_fingerprint_unchanged")
    return true
end

local function test_start_wave_only_advances_from_build_phase()
    local scene = newScene()
    local button = scene.hud.startWaveBtn
    local x = button.x + button.w / 2
    local y = button.y + button.h / 2

    tap(scene, x, y)
    assert(scene.state == GameplayScene.STATE_WAVE)
    assert(scene.waveManager:getCurrentWave() == 1)

    local fingerprintAfterStart = stateFingerprint(scene)
    tap(scene, x, y)

    assert(stateFingerprint(scene) == fingerprintAfterStart)
    assert(scene.waveManager:getCurrentWave() == 1)
    print("[PASS] test_start_wave_only_advances_from_build_phase")
    return true
end

test_hud_panel_tap_is_consumed_without_placement()
test_hud_consumption_fixture_detects_unconsumed_tap()
test_hud_buttons_select_build_mode_without_placement()
test_tap_outside_hud_places_wall()
test_tap_outside_hud_places_selected_tower()
test_failed_placement_keeps_state_fingerprint_unchanged()
test_unaffordable_tower_keeps_state_fingerprint_unchanged()
test_start_wave_only_advances_from_build_phase()
print("\n=== All hud_harness tests passed ===")

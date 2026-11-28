local scriptDirectory = debug.getinfo(1, "S").source:match("@(.*/)") or ""
package.path = scriptDirectory .. "../../src/?.lua;" .. package.path

local CommandProcessor = require("03_game.simulation.commandProcessor")
local CommandResult = require("03_game.simulation.commandResult")
local GameState = require("03_game.simulation.gameState")

local function command(id, commandType, tick, payload)
    return {
        id = id,
        type = commandType,
        tick = tick,
        payload = payload,
    }
end

local function fingerprint(state)
    return table.concat({
        tostring(state.revision),
        tostring(state.tick),
        state.phase,
        tostring(state.nextEntityId),
        tostring(#state.enemies),
        tostring(#state.towers),
        tostring(state.economy.gold),
        tostring(state.economy.lives),
        tostring(state.economy.totalSpent),
        tostring(state.economy.totalEarned),
        tostring(state.map.grid[1][1]),
        tostring(#state.map.currentPath),
        tostring(state.wave.currentWave),
        tostring(state.wave.spawning),
    }, "|")
end

local function newState()
    local map = {
        grid = {{0}},
        currentPath = {{col = 1, row = 1}},
    }
    local economy = {
        gold = 50,
        lives = 20,
        totalSpent = 10,
        totalEarned = 60,
    }
    local enemies = {{id = 1}}
    local towers = {{id = 2}}
    local wave = {currentWave = 3, spawning = false}
    local state = GameState.new({
        map = map,
        economy = economy,
        enemies = enemies,
        towers = towers,
        wave = wave,
    })

    assert(state.map == map)
    assert(state.economy == economy)
    assert(state.enemies == enemies)
    assert(state.towers == towers)
    assert(state.wave == wave)
    return state
end

local function assertResult(result, expected)
    assert(result.commandId == expected.commandId)
    assert(result.accepted == expected.accepted)
    assert(result.code == expected.code)
    assert(result.revision == expected.revision)
    assert(type(result.events) == "table")
end

local function test_fifo_commit_and_processor_ownership()
    local state = newState()
    local trace = {}
    local processor = CommandProcessor.new(state, {
        APPEND = function(currentState, queuedCommand)
            trace[#trace + 1] = queuedCommand.id
            currentState.economy.gold = currentState.economy.gold
                - queuedCommand.payload.cost
            currentState.revision = currentState.revision + 1
            return CommandResult.committed(
                queuedCommand.id,
                currentState.revision,
                {"APPENDED"}
            )
        end,
    })

    processor:enqueue(command(1, "APPEND", 7, {cost = 5}))
    processor:enqueue(command(2, "APPEND", 7, {cost = 3}))
    local results = processor:drain()

    assert(table.concat(trace, ",") == "1,2")
    assert(#results == 2)
    assertResult(results[1], {
        commandId = 1, accepted = true, code = "COMMITTED", revision = 1,
    })
    assertResult(results[2], {
        commandId = 2, accepted = true, code = "COMMITTED", revision = 2,
    })
    assert(state.tick == 0)
    assert(state.economy.gold == 42)
    print("[PASS] test_fifo_commit_and_processor_ownership")
end

local function test_drain_uses_queue_snapshot()
    local state = newState()
    local processor
    processor = CommandProcessor.new(state, {
        APPEND = function(currentState, queuedCommand)
            if queuedCommand.id == 1 then
                processor:enqueue(command(2, "APPEND", 1, {}))
            end
            return CommandResult.committed(
                queuedCommand.id,
                currentState.revision
            )
        end,
    })

    processor:enqueue(command(1, "APPEND", 0, {}))
    local first = processor:drain()
    assert(#first == 1)
    assert(first[1].commandId == 1)
    assert(processor:pendingCount() == 1)

    local second = processor:drain()
    assert(#second == 1)
    assert(second[1].commandId == 2)
    print("[PASS] test_drain_uses_queue_snapshot")
end

local function test_reject_and_invalid_are_state_preserving()
    local state = newState()
    local before = fingerprint(state)
    local processor = CommandProcessor.new(state, {
        REJECT = function(currentState, queuedCommand)
            return CommandResult.rejected(
                queuedCommand.id,
                "INSUFFICIENT_GOLD",
                currentState.revision,
                {"REJECTED"}
            )
        end,
    })

    processor:enqueue(command(1, "REJECT", 0, {}))
    processor:enqueue({id = 2, type = "REJECT", tick = 0})
    processor:enqueue(command(3, "UNKNOWN", 0, {}))
    processor:enqueue(nil)

    local results = processor:drain()
    assert(#results == 4)
    assertResult(results[1], {
        commandId = 1, accepted = false, code = "INSUFFICIENT_GOLD", revision = 0,
    })
    for i = 2, 4 do
        assertResult(results[i], {
            commandId = i == 2 and 2 or (i == 3 and 3 or false),
            accepted = false,
            code = "INVALID_COMMAND",
            revision = 0,
        })
    end
    assert(fingerprint(state) == before)
    print("[PASS] test_reject_and_invalid_are_state_preserving")
end

local function test_terminal_phase_is_rejected_by_handler()
    local state = newState()
    state.phase = "gameover"
    local before = fingerprint(state)
    local processor = CommandProcessor.new(state, {
        PLACE_WALL = function(currentState, queuedCommand)
            if currentState.phase == "gameover"
                or currentState.phase == "victory" then
                return CommandResult.rejected(
                    queuedCommand.id,
                    "INVALID_PHASE",
                    currentState.revision
                )
            end
            return CommandResult.committed(
                queuedCommand.id,
                currentState.revision
            )
        end,
    })

    processor:enqueue(command(1, "PLACE_WALL", 0, {}))
    local result = processor:drain()[1]

    assertResult(result, {
        commandId = 1, accepted = false, code = "INVALID_PHASE", revision = 0,
    })
    assert(fingerprint(state) == before)
    print("[PASS] test_terminal_phase_is_rejected_by_handler")
end

local function test_victory_phase_is_rejected_by_handler()
    local state = newState()
    state.phase = "victory"
    local before = fingerprint(state)
    local processor = CommandProcessor.new(state, {
        PLACE_WALL = function(currentState, queuedCommand)
            if currentState.phase == "gameover"
                or currentState.phase == "victory" then
                return CommandResult.rejected(
                    queuedCommand.id,
                    "INVALID_PHASE",
                    currentState.revision
                )
            end
            return CommandResult.committed(
                queuedCommand.id,
                currentState.revision
            )
        end,
    })

    processor:enqueue(command(1, "PLACE_WALL", 0, {}))
    local result = processor:drain()[1]

    assertResult(result, {
        commandId = 1, accepted = false, code = "INVALID_PHASE", revision = 0,
    })
    assert(fingerprint(state) == before)
    print("[PASS] test_victory_phase_is_rejected_by_handler")
end

local function test_handler_cannot_change_result_command_id()
    local state = newState()
    local processor = CommandProcessor.new(state, {
        WRONG_ID = function(currentState)
            return CommandResult.committed(99, currentState.revision)
        end,
    })

    processor:enqueue(command(1, "WRONG_ID", 0, {}))
    local ok, message = pcall(function()
        processor:drain()
    end)

    assert(ok == false)
    assert(tostring(message):find("invalid CommandResult", 1, true) ~= nil)
    print("[PASS] test_handler_cannot_change_result_command_id")
end

local function test_duplicate_pending_id_and_object_are_invalid()
    local state = newState()
    local processed = {}
    local processor = CommandProcessor.new(state, {
        OBSERVE = function(currentState, queuedCommand)
            processed[#processed + 1] = queuedCommand.id
            return CommandResult.committed(
                queuedCommand.id,
                currentState.revision
            )
        end,
    })
    local first = command(10, "OBSERVE", 4, {})

    processor:enqueue(first)
    processor:enqueue(first)
    processor:enqueue(command(10, "OBSERVE", 4, {}))
    processor:enqueue(command(11, "OBSERVE", 4, {}))

    local results = processor:drain()
    assert(#results == 4)
    assert(results[1].accepted)
    assert(results[2].accepted == false and results[2].code == "INVALID_COMMAND")
    assert(results[3].accepted == false and results[3].code == "INVALID_COMMAND")
    assert(results[4].accepted)
    assert(table.concat(processed, ",") == "10,11")

    processor:enqueue(command(10, "OBSERVE", 5, {}))
    assert(processor:drain()[1].accepted)
    print("[PASS] test_duplicate_pending_id_and_object_are_invalid")
end

local function test_game_state_defaults_and_references()
    local state = GameState.new()
    assert(state.revision == 0)
    assert(state.tick == 0)
    assert(state.nextEntityId == 1)
    assert(state.phase == "build")
    assert(type(state.enemies) == "table")
    assert(type(state.towers) == "table")
    print("[PASS] test_game_state_defaults_and_references")
end

test_fifo_commit_and_processor_ownership()
test_drain_uses_queue_snapshot()
test_reject_and_invalid_are_state_preserving()
test_terminal_phase_is_rejected_by_handler()
test_victory_phase_is_rejected_by_handler()
test_handler_cannot_change_result_command_id()
test_duplicate_pending_id_and_object_are_invalid()
test_game_state_defaults_and_references()
print("\n=== All command_processor_harness tests passed ===")

local CommandResult = require("03_game.simulation.commandResult")

local CommandProcessor = {}
CommandProcessor.__index = CommandProcessor

local function isValidCommand(command)
    return type(command) == "table"
        and type(command.id) == "number"
        and type(command.type) == "string"
        and type(command.tick) == "number"
        and type(command.payload) == "table"
end

local function isValidResult(result, command)
    return type(result) == "table"
        and result.commandId == command.id
        and type(result.accepted) == "boolean"
        and type(result.code) == "string"
        and type(result.revision) == "number"
        and type(result.events) == "table"
end

function CommandProcessor.new(state, handlers)
    assert(type(state) == "table", "state is required")
    assert(type(handlers) == "table", "handlers are required")

    local self = setmetatable({}, CommandProcessor)
    self.state = state
    self.handlers = handlers
    self.queue = {}
    self.pendingIds = {}
    self.pendingCommands = {}
    return self
end

function CommandProcessor:enqueue(command)
    local duplicate = type(command) == "table"
        and (self.pendingCommands[command] ~= nil
            or (command.id ~= nil and self.pendingIds[command.id] ~= nil))

    self.queue[#self.queue + 1] = {
        command = command,
        duplicate = duplicate,
    }

    if type(command) == "table" then
        self.pendingCommands[command] = true
        if command.id ~= nil then
            self.pendingIds[command.id] = true
        end
    end

    return #self.queue
end

function CommandProcessor:pendingCount()
    return #self.queue
end

function CommandProcessor:drain()
    local queue = self.queue
    self.queue = {}
    self.pendingIds = {}
    self.pendingCommands = {}

    local results = {}
    for _, queued in ipairs(queue) do
        local command = queued.command
        local commandId = type(command) == "table" and command.id or nil
        if commandId == nil then
            commandId = false
        end

        if queued.duplicate or not isValidCommand(command)
            or type(self.handlers[command.type]) ~= "function" then
            results[#results + 1] = CommandResult.rejected(
                commandId,
                "INVALID_COMMAND",
                self.state.revision
            )
        else
            local result = self.handlers[command.type](self.state, command)
            assert(isValidResult(result, command),
                "handler for " .. command.type .. " returned an invalid CommandResult")
            results[#results + 1] = result
        end
    end

    return results
end

return CommandProcessor

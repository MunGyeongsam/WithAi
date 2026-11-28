local CommandResult = {}
CommandResult.__index = CommandResult

function CommandResult.new(commandId, accepted, code, revision, events)
    local self = setmetatable({}, CommandResult)
    self.commandId = commandId
    self.accepted = accepted == true
    self.code = code
    self.revision = revision
    self.events = events or {}
    return self
end

function CommandResult.committed(commandId, revision, events)
    return CommandResult.new(commandId, true, "COMMITTED", revision, events)
end

function CommandResult.rejected(commandId, code, revision, events)
    return CommandResult.new(commandId, false, code, revision, events)
end

return CommandResult

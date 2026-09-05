local Logger = {}
local instance

function Logger.get()
    if not instance then
        instance = { messages = {} }
    end
    return instance
end

function Logger.write(message)
    local logger = Logger.get()
    logger.messages[#logger.messages + 1] = message
end

local logger = Logger.get()
Logger.write("게임 시작")
local same_logger = Logger.get()

assert(logger == same_logger)
assert(#logger.messages == 1 and logger.messages[1] == "게임 시작")
print(logger == same_logger, #logger.messages, logger.messages[1])

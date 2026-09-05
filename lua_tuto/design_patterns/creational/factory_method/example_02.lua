local Creator = {}
function Creator:send(message)
    local notification = self:create_notification(message)
    return "send:" .. notification.channel .. ":" .. notification.text
end

local PopupCreator = setmetatable({}, { __index = Creator })
function PopupCreator:create_notification(message)
    return { channel = "popup", text = message }
end

local result = PopupCreator:send("새 기록")
assert(result == "send:popup:새 기록")
print(result)

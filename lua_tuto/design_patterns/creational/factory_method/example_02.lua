local Creator = {}
function Creator:send(message)
    local notification = self:create_notification(message)
    return "send:" .. notification.channel .. ":" .. notification.text
end

local PopupCreator = setmetatable({}, { __index = Creator })
function PopupCreator:create_notification(message)
    return { channel = "popup", text = message }
end

local EmailCreator = setmetatable({}, { __index = Creator })
function EmailCreator:create_notification(message)
    return { channel = "email", text = message }
end

local popup_result = PopupCreator:send("새 기록")
local email_result = EmailCreator:send("새 기록")
assert(popup_result == "send:popup:새 기록")
assert(email_result == "send:email:새 기록")
print(popup_result, email_result)

local Weather = { observers = {}, temperature = 20 }

function Weather.subscribe(observer)
    Weather.observers[#Weather.observers + 1] = observer
    local subscribed = true
    return function()
        if not subscribed then return end
        for index, current in ipairs(Weather.observers) do
            if current == observer then
                table.remove(Weather.observers, index)
                subscribed = false
                return
            end
        end
    end
end

function Weather.set_temperature(value)
    Weather.temperature = value
    local observers = {}
    for index, observer in ipairs(Weather.observers) do observers[index] = observer end
    for _, observer in ipairs(observers) do observer(value) end
end

local display = 0
local log = ""
Weather.subscribe(function(value) display = value end)
local unsubscribe_log = Weather.subscribe(function(value) log = "temperature=" .. value end)
Weather.set_temperature(28)
unsubscribe_log()
Weather.set_temperature(30)
assert(display == 30 and log == "temperature=28")
print(display, log)

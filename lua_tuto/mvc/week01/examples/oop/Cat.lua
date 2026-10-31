
local class = require'class'
local Mammal = require'Mammal'
local Animal = require'Animal'

local Cat = class(Mammal)
function Cat:init(name, age)
    Mammal.init(self, name, age)
    self.mood = "neutral"
    self.sleepHours = 0
end

function Cat:speak()
    local moods = {neutral = "Meow", happy = "Purrrr", angry = "Hisss"}
    return self.name .. " " .. (moods[self.mood] or moods.neutral) .. "!"
end

function Cat:move(distance)
    -- 고양이는 상황에 따라 이동
    if self.mood == "happy" then
        return Mammal.move(self, distance * 0.5) .. " (playing gracefully)"
    else
        return Mammal.move(self, distance)
    end
end

function Cat:nap()
    self.sleepHours = self.sleepHours + 1
    self.energy = math.min(self.maxEnergy, self.energy + 30)
    return self.name .. " takes a nap (sleep hours: " .. self.sleepHours .. ")"
end

function Cat:getInfo()
    local parentInfo = Animal.getInfo(self)
    return parentInfo .. string.format(" Mood:%s Naps:%d", 
        self.mood, self.sleepHours)
end

return Cat
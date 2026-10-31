local class = require'class'
local Bird = require'Bird'
local Animal = require'Animal'

local Penguin = class(Bird)
function Penguin:init(name, age)
    Bird.init(self, name, age, false)  -- 펭귄은 날 수 없음
    self.swimming = true
end

function Penguin:speak()
    return self.name .. " squeaks: Sqawk sqawk!"
end

function Penguin:move(distance)
    -- 펭귄은 헤엄친다 (Bird.move에서 waddles로 표현)
    local cost = distance * 0.6
    self.energy = math.max(0, self.energy - cost)
    return self.name .. " swims " .. distance .. " meters (energy -" .. cost .. ")"
end

function Penguin:dive()
    self.energy = math.max(0, self.energy - 20)
    return self.name .. " dives deep into the ocean (energy -20)"
end

function Penguin:getInfo()
    local parentInfo = Animal.getInfo(self)
    return parentInfo .. string.format(" Swimming:%s", 
        self.swimming and "yes" or "no")
end

return Penguin
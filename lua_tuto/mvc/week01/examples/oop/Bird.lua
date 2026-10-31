local class = require'class'
local Animal = require'Animal'

local Bird = class(Animal)
function Bird:init(name, age, canFly)
    Animal.init(self, name, age)
    self.canFly = canFly or true
    self.wingSpan = 0
end

function Bird:speak()
    return self.name .. " (bird) chirps!"
end

function Bird:move(distance)
    local cost = self.canFly and distance * 0.2 or distance * 0.8
    self.energy = math.max(0, self.energy - cost)
    local method = self.canFly and "flies" or "waddles"
    return self.name .. " " .. method .. " " .. distance .. " meters (energy -" .. cost .. ")"
end

return Bird
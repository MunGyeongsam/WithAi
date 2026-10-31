local class = require'class'
local Bird = require'Bird'
local Animal = require'Animal'

local Eagle = class(Bird)
function Eagle:init(name, age)
    Bird.init(self, name, age, true)
    self.wingSpan = 200
    self.hunting = false
end

function Eagle:speak()
    return self.name .. " screeches: Krrrrr!"
end

function Eagle:hunt()
    if self.canFly then
        self.energy = math.max(0, self.energy - 30)
        return self.name .. " hunts from the sky (energy -30)"
    else
        return self.name .. " cannot hunt (not flying)"
    end
end

function Eagle:getInfo()
    local parentInfo = Animal.getInfo(self)
    return parentInfo .. string.format(" WingSpan:%dcm", self.wingSpan)
end

return Eagle

local class = require'class'
local Mammal = require'Mammal'
local Animal = require'Animal'

local Dog = class(Mammal)
function Dog:init(name, age)
    Mammal.init(self, name, age)
    self.breed = "Unknown"
    self.happiness = 50
end

function Dog:speak()
    return self.name .. " barks: Woof! Woof!"
end

function Dog:move(distance)
    self.happiness = math.min(100, self.happiness + 5)
    return Mammal.move(self, distance) .. " (happiness +5)"
end

function Dog:fetch()
    self.energy = math.max(0, self.energy - 10)
    self.happiness = math.min(100, self.happiness + 20)
    return self.name .. " fetches the ball happily! (happiness +20, energy -10)"
end

function Dog:getInfo()
    local parentInfo = Animal.getInfo(self)
    return parentInfo .. string.format(" Happiness:%d Breed:%s", 
        self.happiness, self.breed)
end

return Dog
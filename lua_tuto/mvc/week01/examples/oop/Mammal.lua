local class = require'class'
local Animal = require'Animal'

local Mammal = class(Animal)
function Mammal:init(name, age)
    Animal.init(self, name, age)
    self.warmBlooded = true
end

function Mammal:speak()
    return self.name .. " (mammal) makes a warm-blooded sound"
end

return Mammal
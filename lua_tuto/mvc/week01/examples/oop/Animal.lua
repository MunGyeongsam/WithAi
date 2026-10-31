--동물
local class = require 'class'
local Animal = class()
function Animal:init(name, age)
   self.name = name
   self.age = age
   self.energy = 100
   self.maxEnergy = 100
end

function Animal:speak()
   return self.name .. " makes a sound"
end

function Animal:move(distance)
   local cost = distance * 0.5
   self.energy = math.max(0, self.energy - cost)
   return self.name .. " moves " .. distance .. " meters (energy -" .. cost .. ")"
end

function Animal:eat(food)
   self.energy = math.min(self.maxEnergy, self.energy + 20)
   return self.name .. " eats " .. food .. " (energy +20)"
end

function Animal:sleep()
   self.energy = self.maxEnergy
   return self.name .. " sleeps and recovers energy"
end

function Animal:getInfo()
   return string.format("[%s] Age:%d Energy:%d/%d",
       self.name, self.age, self.energy, self.maxEnergy)
end

return Animal
local fire = { effect = function(_, target) return "fire:" .. target end }
local ice = { effect = function(_, target) return "ice:" .. target end }
local spell = { element = fire }
function spell:set_element(element)
	self.element = element
end
function spell:cast(target) return self.element:effect(target) end
assert(spell:cast("slime") == "fire:slime")
print(spell:cast("slime"))
spell:set_element(ice)
assert(spell:cast("slime") == "ice:slime")
print(spell:cast("slime"))

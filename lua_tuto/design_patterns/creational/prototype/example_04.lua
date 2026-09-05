local prototype = { tags = { "enemy" }, color = "red" }
local function clone(source)
	local copy = { tags = {} }
	for index, tag in ipairs(source.tags) do copy.tags[index] = tag end
	copy.color = source.color
	return copy
end

local copy = clone(prototype)
copy.tags[#copy.tags + 1] = "boss"
assert(#prototype.tags == 1 and #copy.tags == 2)
print(#prototype.tags, #copy.tags)

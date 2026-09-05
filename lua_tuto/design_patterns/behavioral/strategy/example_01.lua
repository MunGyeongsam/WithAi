local function sort_values(values, compare)
    local result = { unpack(values) }
    table.sort(result, compare)
    return result
end

local ascending = function(left, right) return left < right end
local descending = function(left, right) return left > right end

local sorter = { strategy = descending }
function sorter:set_strategy(strategy)
    self.strategy = strategy
end
function sorter:sort(values)
    return sort_values(values, self.strategy)
end

local values = { 3, 1, 2 }
local sorted = sorter:sort(values)
print(table.concat(sorted, ","))
sorter:set_strategy(ascending)
sorted = sorter:sort(values)
assert(table.concat(sorted, ",") == "1,2,3")
print(table.concat(sorted, ","))

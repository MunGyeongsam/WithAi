local tokens = {
	{ value = 3, accept = function(self, visitor) return visitor:visit_number(self) end },
	{ value = "ok", accept = function(self, visitor) return visitor:visit_text(self) end }
}

local serialize = {}
function serialize:visit_number(token) return tostring(token.value) end
function serialize:visit_text(token) return '"' .. token.value .. '"' end

local results = {}
for _, token in ipairs(tokens) do results[#results + 1] = token:accept(serialize) end
assert(results[1] == "3" and results[2] == '"ok"')
print(table.concat(results, ","))

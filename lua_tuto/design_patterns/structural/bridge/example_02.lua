local json = { encode = function(_, value) return "json:" .. value end }
local xml = { encode = function(_, value) return "xml:" .. value end }
local report = { format = json }
function report:export(value) return self.format:encode(value) end
assert(report:export("score") == "json:score")
print(report:export("score"))
report.format = xml
assert(report:export("score") == "xml:score")
print(report:export("score"))

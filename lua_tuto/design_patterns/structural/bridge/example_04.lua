local low_quality = { save = function(_, data) return "low:" .. data end }
local high_quality = { save = function(_, data) return "high:" .. data end }
local snapshot = { storage = low_quality }
function snapshot:save(data) return self.storage:save(data) end
assert(snapshot:save("map") == "low:map")
print(snapshot:save("map"))
snapshot.storage = high_quality
assert(snapshot:save("map") == "high:map")
print(snapshot:save("map"))

local function prototype(kind, value)
    return {
        kind = kind,
        value = value,
        clone = function(self)
            return { kind = self.kind, value = self.value }
        end
    }
end

local registry = {}
function registry:register(kind, template)
    self[kind] = template
end
function registry:create(kind, x, y)
    local template = assert(self[kind], "unknown prototype")
    local object = template:clone()
    object.x, object.y = x, y
    return object
end

registry:register("coin", prototype("coin", 10))
registry:register("gem", prototype("gem", 50))

local coin = registry:create("coin", 4, 8)
local gem = registry:create("gem", 10, 12)
assert(coin.kind == "coin" and gem.kind == "gem")
print(coin.kind, coin.x, coin.y, gem.kind, gem.value)

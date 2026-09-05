local prototypes = {
    coin = { kind = "coin", value = 10 },
    gem = { kind = "gem", value = 50 }
}

local function spawn(kind, x, y)
    local template = prototypes[kind]
    assert(template, "unknown prototype")
    local object = {}
    for key, value in pairs(template) do object[key] = value end
    object.x, object.y = x, y
    return object
end

local coin = spawn("coin", 4, 8)
local gem = spawn("gem", 10, 12)
assert(coin.kind == "coin" and gem.kind == "gem")
print(coin.kind, coin.x, coin.y, gem.kind, gem.value)

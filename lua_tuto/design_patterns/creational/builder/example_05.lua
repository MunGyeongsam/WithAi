local function level_builder()
    local level = { enemies = {} }
    local builder = {}
    function builder:title(value) level.title = value; return self end
    function builder:enemy(value) level.enemies[#level.enemies + 1] = value; return self end
    function builder:build()
        assert(level.title and #level.enemies > 0, "title and enemies are required")
        local result = { title = level.title, enemies = {} }
        for index, enemy in ipairs(level.enemies) do result.enemies[index] = enemy end
        return result
    end
    return builder
end
local level = level_builder():title("Cave"):enemy("slime"):enemy("bat"):build()
assert(level.title == "Cave" and #level.enemies == 2)
print(level.title, #level.enemies)

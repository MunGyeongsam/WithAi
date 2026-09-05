local function enemy_builder()
    local enemy = { speed = 0 }
    local builder = {}
    function builder:health(value) enemy.health = value; return self end
    function builder:speed(value) enemy.speed = value; return self end
    function builder:build()
        assert(enemy.health and enemy.health > 0, "positive health is required")
        return { health = enemy.health, speed = enemy.speed }
    end
    return builder
end
local enemy = enemy_builder():health(50):speed(3):build()
assert(enemy.health == 50 and enemy.speed == 3)
print(enemy.health, enemy.speed)

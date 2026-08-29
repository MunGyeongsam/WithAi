-- Lua는 여러 값을 반환할 수 있다 (C#의 out/tuple보다 깔끔)
local function findEnemy()
    return "Slime", 100, 50     -- name, hp, mp
end

local name, hp, mp = findEnemy()
print(name, hp, mp)    -- Slime  100  50

-- 필요 없는 값은 버린다
local name = findEnemy()    -- hp, mp 버려짐

-- 관례: 불필요한 값은 _ 로 받는다
local _, _, mp = findEnemy()


-- 연습 7-1: 깊은 복사 + 순환 참조
local function deepCopy(orig, visited)
    if type(orig) ~= "table" then return orig end
    
    visited = visited or {}
    if visited[orig] then
        return visited[orig]   -- 이미 복사한 테이블 재사용
    end
    
    local copy = {}
    visited[orig] = copy       -- 복사 전에 등록 (순환 참조 대비)
    
    for k, v in pairs(orig) do
        copy[deepCopy(k, visited)] = deepCopy(v, visited)
    end
    
    return copy
end

-- 테스트
local a = {value = 1}
a.self = a   -- 순환 참조

local b = deepCopy(a)
print(b.value)        -- 1
print(b.self == b)    -- true (복사본 내에서 자기 참조 유지)
print(b.self ~= a)    -- true (원본과는 다른 테이블)


-- 연습 7-3: Set 연산
local function toSet(array)
    local set = {}
    for i = 1, #array do
        set[array[i]] = true
    end
    return set
end

local function union(a, b)
    local result = {}
    for k in pairs(a) do result[k] = true end
    for k in pairs(b) do result[k] = true end
    return result
end

local function intersection(a, b)
    local result = {}
    for k in pairs(a) do
        if b[k] then result[k] = true end
    end
    return result
end

local function difference(a, b)
    local result = {}
    for k in pairs(a) do
        if not b[k] then result[k] = true end
    end
    return result
end

local function printSet(name, set)
    local parts = {}
    for k in pairs(set) do parts[#parts + 1] = k end
    print(name .. ": {" .. table.concat(parts, ", ") .. "}")
end

local a = toSet({"fire", "ice", "wind"})
local b = toSet({"ice", "earth", "wind"})

printSet("union", union(a, b))           -- fire, ice, wind, earth
printSet("intersection", intersection(a, b))  -- ice, wind
printSet("difference", difference(a, b))      -- fire


-- 연습 7-4: safeSet
local function safeSet(t, value, ...)
    local keys = {...}
    local current = t
    
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(current[key]) ~= "table" then
            current[key] = {}
        end
        current = current[key]
    end
    
    current[keys[#keys]] = value
end

local t = {}
safeSet(t, 100, "player", "stats", "hp")
print(t.player.stats.hp)   -- 100

safeSet(t, "Hero", "player", "info", "name")
print(t.player.info.name)  -- Hero

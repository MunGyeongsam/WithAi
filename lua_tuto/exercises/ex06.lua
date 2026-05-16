-- 연습 6-1: 인벤토리 시스템
local function addItem(inventory, item)
    inventory[#inventory + 1] = item
end

local function removeItem(inventory, index)
    if index >= 1 and index <= #inventory then
        table.remove(inventory, index)
    end
end

local function findItem(inventory, item)
    for i = 1, #inventory do
        if inventory[i] == item then
            return i
        end
    end
    return nil
end

local function printInventory(inventory)
    print("=== Inventory ===")
    for i = 1, #inventory do
        print(string.format("  [%d] %s", i, inventory[i]))
    end
    print(string.format("  Total: %d items", #inventory))
end

-- 테스트
local inv = {}
addItem(inv, "Sword")
addItem(inv, "Shield")
addItem(inv, "Potion")
printInventory(inv)

local idx = findItem(inv, "Shield")
print("Shield at index:", idx)   -- 2

removeItem(inv, 2)
printInventory(inv)   -- Sword, Potion


-- 연습 6-2: 점수 테이블 정렬
local leaderboard = {
    {name = "Alice", score = 1500},
    {name = "Bob", score = 2300},
    {name = "Charlie", score = 800},
}

table.sort(leaderboard, function(a, b)
    return a.score > b.score   -- 내림차순
end)

for i, entry in ipairs(leaderboard) do
    print(string.format("%d. %s — %d", i, entry.name, entry.score))
end
-- 1. Bob — 2300
-- 2. Alice — 1500
-- 3. Charlie — 800


-- 연습 6-3: # 함정
local a = {1, 2, 3}
local b = {1, nil, 3}
local c = {x = 1, y = 2, z = 3}
print(#a, #b, #c)
-- #a = 3 (정상)
-- #b = 1 또는 3 (구현에 따라 다름! nil 구멍)
-- #c = 0 (배열 부분이 없으므로)


-- 연습 6-4: Swap-Remove
local function swapRemove(t, i)
    local n = #t
    if i < n then
        t[i] = t[n]
    end
    t[n] = nil
end

-- table.remove(t, 50): 인덱스 51~100을 한 칸씩 당김 → O(n)
-- swapRemove(t, 50): 마지막 요소를 50번에 넣고 마지막 삭제 → O(1)
-- 단, 순서가 변경됨!

local t = {}
for i = 1, 100 do t[i] = i end
swapRemove(t, 50)
print(#t)     -- 99
print(t[50])  -- 100 (마지막 요소가 이동됨)

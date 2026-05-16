-- 연습 5-1: 다중 반환
local function getPlayerInfo()
    return 100.5, 200.3, 1.57   -- x, y, angle
end

local x, y, angle = getPlayerInfo()
print(x, y, angle)


-- 연습 5-2: map 함수
local function map(t, func)
    local result = {}
    for i = 1, #t do
        result[i] = func(t[i])
    end
    return result
end

local numbers = {1, 2, 3, 4, 5}
local doubled = map(numbers, function(x) return x * 2 end)
for i = 1, #doubled do
    print(doubled[i])   -- 2, 4, 6, 8, 10
end


-- 연습 5-3: 클로저 활용
local function makeHealthBar(maxHp)
    local hp = maxHp

    return {
        damage = function(amount)
            hp = math.max(0, hp - amount)
        end,
        heal = function(amount)
            hp = math.min(maxHp, hp + amount)
        end,
        getPercent = function()
            return hp / maxHp * 100
        end,
    }
end

local bar = makeHealthBar(100)
bar.damage(30)
print(bar.getPercent())    -- 70
bar.heal(50)
print(bar.getPercent())    -- 100 (maxHp 초과 방지)
bar.damage(200)
print(bar.getPercent())    -- 0 (0 미만 방지)


-- 연습 5-4: 콜론 문법 버그
local enemy = {hp = 100, name = "Goblin"}

function enemy:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        print(self.name .. " is dead!")
    end
end

-- 버그: enemy.takeDamage(30)
-- . 으로 호출하면 self에 30이 들어감!
-- 수정:
enemy:takeDamage(30)    -- : 으로 호출해야 self = enemy
print(enemy.hp)         -- 70

-- ============================================================================
-- tower.lua — 타워 객체 (Gun / Slow / Rocket / Anti-Air)
-- ============================================================================
local Tower = {}
Tower.__index = Tower

-- 타워 타입 정의 (Xeno Tactic 스타일)
local TOWER_DEFS = {
    gun = {
        name = "Gun",
        cost = 30,
        range = 100,
        damage = 8,
        fireRate = 2.5,   -- 초당 발사
        color = {0.3, 0.7, 1.0},
        targetAir = false,
        slow = 0,
        splash = 0,
        upgrades = {
            {cost = 40, damage = 14, range = 110, fireRate = 3.0},
            {cost = 60, damage = 22, range = 120, fireRate = 3.5},
            {cost = 100, damage = 35, range = 130, fireRate = 4.0},
        },
    },
    slow = {
        name = "Slow",
        cost = 50,
        range = 90,
        damage = 2,
        fireRate = 1.5,
        color = {0.2, 0.8, 0.9},
        targetAir = false,
        slow = 0.4,       -- 40% 감속
        slowDuration = 2.0,
        splash = 60,
        upgrades = {
            {cost = 60, damage = 3, range = 100, slow = 0.5, splash = 70},
            {cost = 90, damage = 5, range = 110, slow = 0.6, splash = 80},
            {cost = 140, damage = 8, range = 120, slow = 0.7, splash = 90},
        },
    },
    rocket = {
        name = "Rocket",
        cost = 80,
        range = 120,
        damage = 45,
        fireRate = 0.5,
        color = {1.0, 0.4, 0.2},
        targetAir = false,
        slow = 0,
        splash = 0,
        upgrades = {
            {cost = 100, damage = 70, range = 130},
            {cost = 150, damage = 110, range = 140},
            {cost = 220, damage = 170, range = 150},
        },
    },
    antiair = {
        name = "Anti-Air",
        cost = 60,
        range = 140,
        damage = 20,
        fireRate = 2.0,
        color = {0.9, 0.9, 0.3},
        targetAir = true,  -- 공중 전용
        slow = 0,
        splash = 0,
        upgrades = {
            {cost = 70, damage = 35, range = 150},
            {cost = 110, damage = 55, range = 160},
            {cost = 170, damage = 80, range = 180},
        },
    },
}

function Tower.new(towerType, x, y)
    local def = TOWER_DEFS[towerType]
    if not def then return nil end

    local self = setmetatable({}, Tower)
    self.type = towerType
    self.x = x
    self.y = y
    self.level = 1
    self.range = def.range
    self.damage = def.damage
    self.fireRate = def.fireRate
    self.slow = def.slow or 0
    self.slowDuration = def.slowDuration or 1.5
    self.splash = def.splash or 0
    self.targetAir = def.targetAir or false
    self.color = def.color
    self.name = def.name
    self.cooldown = 0
    self.target = nil
    return self
end

function Tower:update(dt, enemies)
    self.cooldown = self.cooldown - dt

    -- 타겟 유효성
    if self.target then
        if self.target.dead or not self:_inRange(self.target) or not self:_canTarget(self.target) then
            self.target = nil
        end
    end

    -- 새 타겟 탐색
    if not self.target then
        self.target = self:_findTarget(enemies)
    end

    -- 발사
    local projectile = nil
    if self.target and self.cooldown <= 0 then
        self.cooldown = 1.0 / self.fireRate
        projectile = {
            targetX = self.target.x,
            targetY = self.target.y,
            damage = self.damage,
            splash = self.splash,
            slow = self.slow,
            slowDuration = self.slowDuration,
            target = self.target,
        }
    end

    return projectile
end

function Tower:_canTarget(enemy)
    if self.targetAir then
        return enemy.flying == true
    else
        return not enemy.flying
    end
end

function Tower:_inRange(enemy)
    local dx = enemy.x - self.x
    local dy = enemy.y - self.y
    return (dx * dx + dy * dy) <= (self.range * self.range)
end

function Tower:_findTarget(enemies)
    local best = nil
    local bestProgress = -1
    for _, enemy in ipairs(enemies) do
        if not enemy.dead and self:_canTarget(enemy) and self:_inRange(enemy) then
            if enemy.progress > bestProgress then
                best = enemy
                bestProgress = enemy.progress
            end
        end
    end
    return best
end

function Tower:canUpgrade()
    local def = TOWER_DEFS[self.type]
    return self.level <= #def.upgrades
end

function Tower:getUpgradeCost()
    if not self:canUpgrade() then return nil end
    local def = TOWER_DEFS[self.type]
    return def.upgrades[self.level].cost
end

function Tower:upgrade()
    if not self:canUpgrade() then return false end
    local def = TOWER_DEFS[self.type]
    local upg = def.upgrades[self.level]
    self.damage = upg.damage or self.damage
    self.range = upg.range or self.range
    self.fireRate = upg.fireRate or self.fireRate
    self.slow = upg.slow or self.slow
    self.splash = upg.splash or self.splash
    self.level = self.level + 1
    return true
end

function Tower:getSellValue()
    local def = TOWER_DEFS[self.type]
    local total = def.cost
    for i = 1, self.level - 1 do
        total = total + (def.upgrades[i] and def.upgrades[i].cost or 0)
    end
    return math.floor(total * 0.6)
end

function Tower:draw()
    local gr = love.graphics
    local size = 18 + (self.level - 1) * 3

    -- 사거리 (반투명)
    gr.setColor(self.color[1], self.color[2], self.color[3], 0.08)
    gr.circle("fill", self.x, self.y, self.range)

    -- 타워 본체
    gr.setColor(self.color[1], self.color[2], self.color[3], 1)
    if self.targetAir then
        -- AA: 삼각형
        gr.polygon("fill",
            self.x, self.y - size / 2,
            self.x - size / 2, self.y + size / 2,
            self.x + size / 2, self.y + size / 2)
    elseif self.type == "rocket" then
        -- Rocket: 다이아몬드
        gr.polygon("fill",
            self.x, self.y - size / 2,
            self.x + size / 2, self.y,
            self.x, self.y + size / 2,
            self.x - size / 2, self.y)
    elseif self.type == "slow" then
        -- Slow: 원
        gr.circle("fill", self.x, self.y, size / 2)
    else
        -- Gun: 사각형
        gr.rectangle("fill", self.x - size / 2, self.y - size / 2, size, size)
    end

    -- 레벨 표시
    if self.level > 1 then
        gr.setColor(1, 1, 1, 0.9)
        gr.print(tostring(self.level), self.x - 3, self.y - 5)
    end

    gr.setColor(1, 1, 1, 1)
end

-- 상수/접근
Tower.DEFS = TOWER_DEFS

function Tower.getCost(towerType)
    local def = TOWER_DEFS[towerType]
    return def and def.cost or 0
end

function Tower.getTypes()
    return {"gun", "slow", "rocket", "antiair"}
end

return Tower

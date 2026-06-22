-- ============================================================================
-- enemy.lua — 적 유닛 (지상 + 공중)
-- ============================================================================
local Enemy = {}
Enemy.__index = Enemy

-- 적 타입 정의
local ENEMY_DEFS = {
    normal = {
        name = "Alien",
        hp = 40,
        speed = 55,
        reward = 8,
        color = {0.9, 0.25, 0.2},
        size = 10,
        flying = false,
    },
    fast = {
        name = "Scout",
        hp = 25,
        speed = 110,
        reward = 12,
        color = {1.0, 0.8, 0.1},
        size = 8,
        flying = false,
    },
    tank = {
        name = "Brute",
        hp = 180,
        speed = 30,
        reward = 25,
        color = {0.5, 0.15, 0.5},
        size = 14,
        flying = false,
    },
    flyer = {
        name = "Chopper",
        hp = 60,
        speed = 70,
        reward = 20,
        color = {0.3, 0.9, 0.6},
        size = 11,
        flying = true,
    },
    boss = {
        name = "Overlord",
        hp = 500,
        speed = 22,
        reward = 80,
        color = {0.8, 0.0, 0.8},
        size = 18,
        flying = false,
    },
}

function Enemy.new(enemyType, waypoints, entryPixel, exitPixel)
    local def = ENEMY_DEFS[enemyType]
    if not def then return nil end

    local self = setmetatable({}, Enemy)
    self.type = enemyType
    self.flying = def.flying
    self.hp = def.hp
    self.maxHp = def.hp
    self.baseSpeed = def.speed
    self.speed = def.speed
    self.reward = def.reward
    self.color = def.color
    self.size = def.size
    self.dead = false
    self.reachedEnd = false
    self.progress = 0

    -- 슬로우 효과
    self.slowAmount = 0
    self.slowTimer = 0

    -- 경로 설정
    if self.flying then
        -- 공중: 직선 (entry → exit)
        self.waypoints = {entryPixel, exitPixel}
    else
        -- 지상: BFS 경로
        self.waypoints = waypoints or {}
    end

    self.waypointIndex = 1
    if self.waypoints[1] then
        self.x = self.waypoints[1].x
        self.y = self.waypoints[1].y
    else
        self.x = 0
        self.y = 0
    end

    return self
end

function Enemy:updatePath(newWaypoints)
    -- 지상 적이 경로 갱신을 받을 때 (맵 변경 시)
    if self.flying then return end
    if not newWaypoints or #newWaypoints == 0 then return end

    -- 가장 가까운 새 웨이포인트를 찾아 진행 연결
    local bestIdx = 1
    local bestDist = math.huge
    for i, wp in ipairs(newWaypoints) do
        local dx = wp.x - self.x
        local dy = wp.y - self.y
        local d = dx * dx + dy * dy
        if d < bestDist then
            bestDist = d
            bestIdx = i
        end
    end

    self.waypoints = newWaypoints
    self.waypointIndex = bestIdx
end

function Enemy:update(dt)
    if self.dead or self.reachedEnd then return end

    -- 슬로우 처리
    if self.slowTimer > 0 then
        self.slowTimer = self.slowTimer - dt
        self.speed = self.baseSpeed * (1 - self.slowAmount)
        if self.slowTimer <= 0 then
            self.speed = self.baseSpeed
            self.slowAmount = 0
        end
    end

    local target = self.waypoints[self.waypointIndex + 1]
    if not target then
        self.reachedEnd = true
        return
    end

    local dx = target.x - self.x
    local dy = target.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    local move = self.speed * dt

    if dist <= move then
        self.x = target.x
        self.y = target.y
        self.waypointIndex = self.waypointIndex + 1
        if self.waypointIndex >= #self.waypoints then
            self.reachedEnd = true
        end
    else
        self.x = self.x + (dx / dist) * move
        self.y = self.y + (dy / dist) * move
    end

    -- 진행도
    self.progress = (self.waypointIndex - 1) / math.max(1, #self.waypoints - 1)
end

function Enemy:applySlow(amount, duration)
    if amount > self.slowAmount then
        self.slowAmount = amount
    end
    self.slowTimer = math.max(self.slowTimer, duration)
end

function Enemy:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self.hp = 0
        self.dead = true
    end
end

function Enemy:draw()
    if self.dead then return end
    local gr = love.graphics

    -- 본체
    gr.setColor(self.color[1], self.color[2], self.color[3], 1)
    if self.flying then
        -- 공중: 다이아몬드
        gr.polygon("fill",
            self.x, self.y - self.size,
            self.x + self.size, self.y,
            self.x, self.y + self.size,
            self.x - self.size, self.y)
    else
        gr.circle("fill", self.x, self.y, self.size)
    end

    -- 슬로우 표시
    if self.slowTimer > 0 then
        gr.setColor(0.2, 0.8, 0.9, 0.5)
        gr.circle("line", self.x, self.y, self.size + 3)
    end

    -- HP 바
    local barWidth = self.size * 2
    local barHeight = 3
    local hpRatio = self.hp / self.maxHp
    local bx = self.x - barWidth / 2
    local by = self.y - self.size - 7

    gr.setColor(0.2, 0.2, 0.2, 0.8)
    gr.rectangle("fill", bx, by, barWidth, barHeight)

    if hpRatio > 0.5 then
        gr.setColor(0.1, 0.9, 0.1, 1)
    elseif hpRatio > 0.25 then
        gr.setColor(0.9, 0.7, 0.1, 1)
    else
        gr.setColor(0.9, 0.2, 0.1, 1)
    end
    gr.rectangle("fill", bx, by, barWidth * hpRatio, barHeight)

    gr.setColor(1, 1, 1, 1)
end

Enemy.DEFS = ENEMY_DEFS

return Enemy

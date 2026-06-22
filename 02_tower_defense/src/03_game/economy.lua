-- ============================================================================
-- economy.lua — 자원(골드) 및 생명 관리
-- ============================================================================
local Economy = {}
Economy.__index = Economy

local DEFAULT_GOLD = 200
local DEFAULT_LIVES = 20

function Economy.new(startGold, startLives)
    local self = setmetatable({}, Economy)
    self.gold = startGold or DEFAULT_GOLD
    self.lives = startLives or DEFAULT_LIVES
    self.totalEarned = self.gold
    self.totalSpent = 0
    return self
end

function Economy:canAfford(cost)
    return self.gold >= cost
end

function Economy:spend(cost)
    if not self:canAfford(cost) then return false end
    self.gold = self.gold - cost
    self.totalSpent = self.totalSpent + cost
    return true
end

function Economy:earn(amount)
    self.gold = self.gold + amount
    self.totalEarned = self.totalEarned + amount
end

function Economy:loseLife(amount)
    amount = amount or 1
    self.lives = self.lives - amount
    if self.lives < 0 then
        self.lives = 0
    end
end

function Economy:isGameOver()
    return self.lives <= 0
end

function Economy:getGold()
    return self.gold
end

function Economy:getLives()
    return self.lives
end

return Economy

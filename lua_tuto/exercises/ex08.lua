-- 연습 8-1: Vec2 확장
local Vec2 = {}
Vec2.__index = Vec2

function Vec2.new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vec2)
end

function Vec2.__add(a, b)
    return Vec2.new(a.x + b.x, a.y + b.y)
end

function Vec2.__sub(a, b)
    return Vec2.new(a.x - b.x, a.y - b.y)
end

function Vec2.__mul(a, b)
    if type(a) == "number" then
        return Vec2.new(a * b.x, a * b.y)
    elseif type(b) == "number" then
        return Vec2.new(a.x * b, a.y * b)
    end
end

function Vec2.__unm(a)
    return Vec2.new(-a.x, -a.y)
end

function Vec2.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

function Vec2.__tostring(v)
    return string.format("Vec2(%g, %g)", v.x, v.y)
end

function Vec2:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vec2:normalized()
    local len = self:length()
    if len > 0 then
        return Vec2.new(self.x / len, self.y / len)
    end
    return Vec2.new(0, 0)
end

function Vec2:dot(other)
    return self.x * other.x + self.y * other.y
end

-- 테스트
local a = Vec2.new(3, 4)
print(tostring(a))              -- Vec2(3, 4)
print(a:length())               -- 5
print(tostring(a:normalized())) -- Vec2(0.6, 0.8)
print(a:dot(Vec2.new(1, 0)))    -- 3


-- 연습 8-4: __index 체인
local A = {x = 1}
local B = setmetatable({y = 2}, {__index = A})
local C = setmetatable({z = 3}, {__index = B})

print(C.z, C.y, C.x)   -- 3  2  1
B.x = 10
print(C.x)              -- 10 (B에 x가 생겼으므로 B에서 찾음, A까지 안 감)
A.x = 20
print(C.x)              -- 10 (여전히 B.x = 10)

-- B.x를 nil로 만들면?
B.x = nil
print(C.x)              -- 20 (B에 x가 없으므로 A에서 찾음)

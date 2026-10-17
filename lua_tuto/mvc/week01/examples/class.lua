-- class.lua
-- 메타테이블 기반 최소 클래스 유틸 (LuaJIT / Lua 5.1 호환)
--
-- 사용법:
--   local class = require("class")
--   local Animal = class()
--   function Animal:init(name) self.name = name end
--   function Animal:speak() return self.name .. " makes a sound" end
--
--   local Dog = class(Animal)        -- 상속
--   function Dog:speak() return self.name .. " barks" end
--
--   local d = Dog("Rex")             -- __call 로 생성 (init 자동 호출)

local function class(base)
  local cls = {}
  cls.__index = cls

  -- 클래스 자신을 함수처럼 호출하면 인스턴스를 생성한다 (__call).
  local mt = {
    __call = function(c, ...)
      local self = setmetatable({}, c)
      if self.init then
        self:init(...)
      end
      return self
    end,
  }

  -- 상속: 자식 클래스에서 못 찾은 메서드는 부모에서 찾는다 (__index 체인).
  if base then
    mt.__index = base
  end

  return setmetatable(cls, mt)
end

return class

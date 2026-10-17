-- class.lua
-- 메타테이블 기반 최소 클래스 유틸 (LuaJIT / Lua 5.1 호환).
-- examples/class.lua 와 동일하며, LÖVE 가 pong 폴더만 로드하므로 사본으로 둔다.

local function class(base)
  local cls = {}
  cls.__index = cls

  local mt = {
    __call = function(c, ...)
      local self = setmetatable({}, c)
      if self.init then
        self:init(...)
      end
      return self
    end,
  }

  if base then
    mt.__index = base
  end

  return setmetatable(cls, mt)
end

return class

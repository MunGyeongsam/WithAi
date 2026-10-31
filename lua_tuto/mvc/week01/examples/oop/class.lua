local function class(base)
  local cls = {}
  cls.__index = cls

  cls.new = function(...)
      local self = setmetatable({}, cls)
      if self.init then
        self:init(...)
      end
      return self
    end

  if base then
    setmetatable(cls, { __index = base })
  end

  return cls
end

return class
